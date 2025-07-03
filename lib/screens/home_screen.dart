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
  late ContentType _selectedContent;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    // Initialize selected content and page controller accordingly
    _selectedContent = widget.initialContent;
    _pageController = PageController(initialPage: _selectedContent.index);
  }

  // When user swipes horizontally on the body and page changes, update the toggle UI
  void _onPageChanged(int page) {
    setState(() {
      _selectedContent = ContentType.values[page];
    });
  }

  // When user taps the toggle buttons, update the selected content and animate page change
  void _onToggleChanged(ContentType newContent) {
    setState(() {
      _selectedContent = newContent;

      // Animate the PageView to the selected page
      _pageController.animateToPage(
        newContent.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose PageController properly
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Attach your ModernDrawer here, opens on left-edge swipe or menu button tap
      drawer: const ModernDrawer(),

      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        // ContentToggle widget to switch between Movie and Series tabs
        title: ContentToggle(
          selected: _selectedContent,
          onChanged: _onToggleChanged,
        ),

        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to Search screen on search icon tap
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            tooltip: 'Search',
          ),
        ],
      ),

      // Body wrapped in PageView to enable horizontal swiping between Movies and Series screens
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          HomePage(), // Movies Home screen
          SeriesMainScreen(), // Series Home screen
        ],
      ),
    );
  }
}
