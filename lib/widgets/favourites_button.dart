import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:movie_sansaar_mobile/providers/favourites_provider.dart';

class FavoriteButton extends StatefulWidget {
  final String movieId;
  final String type;
  final VoidCallback? onUnfavorited;

  const FavoriteButton({
    super.key,
    required this.movieId,
    required this.type,
    this.onUnfavorited,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _animate() async {
    setState(() => _scale = 1.3);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => _scale = 1.0);
  }

  void _handleTap(BuildContext context, bool isFavorited) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );

    HapticFeedback.lightImpact();
    _animate();

    if (user == null) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('Please sign in to add favorites.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Future.microtask(() {
                  Navigator.of(dialogContext, rootNavigator: true).pushNamed('/signin');
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
      return;
    }

    if (isFavorited) {
      await favoritesProvider.removeFavorite(widget.movieId);
      widget.onUnfavorited?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removed from favorites')),
      );
    } else {
      await favoritesProvider.addFavorite(widget.movieId, type: widget.type);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, _) {
        final isFavorited = favoritesProvider.isFavorited(widget.movieId);
        final favoriteColor = Theme.of(context).colorScheme.primary;

        return AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.75),
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
          ),
        );
      },
    );
  }
}
