import 'genre_model.dart';
import 'season_model.dart';

class Series {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String firstAirDate;
  final List<Season> seasons;
  final List<Genre> genres;
  final String status;
  final String originalLanguage;

  const Series({
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

  factory Series.fromJson(Map<String, dynamic> json) {
    final parsedSeasons = (json['seasons'] as List<dynamic>?)
            ?.map((s) => Season.fromJson(s))
            .toList() ??
        [];

    final parsedGenres = (json['genres'] as List<dynamic>?)
            ?.map((g) => Genre.fromJson(g))
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
      originalLanguage: json['original_language'] ?? '',
    );
  }

  factory Series.fromListJson(
    Map<String, dynamic> json,
    Map<int, Genre> genreMap,
  ) {
    final parsedGenres = (json['genre_ids'] as List<dynamic>?)
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
      seasons: [],
      genres: parsedGenres,
      status: json['status'] ?? '',
      originalLanguage: json['original_language'] ?? '',
    );
  }
}
