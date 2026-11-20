import 'dart:convert';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class AuthResult {
  final bool success;
  final String message;
  final String? role;
  final int? idJabatan;
  final Map<String, dynamic>? data;

  const AuthResult({
    required this.success,
    required this.message,
    this.role,
    this.idJabatan,
    this.data,
  });
}

class AuthService {
  static Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        ApiConfig.uri('/login'),
        headers: ApiConfig.jsonHeaders(withAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> body = _safeDecode(response.body);

      if (response.statusCode == 200 && body['status'] == true) {
        final String token = (body['token'] ?? '').toString();
        final String role = (body['role'] ?? '').toString();
        final Map<String, dynamic> user =
            body['user'] is Map<String, dynamic> ? body['user'] : {};

        if (token.isEmpty) {
          return const AuthResult(
            success: false,
            message: 'Token login tidak ditemukan dari server',
          );
        }

        int? idJabatan;
        if (role == 'karyawan') {
          final Map<String, dynamic> jabatanObj =
              body['jabatan'] is Map<String, dynamic> ? body['jabatan'] : {};
          idJabatan = _toInt(jabatanObj['id_jabatan']);
          if (idJabatan != 3) {
            return const AuthResult(
              success: false,
              message:
                  'Akses karyawan di aplikasi ini hanya untuk Manajer Operasional.',
            );
          }
          await sharedPrefs.setString(
            'id_karyawan',
            (user['id_karyawan'] ?? '').toString(),
          );
          await sharedPrefs.setInt('id_jabatan', idJabatan);
          await sharedPrefs.remove('id_customer');
        } else {
          await sharedPrefs.setString(
            'id_customer',
            (user['id_customer'] ?? '').toString(),
          );
          await sharedPrefs.remove('id_karyawan');
          await sharedPrefs.remove('id_jabatan');
        }

        await sharedPrefs.setString('token', token);
        await sharedPrefs.setString('role', role);

        return AuthResult(
          success: true,
          message: (body['message'] ?? 'Login berhasil').toString(),
          role: role,
          idJabatan: idJabatan,
          data: body,
        );
      }

      return AuthResult(
        success: false,
        message: (body['message'] ?? body['error'] ?? 'Email atau password salah')
            .toString(),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Tidak dapat terhubung ke server (${ApiConfig.baseUrl}): $e',
      );
    }
  }

  static Future<bool> authenticate(String email, String password) async {
    final result = await login(email, password);
    return result.success;
  }

  static Future<AuthResult> register({
    required String nama,
    required String email,
    required String password,
    required String noTelp,
    required String tanggalLahir,
  }) async {
    try {
      final response = await http.post(
        ApiConfig.uri('/customer/register'),
        headers: ApiConfig.jsonHeaders(withAuth: false),
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'no_telp': noTelp,
          'tanggal_lahir': tanggalLahir,
          'jumlah_poin': 0,
        }),
      );

      final Map<String, dynamic> body = _safeDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult(
          success: true,
          message: (body['message'] ?? 'Registrasi berhasil').toString(),
          data: body['data'] is Map<String, dynamic> ? body['data'] : body,
        );
      }

      return AuthResult(
        success: false,
        message: (body['message'] ?? 'Registrasi gagal').toString(),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Gagal terhubung ke server: $e',
      );
    }
  }

  static Future<AuthResult> forgotPassword(String email) async {
    try {
      final response = await http.post(
        ApiConfig.uri('/customer/forgetPassword'),
        headers: ApiConfig.jsonHeaders(withAuth: false),
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> body = _safeDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: (body['message'] ?? 'Kode reset telah dikirim').toString(),
          data: body['data'] is Map<String, dynamic> ? body['data'] : null,
        );
      }

      return AuthResult(
        success: false,
        message: (body['message'] ?? 'Gagal mengirim kode reset password')
            .toString(),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Gagal terhubung ke server: $e',
      );
    }
  }

  static Future<AuthResult> verifyResetPassword({
    required String passKey,
    required String newPassword,
  }) async {
    try {
      final response = await http.put(
        ApiConfig.uri('/customer/verifyForgetPw/$passKey'),
        headers: ApiConfig.jsonHeaders(withAuth: false),
        body: jsonEncode({'password': newPassword}),
      );

      final Map<String, dynamic> body = _safeDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: (body['message'] ?? 'Password berhasil diubah').toString(),
        );
      }

      return AuthResult(
        success: false,
        message: (body['message'] ?? 'Kode reset tidak valid').toString(),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Gagal terhubung ke server: $e',
      );
    }
  }

  static bool isAuthenticated() {
    final token = sharedPrefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  static String? get role => sharedPrefs.getString('role');
  static int? get idJabatan => sharedPrefs.getInt('id_jabatan');
  static String? get customerId => sharedPrefs.getString('id_customer');
  static String? get karyawanId => sharedPrefs.getString('id_karyawan');

  static Future<void> logout() async {
    try {
      if (isAuthenticated()) {
        await http.post(
          ApiConfig.uri('/logout'),
          headers: ApiConfig.jsonHeaders(withAuth: true),
        );
      }
    } catch (_) {
      // Ignore network error during logout; clear local session regardless.
    } finally {
      await sharedPrefs.remove('token');
      await sharedPrefs.remove('role');
      await sharedPrefs.remove('id_customer');
      await sharedPrefs.remove('id_karyawan');
      await sharedPrefs.remove('id_jabatan');
    }
  }

  static Map<String, dynamic> _safeDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
