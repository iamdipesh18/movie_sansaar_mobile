class MovieGenres {
  // Mapping TMDB genre IDs to human-readable genre names
  static const Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  /// Converts a list of genre IDs to their corresponding genre names.
  /// If an ID is not recognized, 'Unknown' is used as a fallback.
  static List<String> fromIds(List<dynamic> ids) {
    return ids.map((id) => genreMap[id] ?? 'Unknown').toList();
  }
}

class Movie {
  // Basic movie info (always required)
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;

  final String? streamingUrl;
  // Full detail info (available after fetching details)
  final int runtime;
  final String status;
  final List<String> genres;
  final List<String> spokenLanguages;
  final List<String> productionCompanies;
  final int budget;
  final int revenue;
  final String originalLanguage;
  final String tagline;

  // New: imdbId is now needed for streaming APIs
  final String imdbId;

  // Related info like videos and cast (usually in full detail)
  final List<Map<String, dynamic>> videos;
  final List<Map<String, dynamic>> cast;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.runtime,
    required this.status,
    required this.genres,
    required this.spokenLanguages,
    required this.productionCompanies,
    required this.budget,
    required this.revenue,
    required this.originalLanguage,
    required this.tagline,
    required this.imdbId,
    required this.videos,
    required this.cast,
    required this.streamingUrl,
  });

  /// Factory constructor to create a lightweight `Movie` instance,
  /// useful when only partial data is available (e.g., from list or search results).
  factory Movie.minimal({
    required int id,
    required String title,
    String overview = '',
    String posterPath = '',
    String backdropPath = '',
    double voteAverage = 0,
    String releaseDate = '',
  }) {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      voteAverage: voteAverage,
      releaseDate: releaseDate,
      runtime: 0,
      status: '',
      genres: [],
      spokenLanguages: [],
      productionCompanies: [],
      budget: 0,
      revenue: 0,
      originalLanguage: '',
      tagline: '',
      imdbId: '', // Not available in minimal
      videos: [],
      cast: [],
      streamingUrl: '',
    );
  }

  /// Factory constructor to create a full `Movie` instance from JSON data.
  /// Handles both "list" JSON (with genre_ids) and "details" JSON (with genres list).
  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String> genreNames = [];

    if (json['genres'] != null) {
      // Full details JSON: genres is a list of objects with name
      genreNames = (json['genres'] as List)
          .map((g) => g['name'].toString())
          .toList();
    } else if (json['genre_ids'] != null) {
      // List JSON: genre_ids is a list of integers
      genreNames = MovieGenres.fromIds(json['genre_ids']);
    }

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      status: json['status'] ?? '',
      genres: genreNames,
      spokenLanguages:
          (json['spoken_languages'] as List<dynamic>?)
              ?.map((l) => l['english_name'].toString())
              .toList() ??
          [],
      productionCompanies:
          (json['production_companies'] as List<dynamic>?)
              ?.map((p) => p['name'].toString())
              .toList() ??
          [],
      budget: json['budget'] ?? 0,
      revenue: json['revenue'] ?? 0,
      originalLanguage: json['original_language'] ?? '',
      tagline: json['tagline'] ?? '',
      imdbId: json['imdb_id'] ?? '', // New addition for streaming
      videos:
          ((json['videos']?['results']) as List<dynamic>?)
              ?.map((v) => v as Map<String, dynamic>)
              .toList() ??
          [],
      cast:
          ((json['credits']?['cast']) as List<dynamic>?)
              ?.map((c) => c as Map<String, dynamic>)
              .toList() ??
          [],
      streamingUrl: '',
    );
  }
  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    String? releaseDate,
    String? streamingUrl,
    int? runtime,
    String? status,
    List<String>? genres,
    List<String>? spokenLanguages,
    List<String>? productionCompanies,
    int? budget,
    int? revenue,
    String? originalLanguage,
    String? tagline,
    String? imdbId,
    List<Map<String, dynamic>>? videos,
    List<Map<String, dynamic>>? cast,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
      streamingUrl: streamingUrl ?? this.streamingUrl,
      runtime: runtime ?? this.runtime,
      status: status ?? this.status,
      genres: genres ?? this.genres,
      spokenLanguages: spokenLanguages ?? this.spokenLanguages,
      productionCompanies: productionCompanies ?? this.productionCompanies,
      budget: budget ?? this.budget,
      revenue: revenue ?? this.revenue,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      tagline: tagline ?? this.tagline,
      imdbId: imdbId ?? this.imdbId,
      videos: videos ?? this.videos,
      cast: cast ?? this.cast,
    );
  }
}
