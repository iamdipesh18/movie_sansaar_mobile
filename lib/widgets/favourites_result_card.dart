import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/models/movie.dart';
import 'package:movie_sansaar_mobile/models/series.dart';
import 'package:movie_sansaar_mobile/screens/movies/movie_details_screen.dart';
import 'package:movie_sansaar_mobile/screens/series/series_details_screen.dart';
import 'package:movie_sansaar_mobile/widgets/favourites_button.dart';

class FavoritesResultCard extends StatefulWidget {
  final Movie? movie;
  final Series? series;
  final VoidCallback? onUnfavorited;

  const FavoritesResultCard({
    super.key,
    this.movie,
    this.series,
    this.onUnfavorited, required MaterialColor iconColor,
  });

  @override
  State<FavoritesResultCard> createState() => _FavoritesResultCardState();
}

class _FavoritesResultCardState extends State<FavoritesResultCard>
    with SingleTickerProviderStateMixin {
  bool _visible = true;

  void _fadeOutAndRemove() {
    setState(() => _visible = false);
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onUnfavorited?.call();
    });
  }

  @override
  // Widget build(BuildContext context) {
  //   final isMovie = widget.movie != null;
  //   final item = isMovie ? widget.movie! : widget.series!;
  //   final imageUrl = item.posterPath.isNotEmpty
  //       ? 'https://image.tmdb.org/t/p/w500${item.posterPath}'
  //       : null;
  //   return AnimatedOpacity(
  //     opacity: _visible ? 1.0 : 0.0,
  //     duration: const Duration(milliseconds: 300),
  //     child: GestureDetector(
  //       onTap: () {
  //         if (isMovie) {
  //           Navigator.of(context).push(MaterialPageRoute(
  //             builder: (_) => MovieDetailsScreen(movie: widget.movie!),
  //           ));
  //         } else {
  //           Navigator.of(context).push(MaterialPageRoute(
  //             builder: (_) => SeriesDetailsScreen(seriesId: widget.series!.id),
  //           ));
  //         }
  //       },
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: Stack(
  //           children: [
  //             Container(
  //               color: Colors.grey[900],
  //               child: imageUrl != null
  //                   ? Image.network(
  //                       imageUrl,
  //                       width: double.infinity,
  //                       height: double.infinity,
  //                       fit: BoxFit.cover,
  //                     )
  //                   : const Center(child: Icon(Icons.image_not_supported)),
  //             ),
  //             Positioned(
  //               top: 8,
  //               left: 8,
  //               child: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: isMovie
  //                       ? Colors.redAccent.withOpacity(0.8)
  //                       : const Color(0xFF8973B3),
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: Text(
  //                   isMovie ? 'Movie' : 'Series',
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Positioned(
  //               bottom: 8,
  //               right: 8,
  //               child: FavoriteButton(
  //                 movieId: item.id.toString(),
  //                 type: isMovie ? 'movie' : 'series',
  //                 onUnfavorited: _fadeOutAndRemove,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    final bool isMovie = widget.movie != null;

    // Declare typed variables for movie or series to access their fields safely
    final Movie? movie = widget.movie;
    final Series? series = widget.series;

    final String? imageUrl = isMovie
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
                builder: (_) => MovieDetailsScreen(movie: movie!),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SeriesDetailsScreen(seriesId: series!.id),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMovie
                        ? Colors.redAccent.withOpacity(0.8)
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
                  movieId: isMovie
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
