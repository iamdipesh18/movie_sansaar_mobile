import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/screens/movies/movies_home_screen.dart';
import 'package:movie_sansaar_mobile/screens/search_screen.dart';
import 'package:movie_sansaar_mobile/screens/series/series_home_screen.dart';
import 'package:movie_sansaar_mobile/widgets/content_toggle_widget.dart';
import 'package:movie_sansaar_mobile/widgets/drawer.dart';
import '../models/content_type.dart';

class HomeScreen extends StatefulWidget {
  final ContentType initialContent;

  const HomeScreen({super.key, this.initialContent = ContentType.movie});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  int _movieInnerPageIndex = 0;
  int _seriesInnerPageIndex = 0;

  final GlobalKey<MoviesHomeScreenState> _moviesKey = GlobalKey();
  final GlobalKey<SeriesMainScreenState> _seriesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialContent == ContentType.movie ? 0 : 1;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onToggleChanged(ContentType newContent) {
    final newIndex = newContent == ContentType.movie ? 0 : 1;
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onMovieInnerPageChanged(int index) {
    _movieInnerPageIndex = index;
  }

  void _onSeriesInnerPageChanged(int index) {
    _seriesInnerPageIndex = index;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    const velocityThreshold = 500;

    if (velocity > velocityThreshold) {
      // Swipe Right → Go to Movies from Series
      if (_currentIndex == 1 && _seriesInnerPageIndex == 0) {
        _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        _moviesKey.currentState?.jumpToPage(2); // Top Rated
      }
    } else if (velocity < -velocityThreshold) {
      // Swipe Left → Go to Series from Movies
      if (_currentIndex == 0 && _movieInnerPageIndex == 2) {
        _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        _seriesKey.currentState?.jumpToPage(0); // Airing Today
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ModernDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: ContentToggle(
          selected: _currentIndex == 0 ? ContentType.movie : ContentType.series,
          onChanged: _onToggleChanged,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const ClampingScrollPhysics(),
          children: [
            MoviesHomeScreen(
              key: _moviesKey,
              onInnerPageChanged: _onMovieInnerPageChanged,
            ),
            SeriesMainScreen(
              key: _seriesKey,
              onInnerPageChanged: _onSeriesInnerPageChanged,
            ),
          ],
        ),
      ),
    );
  }
}
