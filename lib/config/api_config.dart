import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:intl/intl.dart';

class ApiConfig {
  /// Default targets Linux / Web running against local `php artisan serve`
  /// on `http://127.0.0.1:8000`.
  /// Override when needed with:
  /// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String get apiBaseUrl => '$baseUrl/api';

  static Uri uri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final parsed = Uri.parse('$apiBaseUrl$normalized');
    if (queryParameters == null || queryParameters.isEmpty) {
      return parsed;
    }
    return parsed.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  /// Resolves product image path via `/api/media/{filename}` so it works
  /// reliably on both Flutter Web (CORS-safe) and Flutter Linux/Android.
  static String imageUrl(String? rawPath) {
    if (rawPath == null || rawPath.trim().isEmpty) return '';
    final trimmed = rawPath.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final filename = trimmed.split('/').last;
    return '$apiBaseUrl/media/$filename';
  }

  static Map<String, String> jsonHeaders({bool withAuth = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = sharedPrefs.getString('token');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatRupiah(num value) {
    return _rupiahFormat.format(value);
  }
}
