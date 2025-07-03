import 'package:flutter/material.dart';
import 'package:movie_sansaar_mobile/models/search_result_model.dart';
import 'package:movie_sansaar_mobile/services/search_services.dart';
import 'package:movie_sansaar_mobile/widgets/search_result_card.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final SearchService _searchService = SearchService();

  List<SearchResult> _results = [];
  bool _isLoading = false;
  String _query = '';
  String _voiceInput = '';

  // Speech Recognition
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Animation
  late AnimationController _micPulseController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    _micPulseController.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String query) async {
    setState(() {
      _query = query.trim();
      _isLoading = true;
    });

    try {
      final results = await _searchService.searchAll(_query);
      setState(() => _results = results);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final request = await Permission.microphone.request();
      if (!request.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission denied")),
        );
        return;
      }
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          _stopListening();
        }
      },
      onError: (error) {
        _stopListening();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Speech error: ${error.errorMsg}")),
        );
      },
    );

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Speech recognition not available")),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _voiceInput = '';
    });

    _speech.listen(
      onResult: (val) {
        setState(() {
          _voiceInput = val.recognizedWords;
        });
      },
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });

    if (_voiceInput.trim().isNotEmpty) {
      _controller.text = _voiceInput;
      _onSearch(_voiceInput);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search movies or series...',
                border: InputBorder.none,
              ),
              onSubmitted: _onSearch,
              textInputAction: TextInputAction.search,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.mic),
                tooltip: 'Voice Search',
                onPressed: _startListening,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _query.isEmpty
              ? const Center(
                  child: Text('Start typing or use mic to search...'),
                )
              : _results.isEmpty
              ? const Center(child: Text('No results found.'))
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      return SearchResultCard(result: _results[index]);
                    },
                  ),
                ),
        ),

        // YouTube-style mic listening overlay
        if (_isListening)
          GestureDetector(
            onTap: _stopListening,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 1.0, end: 1.3).animate(
                        CurvedAnimation(
                          parent: _micPulseController,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.mic, size: 40, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Listening...',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _voiceInput.isEmpty ? 'Say something' : _voiceInput,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
