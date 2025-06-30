import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch movies when screen loads
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

    return Scaffold(
      appBar: AppBar(title: const Text('Movie Sansaar')),
      body: movieProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: movieProvider.nowPlayingMovies.length,
              itemBuilder: (context, index) {
                final movie = movieProvider.nowPlayingMovies[index];
                return ListTile(
                  leading: Image.network(
                    '${ApiEndpoints.imageBaseUrl}${movie.posterPath}',
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                  ),
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate),
                );
              },
            ),
    );
  }
}
