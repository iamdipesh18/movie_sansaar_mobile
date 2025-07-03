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

  // For detecting the current inner page index of Movies or Series (NowPlaying/Popular/TopRated)
  int _movieInnerPageIndex = 0;
  int _seriesInnerPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize main page index based on initial content type
    _currentIndex = widget.initialContent == ContentType.movie ? 0 : 1;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Clean up controller resources
    super.dispose();
  }

  // Called when swiping between Movies and Series top-level pages
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Called when user toggles Movies/Series using ContentToggle widget
  void _onToggleChanged(ContentType newContent) {
    final newIndex = newContent == ContentType.movie ? 0 : 1;
    _pageController.animateToPage(
      newIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Called by MoviesHomeScreen when inner page changes
  void _onMovieInnerPageChanged(int index) {
    _movieInnerPageIndex = index;
  }

  // Called by SeriesMainScreen when inner page changes
  void _onSeriesInnerPageChanged(int index) {
    _seriesInnerPageIndex = index;
  }

  // Custom swipe detector to handle cross-page swipes between Movies and Series
  void _handleHorizontalDrag(DragUpdateDetails details) {
    final dx = details.delta.dx;

    // Sensitivity threshold for swipe detection
    const sensitivity = 10;

    if (dx > sensitivity) {
      // Swipe right (move to previous tab/page)
      if (_currentIndex == 1) {
        // Currently on Series
        if (_seriesInnerPageIndex == 0) {
          // If at first inner tab in Series, swipe right should go to last Movies inner tab (Top Rated)
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          // Also notify MoviesHomeScreen to set inner tab to last (handled inside MoviesHomeScreen)
        } else {
          // Otherwise, inner swipe right within Series tabs is handled inside SeriesMainScreen
        }
      } else {
        // Currently on Movies — inner swipes handled inside MoviesHomeScreen
      }
    } else if (dx < -sensitivity) {
      // Swipe left (move to next tab/page)
      if (_currentIndex == 0) {
        // Currently on Movies
        if (_movieInnerPageIndex == 2) {
          // If at last inner tab in Movies, swipe left should go to first Series inner tab (Airing Today)
          _pageController.animateToPage(
            1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          // Also notify SeriesMainScreen to set inner tab to first (handled inside SeriesMainScreen)
        } else {
          // Otherwise, inner swipe left handled inside MoviesHomeScreen
        }
      } else {
        // Currently on Series — inner swipes handled inside SeriesMainScreen
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

      // GestureDetector wraps PageView to detect horizontal swipes
      body: GestureDetector(
        onHorizontalDragUpdate: _handleHorizontalDrag,
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const ClampingScrollPhysics(),
          children: [
            // Pass callbacks to get inner page changes
            MoviesHomeScreen(
              onInnerPageChanged: _onMovieInnerPageChanged,
              jumpToPage: (index) {
                // For when user swipes from Series → Movies and you want to set inner tab
                // Will be handled inside MoviesHomeScreen
              },
            ),
            SeriesMainScreen(
              onInnerPageChanged: _onSeriesInnerPageChanged,
              jumpToPage: (index) {
                // For when user swipes from Movies → Series and want to set inner tab
                // Will be handled inside SeriesMainScreen
              },
            ),
          ],
        ),
      ),
    );
  }
}
