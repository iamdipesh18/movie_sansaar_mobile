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
  late Future<Series> _seriesFuture;
  final SeriesApiService _apiService = SeriesApiService();

  // Track expanded seasons and loaded episodes
  final Map<int, bool> _expandedSeasons = {};
  final Map<int, List<Episode>> _seasonEpisodes = {};
  final Map<int, bool> _loadingEpisodes = {};

  @override
  void initState() {
    super.initState();
    _seriesFuture = _apiService.fetchSeriesDetails(widget.seriesId);
  }

  void _navigateToTrailerPlayer(Series series) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrailerPlayerScreen(
          contentId: series.id,
          contentTitle: series.name,
          posterUrl: 'https://image.tmdb.org/t/p/w500${series.posterPath}',
          isSeries: true,
        ),
      ),
    );
  }

  Future<void> _loadEpisodes(int seriesId, int seasonNumber) async {
    if (_seasonEpisodes.containsKey(seasonNumber)) return; // already loaded
    setState(() {
      _loadingEpisodes[seasonNumber] = true;
    });

    try {
      final episodes = await _apiService.fetchSeasonEpisodes(
        seriesId,
        seasonNumber,
      );
      setState(() {
        _seasonEpisodes[seasonNumber] = episodes;
      });
    } catch (e) {
      // Handle error or show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load episodes for season $seasonNumber'),
        ),
      );
    } finally {
      setState(() {
        _loadingEpisodes[seasonNumber] = false;
      });
    }
  }

  Widget _buildPosterWithPlayButton(Series series) {
    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: 'https://image.tmdb.org/t/p/w500${series.posterPath}',
          height: 320,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(height: 320, color: Colors.grey.shade800),
          errorWidget: (_, __, ___) =>
              Container(height: 320, color: Colors.grey.shade900),
        ),
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
                onPressed: () => _navigateToTrailerPlayer(series),
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

  Widget _buildSeasonCard(Series series, Season season) {
    // Filter out season 0 (specials) because you requested season start at 1
    if (season.seasonNumber == 0) return const SizedBox.shrink();

    final episodes = _seasonEpisodes[season.seasonNumber] ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        key: PageStorageKey(season.seasonNumber),
        initiallyExpanded: _expandedSeasons[season.seasonNumber] ?? false,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedSeasons[season.seasonNumber] = expanded;
          });
          if (expanded && episodes.isEmpty) {
            _loadEpisodes(series.id, season.seasonNumber);
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
            ...episodes.map(_buildEpisodeTile).toList(),
        ],
      ),
    );
  }

  Widget _buildContent(Series series, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildPosterWithPlayButton(series),
          ),
          const SizedBox(height: 16),
          Text(
            series.name,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: colorScheme.primary),
              const SizedBox(width: 4),
              Text(
                series.firstAirDate.isNotEmpty ? series.firstAirDate : 'N/A',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text('${series.voteAverage}', style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Overview',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            series.overview.isNotEmpty
                ? series.overview
                : 'No overview available.',
            style: textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          if (series.seasons.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Seasons',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...series.seasons
                .map((season) => _buildSeasonCard(series, season))
                .toList(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Series Details')),
      body: FutureBuilder<Series>(
        future: _seriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Series not found'));
          }
          return _buildContent(snapshot.data!, context);
        },
      ),
    );
  }
}
