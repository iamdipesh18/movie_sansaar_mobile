import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:movie_sansaar_mobile/providers/favourites_provider.dart';

/// A button widget to toggle favorite status of a movie or series.
///
/// Requires the `movieId` (or item id) and the content `type` ("movie" or "series").
/// It listens to the favorite state and updates the UI accordingly.
///
/// If the user is not logged in, it prompts to sign in before adding favorites.
class FavoriteButton extends StatelessWidget {
  final String movieId; // The ID of the movie or series to favorite/unfavorite
  final String type; // The type of content: "movie" or "series"

  const FavoriteButton({super.key, required this.movieId, required this.type});

  /// Handles the tap on the favorite button.
  ///
  /// Checks if the user is logged in. If not, shows a login dialog.
  /// If logged in, toggles the favorite status accordingly.
  void _handleTap(BuildContext context, bool isFavorited) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );

    if (user == null) {
      // User is not logged in, show login dialog
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please sign in to add favorites.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Future.microtask(() {
                  // Navigate to sign-in screen after dialog closes
                  Navigator.of(
                    dialogContext,
                    rootNavigator: true,
                  ).pushNamed('/signin');
                });
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
      return; // Exit early since user is not logged in
    }

    // User is logged in, toggle favorite status
    if (isFavorited) {
      // Remove from favorites
      favoritesProvider.removeFavorite(movieId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from favorites')));
    } else {
      // Add to favorites, passing the content type
      favoritesProvider.addFavorite(movieId, type: type);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isFavorited = favoritesProvider.isFavorited(movieId);
        final favoriteColor = Theme.of(context).colorScheme.primary;

        return CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surface.withOpacity(0.75),
          child: IconButton(
            tooltip: isFavorited ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited
                  ? favoriteColor
                  : Theme.of(context).iconTheme.color,
            ),
            onPressed: () => _handleTap(context, isFavorited),
          ),
        );
      },
    );
  }
}
