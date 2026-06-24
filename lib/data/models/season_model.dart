import 'episode_model.dart';

class Season {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String airDate;
  final int seasonNumber;
  final int episodeCount;
  final List<Episode> episodes;

  const Season({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.airDate,
    required this.seasonNumber,
    required this.episodeCount,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      airDate: json['air_date'] ?? '',
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'poster_path': posterPath,
      'air_date': airDate,
      'season_number': seasonNumber,
      'episode_count': episodeCount,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }
}
