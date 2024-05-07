import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static String? authToken;
  static String? userName; // Tambah properti untuk menyimpan nama pengguna
  static String? userEmail; // Tambah properti untuk menyimpan email pengguna
  static int? userPoints; // Tambah properti untuk menyimpan poin pengguna

  static Future<bool> authenticate(String email, String password) async {
    String apiURL = 'http://10.0.2.2:8000/api/login';
    try {
      var apiResult = await http.post(Uri.parse(apiURL),
          body: {'email': email, 'password': password});

      if (apiResult.statusCode == 200) {
        // Setelah berhasil login, tetapkan nilai properti
        var responseData = json.decode(apiResult.body);
        authToken = responseData['token'];
        userName = responseData['user_name']; // Ambil nama pengguna dari respons
        userEmail = responseData['user_email']; // Ambil email pengguna dari respons
        userPoints = responseData['user_points']; // Ambil poin pengguna dari respons
        print(apiResult.body);
        return true;
      } else {
        authToken = null;
        userName = null;
        userEmail = null;
        userPoints = null;
        return false;
      }
    } catch (e) {
      authToken = null;
      userName = null;
      userEmail = null;
      userPoints = null;
      return false;
    }
  }

  static bool isAuthenticated() {
    return authToken != null;
  }

  static void logout() {
    print('Token sebelum logout: $authToken');
    authToken = null;
    userName = null;
    userEmail = null;
    userPoints = null;
    print('Token setelah logout: $authToken');
  }
}
