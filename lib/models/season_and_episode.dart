class Season {
  final int id;
  final String name;
  final String posterPath;
  final int seasonNumber;
  final int episodeCount;
  final List<Episode> episodes; // Episodes loaded separately

  Season({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.seasonNumber,
    required this.episodeCount,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      posterPath: json['poster_path'] ?? '',
      seasonNumber: json['season_number'] ?? 0,
      episodeCount: json['episode_count'] ?? 0,
      episodes: [], // Episodes empty at start, will load later
    );
  }
}

class Episode {
  final int id;
  final String name;
  final String overview;
  final String stillPath;
  final int episodeNumber;
  final String airDate;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.episodeNumber,
    required this.airDate,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      stillPath: json['still_path'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      airDate: json['air_date'] ?? '',
    );
  }
}
