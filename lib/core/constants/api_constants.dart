import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  static String get apiKey => _apiKey;

  static String imageUrl(String path, {int width = 500}) =>
      '$imageBaseUrl/w$width$path';

  static String withApiKey(String path, [Map<String, String>? query]) {
    final base = '$path?api_key=$_apiKey';
    if (query == null || query.isEmpty) return base;
    final queryString = query.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$base&$queryString';
  }

  static Uri uri(String path, [Map<String, String>? query]) {
    return Uri.parse(withApiKey(path, query));
  }
}
