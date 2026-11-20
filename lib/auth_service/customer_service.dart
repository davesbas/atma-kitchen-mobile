import 'dart:convert';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/cart_model.dart';
import 'package:atma_kitchen_mobile/model/customer_model.dart';
import 'package:atma_kitchen_mobile/model/saldo_model.dart';
import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class CustomerService {
  static Future<CustomerModel> getUserInfo() async {
    final response = await http.get(
      ApiConfig.uri('/customer'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CustomerModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(
      (body['message'] ?? 'Gagal memuat profil customer (${response.statusCode})')
          .toString(),
    );
  }

  static Future<CustomerModel> updateProfile({
    required int idCustomer,
    required String nama,
    required String email,
    required String noTelp,
    required String tanggalLahir,
    String? password,
  }) async {
    final payload = <String, dynamic>{
      'nama': nama,
      'email': email,
      'no_telp': noTelp,
      'tanggal_lahir': tanggalLahir,
    };
    if (password != null && password.trim().isNotEmpty) {
      payload['password'] = password.trim();
    }

    final response = await http.put(
      ApiConfig.uri('/customer/$idCustomer'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode(payload),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CustomerModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception(
      (body['message'] ?? 'Gagal memperbarui profil').toString(),
    );
  }

  static Future<SaldoInfoModel> getSaldoInfo() async {
    final uid = sharedPrefs.getString('id_customer') ?? '';
    final response = await http.get(
      ApiConfig.uri('/customer/showSaldo/$uid'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return SaldoInfoModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception((body['message'] ?? 'Gagal memuat data saldo').toString());
  }

  static Future<String> requestPenarikanSaldo({
    required int jumlahPenarikan,
    required String bank,
    required String noRek,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/customer/penarikan-saldo'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode({
        'jumlah_penarikan': jumlahPenarikan,
        'bank': bank,
        'no_rek': noRek,
      }),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return (body['message'] ?? 'Pengajuan penarikan berhasil').toString();
    }

    throw Exception(
      (body['message'] ?? 'Gagal mengajukan penarikan saldo').toString(),
    );
  }

  static Future<List<AlamatModel>> getAddresses() async {
    final response = await http.get(
      ApiConfig.uri('/customer/alamat'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(AlamatModel.fromJson)
          .toList();
    }

    throw Exception((body['message'] ?? 'Gagal memuat alamat').toString());
  }

  static Future<AlamatModel> addAddress({
    required String namaJalan,
    required String kecamatan,
    required String kelurahan,
    required int jarak,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/customer/alamat'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode({
        'nama_jalan': namaJalan,
        'kecamatan': kecamatan,
        'kelurahan': kelurahan,
        'jarak': jarak,
      }),
    );

    final body = _safeDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['data'] is Map<String, dynamic>) {
      return AlamatModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception((body['message'] ?? 'Gagal menambahkan alamat').toString());
  }

  static Future<void> deleteAddress(int idAlamat) async {
    final response = await http.delete(
      ApiConfig.uri('/customer/alamat/$idAlamat'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    if (response.statusCode != 200) {
      final body = _safeDecode(response.body);
      throw Exception((body['message'] ?? 'Gagal menghapus alamat').toString());
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
