import 'package:flutter/material.dart';
import '../../data/models/genre_model.dart';
import '../../data/models/series_model.dart';
import '../../data/models/episode_model.dart';
import '../../data/repositories/series_repository.dart';

class SeriesProvider extends ChangeNotifier {
  final SeriesRepository _repository;

  SeriesProvider({SeriesRepository? repository})
      : _repository = repository ?? SeriesRepository();

  List<Series> _airingToday = [];
  List<Series> _popular = [];
  List<Series> _topRated = [];

  int _airingTodayPage = 1;
  int _airingTodayTotalPages = 1;
  int _popularPage = 1;
  int _popularTotalPages = 1;
  int _topRatedPage = 1;
  int _topRatedTotalPages = 1;

  Series? _selected;
  Map<int, Genre> _genreMap = {};
  bool _isLoading = false;
  bool _airingTodayIsLoadingMore = false;
  bool _popularIsLoadingMore = false;
  bool _topRatedIsLoadingMore = false;
  String? _error;

  List<Series> get airingToday => _airingToday;
  List<Series> get popular => _popular;
  List<Series> get topRated => _topRated;
  Series? get selected => _selected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<int, Genre> get genreMap => _genreMap;

  bool get airingTodayIsLoadingMore => _airingTodayIsLoadingMore;
  bool get popularIsLoadingMore => _popularIsLoadingMore;
  bool get topRatedIsLoadingMore => _topRatedIsLoadingMore;
  bool get hasMoreAiringToday => _airingTodayPage < _airingTodayTotalPages;
  bool get hasMorePopular => _popularPage < _popularTotalPages;
  bool get hasMoreTopRated => _topRatedPage < _topRatedTotalPages;

  Future<void> fetchGenres() async {
    try {
      final genres = await _repository.getGenres();
      _genreMap = {for (final g in genres) g.id: g};
    } catch (e) {
      _error = 'Failed to load genres: $e';
      notifyListeners();
    }
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await fetchGenres();
      final results = await Future.wait([
        _repository.getAiringToday(page: 1, genreMap: _genreMap),
        _repository.getPopular(page: 1, genreMap: _genreMap),
        _repository.getTopRated(page: 1, genreMap: _genreMap),
      ]);
      _airingToday = results[0].items;
      _airingTodayPage = results[0].page;
      _airingTodayTotalPages = results[0].totalPages;
      _popular = results[1].items;
      _popularPage = results[1].page;
      _popularTotalPages = results[1].totalPages;
      _topRated = results[2].items;
      _topRatedPage = results[2].page;
      _topRatedTotalPages = results[2].totalPages;
    } catch (e) {
      _error = 'Failed to load series: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAiringToday() async {
    _airingTodayPage = 1;
    await _fetch(
      () async {
        if (_genreMap.isEmpty) await fetchGenres();
        final result = await _repository.getAiringToday(page: 1, genreMap: _genreMap);
        _airingToday = result.items;
        _airingTodayPage = result.page;
        _airingTodayTotalPages = result.totalPages;
      },
    );
  }

  Future<void> fetchPopular() async {
    _popularPage = 1;
    await _fetch(
      () async {
        if (_genreMap.isEmpty) await fetchGenres();
        final result = await _repository.getPopular(page: 1, genreMap: _genreMap);
        _popular = result.items;
        _popularPage = result.page;
        _popularTotalPages = result.totalPages;
      },
    );
  }

  Future<void> fetchTopRated() async {
    _topRatedPage = 1;
    await _fetch(
      () async {
        if (_genreMap.isEmpty) await fetchGenres();
        final result = await _repository.getTopRated(page: 1, genreMap: _genreMap);
        _topRated = result.items;
        _topRatedPage = result.page;
        _topRatedTotalPages = result.totalPages;
      },
    );
  }

  Future<void> loadMoreAiringToday() async {
    if (!hasMoreAiringToday || _airingTodayIsLoadingMore) return;
    await _loadMore(
      () async {
        final result = await _repository.getAiringToday(
          page: _airingTodayPage + 1,
          genreMap: _genreMap,
        );
        _airingToday.addAll(result.items);
        _airingTodayPage = result.page;
        _airingTodayTotalPages = result.totalPages;
      },
      _setAiringTodayLoadingMore,
    );
  }

  Future<void> loadMorePopular() async {
    if (!hasMorePopular || _popularIsLoadingMore) return;
    await _loadMore(
      () async {
        final result = await _repository.getPopular(
          page: _popularPage + 1,
          genreMap: _genreMap,
        );
        _popular.addAll(result.items);
        _popularPage = result.page;
        _popularTotalPages = result.totalPages;
      },
      _setPopularLoadingMore,
    );
  }

  Future<void> loadMoreTopRated() async {
    if (!hasMoreTopRated || _topRatedIsLoadingMore) return;
    await _loadMore(
      () async {
        final result = await _repository.getTopRated(
          page: _topRatedPage + 1,
          genreMap: _genreMap,
        );
        _topRated.addAll(result.items);
        _topRatedPage = result.page;
        _topRatedTotalPages = result.totalPages;
      },
      _setTopRatedLoadingMore,
    );
  }

  Future<void> fetchDetails(int seriesId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selected = await _repository.getFullDetails(seriesId);
    } catch (e) {
      _error = 'Failed to load series details: $e';
      _selected = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Series> getFullDetails(int id) => _repository.getFullDetails(id);

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }

  Future<List<Episode>> fetchEpisodes(int seriesId, int seasonNumber) async {
    try {
      return await _repository.getEpisodes(seriesId, seasonNumber);
    } catch (e) {
      _error = 'Failed to load episodes: $e';
      notifyListeners();
      return [];
    }
  }

  Future<void> _fetch(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMore(
    Future<void> Function() action,
    void Function(bool) setLoading,
  ) async {
    setLoading(true);
    notifyListeners();

    try {
      await action();
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void _setAiringTodayLoadingMore(bool v) => _airingTodayIsLoadingMore = v;
  void _setPopularLoadingMore(bool v) => _popularIsLoadingMore = v;
  void _setTopRatedLoadingMore(bool v) => _topRatedIsLoadingMore = v;
}
