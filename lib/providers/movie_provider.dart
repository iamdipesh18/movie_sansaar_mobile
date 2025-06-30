import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'package:movie_sansaar_mobile/services/movie_api.dart';

class MovieProvider with ChangeNotifier {
  final MovieApiService _apiService = MovieApiService();

  List<Movie> _nowPlayingMovies = [];
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchNowPlayingMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _nowPlayingMovies = await _apiService.fetchNowPlaying();
    } catch (e) {
      print('Error fetching movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
