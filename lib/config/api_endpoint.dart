// class ApiEndpoints {
//   static const String baseUrl =
//       'https://movie-sansaar-server.vercel.app/api'; // use the actual URL
//   static const String nowPlaying = '$baseUrl/movies/now-playing';
//   static const String popular = '$baseUrl/movies/popular';
//   static const String topRated = '$baseUrl/movies/top-rated';
//   static String details(int id) => '$baseUrl/movies/$id';
// }

class ApiEndpoints {
  static const String apiKey =
      'c186762f14592e810da1278859304e21'; // Your API key
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Now Playing Movies
  static const String nowPlaying = '$baseUrl/movie/now_playing?api_key=$apiKey';
  // Popular Movies
  static const String popular = '$baseUrl/movie/popular?api_key=$apiKey';
  // Top Rated Movies
  static const String topRated = '$baseUrl/movie/top_rated?api_key=$apiKey';

  // Movie Details (dynamic URL based on movie ID)
  static String movieDetails(int id) => '$baseUrl/movie/$id?api_key=$apiKey';

  //for searching
  static String searchMovies(String query) =>
    '$baseUrl/search/movie?api_key=$apiKey&query=$query';


}
