import '../models/search_result.dart';
import '../models/paginated_result.dart';
import '../datasources/search_api.dart';

class SearchRepository {
  final SearchApi _api;

  SearchRepository({SearchApi? api}) : _api = api ?? SearchApi();

  Future<PaginatedResult<SearchResult>> searchAll(String query, {int page = 1}) =>
      _api.searchAll(query, page: page);
}
