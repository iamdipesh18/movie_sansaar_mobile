import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/debounce.dart';
import '../../../core/services/snackbar_service.dart';
import '../../providers/search_provider.dart';
import '../../widgets/cards/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final Debounce _debounce = Debounce(duration: const Duration(milliseconds: 400));
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';
  late AnimationController _micPulseController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _controller.addListener(_onQueryChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _debounce.dispose();
    _controller.dispose();
    _speech.stop();
    _micPulseController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchProvider>().loadMore();
    }
  }

  void _onQueryChanged() {
    _debounce.call(() {
      final input = _controller.text.trim();
      if (input.isNotEmpty) {
        context.read<SearchProvider>().search(input);
      }
    });
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final request = await Permission.microphone.request();
      if (!request.isGranted) {
        SnackbarService.error(context, "Microphone permission denied");
        return;
      }
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') _stopListening();
      },
      onError: (error) {
        _stopListening();
        SnackbarService.error(context, "Speech error: ${error.errorMsg}");
      },
    );

    if (!available) {
      SnackbarService.info(context, "Speech recognition not available");
      return;
    }

    setState(() {
      _isListening = true;
      _voiceInput = '';
    });

    _speech.listen(onResult: (val) {
      setState(() => _voiceInput = val.recognizedWords);
    });
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);

    if (_voiceInput.trim().isNotEmpty) {
      _controller.text = _voiceInput;
      context.read<SearchProvider>().search(_voiceInput);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

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
              onSubmitted: (q) => searchProvider.search(q.trim()),
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
          body: _buildBody(searchProvider),
        ),
        if (_isListening) _buildMicOverlay(),
      ],
    );
  }

  Widget _buildBody(SearchProvider provider) {
    if (_controller.text.isEmpty) {
      return const Center(child: Text('Start typing or use mic to search...'));
    }

    if (provider.isLoading && provider.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.results.isEmpty) {
      return const Center(child: Text('No results found.'));
    }

    final items = provider.results;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.65,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return SearchResultCard(result: items[index]);
          },
        ),
        if (provider.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildMicOverlay() {
    return GestureDetector(
      onTap: _stopListening,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _voiceInput.isEmpty ? 'Say something' : _voiceInput,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white70, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
