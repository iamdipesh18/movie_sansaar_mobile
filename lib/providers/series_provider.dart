import 'package:flutter/foundation.dart';
import '../models/series.dart';
import '../models/season_and_episode.dart';
import '../models/genre.dart'; // Import Genre model
import '../services/series_api_service.dart';

/// Provider managing series lists, genres, searches, and details
class SeriesProvider extends ChangeNotifier {
  final SeriesApiService _apiService = SeriesApiService();

  // ========== STATE VARIABLES ==========

  List<Series> _airingToday = [];
  List<Series> _popular = [];
  List<Series> _topRated = [];

  List<Series> _searchResults = [];

  Series? _selectedSeries;

  Map<int, Genre> _genreMap = {}; // Genre cache for ID to Genre object

  bool _isLoading = false;
  String? _errorMessage;

  // ========== GETTERS ==========

  List<Series> get airingToday => _airingToday;
  List<Series> get popular => _popular;
  List<Series> get topRated => _topRated;
  List<Series> get searchResults => _searchResults;
  Series? get selectedSeries => _selectedSeries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<int, Genre> get genreMap => _genreMap;

  // ========== FETCH GENRES ==========

  /// Fetches and caches the genre list from TMDB
  Future<void> fetchGenres() async {
    try {
      final genresList = await _apiService.fetchGenres();
      _genreMap = {for (var genre in genresList) genre.id: genre};
    } catch (e) {
      _errorMessage = 'Failed to load genres: $e';
      notifyListeners();
    }
  }

  // ========== FETCH ALL SERIES WITH GENRES ==========

  /// Fetch all series lists at once, fetching genres first
  Future<void> fetchAllSeries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await fetchGenres();

      // Pass genreMap to get full genre info for series lists
      _airingToday = await _apiService.fetchAiringToday(_genreMap);
      _popular = await _apiService.fetchPopular(_genreMap);
      _topRated = await _apiService.fetchTopRated(_genreMap);
    } catch (e) {
      _errorMessage = 'Failed to load series: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== INDIVIDUAL FETCHES ==========

  Future<void> fetchAiringToday() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ensure genres are loaded before fetching series
      if (_genreMap.isEmpty) await fetchGenres();

      _airingToday = await _apiService.fetchAiringToday(_genreMap);
    } catch (e) {
      _errorMessage = 'Failed to load airing today series: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopular() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_genreMap.isEmpty) await fetchGenres();

      _popular = await _apiService.fetchPopular(_genreMap);
    } catch (e) {
      _errorMessage = 'Failed to load popular series: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTopRated() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_genreMap.isEmpty) await fetchGenres();

      _topRated = await _apiService.fetchTopRated(_genreMap);
    } catch (e) {
      _errorMessage = 'Failed to load top rated series: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== SEARCH ==========

  Future<void> searchSeries(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchSeries(query);
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // ========== SERIES DETAILS ==========

  Future<void> fetchFullSeriesDetails(int seriesId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedSeries = await _apiService.fetchFullDetails(seriesId);
    } catch (e) {
      _errorMessage = 'Failed to load series details: $e';
      _selectedSeries = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedSeries() {
    _selectedSeries = null;
    notifyListeners();
  }

  // ========== EPISODES PER SEASON ==========

  Future<List<Episode>> fetchEpisodes(int seriesId, int seasonNumber) async {
    try {
      return await _apiService.fetchEpisodes(seriesId, seasonNumber);
    } catch (e) {
      _errorMessage = 'Failed to load episodes: $e';
      notifyListeners();
      return [];
    }
  }
}
