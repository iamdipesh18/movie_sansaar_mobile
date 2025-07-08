import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/widgets/drawer.dart';
import 'airing_today_series_screen.dart';
import 'popular_series_screen.dart';
import 'top_rated_series_screen.dart';

typedef PageChangedCallback = void Function(int index);

class SeriesMainScreen extends StatefulWidget {
  final PageChangedCallback? onInnerPageChanged;

  const SeriesMainScreen({super.key, this.onInnerPageChanged});

  @override
  State<SeriesMainScreen> createState() => SeriesMainScreenState();
}

class SeriesMainScreenState extends State<SeriesMainScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AiringTodaySeriesScreen(),
    PopularSeriesScreen(),
    TopRatedSeriesScreen(),
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

  void _onTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onInnerPageChanged?.call(index);
  }

  void jumpToPage(int index) {
    _pageController.jumpToPage(index);
    setState(() {
      _selectedIndex = index;
    });
    widget.onInnerPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawerScrimColor: Colors.black.withOpacity(0.6),
      drawer: const ModernDrawer(),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
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
                          onTap: () => _onTap(index),
                          hoverColor: theme.colorScheme.primary.withOpacity(0.2),
                          splashColor: theme.colorScheme.primary.withOpacity(0.3),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.8)
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
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
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
              onPageChanged: _onPageChanged,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
