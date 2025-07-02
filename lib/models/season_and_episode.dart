/// Represents a single season in a TV series.
class Season {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String airDate;
  final int seasonNumber;
  final int episodeCount;

  /// List of episodes for this season (lazily loaded).
  final List<Episode> episodes;

  Season({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.airDate,
    required this.seasonNumber,
    required this.episodeCount,
    this.episodes = const [],
  });

  /// Creates a Season object from JSON.
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

  /// Converts a Season object to JSON.
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

/// Represents a single episode within a season.
class Episode {
  final int id;
  final String name;
  final String overview;
  final String stillPath;
  final int episodeNumber;
  final int seasonNumber;
  final String airDate;
  final double voteAverage;
  final int runtime;

  /// Optional: List of guest stars in the episode
  final List<String> guestStars;

  /// Optional: List of crew members (e.g. director, writer)
  final List<String> crew;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.airDate,
    required this.voteAverage,
    required this.runtime,
    this.guestStars = const [],
    this.crew = const [],
  });

  /// Creates an Episode object from JSON.
  factory Episode.fromJson(Map<String, dynamic> json) {
    final guestStarsJson = json['guest_stars'] as List<dynamic>? ?? [];
    final crewJson = json['crew'] as List<dynamic>? ?? [];

    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      stillPath: json['still_path'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      airDate: json['air_date'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      runtime: json['runtime'] ?? 0,
      guestStars: guestStarsJson.map((e) => e['name'] as String).toList(),
      crew: crewJson.map((e) => e['name'] as String).toList(),
    );
  }

  /// Converts an Episode object to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'still_path': stillPath,
      'episode_number': episodeNumber,
      'season_number': seasonNumber,
      'air_date': airDate,
      'vote_average': voteAverage,
      'runtime': runtime,
      'guest_stars': guestStars,
      'crew': crew,
    };
  }
}
