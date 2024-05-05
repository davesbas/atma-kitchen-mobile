import 'package:atma_kitchen_mobile/model/login_model.dart';
import 'dart:convert';
import 'package:http/http.dart';

class UserClient {
  static final String url = '10.0.2.2:8000';
  static final String endpoint = '/api/login';
  static Future<LoginModel> login(String email, String password) async {
    try {
      var response = await post(
        Uri.http(url, '/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode != 200) throw Exception(response.reasonPhrase);

      var userData = json.decode(response.body);
      LoginModel user = LoginModel.fromJson(userData['data']);

      return user;
    } catch (e) {
      return Future.error(e.toString());
    }
  }
}