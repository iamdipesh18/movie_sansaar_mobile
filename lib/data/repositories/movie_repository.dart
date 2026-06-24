import '../models/movie_model.dart';
import '../models/paginated_result.dart';
import '../datasources/movie_api.dart';

class MovieRepository {
  final MovieApi _api;

  MovieRepository({MovieApi? api}) : _api = api ?? MovieApi();

  Future<PaginatedResult<Movie>> getNowPlaying({int page = 1}) =>
      _api.fetchNowPlaying(page: page);

  Future<PaginatedResult<Movie>> getPopular({int page = 1}) =>
      _api.fetchPopular(page: page);

  Future<PaginatedResult<Movie>> getTopRated({int page = 1}) =>
      _api.fetchTopRated(page: page);

  Future<PaginatedResult<Movie>> search(String query, {int page = 1}) =>
      _api.search(query, page: page);

  Future<Movie> getDetails(int id) => _api.fetchDetails(id);

  Future<String?> getTrailerKey(int id) => _api.fetchTrailerKey(id);
}
