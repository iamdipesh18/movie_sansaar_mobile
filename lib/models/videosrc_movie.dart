/// Model representing a movie fetched from vidsrc.xyz
///
/// This structure is based on the JSON returned from:
/// https://vidsrc.xyz/movies/latest/page-1.json
///
/// Example movie JSON:
/// {
///   "id": "385687",
///   "title": "Fast X",
///   "poster": "https://image.tmdb.org/t/p/w600_and_h900_bestv2/fiVW06jE7z9YnO4trhaMEdclSiC.jpg",
///   "year": "2023"
/// }
class VidSrcMovie {
  final String id; // Usually TMDB ID as String
  final String title; // Movie title
  final String poster; // Full poster URL
  final String year; // Release year

  VidSrcMovie({
    required this.id,
    required this.title,
    required this.poster,
    required this.year,
  });

  /// Factory constructor to create a VidSrcMovie from JSON map
  factory VidSrcMovie.fromJson(Map<String, dynamic> json) {
    return VidSrcMovie(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      poster: json['poster'] ?? '',
      year: json['year'] ?? '',
    );
  }
}
