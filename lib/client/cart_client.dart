import 'dart:convert';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/cart_model.dart';
import 'package:atma_kitchen_mobile/model/order_model.dart';
import 'package:http/http.dart' as http;

class CartClient {
  static Future<CartModel> fetchCart() async {
    final response = await http.get(
      ApiConfig.uri('/cart'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );
    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception((body['message'] ?? 'Gagal memuat keranjang').toString());
  }

  static Future<CartModel> addItem(int idProduk, {int jumlah = 1}) async {
    final response = await http.post(
      ApiConfig.uri('/cart/items'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode({'id_produk': idProduk, 'jumlah': jumlah}),
    );
    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception(
      (body['message'] ?? 'Gagal menambah item ke keranjang').toString(),
    );
  }

  static Future<CartModel> updateItem(int idProduk, int jumlah) async {
    final response = await http.put(
      ApiConfig.uri('/cart/items/$idProduk'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode({'jumlah': jumlah}),
    );
    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception(
      (body['message'] ?? 'Gagal memperbarui jumlah item').toString(),
    );
  }

  static Future<CartModel> removeItem(int idProduk) async {
    final response = await http.delete(
      ApiConfig.uri('/cart/items/$idProduk'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
    );
    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception((body['message'] ?? 'Gagal menghapus item').toString());
  }

  static Future<CartModel> updateDelivery({
    required String tglAmbil,
    required String jenis,
    int? idAlamat,
  }) async {
    final response = await http.put(
      ApiConfig.uri('/cart/delivery'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode({
        'tgl_ambil': tglAmbil,
        'jenis': jenis,
        'id_alamat': idAlamat,
      }),
    );
    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception(
      (body['message'] ?? 'Gagal memperbarui pengiriman').toString(),
    );
  }

  static Future<CartModel> togglePoin(bool usePoin) async {
    final response = await http.put(
      ApiConfig.uri('/cart/poin'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode({'use_poin': usePoin}),
    );
    final body = _safeDecode(response.body);
    if (response.statusCode == 200 && body['data'] is Map<String, dynamic>) {
      return CartModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception((body['message'] ?? 'Gagal mengubah penggunaan poin').toString());
  }

  static Future<OrderModel> checkout({
    required String jenisPembayaran,
    required String tglAmbil,
    required String jenisPengiriman,
    int? idAlamat,
    required bool usePoin,
    String? catatanBukti,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/checkout'),
      headers: ApiConfig.jsonHeaders(withAuth: true),
      body: jsonEncode({
        'jenis_pembayaran': jenisPembayaran,
        'tgl_ambil': tglAmbil,
        'jenis': jenisPengiriman,
        'id_alamat': idAlamat,
        'use_poin': usePoin,
        if (catatanBukti != null && catatanBukti.trim().isNotEmpty)
          'catatan_bukti': catatanBukti.trim(),
      }),
    );
    final body = _safeDecode(response.body);
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['data'] is Map<String, dynamic>) {
      return OrderModel.fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception((body['message'] ?? 'Checkout gagal').toString());
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
