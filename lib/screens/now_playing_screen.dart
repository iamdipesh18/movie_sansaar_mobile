import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';
import 'package:movie_sansaar_mobile/providers/theme_provider.dart';
import 'package:movie_sansaar_mobile/screens/movie_details_screen.dart';
import 'package:movie_sansaar_mobile/screens/search_screen.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.redAccent,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleTheme,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: movieProvider.isLoading
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
            ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster image
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    '${ApiEndpoints.imageBaseUrl}${movie.posterPath}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Movie details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.releaseDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
