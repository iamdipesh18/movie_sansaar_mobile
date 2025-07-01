import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/providers/series_provider.dart';
import 'package:movie_sansaar_mobile/widgets/series_card.dart';
import 'package:provider/provider.dart';

import 'series_details_screen.dart';

class PopularSeriesScreen extends StatefulWidget {
  const PopularSeriesScreen({super.key});

  @override
  State<PopularSeriesScreen> createState() => _PopularSeriesScreenState();
}

class _PopularSeriesScreenState extends State<PopularSeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SeriesProvider>(context, listen: false).fetchPopular();
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

    final popularList = seriesProvider.popular;

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: popularList.length,
      itemBuilder: (context, index) {
        final series = popularList[index];
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
