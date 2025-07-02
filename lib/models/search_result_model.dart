import '../config/api_endpoint.dart';

enum ContentType { movie, series }

class SearchResult {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final String releaseDate;
  final double rating;
  final ContentType type;

  SearchResult({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.rating,
    required this.type,
  });

  /// Constructs SearchResult from movie JSON response
  factory SearchResult.fromMovieJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      title: json['title'] ?? '',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      type: ContentType.movie,
    );
  }

  /// Constructs SearchResult from series JSON response
  factory SearchResult.fromSeriesJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'],
      title: json['name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['first_air_date'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      type: ContentType.series,
    );
  }

  /// Returns full image URL or placeholder if no posterPath available
  String get posterUrl {
    if (posterPath.isEmpty) {
      // Fallback placeholder image
      return 'https://via.placeholder.com/100x150.png?text=No+Image';
    }
    return ApiEndpoints.imageUrl(posterPath);
  }

  /// Extracts year part from releaseDate string if available
  String get releaseYear {
    if (releaseDate.isEmpty) return '';
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (_) {
      return '';
    }
  }

  @override
  String toString() {
    return 'SearchResult(id: $id, title: $title, type: $type, rating: $rating)';
  }
}
