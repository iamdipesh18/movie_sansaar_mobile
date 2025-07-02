import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_sansaar_mobile/models/videosrc_movie.dart';

/// Service class to fetch latest movie data from vidsrc.xyz
/// This handles making the HTTP request and parsing the JSON response.
class VidSrcService {
  /// Fetches the latest movies from vidsrc.xyz based on the given page number.
  ///
  /// Example endpoint:
  /// https://vidsrc.xyz/movies/latest/page-1.json
  ///
  /// Throws an exception if the request fails or the format is unexpected.
  static Future<List<VidSrcMovie>> fetchLatestMovies(int page) async {
    final url = 'https://vidsrc.xyz/movies/latest/page-$page.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the body into a usable JSON object
      final data = json.decode(response.body);

      // Extract the 'movies' key if it exists and is a list
      if (data is Map && data.containsKey('movies') && data['movies'] is List) {
        final moviesJson = data['movies'] as List;
        // Convert each JSON entry into a VidSrcMovie object
        return moviesJson.map((json) => VidSrcMovie.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format: "movies" key missing');
      }
    } else {
      throw Exception('Failed to load movies (status: ${response.statusCode})');
    }
  }
}
