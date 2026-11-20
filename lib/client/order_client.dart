import 'dart:convert';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/order_model.dart';
import 'package:http/http.dart' as http;

class OrderClient {
  static Future<List<OrderModel>> fetchOrders({String? search}) async {
    final query =
        (search != null && search.trim().isNotEmpty) ? {'search': search.trim()} : null;

    final response = await http.get(
      ApiConfig.uri('/customer/orders', query),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
    }

    throw Exception(
      (body['message'] ?? 'Gagal memuat riwayat pesanan').toString(),
    );
  }

  static Future<String> confirmOrderSelesai(int idTransaksi) async {
    final response = await http.put(
      ApiConfig.uri('/customer/orders/$idTransaksi/selesai'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );

    final body = _safeDecode(response.body);
    if (response.statusCode == 200) {
      return (body['message'] ?? 'Pesanan dikonfirmasi selesai').toString();
    }

    throw Exception(
      (body['message'] ?? 'Gagal mengonfirmasi pesanan').toString(),
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
