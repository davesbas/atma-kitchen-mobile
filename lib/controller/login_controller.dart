import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:atma_kitchen_mobile/view/manajerOperasional/presensiView.dart';
import 'package:flutter/material.dart';
import 'package:atma_kitchen_mobile/auth_service/auth_service.dart';
import 'package:atma_kitchen_mobile/view/customer/customerView.dart';
import 'package:atma_kitchen_mobile/view/loginView.dart';

class LoginController {
  static Future<void> loginUser(
      BuildContext context, String email, String password) async {
    bool loginSuccess = await AuthService.authenticate(email, password);

    if (loginSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Success')),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (AuthService.isAuthenticated() &&
          sharedPrefs.get("role") == "customer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => customerViewPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AttendanceManagementPage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Failed')),
      );

      await Future.delayed(const Duration(seconds: 2));
    }
  }

  // Method untuk logout
  static void logout(BuildContext context) {
    // Hapus token
    // AuthService.authToken = null;

    // Navigasi ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }
}
