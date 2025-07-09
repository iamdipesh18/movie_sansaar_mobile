import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/screens/movies/movie_details_screen.dart';
import 'package:movie_sansaar_mobile/screens/series/series_details_screen.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../models/series.dart';
import '../../providers/favourites_provider.dart';
import '../../services/movie_api_service.dart';
import '../../services/series_api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoritesProvider favoritesProvider;

  final MovieApiService _movieApiService = MovieApiService();
  final SeriesApiService _seriesApiService = SeriesApiService();

  Map<String, Movie> favoriteMovies = {};
  Map<String, Series> favoriteSeries = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoritesDetails();
  }

  Future<void> _loadFavoritesDetails() async {
    favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final favs = favoritesProvider.favorites;

    List<Future> fetchTasks = [];

    for (var entry in favs.entries) {
      final id = entry.key;
      final type = entry.value; // e.g. 'movie' or 'series'

      if (type == 'movie') {
        fetchTasks.add(_movieApiService.fetchMovieDetails(int.parse(id)).then((movie) {
          favoriteMovies[id] = movie;
        }).catchError((_) {}));
      } else if (type == 'series') {
        fetchTasks.add(_seriesApiService.fetchFullDetails(int.parse(id)).then((series) {
          favoriteSeries[id] = series;
        }).catchError((_) {}));
      }
    }

    await Future.wait(fetchTasks);

    setState(() {
      _isLoading = false;
    });
  }

  void _openMovieDetails(Movie movie) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
    );
  }

  void _openSeriesDetails(Series series) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SeriesDetailsScreen(seriesId: series.id)),
    );
  }

  // Override back button behavior here
  Future<bool> _onWillPop() async {
    Navigator.of(context).pushReplacementNamed('/combined_home');
    return false; // prevent default pop
  }

  @override
  Widget build(BuildContext context) {
    favoritesProvider = Provider.of<FavoritesProvider>(context);
    final favorites = favoritesProvider.favorites;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (favorites.isEmpty) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Favorites'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacementNamed(context, '/combined_home'),
            ),
          ),
          body: const Center(child: Text('No favorites added yet.')),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacementNamed(context, '/combined_home'),
          ),
        ),
        body: ListView(
          children: [
            if (favoriteMovies.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Favorite Movies', style: Theme.of(context).textTheme.titleLarge),
              ),
              ...favoriteMovies.values.map(
                (movie) => ListTile(
                  leading: movie.posterPath.isNotEmpty
                      ? Image.network('https://image.tmdb.org/t/p/w92${movie.posterPath}')
                      : null,
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: () {
                      favoritesProvider.removeFavorite(movie.id.toString());
                      setState(() {
                        favoriteMovies.remove(movie.id.toString());
                      });
                    },
                  ),
                  onTap: () => _openMovieDetails(movie),
                ),
              ),
            ],
            if (favoriteSeries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Favorite Series', style: Theme.of(context).textTheme.titleLarge),
              ),
              ...favoriteSeries.values.map(
                (series) => ListTile(
                  leading: series.posterPath.isNotEmpty
                      ? Image.network('https://image.tmdb.org/t/p/w92${series.posterPath}')
                      : null,
                  title: Text(series.name),
                  subtitle: Text('First Air: ${series.firstAirDate}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: () {
                      favoritesProvider.removeFavorite(series.id.toString());
                      setState(() {
                        favoriteSeries.remove(series.id.toString());
                      });
                    },
                  ),
                  onTap: () => _openSeriesDetails(series),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
