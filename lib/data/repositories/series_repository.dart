import '../models/genre_model.dart';
import '../models/series_model.dart';
import '../models/paginated_result.dart';
import '../models/episode_model.dart';
import '../datasources/series_api.dart';

class SeriesRepository {
  final SeriesApi _api;

  SeriesRepository({SeriesApi? api}) : _api = api ?? SeriesApi();

  Future<List<Genre>> getGenres() => _api.fetchGenres();

  Future<PaginatedResult<Series>> getAiringToday({
    int page = 1,
    Map<int, Genre>? genreMap,
  }) =>
      _api.fetchAiringToday(page: page, genreMap: genreMap);

  Future<PaginatedResult<Series>> getPopular({
    int page = 1,
    Map<int, Genre>? genreMap,
  }) =>
      _api.fetchPopular(page: page, genreMap: genreMap);

  Future<PaginatedResult<Series>> getTopRated({
    int page = 1,
    Map<int, Genre>? genreMap,
  }) =>
      _api.fetchTopRated(page: page, genreMap: genreMap);

  Future<PaginatedResult<Series>> search(String query, {int page = 1}) =>
      _api.search(query, page: page);

  Future<Series> getDetails(int id) => _api.fetchDetails(id);

  Future<Series> getFullDetails(int id) => _api.fetchFullDetails(id);

  Future<String?> getTrailerKey(int id) => _api.fetchTrailerKey(id);

  Future<List<Episode>> getEpisodes(int seriesId, int seasonNumber) =>
      _api.fetchEpisodes(seriesId, seasonNumber);
}
