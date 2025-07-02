import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/series.dart';
import '../models/season_and_episode.dart';
import '../models/genre.dart'; // <-- Import Genre model

class ApiEndpoints {
  static const String baseUrl = 'https://api.themoviedb.org/3';
}

class SeriesApiService {
  final String _apiKey = 'c186762f14592e810da1278859304e21';

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final query = {'api_key': _apiKey, 'language': 'en-US', ...?queryParams};
    return Uri.parse('${ApiEndpoints.baseUrl}$path').replace(queryParameters: query);
  }

  /// Fetch the list of TV genres from TMDB
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

  /// Fetches series currently airing today
  /// Accepts optional genreMap to convert genre IDs to Genre objects
  Future<List<Series>> fetchAiringToday([Map<int, Genre>? genreMap]) async {
    final url = _buildUri('/tv/airing_today', {'page': '1'});
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>;
      // Use genreMap to parse genres properly if provided
      return results
          .map((json) =>
              genreMap != null ? Series.fromListJson(json, genreMap) : Series.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load airing today series');
    }
  }

  /// Fetches popular series
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

  /// Fetches top rated series
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

  /// Fetch basic series details by series ID
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

  /// Fetch full series details including videos and credits
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

  /// Fetches trailer video key (YouTube) for a series
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

  /// Search for series using a query string
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

  /// Fetches episodes of a given season in a series
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
