import 'package:atma_kitchen_mobile/model/produk.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProdukClient {
  static final String baseUrl = 'http://10.0.2.2:8000';
  static final String endpoint = '/api/produk';

  static Future<List<Produk>> fetchAll() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {"Connection": "Keep-Alive"},
      );
      if (response.statusCode == 200) {
        final Iterable list = json.decode(response.body)['data'];
        return list.map((e) => Produk.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load products: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}
