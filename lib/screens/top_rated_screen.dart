import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/providers/theme_provider.dart';
import 'package:movie_sansaar_mobile/screens/search_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchTopRatedMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final movies = movieProvider.popularMovies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Rated Movies'),
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
          : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: movies[index]);
              },
            ),
    );
  }
}
