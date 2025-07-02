import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/providers/movie_provider.dart';
import 'package:provider/provider.dart';
import '../../widgets/movie_card.dart';

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

  /// Calculates how many cards should fit per row based on screen width
  int _calculateCrossAxisCount(double width) {
    if (width >= 1200) return 6; // Desktop
    if (width >= 1000) return 5;
    if (width >= 800) return 4;
    if (width >= 600) return 3;
    return 2; // Default for phones
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = _calculateCrossAxisCount(screenWidth);

    return movieProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GridView.builder(
              itemCount: movieProvider.nowPlayingMovies.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                final movie = movieProvider.nowPlayingMovies[index];
                return MovieCard(movie: movie);
              },
            ),
          );
  }
}
