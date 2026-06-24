import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/series_model.dart';
import '../../../providers/series_provider.dart';
import '../../../widgets/cards/series_card.dart';
import '../../../widgets/common/responsive_grid.dart';

class AiringTodayTab extends StatefulWidget {
  const AiringTodayTab({super.key});

  @override
  State<AiringTodayTab> createState() => _AiringTodayTabState();
}

class _AiringTodayTabState extends State<AiringTodayTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().fetchAiringToday();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SeriesProvider>().loadMoreAiringToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeriesProvider>();

    if (provider.isLoading && provider.airingToday.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.airingToday.isEmpty) {
      return Center(child: Text(provider.error!));
    }

    return ResponsiveGrid<Series>(
      scrollController: _scrollController,
      items: provider.airingToday,
      itemBuilder: (series) => SeriesCard(series: series),
      footer: provider.airingTodayIsLoadingMore
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : null,
    );
  }
}
