import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/screens/now_playing_screen.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';

class PopularScreen extends StatefulWidget {
  const PopularScreen({super.key});

  @override
  State<PopularScreen> createState() => _PopularScreenState();
}

class _PopularScreenState extends State<PopularScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MovieProvider>(context, listen: false).fetchPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    final movies = movieProvider.popularMovies;

    return Scaffold(
      appBar: AppBar(title: const Text('Popular Movies')),
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
