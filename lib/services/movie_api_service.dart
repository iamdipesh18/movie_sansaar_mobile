import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';

class MovieApiService {
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

  // General fetch function to reuse with different endpoints
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

  // Fetch trailer key for YouTube trailer (used for playing video)
  Future<String?> fetchTrailerKey(int movieId) async {
    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=c186762f14592e810da1278859304e21&language=en-US',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['results'] as List;

      // Find the first YouTube trailer
      final trailer = videos.firstWhere(
        (video) => video['site'] == 'YouTube' && video['type'] == 'Trailer',
        orElse: () => null,
      );

      return trailer != null ? trailer['key'] : null;
    } else {
      throw Exception('Failed to fetch trailer');
    }
  }

  // ✅ NEW: Fetch full movie details including genres, runtime, videos, cast, etc.
  Future<Movie> fetchMovieDetails(int movieId) async {
    // Return from cache if available
    if (_movieDetailsCache.containsKey(movieId)) {
      return _movieDetailsCache[movieId]!;
    }

    final url = Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId?api_key=c186762f14592e810da1278859304e21&language=en-US&append_to_response=videos,credits',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final movie = Movie.fromJson(data); // Uses expanded model

      // Save to cache
      _movieDetailsCache[movieId] = movie;

      return movie;
    } else {
      throw Exception('Failed to fetch movie details');
    }
  }
}
