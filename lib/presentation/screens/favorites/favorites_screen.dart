import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';
import '../../providers/series_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/cards/favorites_card.dart';
import '../../widgets/common/shimmer_card.dart';

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
  final List<_FavoriteItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final favs = context.read<FavoritesProvider>().favorites;
    _items.clear();

    final movieProvider = context.read<MovieProvider>();
    final seriesProvider = context.read<SeriesProvider>();
    final tasks = <Future>[];

    for (final entry in favs.entries) {
      final id = entry.key;
      final type = entry.value;

      if (type == 'movie') {
        tasks.add(movieProvider
            .getDetails(int.parse(id))
            .then((m) => _items.add(_FavoriteItem(type: 'movie', item: m)))
            .catchError((_) {}));
      } else {
        tasks.add(seriesProvider
            .getFullDetails(int.parse(id))
            .then((s) => _items.add(_FavoriteItem(type: 'series', item: s)))
            .catchError((_) {}));
      }
    }

    await Future.wait(tasks);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) Navigator.pushReplacementNamed(context, '/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : favorites.favorites.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: _buildGrid(),
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No favorites added yet.',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_isLoading && _items.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.66,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (_, __) => const ShimmerCard(),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return FavoritesCard(
          movie: item.type == 'movie' ? item.item : null,
          series: item.type == 'series' ? item.item : null,
          onUnfavorited: () {
            setState(() => _items.removeAt(index));
          },
        );
      },
    );
  }
}
