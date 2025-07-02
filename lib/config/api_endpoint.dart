class ApiEndpoints {
  // Your TMDb API key
  static const String apiKey = 'c186762f14592e810da1278859304e21';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // ✅ Appends the API key and optional query parameters
  static String withApiKey(String path, [Map<String, String>? query]) {
    final base = '$path?api_key=$apiKey';
    if (query == null) return base;

    final queryString = query.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$base&$queryString';
  }

  // ✅ Image URL builder (default width: w500)
  static String imageUrl(String path, {int width = 500}) =>
      'https://image.tmdb.org/t/p/w$width$path';

  // ===================== MOVIES =====================

  /// Now Playing Movies
  static final nowPlaying = withApiKey('$baseUrl/movie/now_playing');

  /// Popular Movies
  static final popular = withApiKey('$baseUrl/movie/popular');

  /// Top Rated Movies
  static final topRated = withApiKey('$baseUrl/movie/top_rated');

  /// Search Movies
  static String searchMovies(String query) =>
      withApiKey('$baseUrl/search/movie', {'query': query});

  /// Basic Movie Details
  static String movieDetails(int id) => withApiKey('$baseUrl/movie/$id');

  /// Movie Details with Videos & Credits
  static String fullMovieDetails(int id) => withApiKey(
        '$baseUrl/movie/$id',
        {'append_to_response': 'videos,credits'},
      );

  /// Get Movie Trailers
  static String movieTrailer(int id) => withApiKey('$baseUrl/movie/$id/videos');

  // ===================== TV SERIES =====================

  /// TV Series Airing Today
  static final airingTodaySeries = withApiKey('$baseUrl/tv/airing_today');

  /// Popular TV Series
  static final popularSeries = withApiKey('$baseUrl/tv/popular');

  /// Top Rated TV Series
  static final topRatedSeries = withApiKey('$baseUrl/tv/top_rated');

  /// Search Series
  static String searchSeries(String query) =>
      withApiKey('$baseUrl/search/tv', {'query': query});

  /// Basic Series Details
  static String seriesDetails(int id) => withApiKey('$baseUrl/tv/$id');

  /// Series Details with Videos & Credits
  static String fullSeriesDetails(int id) => withApiKey(
        '$baseUrl/tv/$id',
        {'append_to_response': 'videos,credits'},
      );

  /// Get Series Trailers
  static String seriesTrailer(int id) => withApiKey('$baseUrl/tv/$id/videos');
}
