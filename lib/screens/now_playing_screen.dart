import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';
import 'package:movie_sansaar_mobile/providers/movie_provider.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreen();
}

class _NowPlayingScreen extends State<NowPlayingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(
        context,
        listen: false,
      ).fetchNowPlayingMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return movieProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: movieProvider.nowPlayingMovies.length,
              itemBuilder: (context, index) {
                final movie = movieProvider.nowPlayingMovies[index];
                return MovieCard(movie: movie);
              },
            ),
          );
  }
}
