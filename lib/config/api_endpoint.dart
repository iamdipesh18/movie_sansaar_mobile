import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  // ✅ Load API key from .env file
  static final String apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // ✅ Appends the API key and optional query parameters
  static String withApiKey(String path, [Map<String, String>? query]) {
    final base = '$path?api_key=$apiKey';
    if (query == null) return base;

    final queryString = query.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$base&$queryString';
  }

  // ✅ Image URL builder (default width: w500)
  static String imageUrl(String path, {int width = 500}) =>
      'https://image.tmdb.org/t/p/w$width$path';

  // ===================== MOVIES =====================

  static final nowPlaying = withApiKey('$baseUrl/movie/now_playing');
  static final popular = withApiKey('$baseUrl/movie/popular');
  static final topRated = withApiKey('$baseUrl/movie/top_rated');

  static String searchMovies(String query) =>
      withApiKey('$baseUrl/search/movie', {'query': query});

  static String movieDetails(int id) => withApiKey('$baseUrl/movie/$id');

  static String fullMovieDetails(int id) => withApiKey(
        '$baseUrl/movie/$id',
        {'append_to_response': 'videos,credits'},
      );

  static String movieTrailer(int id) => withApiKey('$baseUrl/movie/$id/videos');

  // ===================== TV SERIES =====================

  static final airingTodaySeries = withApiKey('$baseUrl/tv/airing_today');
  static final popularSeries = withApiKey('$baseUrl/tv/popular');
  static final topRatedSeries = withApiKey('$baseUrl/tv/top_rated');

  static String searchSeries(String query) =>
      withApiKey('$baseUrl/search/tv', {'query': query});

  static String seriesDetails(int id) => withApiKey('$baseUrl/tv/$id');

  static String fullSeriesDetails(int id) => withApiKey(
        '$baseUrl/tv/$id',
        {'append_to_response': 'videos,credits'},
      );

  static String seriesTrailer(int id) => withApiKey('$baseUrl/tv/$id/videos');
}
