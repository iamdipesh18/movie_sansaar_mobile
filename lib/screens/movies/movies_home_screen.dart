import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/widgets/drawer.dart';
import 'now_playing_screen.dart';
import 'popular_screen.dart';
import 'top_rated_screen.dart';
import '../search_screen.dart';

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

  final List<String> _labels = const ['Now Playing', 'Popular', 'Top Rated'];

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawerScrimColor: Colors.black.withOpacity(0.6),
      drawer: const AppDrawer(),

      // // Modern-style centered AppBar title
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: Hero(
      //     tag: 'movies',
      //     child: Material(
      //       color: Colors.transparent,
      //       child: Text(
      //         'Movies',
      //         style: theme.textTheme.titleLarge?.copyWith(
      //           color: theme.appBarTheme.foregroundColor,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.search),
      //       onPressed: _onSearchPressed,
      //       tooltip: 'Search',
      //     ),
      //   ],
      //   elevation: 0,
      // ),

      // Section Selector (Now Playing, Popular, Top Rated)
      body: Column(
        children: [
          // Blurred background selector bar
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
                      child: GestureDetector(
                        onTap: () => _onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
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
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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

          // Animated screen transition
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation);
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              key: ValueKey<int>(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
