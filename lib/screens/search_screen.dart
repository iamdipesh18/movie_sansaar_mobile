import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/models/search_result_model.dart';
import 'package:movie_sansaar_mobile/services/search_services.dart';
import 'package:movie_sansaar_mobile/widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _searchService = SearchService();

  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _query = '';

  /// Called when the user submits a search query
  /// Fetches combined movie and series results asynchronously
  void _onSearch(String query) async {
    setState(() {
      _query = query.trim();
      _isLoading = true; // Show loading spinner
    });

    try {
      final results = await _searchService.searchAll(query);
      setState(() {
        _results = results; // Update UI with fetched results
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      setState(() => _isLoading = false); // Hide loading spinner
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up controller when screen disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search movies or series...',
            border: InputBorder.none,
          ),
          onSubmitted: _onSearch, // Trigger search on submit
          textInputAction: TextInputAction.search,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : _query.isEmpty
          ? const Center(
              child: Text('Start typing to search...'),
            ) // Prompt to type
          : _results.isEmpty
          ? const Center(child: Text('No results found.')) // No matches found
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              // Display results in a grid with 2 columns
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio:
                      0.65, // Adjust card aspect ratio (width/height)
                ),
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  // Using your SearchResultCard widget for each item
                  return SearchResultCard(result: result);
                },
              ),
            ),
    );
  }
}
