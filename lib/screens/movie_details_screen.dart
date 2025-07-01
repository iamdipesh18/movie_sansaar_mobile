import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import 'trailer_player_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  /// Navigate to the full trailer player screen
  void _navigateToTrailerPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerPlayerScreen(
          movieId: widget.movie.id,
          movieTitle: widget.movie.title,
          posterUrl:
              'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
        ),
      ),
    );
  }

  /// Builds the movie poster with a "Watch Trailer" button overlaid
  Widget _buildPosterWithPlayButton() {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: 'https://image.tmdb.org/t/p/w500${widget.movie.posterPath}',
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(height: 320, color: Colors.grey.shade800),
          errorWidget: (_, __, ___) =>
              Container(height: 320, color: Colors.grey.shade900),
        ),

        // Adds a dark gradient to improve text readability over image
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),

        // Watch trailer button at bottom-right
        Positioned(
          bottom: 16,
          right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('Watch Trailer'),
                onPressed: _navigateToTrailerPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.85),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Displays title, release date, rating, etc.
  Widget _buildMovieHeader(TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.movie.title,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(widget.movie.releaseDate, style: textTheme.bodyMedium),
            const SizedBox(width: 16),
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text('${widget.movie.voteAverage}', style: textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }

  /// Section for the "Overview" with description
  Widget _buildMovieOverview(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          widget.movie.overview,
          style: textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }

  /// Main body section builder
  Widget _buildContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster with trailer button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildPosterWithPlayButton(),
            ),
          ),

          // Header: Title, release date, rating
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMovieHeader(textTheme, colorScheme),
          ),

          const SizedBox(height: 24),

          // Overview section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMovieOverview(textTheme),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.title)),
      body: _buildContent(context),
    );
  }
}
