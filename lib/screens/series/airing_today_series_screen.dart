import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/providers/series_provider.dart';
import 'package:movie_sansaar_mobile/widgets/series_card.dart';
import 'package:provider/provider.dart';
import 'series_details_screen.dart';

class AiringTodaySeriesScreen extends StatefulWidget {
  const AiringTodaySeriesScreen({super.key});

  @override
  State<AiringTodaySeriesScreen> createState() =>
      _AiringTodaySeriesScreenState();
}

class _AiringTodaySeriesScreenState extends State<AiringTodaySeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SeriesProvider>(context, listen: false).fetchAiringToday();
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

    final airingTodayList = seriesProvider.airingToday;

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: airingTodayList.length,
      itemBuilder: (context, index) {
        final series = airingTodayList[index];
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
