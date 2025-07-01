import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/config/api_endpoint.dart';
import '../models/series.dart';
import '../screens/series/series_details_screen.dart';

/// A reusable card widget to display a single TV series in a vertical list.
///
/// Matches the visual style of [MovieCard].
/// - Shows poster, name, air date, and overview.
/// - Taps navigate to [SeriesDetailsScreen] by default.
/// - Optionally allows overriding tap behavior via [onTap].
class SeriesCard extends StatelessWidget {
  final Series series;

  /// Optional custom tap handler. If null, defaults to opening [SeriesDetailsScreen].
  final VoidCallback? onTap;

  const SeriesCard({super.key, required this.series, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          onTap ??
          () {
            // Default behavior: Navigate to details screen with seriesId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeriesDetailsScreen(seriesId: series.id),
              ),
            );
          },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Series poster
            Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    '${ApiEndpoints.imageBaseUrl}${series.posterPath}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Series information
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Series name
                    Text(
                      series.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // First air date
                    Text(
                      series.firstAirDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    // Overview
                    Text(
                      series.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
