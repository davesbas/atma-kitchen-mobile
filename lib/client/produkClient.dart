import 'dart:convert';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/produk.dart';
import 'package:http/http.dart' as http;

class ProdukClient {
  static Future<List<Produk>> fetchAll() async {
    try {
      final response = await http.get(
        ApiConfig.uri('/produk'),
        headers: ApiConfig.jsonHeaders(withAuth: false),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> list =
            decoded is Map<String, dynamic> ? (decoded['data'] ?? []) : [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(Produk.fromJson)
            .toList();
      } else {
        throw Exception('Gagal memuat produk (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server (${ApiConfig.baseUrl}): $e');
    }
  }
}
