import 'dart:convert';
import '../../core/services/http_service.dart';
import '../models/genre_model.dart';
import '../models/series_model.dart';
import '../models/episode_model.dart';
import '../models/paginated_result.dart';

class SeriesApi {
  final HttpService _http = HttpService.instance;

  Future<List<Genre>> fetchGenres() async {
    final response = await _http.get('/genre/tv/list');
    final data = _decode(response.data);
    final genresJson = data['genres'] as List<dynamic>;
    return genresJson.map((json) => Genre.fromJson(json)).toList();
  }

  Future<PaginatedResult<Series>> fetchAiringToday({
    int page = 1,
    Map<int, Genre>? genreMap,
  }) async {
    final response = await _http.get(
      '/tv/airing_today',
      queryParameters: {'page': '$page'},
    );
    return _parseSeriesList(response.data, genreMap);
  }

  Future<PaginatedResult<Series>> fetchPopular({
    int page = 1,
    Map<int, Genre>? genreMap,
  }) async {
    final response = await _http.get(
      '/tv/popular',
      queryParameters: {'page': '$page'},
    );
    return _parseSeriesList(response.data, genreMap);
  }

  Future<PaginatedResult<Series>> fetchTopRated({
    int page = 1,
    Map<int, Genre>? genreMap,
  }) async {
    final response = await _http.get(
      '/tv/top_rated',
      queryParameters: {'page': '$page'},
    );
    return _parseSeriesList(response.data, genreMap);
  }

  Future<Series> fetchDetails(int seriesId) async {
    final response = await _http.get('/tv/$seriesId');
    final data = _decode(response.data);
    return Series.fromJson(data);
  }

  Future<Series> fetchFullDetails(int seriesId) async {
    final response = await _http.get(
      '/tv/$seriesId',
      queryParameters: {'append_to_response': 'videos,credits'},
    );
    final data = _decode(response.data);
    return Series.fromJson(data);
  }

  Future<String?> fetchTrailerKey(int seriesId) async {
    try {
      final response = await _http.get('/tv/$seriesId/videos');
      final data = _decode(response.data);
      final videos = data['results'] as List<dynamic>;

      final trailer = videos.firstWhere(
        (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
        orElse: () => null,
      );
      return trailer != null ? trailer['key'] : null;
    } catch (_) {
      return null;
    }
  }

  Future<PaginatedResult<Series>> search(String query, {int page = 1}) async {
    final response = await _http.get(
      '/search/tv',
      queryParameters: {'query': query, 'page': '$page'},
    );
    return _parseSeriesList(response.data);
  }

  Future<List<Episode>> fetchEpisodes(int seriesId, int seasonNumber) async {
    final response = await _http.get('/tv/$seriesId/season/$seasonNumber');
    final data = _decode(response.data);
    final episodesJson = data['episodes'] as List<dynamic>? ?? [];
    return episodesJson.map((e) => Episode.fromJson(e)).toList();
  }

  PaginatedResult<Series> _parseSeriesList(
    dynamic body, [
    Map<int, Genre>? genreMap,
  ]) {
    final data = _decode(body);
    final results = data['results'] as List<dynamic>;
    final items = results
        .map((json) => genreMap != null
            ? Series.fromListJson(json, genreMap)
            : Series.fromJson(json))
        .toList();

    return PaginatedResult<Series>(
      items: items,
      page: data['page'] ?? 1,
      totalPages: data['total_pages'] ?? 1,
    );
  }

  Map<String, dynamic> _decode(dynamic body) {
    return jsonDecode(jsonEncode(body)) as Map<String, dynamic>;
  }
}
