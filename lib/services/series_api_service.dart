import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ NEW
import '../models/series.dart';
import '../models/season_and_episode.dart';
import '../models/genre.dart';

class ApiEndpoints {
  static const String baseUrl = 'https://api.themoviedb.org/3';
}

class SeriesApiService {
  // ✅ Load the API key securely from .env
  final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final query = {'api_key': _apiKey, 'language': 'en-US', ...?queryParams};
    return Uri.parse('${ApiEndpoints.baseUrl}$path').replace(queryParameters: query);
  }

  Future<List<Genre>> fetchGenres() async {
    final url = _buildUri('/genre/tv/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final genresJson = data['genres'] as List<dynamic>;
      return genresJson.map((json) => Genre.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load TV genres');
    }
  }

  Future<List<Series>> fetchAiringToday([Map<int, Genre>? genreMap]) async {
    final url = _buildUri('/tv/airing_today', {'page': '1'});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      return results
          .map((json) =>
              genreMap != null ? Series.fromListJson(json, genreMap) : Series.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load airing today series');
    }
  }

  Future<List<Series>> fetchPopular([Map<int, Genre>? genreMap]) async {
    final url = _buildUri('/tv/popular', {'page': '1'});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      return results
          .map((json) =>
              genreMap != null ? Series.fromListJson(json, genreMap) : Series.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load popular series');
    }
  }

  Future<List<Series>> fetchTopRated([Map<int, Genre>? genreMap]) async {
    final url = _buildUri('/tv/top_rated', {'page': '1'});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      return results
          .map((json) =>
              genreMap != null ? Series.fromListJson(json, genreMap) : Series.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load top rated series');
    }
  }

  Future<Series> fetchSeriesDetails(int seriesId) async {
    final url = _buildUri('/tv/$seriesId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Series.fromJson(data);
    } else {
      throw Exception('Failed to load series details');
    }
  }

  Future<Series> fetchFullDetails(int seriesId) async {
    final url = _buildUri('/tv/$seriesId', {'append_to_response': 'videos,credits'});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Series.fromJson(data);
    } else {
      throw Exception('Failed to load full series details');
    }
  }

  Future<String?> fetchTrailerKey(int seriesId) async {
    final url = _buildUri('/tv/$seriesId/videos');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final videos = data['results'] as List<dynamic>;

      final trailer = videos.firstWhere(
        (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
        orElse: () => null,
      );

      return trailer != null ? trailer['key'] : null;
    } else {
      throw Exception('Failed to fetch trailer');
    }
  }

  Future<List<Series>> searchSeries(String query) async {
    final url = _buildUri('/search/tv', {'query': query, 'page': '1'});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.map((json) => Series.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search series');
    }
  }

  Future<List<Episode>> fetchEpisodes(int seriesId, int seasonNumber) async {
    final url = _buildUri('/tv/$seriesId/season/$seasonNumber');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final episodesJson = data['episodes'] as List<dynamic>? ?? [];
      return episodesJson.map((e) => Episode.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load episodes for season $seasonNumber');
    }
  }
}
