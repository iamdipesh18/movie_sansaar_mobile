import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/snackbar_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';

class FavoriteButton extends StatefulWidget {
  final String contentId;
  final String type;
  final VoidCallback? onUnfavorited;

  const FavoriteButton({
    super.key,
    required this.contentId,
    required this.type,
    this.onUnfavorited,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _animate() {
    setState(() => _scale = 1.3);
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _scale = 1.0);
    });
  }

  Future<void> _handleTap(bool isFavorited) async {
    final auth = context.read<AuthProvider>();
    final favorites = context.read<FavoritesProvider>();

    HapticFeedback.lightImpact();
    _animate();

    if (!auth.isLoggedIn) {
      _showLoginDialog();
      return;
    }

    if (isFavorited) {
      await favorites.removeFavorite(widget.contentId);
      widget.onUnfavorited?.call();
      SnackbarService.success(context, 'Removed from favorites');
    } else {
      await favorites.addFavorite(widget.contentId, type: widget.type);
      SnackbarService.success(context, 'Added to favorites');
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please sign in to add favorites.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(ctx, rootNavigator: true).pushNamed('/signin');
            },
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        final isFavorited = provider.isFavorited(widget.contentId);

        return AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.75),
            child: IconButton(
              tooltip: isFavorited
                  ? 'Remove from favorites'
                  : 'Add to favorites',
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited
                    ? Colors.red
                    : Colors.red.withValues(alpha: 0.4),
              ),
              onPressed: () => _handleTap(isFavorited),
            ),
          ),
        );
      },
    );
  }
}
