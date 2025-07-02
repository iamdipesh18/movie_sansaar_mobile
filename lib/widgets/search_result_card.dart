import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_sansaar_mobile/models/movie.dart';

import '../models/search_result_model.dart';

import '../screens/movies/movie_details_screen.dart';
import '../screens/series/series_details_screen.dart';

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
                builder: (_) => MovieDetailsScreen(
                  movie: Movie.minimal(
                    id: result.id,
                    title: result.title,
                    posterPath: result.posterPath,
                    backdropPath: '', // Or result.backdropPath if available
                    voteAverage: 0.0,
                    releaseDate: result.releaseDate ?? '',
                    overview: result.overview ?? '',
                  ),
                ),
              ),
            );
          } else if (result.type == ContentType.series) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeriesDetailsScreen(seriesId: result.id),
              ),
            );
          }
        },

        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Poster image fills the card
              AspectRatio(
                aspectRatio: 2 / 3, // typical poster ratio
                child: CachedNetworkImage(
                  imageUrl: result.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey.shade300),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // Positioned content type chip at top left
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: result.type == ContentType.movie
                        ? Colors.redAccent.withOpacity(0.8)
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
