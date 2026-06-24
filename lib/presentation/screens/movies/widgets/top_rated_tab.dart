import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/movie_model.dart';
import '../../../providers/movie_provider.dart';
import '../../../widgets/cards/movie_card.dart';
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
      context.read<MovieProvider>().fetchTopRated();
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
      context.read<MovieProvider>().loadMoreTopRated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    if (provider.isLoading && provider.topRated.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ResponsiveGrid<Movie>(
      scrollController: _scrollController,
      items: provider.topRated,
      itemBuilder: (movie) => MovieCard(movie: movie),
      footer: provider.topRatedIsLoadingMore
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : null,
    );
  }
}
