import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ NEW
import '../models/movie.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';

class MovieApiService {
  // ✅ Load API key from .env
  final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  // In-memory cache for movie details
  final Map<int, Movie> _movieDetailsCache = {};

  // Fetch list of now playing movies (basic details only)
  Future<List<Movie>> fetchNowPlaying() async {
    final response = await http.get(Uri.parse(ApiEndpoints.nowPlaying));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load now playing movies');
    }
  }

  // Reusable fetch function for different endpoints
  Future<List<Movie>> fetchMovies(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  // ✅ Secure fetch of trailer key
  Future<String?> fetchTrailerKey(int movieId) async {
    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=$_apiKey&language=en-US',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['results'] as List;

      final trailer = videos.firstWhere(
        (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
        orElse: () => null,
      );

      return trailer != null ? trailer['key'] : null;
    } else {
      throw Exception('Failed to fetch trailer');
    }
  }

  // ✅ Secure full movie details fetch with caching
  Future<Movie> fetchMovieDetails(int movieId) async {
    if (_movieDetailsCache.containsKey(movieId)) {
      return _movieDetailsCache[movieId]!;
    }

    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId?api_key=$_apiKey&language=en-US&append_to_response=videos,credits',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final movie = Movie.fromJson(data);
      _movieDetailsCache[movieId] = movie;
      return movie;
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }
}
