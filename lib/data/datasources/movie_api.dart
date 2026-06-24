import 'dart:convert';
import '../../core/services/http_service.dart';
import '../models/movie_model.dart';
import '../models/paginated_result.dart';

class MovieApi {
  final HttpService _http = HttpService.instance;
  final Map<int, Movie> _detailsCache = {};

  Future<PaginatedResult<Movie>> fetchNowPlaying({int page = 1}) async {
    final response = await _http.get(
      '/movie/now_playing',
      queryParameters: {'page': '$page'},
    );
    return _parseMovies(response.data);
  }

  Future<PaginatedResult<Movie>> fetchPopular({int page = 1}) async {
    final response = await _http.get(
      '/movie/popular',
      queryParameters: {'page': '$page'},
    );
    return _parseMovies(response.data);
  }

  Future<PaginatedResult<Movie>> fetchTopRated({int page = 1}) async {
    final response = await _http.get(
      '/movie/top_rated',
      queryParameters: {'page': '$page'},
    );
    return _parseMovies(response.data);
  }

  Future<PaginatedResult<Movie>> search(String query, {int page = 1}) async {
    final response = await _http.get(
      '/search/movie',
      queryParameters: {'query': query, 'page': '$page'},
    );
    return _parseMovies(response.data);
  }

  Future<String?> fetchTrailerKey(int movieId) async {
    try {
      final response = await _http.get('/movie/$movieId/videos');
      final data = response.data as Map<String, dynamic>;
      final videos = data['results'] as List;

      final trailer = videos.firstWhere(
        (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
        orElse: () => null,
      );
      return trailer != null ? trailer['key'] : null;
    } catch (_) {
      return null;
    }
  }

  Future<Movie> fetchDetails(int movieId) async {
    if (_detailsCache.containsKey(movieId)) {
      return _detailsCache[movieId]!;
    }

    final response = await _http.get(
      '/movie/$movieId',
      queryParameters: {'append_to_response': 'videos,credits'},
    );
    final data = response.data as Map<String, dynamic>;
    final movie = Movie.fromJson(data);
    _detailsCache[movieId] = movie;
    return movie;
  }

  PaginatedResult<Movie> _parseMovies(dynamic body) {
    final data = jsonDecode(jsonEncode(body)) as Map<String, dynamic>;
    final results = data['results'] as List;
    final items = results.map((json) => Movie.fromJson(json)).toList();

    return PaginatedResult<Movie>(
      items: items,
      page: data['page'] ?? 1,
      totalPages: data['total_pages'] ?? 1,
    );
  }
}
