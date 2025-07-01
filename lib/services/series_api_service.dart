import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_sansaar_mobile/models/season_and_episode.dart';
import '../models/series.dart';

/// Centralized API endpoints for TMDB
class ApiEndpoints {
  static const String baseUrl = 'https://api.themoviedb.org/3';
}

class SeriesApiService {
  final String _apiKey = 'c186762f14592e810da1278859304e21';

  /// Fetches list of TV series airing today
  Future<List<Series>> fetchAiringToday() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/tv/airing_today?api_key=$_apiKey&language=en-US&page=1',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Series.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load airing today series');
    }
  }

  /// Fetches popular TV series
  Future<List<Series>> fetchPopular() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/tv/popular?api_key=$_apiKey&language=en-US&page=1',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Series.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load popular series');
    }
  }

  /// Fetches top rated TV series
  Future<List<Series>> fetchTopRated() async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/tv/top_rated?api_key=$_apiKey&language=en-US&page=1',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Series.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load top rated series');
    }
  }

  /// Fetch detailed info about a specific series by ID
  Future<Series> fetchSeriesDetails(int seriesId) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/tv/$seriesId?api_key=$_apiKey&language=en-US',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Series.fromJson(data);
    } else {
      throw Exception('Failed to load series details');
    }
  }

  /// Fetch trailer video key for a given series ID
  Future<String?> fetchTrailerKey(int seriesId) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/tv/$seriesId/videos?api_key=$_apiKey&language=en-US',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List videos = data['results'];
      final trailer = videos.firstWhere(
        (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
        orElse: () => null,
      );
      return trailer != null ? trailer['key'] : null;
    } else {
      throw Exception('Failed to fetch trailer');
    }
  }

  /// Search series by query string
  Future<List<Series>> searchSeries(String query) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/search/tv?api_key=$_apiKey&language=en-US&query=$query&page=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Series.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search series');
    }
  }

  //seasons and episodes
  /// Fetch episodes for a given series ID and season number
Future<List<Episode>> fetchSeasonEpisodes(int seriesId, int seasonNumber) async {
  final url = Uri.parse(
    '${ApiEndpoints.baseUrl}/tv/$seriesId/season/$seasonNumber?api_key=$_apiKey&language=en-US',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final episodesJson = data['episodes'] as List? ?? [];
    return episodesJson.map((e) => Episode.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load episodes for season $seasonNumber');
  }
}

}
