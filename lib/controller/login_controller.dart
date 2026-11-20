import 'package:atma_kitchen_mobile/auth_service/auth_service.dart';
import 'package:atma_kitchen_mobile/view/customer/customerView.dart';
import 'package:atma_kitchen_mobile/view/dashboardView.dart';
import 'package:atma_kitchen_mobile/view/manajerOperasional/presensiView.dart';
import 'package:flutter/material.dart';

class LoginController {
  static Future<bool> loginUser(
    BuildContext context,
    String email,
    String password,
  ) async {
    final result = await AuthService.login(email, password);

    if (!context.mounted) return result.success;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );

    if (result.success) {
      final Widget destination = AuthService.role == 'customer'
          ? const CustomerViewPage()
          : const AttendanceManagementPage();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (_) => false,
      );
    }

    return result.success;
  }

  static Future<void> logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AtmaKitchenPage()),
      (_) => false,
    );
  }
}
