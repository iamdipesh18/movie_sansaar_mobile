import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';

class MovieApiService {
  Future<List<Movie>> fetchNowPlaying() async {
    final response = await http.get(Uri.parse(ApiEndpoints.nowPlaying));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results']; // might be data directly
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }
}
