import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/widgets/favourites_result_card.dart';
import 'package:movie_sansaar_mobile/widgets/favourites_shimmer_card.dart';
import 'package:provider/provider.dart';
import '../../providers/favourites_provider.dart';
import '../../services/movie_api_service.dart';
import '../../services/series_api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoriteItem {
  final String type;
  final dynamic item;

  _FavoriteItem({required this.type, required this.item});
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final MovieApiService _movieApiService = MovieApiService();
  final SeriesApiService _seriesApiService = SeriesApiService();

  final List<_FavoriteItem> _favoriteItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoritesDetails();
  }

  Future<void> _loadFavoritesDetails() async {
    final favs = Provider.of<FavoritesProvider>(context, listen: false).favorites;
    _favoriteItems.clear();

    List<Future> tasks = [];

    for (var entry in favs.entries) {
      final id = entry.key;
      final type = entry.value;

      if (type == 'movie') {
        tasks.add(_movieApiService.fetchMovieDetails(int.parse(id)).then((movie) {
          _favoriteItems.add(_FavoriteItem(type: 'movie', item: movie));
        }).catchError((_) {}));
      } else if (type == 'series') {
        tasks.add(_seriesApiService.fetchFullDetails(int.parse(id)).then((series) {
          _favoriteItems.add(_FavoriteItem(type: 'series', item: series));
        }).catchError((_) {}));
      }
    }

    await Future.wait(tasks);
    setState(() => _isLoading = false);
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _isLoading = true;
    });
    await _loadFavoritesDetails();
  }

  Future<bool> _onWillPop() async {
    Navigator.of(context).pushReplacementNamed('/combined_home');
    return false;
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No favorites added yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedGrid() {
    final isLoading = _isLoading && _favoriteItems.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: isLoading ? 6 : _favoriteItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.66,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          if (isLoading) return const FavoritesShimmerCard();

          final item = _favoriteItems[index];
          return FavoritesResultCard(
            movie: item.type == 'movie' ? item.item : null,
            series: item.type == 'series' ? item.item : null,
            onUnfavorited: () {
              setState(() {
                _favoriteItems.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

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
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoritesProvider.favorites.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshFavorites,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _buildUnifiedGrid(),
                    ),
                  ),
      ),
    );
  }
}
