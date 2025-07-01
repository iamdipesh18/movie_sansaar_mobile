import 'package:movie_sansaar_mobile/models/season_and_episode.dart';

class Series {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final String firstAirDate;
  final List<Season> seasons; // New field

  Series({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.firstAirDate,
    required this.seasons, // Add to constructor
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    var seasonsJson = json['seasons'] as List<dynamic>? ?? [];

    return Series(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
      seasons: seasonsJson.map((s) => Season.fromJson(s)).toList(),
    );
  }
}
