/// Represents a TV Series object fetched from the API.
class Series {
  final int id;
  final String name; // Series title
  final String overview; // Description
  final String posterPath; // Image poster path
  final double voteAverage; // Average rating
  final String firstAirDate; // First aired date

  Series({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.firstAirDate,
  });

  /// Factory constructor to create a Series instance from JSON map.
  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
    );
  }
}
