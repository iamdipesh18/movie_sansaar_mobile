import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_card.dart';

class TopRatedScreen extends StatefulWidget {
  const TopRatedScreen({super.key});

  @override
  State<TopRatedScreen> createState() => _TopRatedScreen();
}

class _TopRatedScreen extends State<TopRatedScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch top rated movies once the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchTopRatedMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return movieProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: movieProvider.topRatedMovies.length,
            itemBuilder: (context, index) {
              final movie = movieProvider.topRatedMovies[index];
              return MovieCard(movie: movie);
            },
          );
  }
}
