import 'dart:convert';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/absensi_model.dart';
import 'package:http/http.dart' as http;

class AbsensiService {
  static Future<List<AbsensiModel>> fetchAbsensi({String? tanggal}) async {
    final query = (tanggal != null && tanggal.isNotEmpty)
        ? {'tanggal': tanggal}
        : null;

    final response = await http.get(
      ApiConfig.uri('/absensi', query),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AbsensiModel.fromJson)
          .toList();
    }

    throw Exception(
      (body['message'] ?? 'Gagal memuat data absensi').toString(),
    );
  }

  static Future<AbsensiModel> markAttendance(
    int idKaryawan, {
    String? tanggal,
  }) async {
    final payload = <String, dynamic>{'id_karyawan': idKaryawan};
    if (tanggal != null && tanggal.isNotEmpty) {
      payload['tanggal'] = tanggal;
    }

    final response = await http.post(
      ApiConfig.uri('/absensi/store'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode(payload),
    );

    final body = _safeDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['data'] is Map<String, dynamic>) {
      return AbsensiModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(
      (body['message'] ?? 'Gagal mencatat ketidakhadiran').toString(),
    );
  }

  static Future<void> deleteAttendance(int idAbsensi) async {
    final response = await http.delete(
      ApiConfig.uri('/absensi/$idAbsensi'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    if (response.statusCode != 200) {
      final body = _safeDecode(response.body);
      throw Exception(
        (body['message'] ?? 'Gagal membatalkan catatan absensi').toString(),
      );
    }
  }

  static Map<String, dynamic> _safeDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }
}
