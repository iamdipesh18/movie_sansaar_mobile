import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/snackbar_service.dart';
import '../../../data/models/series_model.dart';
import '../../../data/models/season_model.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/repositories/series_repository.dart';
import '../trailer/trailer_screen.dart';
import '../player/player_screen.dart';
import '../../providers/series_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';

class SeriesDetailScreen extends StatefulWidget {
  final int seriesId;

  const SeriesDetailScreen({super.key, required this.seriesId});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  Series? _series;
  bool _isLoading = true;
  bool _isProcessingFavorite = false;

  final Map<int, bool> _expandedSeasons = {};
  final Map<int, List<Episode>> _seasonEpisodes = {};
  final Map<int, bool> _loadingEpisodes = {};

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final provider = context.read<SeriesProvider>();
      await provider.fetchDetails(widget.seriesId);
      setState(() {
        _series = provider.selected;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToTrailer() {
    if (_series == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerScreen(
          contentId: widget.seriesId,
          contentTitle: _series!.name,
          posterUrl: ApiConstants.imageUrl(_series!.backdropPath, width: 500),
          isSeries: true,
        ),
      ),
    );
  }

  void _navigateToPlayer({int season = 1, int episode = 1}) {
    if (_series == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          contentId: widget.seriesId,
          contentTitle: _series!.name,
          isSeries: true,
          seasonNumber: season,
          episodeNumber: episode,
        ),
      ),
    );
  }

  Future<void> _loadEpisodes(int seasonNumber) async {
    if (_seasonEpisodes.containsKey(seasonNumber)) return;
    setState(() => _loadingEpisodes[seasonNumber] = true);

    try {
      final repo = SeriesRepository();
      final episodes =
          await repo.getEpisodes(widget.seriesId, seasonNumber);
      setState(() => _seasonEpisodes[seasonNumber] = episodes);
    } catch (_) {
      if (mounted) {
        SnackbarService.error(
            context, 'Failed to load episodes for season $seasonNumber');
      }
    } finally {
      setState(() => _loadingEpisodes[seasonNumber] = false);
    }
  }

  Future<void> _handleFavorite() async {
    if (_isProcessingFavorite || _series == null) return;
    setState(() => _isProcessingFavorite = true);

    try {
      final auth = context.read<AuthProvider>();
      final favorites = context.read<FavoritesProvider>();

      if (!auth.isLoggedIn) {
        _showLoginDialog();
        return;
      }

      final id = _series!.id.toString();
      if (favorites.isFavorited(id)) {
        await favorites.removeFavorite(id);
        SnackbarService.success(context, 'Removed from favorites');
      } else {
        await favorites.addFavorite(id, type: 'series');
        SnackbarService.success(context, 'Added to favorites');
      }
    } catch (e) {
      SnackbarService.error(context, 'Error updating favorites');
    } finally {
      setState(() => _isProcessingFavorite = false);
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please sign in to add favorites.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/signin');
            },
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
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

  Widget _buildContent() {
    return ListView(
      children: [
        _buildBackdropHeader(),
        _buildSectionTitle('Genres'),
        _buildGenreChips(),
        _buildSectionTitle('Overview'),
        _buildOverview(),
        _buildSectionTitle('Seasons'),
        ...?_series?.seasons
            .where((s) => s.seasonNumber > 0)
            .map(_buildSeasonCard),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBackdropHeader() {
    if (_series == null) return const SizedBox.shrink();
    final favorites = context.watch<FavoritesProvider>();
    final isFavorited = favorites.isFavorited(_series!.id.toString());

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: ApiConstants.imageUrl(_series!.backdropPath, width: 500),
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
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 12,
          child: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Theme.of(context).iconTheme.color,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          right: 12,
          child: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
            child: IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited
                    ? Colors.redAccent
                    : Theme.of(context).iconTheme.color,
              ),
              onPressed: _handleFavorite,
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _series!.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'First Air: ${_series!.firstAirDate}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(_series!.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  _buildGlassButton(
                    icon: Icons.play_arrow,
                    label: 'Trailer',
                    onTap: _navigateToTrailer,
                    background: Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGlassButton(
                      icon: Icons.videocam,
                      label: 'Watch S1E1',
                      onTap: () => _navigateToPlayer(),
                      background: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassButton(
                      icon: Icons.movie,
                      label: 'Latest Ep',
                      onTap: () => _navigateToPlayer(
                        season: _series!.seasons.isNotEmpty
                            ? _series!.seasons.last.seasonNumber
                            : 1,
                        episode: 1,
                      ),
                      background: Colors.greenAccent.shade700,
                    ),
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
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
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
        children: _series!.genres
            .map((g) => Chip(
                  label: Text(g.name),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildSeasonCard(Season season) {
    final episodes = _seasonEpisodes[season.seasonNumber] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        key: PageStorageKey(season.seasonNumber),
        initiallyExpanded: _expandedSeasons[season.seasonNumber] ?? false,
        onExpansionChanged: (expanded) {
          setState(() => _expandedSeasons[season.seasonNumber] = expanded);
          if (expanded && episodes.isEmpty) {
            _loadEpisodes(season.seasonNumber);
          }
        },
        leading: season.posterPath.isNotEmpty
            ? CachedNetworkImage(
                imageUrl:
                    ApiConstants.imageUrl(season.posterPath, width: 92),
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
            ...episodes.map((e) => _buildEpisodeTile(e, season.seasonNumber)),
        ],
      ),
    );
  }

  Widget _buildEpisodeTile(Episode episode, int seasonNumber) {
    return ListTile(
      leading: episode.stillPath.isNotEmpty
          ? CachedNetworkImage(
              imageUrl:
                  ApiConstants.imageUrl(episode.stillPath, width: 92),
              width: 90,
              fit: BoxFit.cover,
            )
          : null,
      title: Text('${episode.episodeNumber}. ${episode.name}'),
      subtitle: Text(
        episode.overview.isNotEmpty ? episode.overview : 'No description',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (episode.airDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(episode.airDate),
            ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill, color: Colors.blueAccent),
            onPressed: () => _navigateToPlayer(
              season: seasonNumber,
              episode: episode.episodeNumber,
            ),
          ),
        ],
      ),
    );
  }
}
