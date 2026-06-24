import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/content_type.dart';
import '../../../data/models/search_result.dart';
import '../../../data/models/movie_model.dart';
import '../../screens/movies/movie_detail_screen.dart';
import '../../screens/series/series_detail_screen.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;

  const SearchResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: GestureDetector(
        onTap: () {
          if (result.type == ContentType.movie) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(
                  movie: Movie.minimal(
                    id: result.id,
                    title: result.title,
                    posterPath: result.posterPath,
                    voteAverage: result.rating,
                    releaseDate: result.releaseDate,
                    overview: result.overview,
                  ),
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SeriesDetailScreen(seriesId: result.id),
              ),
            );
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: CachedNetworkImage(
                  imageUrl: result.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade300),
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.broken_image,
                        color: Colors.white, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: result.type == ContentType.movie
                        ? Colors.redAccent.withValues(alpha: 0.8)
                        : const Color(0xFF8973B3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result.type == ContentType.movie ? 'Movie' : 'Series',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
