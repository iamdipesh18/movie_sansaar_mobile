import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/providers/series_provider.dart';
import 'package:movie_sansaar_mobile/widgets/series_card.dart';
import 'package:provider/provider.dart';
import 'series_details_screen.dart';  // Make sure the path is correct

class SeriesSearchScreen extends StatefulWidget {
  const SeriesSearchScreen({super.key});

  @override
  State<SeriesSearchScreen> createState() => _SeriesSearchScreenState();
}

class _SeriesSearchScreenState extends State<SeriesSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  void _onSearchChanged() {
    setState(() {
      _query = _controller.text;
    });
    if (_query.isNotEmpty) {
      Provider.of<SeriesProvider>(context, listen: false).searchSeries(_query);
    } else {
      // Clear search results if query is empty
      Provider.of<SeriesProvider>(context, listen: false).clearSearchResults();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seriesProvider = Provider.of<SeriesProvider>(context);
    final searchResults = seriesProvider.searchResults;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search series...',
            border: InputBorder.none,
          ),
          onChanged: (_) => _onSearchChanged(),
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Enter a series name to search'))
          : seriesProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : searchResults.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final series = searchResults[index];
                        return SeriesCard(
                          series: series,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SeriesDetailsScreen(seriesId: series.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
