import 'package:flutter/material.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/models/series_model.dart';
import '../../screens/movies/movie_detail_screen.dart';
import '../../screens/series/series_detail_screen.dart';
import '../buttons/favorite_button.dart';

class FavoritesCard extends StatefulWidget {
  final Movie? movie;
  final Series? series;
  final VoidCallback? onUnfavorited;

  const FavoritesCard({
    super.key,
    this.movie,
    this.series,
    this.onUnfavorited,
  });

  @override
  State<FavoritesCard> createState() => _FavoritesCardState();
}

class _FavoritesCardState extends State<FavoritesCard>
    with SingleTickerProviderStateMixin {
  bool _visible = true;

  void _fadeOutAndRemove() {
    setState(() => _visible = false);
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onUnfavorited?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMovie = widget.movie != null;
    final movie = widget.movie;
    final series = widget.series;

    final imageUrl = isMovie
        ? (movie!.posterPath.isNotEmpty
            ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
            : null)
        : (series!.posterPath.isNotEmpty
            ? 'https://image.tmdb.org/t/p/w500${series.posterPath}'
            : null);

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          if (isMovie) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movie: movie!),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SeriesDetailScreen(seriesId: series!.id),
              ),
            );
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Container(
                color: Colors.grey[900],
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : const Center(child: Icon(Icons.image_not_supported)),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMovie
                        ? Colors.redAccent.withValues(alpha: 0.8)
                        : const Color(0xFF8973B3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isMovie ? 'Movie' : 'Series',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: FavoriteButton(
                  contentId: isMovie
                      ? movie!.id.toString()
                      : series!.id.toString(),
                  type: isMovie ? 'movie' : 'series',
                  onUnfavorited: _fadeOutAndRemove,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
