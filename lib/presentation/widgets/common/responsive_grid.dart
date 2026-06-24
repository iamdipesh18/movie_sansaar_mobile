import 'package:flutter/material.dart';

class ResponsiveGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final ScrollController? scrollController;
  final Widget? footer;

  const ResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.footer,
  });

  int _crossAxisCount(double width) {
    if (width >= 1200) return 6;
    if (width >= 1000) return 5;
    if (width >= 800) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _crossAxisCount(MediaQuery.of(context).size.width);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => itemBuilder(items[index]),
              childCount: items.length,
            ),
          ),
          if (footer != null)
            SliverToBoxAdapter(child: footer!),
        ],
      ),
    );
  }
}
