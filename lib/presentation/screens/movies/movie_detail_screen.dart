import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/snackbar_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/movie_model.dart';
import '../trailer/trailer_screen.dart';
import '../player/player_screen.dart';
import '../../providers/movie_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _movie;
  bool _isLoading = true;
  bool _isProcessingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final provider = context.read<MovieProvider>();
      final movie = await provider.getDetails(widget.movie.id);
      setState(() {
        _movie = movie;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToTrailer() {
    if (_movie == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerScreen(
          contentId: _movie!.id,
          contentTitle: _movie!.title,
          posterUrl: ApiConstants.imageUrl(_movie!.backdropPath, width: 500),
        ),
      ),
    );
  }

  void _navigateToPlayer() {
    if (_movie == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          contentId: _movie!.id,
          contentTitle: _movie!.title,
        ),
      ),
    );
  }

  Future<void> _handleFavorite() async {
    if (_isProcessingFavorite || _movie == null) return;
    setState(() => _isProcessingFavorite = true);

    try {
      final auth = context.read<AuthProvider>();
      final favorites = context.read<FavoritesProvider>();

      if (!auth.isLoggedIn) {
        _showLoginDialog();
        return;
      }

      final id = _movie!.id.toString();
      if (favorites.isFavorited(id)) {
        await favorites.removeFavorite(id);
        SnackbarService.success(context, 'Removed from favorites');
      } else {
        await favorites.addFavorite(id);
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
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBackdropHeader() {
    if (_movie == null) return const SizedBox.shrink();
    final favorites = context.watch<FavoritesProvider>();
    final isFavorited = favorites.isFavorited(_movie!.id.toString());

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: ApiConstants.imageUrl(_movie!.backdropPath, width: 500),
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
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                _movie!.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              if (_movie!.tagline.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '"${_movie!.tagline}"',
                  style: const TextStyle(
                      color: Colors.white70, fontStyle: FontStyle.italic),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(_movie!.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 12),
                  Text(_movie!.releaseDate,
                      style: const TextStyle(color: Colors.white70)),
                  if (_movie!.runtime > 0) ...[
                    const SizedBox(width: 12),
                    Text(DateFormatter.formatRuntime(_movie!.runtime),
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGlassButton(
                      icon: Icons.play_arrow,
                      label: 'Trailer',
                      onTap: _navigateToTrailer,
                      background: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassButton(
                      icon: Icons.videocam,
                      label: 'Watch',
                      onTap: _navigateToPlayer,
                      background: Colors.blueAccent,
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
            backgroundColor: background.withValues(alpha: 0.85),
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

  Widget _buildGenreChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: _movie!.genres
            .map((g) => Chip(
                  label: Text(g),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _movie!.overview,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(height: 1.5),
      ),
    );
  }
}
