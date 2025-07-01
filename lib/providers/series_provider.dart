import 'package:flutter/foundation.dart';
import '../models/series.dart';
import '../services/series_api_service.dart';

class SeriesProvider extends ChangeNotifier {
  final SeriesApiService _apiService = SeriesApiService();

  List<Series> _airingToday = [];
  List<Series> _popular = [];
  List<Series> _topRated = [];
  List<Series> _searchResults = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Public getters
  List<Series> get airingToday => _airingToday;
  List<Series> get popular => _popular;
  List<Series> get topRated => _topRated;
  List<Series> get searchResults => _searchResults;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all categories at once (optional)
  Future<void> fetchAllSeries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _airingToday = await _apiService.fetchAiringToday();
      _popular = await _apiService.fetchPopular();
      _topRated = await _apiService.fetchTopRated();
    } catch (e) {
      _errorMessage = 'Failed to load series: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAiringToday() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _airingToday = await _apiService.fetchAiringToday();
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
      _popular = await _apiService.fetchPopular();
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
      _topRated = await _apiService.fetchTopRated();
    } catch (e) {
      _errorMessage = 'Failed to load top rated series: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search series by query
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

}
