import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/snackbar_service.dart';
import '../../../data/models/content_type.dart';
import '../movies/movie_list_screen.dart';
import '../series/series_list_screen.dart';
import '../search/search_screen.dart';
import '../../widgets/navigation/app_drawer.dart';
import '../../widgets/navigation/content_toggle.dart';

class HomeScreen extends StatefulWidget {
  final ContentType initialContent;

  const HomeScreen({super.key, this.initialContent = ContentType.movie});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  int _movieTabIndex = 0;
  int _seriesTabIndex = 0;
  DateTime? _lastBackPressed;

  final GlobalKey<MovieListScreenState> _moviesKey = GlobalKey();
  final GlobalKey<SeriesListScreenState> _seriesKey = GlobalKey();

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

  void _onToggleChanged(ContentType type) {
    final index = type == ContentType.movie ? 0 : 1;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    const threshold = 500;

    if (velocity > threshold && _currentIndex == 1 && _seriesTabIndex == 0) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _moviesKey.currentState?.jumpToTab(2);
    } else if (velocity < -threshold &&
        _currentIndex == 0 &&
        _movieTabIndex == 2) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _seriesKey.currentState?.jumpToTab(0);
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      SnackbarService.info(context, 'Press back again to exit');
      return false;
    }
    await SystemNavigator.pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final contentType = _currentIndex == 0 ? ContentType.movie : ContentType.series;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: ContentToggle(
            selected: contentType,
            onChanged: _onToggleChanged,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              tooltip: 'Search',
            ),
          ],
        ),
        body: GestureDetector(
          onHorizontalDragEnd: _handleDragEnd,
          child: PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            physics: const ClampingScrollPhysics(),
            children: [
              MovieListScreen(
                key: _moviesKey,
                onTabChanged: (i) => _movieTabIndex = i,
              ),
              SeriesListScreen(
                key: _seriesKey,
                onTabChanged: (i) => _seriesTabIndex = i,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
