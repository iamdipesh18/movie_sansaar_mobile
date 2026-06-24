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
  final List<String> guestStars;
  final List<String> crew;

  const Episode({
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
