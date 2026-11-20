import 'package:atma_kitchen_mobile/auth_service/auth_service.dart';
import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:atma_kitchen_mobile/view/customer/customerView.dart';
import 'package:atma_kitchen_mobile/view/dashboardView.dart';
import 'package:atma_kitchen_mobile/view/manajerOperasional/presensiView.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  await initializeDateFormatting('id_ID', null);
  runApp(const AtmaKitchenApp());
}

class AtmaKitchenApp extends StatelessWidget {
  const AtmaKitchenApp({super.key});

  Widget _resolveHome() {
    if (AuthService.isAuthenticated()) {
      if (AuthService.role == 'customer') {
        return const CustomerViewPage();
      }
      if (AuthService.role == 'karyawan' && AuthService.idJabatan == 3) {
        return const AttendanceManagementPage();
      }
    }
    return const AtmaKitchenPage();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8D4E2A),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Atma Kitchen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFAF6F2),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      home: _resolveHome(),
    );
  }
}
