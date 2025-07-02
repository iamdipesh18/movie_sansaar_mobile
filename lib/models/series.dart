// lib/models/series.dart
import 'season_and_episode.dart';
import 'genre.dart'; // ✅ Import Genre model

/// Represents a single TV Series entity returned from the TMDB API
class Series {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String firstAirDate;
  final List<Season> seasons;
  final List<Genre> genres; // ✅ Changed from List<String> to List<Genre>
  final String status; // ✅ Add status field
  final String originalLanguage; // ✅ Add this line

  Series({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.firstAirDate,
    required this.seasons,
    required this.genres,
    required this.status,
    required this.originalLanguage,
  });

  /// Factory constructor to create a Series instance from JSON data
  factory Series.fromJson(Map<String, dynamic> json) {
    final List<Season> parsedSeasons =
        (json['seasons'] as List<dynamic>?)
            ?.map((seasonJson) => Season.fromJson(seasonJson))
            .toList() ??
        [];

    final List<Genre> parsedGenres =
        (json['genres'] as List<dynamic>?)
            ?.map((genreJson) => Genre.fromJson(genreJson))
            .toList() ??
        [];

    return Series(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
      seasons: parsedSeasons,
      genres: parsedGenres,
      status: json['status'] ?? '',
      originalLanguage: json['original_language'] ?? '', // ✅ Add this
    );
  }

  // Factory constructor for list JSON with genreMap to parse genre_ids into Genre objects
  factory Series.fromListJson(
    Map<String, dynamic> json,
    Map<int, Genre> genreMap,
  ) {
    final List<Genre> parsedGenres =
        (json['genre_ids'] as List<dynamic>?)
            ?.map((id) => genreMap[id] ?? Genre(id: id, name: 'Unknown'))
            .toList() ??
        [];

    return Series(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
      seasons: [], // Seasons are not included in list endpoints
      genres: parsedGenres,
      status: json['status'] ?? '',
      originalLanguage: json['original_language'] ?? '',
    );
  }
}
