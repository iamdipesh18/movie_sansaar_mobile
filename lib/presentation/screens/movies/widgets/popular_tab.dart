import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/movie_model.dart';
import '../../../providers/movie_provider.dart';
import '../../../widgets/cards/movie_card.dart';
import '../../../widgets/common/responsive_grid.dart';

class PopularTab extends StatefulWidget {
  const PopularTab({super.key});

  @override
  State<PopularTab> createState() => _PopularTabState();
}

class _PopularTabState extends State<PopularTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().fetchPopular();
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
      context.read<MovieProvider>().loadMorePopular();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    if (provider.isLoading && provider.popular.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ResponsiveGrid<Movie>(
      scrollController: _scrollController,
      items: provider.popular,
      itemBuilder: (movie) => MovieCard(movie: movie),
      footer: provider.popularIsLoadingMore
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          : null,
    );
  }
}
