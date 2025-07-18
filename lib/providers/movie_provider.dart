import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';
import '../models/movie.dart';
import 'package:movie_sansaar_mobile/services/movie_api_service.dart';

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


  List<Movie> popularMovies = [];
List<Movie> topRatedMovies = [];

Future<void> fetchPopularMovies() async {
  _isLoading = true;
  notifyListeners();

  try {
    popularMovies = await _apiService.fetchMovies(ApiEndpoints.popular);
  } catch (e) {
    print('Error fetching popular movies: $e');
  }

  _isLoading = false;
  notifyListeners();
}

Future<void> fetchTopRatedMovies() async {
  _isLoading = true;
  notifyListeners();

  try {
    topRatedMovies = await _apiService.fetchMovies(ApiEndpoints.topRated);
  } catch (e) {
    print('Error fetching top-rated movies: $e');
  }

  _isLoading = false;
  notifyListeners();
}


}


