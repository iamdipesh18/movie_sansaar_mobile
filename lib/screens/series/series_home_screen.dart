import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/screens/series/airing_today_series_screen.dart';
import 'package:movie_sansaar_mobile/screens/series/popular_series_screen.dart';
import 'package:movie_sansaar_mobile/screens/series/top_rated_series_screen.dart';
import 'package:movie_sansaar_mobile/widgets/drawer.dart';
import 'series_search_screen.dart'; // We'll create this soon

class SeriesMainScreen extends StatefulWidget {
  const SeriesMainScreen({super.key});

  @override
  State<SeriesMainScreen> createState() => _SeriesMainScreenState();
}

class _SeriesMainScreenState extends State<SeriesMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    AiringTodaySeriesScreen(),
    PopularSeriesScreen(),
    TopRatedSeriesScreen(),
  ];

  static const List<String> _titles = ['Airing Today', 'Popular', 'Top Rated'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to the search screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SeriesSearchScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(), // your existing drawer widget
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Airing Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Popular',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Top Rated'),
        ],
      ),
    );
  }
}
