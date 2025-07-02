import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/providers/series_provider.dart';
import 'package:movie_sansaar_mobile/widgets/series_card.dart';
import 'package:provider/provider.dart';

class TopRatedSeriesScreen extends StatefulWidget {
  const TopRatedSeriesScreen({super.key});

  @override
  State<TopRatedSeriesScreen> createState() => _TopRatedSeriesScreenState();
}

class _TopRatedSeriesScreenState extends State<TopRatedSeriesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch top-rated series on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SeriesProvider>(context, listen: false).fetchTopRated();
    });
  }

  /// Adjust number of columns for responsive grid
  int _calculateCrossAxisCount(double width) {
    if (width >= 1200) return 6;
    if (width >= 1000) return 5;
    if (width >= 800) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final seriesProvider = Provider.of<SeriesProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);

    if (seriesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (seriesProvider.errorMessage != null) {
      return Center(child: Text(seriesProvider.errorMessage!));
    }

    final topRatedList = seriesProvider.topRated;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.builder(
        itemCount: topRatedList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.6,
        ),
        itemBuilder: (context, index) {
          final series = topRatedList[index];
          return SeriesCard(series: series);
        },
      ),
    );
  }
}
