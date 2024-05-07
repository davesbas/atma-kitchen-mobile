import 'dart:convert';
import 'package:atma_kitchen_mobile/auth_service/customer_service.dart';
import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static Future<bool> authenticate(String email, String password) async {
    String apiURL = 'http://10.0.2.2:8000/api/login';
    try {
      var apiResult = await http.post(Uri.parse(apiURL),
          body: {'email': email, 'password': password});

      if (apiResult.statusCode == 200) {
        var responseData = json.decode(apiResult.body);
        await sharedPrefs.setString("token", responseData["token"]);

        if (responseData['role'] == "customer") {
          await sharedPrefs.setString(
              "id_customer", responseData['user']['id_customer'].toString());
        } else {
          if (responseData['jabatan']['id_jabatan'] != 3) return false;
          await sharedPrefs.setString(
              "id_karyawan", responseData['user']['id_karyawan'].toString());
        }

        print(responseData);

        await sharedPrefs.setString("role", responseData["role"]);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return true;
    }
  }

  static bool isAuthenticated() {
    return sharedPrefs.getString("token")!.isNotEmpty;
  }

  static Future<void> logout() async {
    print("Token sebelum Logout:  ${sharedPrefs.get("token")}");
    print("role sebelum Logout:  ${sharedPrefs.get("role")}");
    print("id_customer sebelum Logout:  ${sharedPrefs.get("id_customer")}");
    print("id_karyawan sebelum Logout:  ${sharedPrefs.get("id_karyawan")}");

    await sharedPrefs.remove("token");
    await sharedPrefs.remove("role");
    await sharedPrefs.remove("id_customer");
    await sharedPrefs.remove("id_karyawan");

    print("Token setelah Logout:  ${sharedPrefs.get("token")}");
    print("Token setelah Logout:  ${sharedPrefs.get("role")}");
    print("Token setelah Logout:  ${sharedPrefs.get("id_customer")}");
    print("Token setelah Logout:  ${sharedPrefs.get("id_karyawan")}");

    // print('Token sebelum logout: $authToken');
    // print('nama: $userName');
    // print('email: $userEmail');
    // print('poin: $userPoints');
    // authToken = null;
    // userName = null;
    // userEmail = null;
    // userPoints = null;
    // userRole = null; // Mengosongkan role saat logout
    // print('Token setelah logout: $authToken');
    // print('Token sebelum logout: $authToken');
    // print('nama: $userName');
    // print('email: $userEmail');
    // print('poin: $userPoints');
  }
}
