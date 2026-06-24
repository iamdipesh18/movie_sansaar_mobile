import 'package:flutter/material.dart';
import '../../data/models/search_result.dart';
import '../../data/repositories/search_repository.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repository;

  SearchProvider({SearchRepository? repository})
      : _repository = repository ?? SearchRepository();

  List<SearchResult> _results = [];
  String _currentQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  List<SearchResult> get results => _results;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _currentPage < _totalPages;
  String? get error => _error;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _results = [];
      _currentQuery = '';
      notifyListeners();
      return;
    }

    _currentQuery = query;
    _currentPage = 1;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.searchAll(query, page: 1);
      _results = result.items;
      _currentPage = result.page;
      _totalPages = result.totalPages;
    } catch (e) {
      _error = 'Search failed: $e';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || _isLoadingMore || _currentQuery.isEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _repository.searchAll(
        _currentQuery,
        page: _currentPage + 1,
      );
      _results.addAll(result.items);
      _currentPage = result.page;
      _totalPages = result.totalPages;
    } catch (e) {
      _error = 'Search failed: $e';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clear() {
    _results = [];
    _currentQuery = '';
    _error = null;
    notifyListeners();
  }
}
