import 'package:flutter/material.dart';
import '../../data/models/movie_model.dart';
import '../../data/models/paginated_result.dart';
import '../../data/repositories/movie_repository.dart';

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieProvider({MovieRepository? repository})
      : _repository = repository ?? MovieRepository();

  List<Movie> _nowPlaying = [];
  List<Movie> _popular = [];
  List<Movie> _topRated = [];

  int _nowPlayingPage = 1;
  int _nowPlayingTotalPages = 1;
  int _popularPage = 1;
  int _popularTotalPages = 1;
  int _topRatedPage = 1;
  int _topRatedTotalPages = 1;

  bool _isLoading = false;
  bool _nowPlayingIsLoadingMore = false;
  bool _popularIsLoadingMore = false;
  bool _topRatedIsLoadingMore = false;
  String? _error;

  List<Movie> get nowPlaying => _nowPlaying;
  List<Movie> get popular => _popular;
  List<Movie> get topRated => _topRated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get nowPlayingIsLoadingMore => _nowPlayingIsLoadingMore;
  bool get popularIsLoadingMore => _popularIsLoadingMore;
  bool get topRatedIsLoadingMore => _topRatedIsLoadingMore;
  bool get hasMoreNowPlaying => _nowPlayingPage < _nowPlayingTotalPages;
  bool get hasMorePopular => _popularPage < _popularTotalPages;
  bool get hasMoreTopRated => _topRatedPage < _topRatedTotalPages;

  Future<void> fetchNowPlaying() async {
    _nowPlayingPage = 1;
    await _fetchAndAssign(
      () => _repository.getNowPlaying(page: 1),
      (result) {
        _nowPlaying = result.items;
        _nowPlayingPage = result.page;
        _nowPlayingTotalPages = result.totalPages;
      },
    );
  }

  Future<void> fetchPopular() async {
    _popularPage = 1;
    await _fetchAndAssign(
      () => _repository.getPopular(page: 1),
      (result) {
        _popular = result.items;
        _popularPage = result.page;
        _popularTotalPages = result.totalPages;
      },
    );
  }

  Future<void> fetchTopRated() async {
    _topRatedPage = 1;
    await _fetchAndAssign(
      () => _repository.getTopRated(page: 1),
      (result) {
        _topRated = result.items;
        _topRatedPage = result.page;
        _topRatedTotalPages = result.totalPages;
      },
    );
  }

  Future<void> loadMoreNowPlaying() async {
    if (!hasMoreNowPlaying || _nowPlayingIsLoadingMore) return;
    await _loadMore(
      () => _repository.getNowPlaying(page: _nowPlayingPage + 1),
      (result) {
        _nowPlaying.addAll(result.items);
        _nowPlayingPage = result.page;
        _nowPlayingTotalPages = result.totalPages;
      },
      _setNowPlayingLoadingMore,
    );
  }

  Future<void> loadMorePopular() async {
    if (!hasMorePopular || _popularIsLoadingMore) return;
    await _loadMore(
      () => _repository.getPopular(page: _popularPage + 1),
      (result) {
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
      () => _repository.getTopRated(page: _topRatedPage + 1),
      (result) {
        _topRated.addAll(result.items);
        _topRatedPage = result.page;
        _topRatedTotalPages = result.totalPages;
      },
      _setTopRatedLoadingMore,
    );
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getNowPlaying(page: 1),
        _repository.getPopular(page: 1),
        _repository.getTopRated(page: 1),
      ]);
      _nowPlaying = results[0].items;
      _nowPlayingPage = results[0].page;
      _nowPlayingTotalPages = results[0].totalPages;
      _popular = results[1].items;
      _popularPage = results[1].page;
      _popularTotalPages = results[1].totalPages;
      _topRated = results[2].items;
      _topRatedPage = results[2].page;
      _topRatedTotalPages = results[2].totalPages;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Movie> getDetails(int id) => _repository.getDetails(id);

  Future<String?> getTrailerKey(int id) => _repository.getTrailerKey(id);

  Future<void> _fetchAndAssign(
    Future<PaginatedResult<Movie>> Function() action,
    void Function(PaginatedResult<Movie>) assign,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await action();
      assign(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadMore(
    Future<PaginatedResult<Movie>> Function() action,
    void Function(PaginatedResult<Movie>) assign,
    void Function(bool) setLoading,
  ) async {
    setLoading(true);
    notifyListeners();

    try {
      final result = await action();
      assign(result);
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void _setNowPlayingLoadingMore(bool v) => _nowPlayingIsLoadingMore = v;
  void _setPopularLoadingMore(bool v) => _popularIsLoadingMore = v;
  void _setTopRatedLoadingMore(bool v) => _topRatedIsLoadingMore = v;
}
