// lib/screens/series/series_details_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_sansaar_mobile/models/season_and_episode.dart';
import '../../models/series.dart';
import '../../services/series_api_service.dart';
import '../trailer_player_screen.dart';

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

  // State maps to track expanded seasons and episodes loaded
  final Map<int, bool> _expandedSeasons = {};
  final Map<int, List<Episode>> _seasonEpisodes = {};
  final Map<int, bool> _loadingEpisodes = {};

  @override
  void initState() {
    super.initState();
    _loadFullSeriesDetails();
  }

  /// Fetches full series detail from TMDB (includes videos, credits, seasons, genres)
  Future<void> _loadFullSeriesDetails() async {
    try {
      final data = await _apiService.fetchFullDetails(widget.seriesId);
      setState(() {
        _series = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading series details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Navigate to the trailer player screen
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

  /// Loads episodes for a specific season if not loaded yet
  Future<void> _loadEpisodes(int seriesId, int seasonNumber) async {
    if (_seasonEpisodes.containsKey(seasonNumber)) return; // Already loaded

    setState(() => _loadingEpisodes[seasonNumber] = true);

    try {
      final episodes = await _apiService.fetchEpisodes(seriesId, seasonNumber);
      setState(() => _seasonEpisodes[seasonNumber] = episodes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load episodes for season $seasonNumber'),
        ),
      );
    } finally {
      setState(() => _loadingEpisodes[seasonNumber] = false);
    }
  }

  /// Floating back button overlay on backdrop image
  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
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

  /// Backdrop header with gradient, title, rating, language, and trailer button
  Widget _buildBackdropHeader() {
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
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.85),
                ],
              ),
            ),
          ),
        ),
        _buildBackButton(),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Show Status and First Air Date in a row
              Row(
                children: [
                  // You can add a chip or text for status if you add it in Series model
                  // For now just showing firstAirDate and original language
                  Text(
                    'First Air: ${_series!.firstAirDate}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(width: 12),
                  // Original Language if you add this to Series model
                  // For now skipping, or show a placeholder like 'en'
                  // Text(
                  //   'Language: ${_series!.originalLanguage.toUpperCase()}',
                  //   style: const TextStyle(color: Colors.white70),
                  // ),
                ],
              ),

              const SizedBox(height: 8),

              // Genres as chips
              // SizedBox(
              //   height: 30,
              //   child: ListView(
              //     scrollDirection: Axis.horizontal,
              //     children: _series!.genres.map((genre) {
              //       return Container(
              //         margin: const EdgeInsets.only(right: 8),
              //         child: Chip(
              //           label: Text(genre.name),
              //           backgroundColor: Colors.grey.shade200,
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _series!.genres.map((genre) {
                    return Chip(
                      label: Text(
                        genre.name,
                        style: TextStyle(
                          color: Colors
                              .red
                              .shade700, // use Colors.red instead of redAccent
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: Colors.red.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade400, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _series!.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  _buildGlassButton(
                    icon: Icons.play_arrow,
                    label: 'Trailer',
                    onTap: _navigateToTrailerPlayer,
                    background: Colors.redAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Blurred glass-style button (reusable)
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

  /// Section title widget (e.g. "Overview", "Seasons")
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

  /// Overview text block
  Widget _buildOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _series!.overview,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  /// Builds season expansion card with episodes inside
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

  /// Builds episode tile inside season expansion
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
      ),
      trailing: Text(episode.airDate.isNotEmpty ? episode.airDate : ''),
    );
  }

  /// Main scrollable content for series details
  Widget _buildContent() {
    return ListView(
      children: [
        _buildBackdropHeader(),
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
}
