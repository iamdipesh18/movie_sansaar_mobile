import 'dart:ui';
import 'package:flutter/material.dart';
import 'widgets/airing_today_tab.dart';
import 'widgets/popular_tab.dart';
import 'widgets/top_rated_tab.dart';

typedef TabChangedCallback = void Function(int index);

class SeriesListScreen extends StatefulWidget {
  final TabChangedCallback? onTabChanged;

  const SeriesListScreen({super.key, this.onTabChanged});

  @override
  State<SeriesListScreen> createState() => SeriesListScreenState();
}

class SeriesListScreenState extends State<SeriesListScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    AiringTodayTab(),
    PopularTab(),
    TopRatedTab(),
  ];

  final List<String> _labels = const ['Airing Today', 'Popular', 'Top Rated'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void jumpToTab(int index) {
    _pageController.jumpToPage(index);
    setState(() => _selectedIndex = index);
    widget.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawerScrimColor: Colors.black.withValues(alpha: 0.6),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_labels.length, (index) {
                    final isSelected = _selectedIndex == index;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(alpha: 0.8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                _labels[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.textTheme.bodyMedium?.color,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedIndex = index);
                widget.onTabChanged?.call(index);
              },
              children: _tabs,
            ),
          ),
        ],
      ),
    );
  }
}
