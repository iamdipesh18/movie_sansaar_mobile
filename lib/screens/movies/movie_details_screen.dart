import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/movie.dart';
import '../../services/movie_api_service.dart';
import '../trailer_player_screen.dart';
import '../../services/auth_service.dart';
import '../../providers/favourites_provider.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie; // Initial lightweight movie object (from list screen)

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  Movie? _movie; // Holds full movie details after API call
  bool _isLoading = true;
  bool _isProcessingFavorite = false; // To prevent multiple taps

  @override
  void initState() {
    super.initState();
    _loadFullMovieDetails();
  }

  // Fetches full movie details from TMDB
  Future<void> _loadFullMovieDetails() async {
    try {
      final fullMovie = await MovieApiService().fetchMovieDetails(
        widget.movie.id,
      );
      setState(() {
        _movie = fullMovie;
        _isLoading = false;
      });
      // No need to set favorite here, provider will manage that
    } catch (e) {
      debugPrint('Error loading movie details: $e');
      setState(() => _isLoading = false);
    }
  }

  // Navigate to trailer screen
  void _navigateToTrailerPlayer() {
    if (_movie == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerPlayerScreen(
          contentId: _movie!.id,
          contentTitle: _movie!.title,
          posterUrl: 'https://image.tmdb.org/t/p/w500${_movie!.posterPath}',
          isSeries: false,
        ),
      ),
    );
  }

  /// Floating back button placed over the header
  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12, // adjusts below status bar
      left: 12,
      child: CircleAvatar(
        backgroundColor: Colors.black54,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Favorite button placed on the top right corner
  Widget _buildFavoriteButton() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isLoggedIn = authService.currentUser != null;

    // Get favorite state from provider directly
    final isFavorited = _movie != null
        ? favoritesProvider.isFavorited(_movie!.id.toString())
        : false;

    Future<void> handleFavoriteTap() async {
      if (_isProcessingFavorite) return; // Prevent multiple taps

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
          await favoritesProvider.removeFavorite(_movie!.id.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from favorites')),
          );
        } else {
          await favoritesProvider.addFavorite(_movie!.id.toString());
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

  // Build the large backdrop with overlay content (title, tagline, buttons)
  Widget _buildBackdropHeader() {
    if (_movie == null) return const SizedBox.shrink();

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://image.tmdb.org/t/p/original${_movie!.backdropPath}',
          height: 450,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // Dark gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),
        ),
        _buildBackButton(),
        _buildFavoriteButton(), // Favorite button here
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _movie!.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_movie!.tagline.isNotEmpty)
                Text(
                  '"${_movie!.tagline}"',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade400, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _movie!.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _movie!.releaseDate,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatRuntime(_movie!.runtime),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildGlassButton(
                    icon: Icons.play_arrow,
                    label: 'Trailer',
                    onTap: _navigateToTrailerPlayer,
                    background: Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  // Add more buttons here if needed
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Blurred glass-style button
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
            backgroundColor: background.withOpacity(0.85),
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

  // Convert minutes to readable runtime format (e.g. 2h 30m)
  String _formatRuntime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  // Title section (e.g. "Genres")
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

  // Overview content
  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _movie!.overview,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  // Genre chips row
  Widget _buildGenreChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: _movie!.genres
            .map(
              (genre) => Chip(
                label: Text(genre),
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            )
            .toList(),
      ),
    );
  }

  // Full scrollable content
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
