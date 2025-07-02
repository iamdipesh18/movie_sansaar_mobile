import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movie_sansaar_mobile/models/search_result_model.dart';
import '../config/api_endpoint.dart';

class SearchService {
  Future<List<SearchResult>> searchAll(String query) async {
    final List<SearchResult> allResults = [];

    try {
      final movieUrl = Uri.parse(ApiEndpoints.searchMovies(query));
      final seriesUrl = Uri.parse(ApiEndpoints.searchSeries(query));

      final responses = await Future.wait([
        http.get(movieUrl),
        http.get(seriesUrl),
      ]);

      // Process movies response
      if (responses[0].statusCode == 200) {
        final movieData = jsonDecode(responses[0].body);
        final List movieResults = movieData['results'];
        allResults.addAll(
          movieResults.map((json) => SearchResult.fromMovieJson(json)),
        );
      } else {
        // Optionally log or handle movie search failure here
      }

      // Process series response
      if (responses[1].statusCode == 200) {
        final seriesData = jsonDecode(responses[1].body);
        final List seriesResults = seriesData['results'];
        allResults.addAll(
          seriesResults.map((json) => SearchResult.fromSeriesJson(json)),
        );
      } else {
        // Optionally log or handle series search failure here
      }

      // Optional: sort combined results by rating desc
      allResults.sort((a, b) => b.rating.compareTo(a.rating));

      // Optional: limit results to top 50 to avoid huge lists
      return allResults.take(50).toList();
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }
}
