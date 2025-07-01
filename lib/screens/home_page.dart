import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/widgets/drawer.dart';
import 'now_playing_screen.dart';
import 'popular_screen.dart';
import 'top_rated_screen.dart';
import 'search_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    NowPlayingScreen(),
    PopularScreen(),
    TopRatedScreen(),
  ];

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onSearchPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Sansaar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _onSearchPressed,
            tooltip: 'Search',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle),
            label: 'Now Playing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Popular',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Top Rated'),
        ],
      ),
    );
  }
}
