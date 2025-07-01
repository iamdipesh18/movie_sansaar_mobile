import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/providers/series_provider.dart';
import 'package:movie_sansaar_mobile/widgets/series_card.dart';
import 'package:provider/provider.dart';
import 'series_details_screen.dart';  // Import your details screen

class TopRatedSeriesScreen extends StatefulWidget {
  const TopRatedSeriesScreen({super.key});

  @override
  State<TopRatedSeriesScreen> createState() => _TopRatedSeriesScreenState();
}

class _TopRatedSeriesScreenState extends State<TopRatedSeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SeriesProvider>(context, listen: false).fetchTopRated();
    });
  }

  @override
  Widget build(BuildContext context) {
    final seriesProvider = Provider.of<SeriesProvider>(context);

    if (seriesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (seriesProvider.errorMessage != null) {
      return Center(child: Text(seriesProvider.errorMessage!));
    }

    final topRatedList = seriesProvider.topRated;

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: topRatedList.length,
      itemBuilder: (context, index) {
        final series = topRatedList[index];
        return SeriesCard(
          series: series,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeriesDetailsScreen(seriesId: series.id),
              ),
            );
          },
        );
      },
    );
  }
}
