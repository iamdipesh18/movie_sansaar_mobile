import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/series_model.dart';
import '../../../providers/series_provider.dart';
import '../../../widgets/cards/series_card.dart';
import '../../../widgets/common/responsive_grid.dart';

class TopRatedTab extends StatefulWidget {
  const TopRatedTab({super.key});

  @override
  State<TopRatedTab> createState() => _TopRatedTabState();
}

class _TopRatedTabState extends State<TopRatedTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().fetchTopRated();
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
      context.read<SeriesProvider>().loadMoreTopRated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeriesProvider>();

    if (provider.isLoading && provider.topRated.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.topRated.isEmpty) {
      return Center(child: Text(provider.error!));
    }

    return ResponsiveGrid<Series>(
      scrollController: _scrollController,
      items: provider.topRated,
      itemBuilder: (series) => SeriesCard(series: series),
      footer: provider.topRatedIsLoadingMore
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : null,
    );
  }
}
