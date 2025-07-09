import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:movie_sansaar_mobile/models/season_and_episode.dart';
import '../../models/series.dart';
import '../../services/series_api_service.dart';
import '../trailer_player_screen.dart';
import '../../services/auth_service.dart';
import '../../providers/favourites_provider.dart';

class SeriesDetailsScreen extends StatefulWidget {
  final int seriesId;

  const SeriesDetailsScreen({super.key, required this.seriesId});

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  Series? _series;
  bool _isLoading = true;

  final SeriesApiService _apiService = SeriesApiService();
  final Map<int, bool> _expandedSeasons = {};
  final Map<int, List<Episode>> _seasonEpisodes = {};
  final Map<int, bool> _loadingEpisodes = {};

  bool _isProcessingFavorite = false; // To prevent multiple taps

  @override
  void initState() {
    super.initState();
    _loadFullSeriesDetails();
  }

  Future<void> _loadFullSeriesDetails() async {
    try {
      final data = await _apiService.fetchFullDetails(widget.seriesId);
      setState(() {
        _series = data;
        _isLoading = false;
      });
      debugPrint('Series details loaded: ${data.name}');
    } catch (e) {
      debugPrint('Error loading series details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToTrailerPlayer() {
    if (_series == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerPlayerScreen(
          contentId: _series!.id,
          contentTitle: _series!.name,
          posterUrl: 'https://image.tmdb.org/t/p/w500${_series!.posterPath}',
          isSeries: true,
        ),
      ),
    );
  }

  Future<void> _loadEpisodes(int seriesId, int seasonNumber) async {
    if (_seasonEpisodes.containsKey(seasonNumber)) return;

    setState(() => _loadingEpisodes[seasonNumber] = true);

    try {
      final episodes = await _apiService.fetchEpisodes(seriesId, seasonNumber);
      setState(() => _seasonEpisodes[seasonNumber] = episodes);
      debugPrint('Loaded episodes for season $seasonNumber');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load episodes for season $seasonNumber'),
        ),
      );
      debugPrint('Error loading episodes: $e');
    } finally {
      setState(() => _loadingEpisodes[seasonNumber] = false);
    }
  }

  /// Back button on top-left corner
  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 12,
      child: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withOpacity(0.75),
        child: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Theme.of(context).iconTheme.color,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Favorite button on top-right corner
  Widget _buildFavoriteButton() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isLoggedIn = authService.currentUser != null;

    final isFavorited = _series != null
        ? favoritesProvider.isFavorited(_series!.id.toString())
        : false;

    Future<void> handleFavoriteTap() async {
      if (_isProcessingFavorite) return; // prevent multiple taps

      if (!isLoggedIn) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Login Required'),
            content: const Text('Please sign in to add favorites.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Future.microtask(
                    () => Navigator.pushNamed(context, '/signin'),
                  );
                },
                child: const Text('Sign In'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        _isProcessingFavorite = true;
      });

      try {
        if (isFavorited) {
          await favoritesProvider.removeFavorite(_series!.id.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from favorites')),
          );
        } else {
          await favoritesProvider.addFavorite(
            _series!.id.toString(),
            type: 'series',
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));
      } finally {
        setState(() {
          _isProcessingFavorite = false;
        });
      }
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 12,
      child: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withOpacity(0.75),
        child: IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited
                ? Colors.redAccent
                : Theme.of(context).iconTheme.color,
          ),
          tooltip: isFavorited ? 'Remove from favorites' : 'Add to favorites',
          onPressed: handleFavoriteTap,
        ),
      ),
    );
  }

  Widget _buildBackdropHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_series == null) return const SizedBox.shrink();

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://image.tmdb.org/t/p/original${_series!.backdropPath}',
          height: 450,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark
                      ? Colors.black.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  isDark
                      ? Colors.black.withOpacity(0.85)
                      : Colors.white.withOpacity(0.2),
                ],
              ),
            ),
          ),
        ),
        _buildBackButton(),
        _buildFavoriteButton(),
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _series!.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'First Air: ${_series!.firstAirDate}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade400, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _series!.voteAverage.toStringAsFixed(1),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  _buildGlassButton(
                    icon: Icons.play_arrow,
                    label: 'Trailer',
                    onTap: _navigateToTrailerPlayer,
                    background: Colors.redAccent.withOpacity(0.85),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color background,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _series!.overview,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildGenreChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _series!.genres.map((genre) {
          return Chip(
            label: Text(
              genre.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeasonCard(Season season) {
    if (season.seasonNumber == 0) return const SizedBox.shrink();

    final episodes = _seasonEpisodes[season.seasonNumber] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        key: PageStorageKey(season.seasonNumber),
        initiallyExpanded: _expandedSeasons[season.seasonNumber] ?? false,
        onExpansionChanged: (expanded) {
          setState(() => _expandedSeasons[season.seasonNumber] = expanded);
          if (expanded && episodes.isEmpty) {
            _loadEpisodes(_series!.id, season.seasonNumber);
          }
        },
        leading: season.posterPath.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w92${season.posterPath}',
                width: 50,
                fit: BoxFit.cover,
              )
            : null,
        title: Text('Season ${season.seasonNumber}: ${season.name}'),
        subtitle: Text('${season.episodeCount} episodes'),
        children: [
          if (_loadingEpisodes[season.seasonNumber] ?? false)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (episodes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No episodes found'),
            )
          else
            ...episodes.map(_buildEpisodeTile),
        ],
      ),
    );
  }

  Widget _buildEpisodeTile(Episode episode) {
    return ListTile(
      leading: episode.stillPath.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: 'https://image.tmdb.org/t/p/w92${episode.stillPath}',
              width: 90,
              fit: BoxFit.cover,
            )
          : null,
      title: Text('${episode.episodeNumber}. ${episode.name}'),
      subtitle: Text(
        episode.overview.isNotEmpty ? episode.overview : 'No description',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(episode.airDate.isNotEmpty ? episode.airDate : ''),
    );
  }

  Widget _buildContent() {
    return ListView(
      children: [
        _buildBackdropHeader(),
        _buildSectionTitle('Genres'),
        _buildGenreChips(),
        _buildSectionTitle('Overview'),
        _buildOverview(),
        _buildSectionTitle('Seasons'),
        ..._series!.seasons.map(_buildSeasonCard),
        const SizedBox(height: 32),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
}
