import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesShimmerCard extends StatelessWidget {
  const FavoritesShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade900,
        ),
      ),
    );
  }
}
