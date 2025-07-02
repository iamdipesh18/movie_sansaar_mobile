// home_screen.dart

import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/screens/movies/movies_home_screen.dart';
import 'package:movie_sansaar_mobile/screens/search_screen.dart';
import 'package:movie_sansaar_mobile/screens/series/series_home_screen.dart';
import 'package:movie_sansaar_mobile/widgets/content_toggle_widget.dart';
import 'package:movie_sansaar_mobile/widgets/drawer.dart';
import '../models/content_type.dart';

class HomeScreen extends StatefulWidget {
  final ContentType initialContent;

  const HomeScreen({Key? key, this.initialContent = ContentType.movie})
    : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ContentType _selectedContent;

  @override
  void initState() {
    super.initState();
    _selectedContent = widget.initialContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: ContentToggle(
          selected: _selectedContent,
          onChanged: (newSelection) {
            setState(() {
              _selectedContent = newSelection;
            });
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
                Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SearchScreen()),
  );
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: _selectedContent == ContentType.movie
          ? const HomePage()
          : const SeriesMainScreen(),
    );
  }
}
