class ApiEndpoints {
  static const String baseUrl =
      'https://movie-sansaar-server.vercel.app/api'; // use the actual URL
  static const String nowPlaying = '$baseUrl/movies/now-playing';
  static const String popular = '$baseUrl/movies/popular';
  static const String topRated = '$baseUrl/movies/top-rated';
  static String details(int id) => '$baseUrl/movies/$id';
}
