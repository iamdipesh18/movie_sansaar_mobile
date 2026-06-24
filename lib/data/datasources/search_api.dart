import 'dart:convert';
import '../../core/services/http_service.dart';
import '../models/search_result.dart';
import '../models/paginated_result.dart';

class SearchApi {
  final HttpService _http = HttpService.instance;

  Future<PaginatedResult<SearchResult>> searchAll(String query, {int page = 1}) async {
    final responses = await Future.wait([
      _http.get('/search/movie', queryParameters: {'query': query, 'page': '$page'}),
      _http.get('/search/tv', queryParameters: {'query': query, 'page': '$page'}),
    ]);

    final results = <SearchResult>[];
    int totalPages = 1;

    final movieData = jsonDecode(jsonEncode(responses[0].data)) as Map<String, dynamic>;
    final movieResults = movieData['results'] as List? ?? [];
    results.addAll(
      movieResults.map((json) => SearchResult.fromMovieJson(json)),
    );
    totalPages = movieData['total_pages'] ?? 1;

    final seriesData = jsonDecode(jsonEncode(responses[1].data)) as Map<String, dynamic>;
    final seriesResults = seriesData['results'] as List? ?? [];
    results.addAll(
      seriesResults.map((json) => SearchResult.fromSeriesJson(json)),
    );
    totalPages =
        (seriesData['total_pages'] ?? 1) > totalPages
            ? seriesData['total_pages']
            : totalPages;

    results.sort((a, b) => b.rating.compareTo(a.rating));
    final items = results.take(50).toList();

    return PaginatedResult<SearchResult>(
      items: items,
      page: page,
      totalPages: totalPages,
    );
  }
}
