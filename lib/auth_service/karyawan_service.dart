import 'dart:convert';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/karyawan_model.dart';
import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class EmployeeService {
  static Future<KaryawanModel> getEmployeeInfo() async {
    final uid = sharedPrefs.getString('id_karyawan') ?? '';
    final response = await http.get(
      ApiConfig.uri('/karyawan/$uid'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return KaryawanModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(
      (body['message'] ?? 'Gagal mengambil informasi karyawan').toString(),
    );
  }

  static Future<List<KaryawanModel>> fetchAllEmployees({int? idJabatan}) async {
    final query = idJabatan != null ? {'id_jabatan': idJabatan} : null;
    final response = await http.get(
      ApiConfig.uri('/karyawan', query),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(KaryawanModel.fromJson)
          .toList();
    }

    throw Exception(
      (body['message'] ?? 'Gagal mengambil daftar karyawan').toString(),
    );
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
