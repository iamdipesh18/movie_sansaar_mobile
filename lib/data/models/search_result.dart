import '../../core/constants/api_constants.dart';
import 'content_type.dart';

class SearchResult {
  final int id;
  final String title;
  final String posterPath;
  final String overview;
  final String releaseDate;
  final double rating;
  final ContentType type;

  const SearchResult({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.rating,
    required this.type,
  });

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

  String get posterUrl {
    if (posterPath.isEmpty) {
      return 'https://via.placeholder.com/100x150.png?text=No+Image';
    }
    return ApiConstants.imageUrl(posterPath);
  }

  String get releaseYear {
    if (releaseDate.isEmpty) return '';
    try {
      return DateTime.parse(releaseDate).year.toString();
    } catch (_) {
      return '';
    }
  }
}
