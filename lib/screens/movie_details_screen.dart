import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/screens/trailer_player_screen.dart';
import '../models/movie.dart';
import '../services/movie_api_service.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final MovieApiService _movieApiService = MovieApiService();

  MovieDetailsScreen({super.key, required this.movie});

  void _playTrailer(BuildContext context) async {
    try {
      final key = await _movieApiService.fetchTrailerKey(movie.id);
      if (key != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TrailerPlayerScreen(
              trailerKey: key,
              movieTitle: movie.title,
              posterUrl: 'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Trailer not available')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching trailer: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              movie.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Release Date: ${movie.releaseDate}'),
            const SizedBox(height: 8),
            Text('Rating: ${movie.voteAverage} ⭐'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill),
              label: const Text('Watch Trailer'),
              onPressed: () => _playTrailer(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(movie.overview),
          ],
        ),
      ),
    );
  }
}
