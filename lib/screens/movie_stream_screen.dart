// lib/screens/movie_stream_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class MovieStreamScreen extends StatefulWidget {
  final int movieId;
  final String title;

  const MovieStreamScreen({
    super.key,
    required this.movieId,
    required this.title,
  });

  @override
  State<MovieStreamScreen> createState() => _MovieStreamScreenState();
}

class _MovieStreamScreenState extends State<MovieStreamScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true; // Indicates if we're still checking sources/loading
  bool _movieAvailable = false; // True if a working stream URL is found
  String? _finalUrl; // The selected streaming URL to load in WebView

  // List of streaming embed base URLs to try in order
  final List<String> _embedSources = [
    'https://vidsrc.to/embed/movie/',
    'https://multiembed.mov/?video_id=',
    'https://2embed.org/embed/',
  ];

  /// Checks each embed source URL for movie availability by
  /// fetching the page and verifying if it contains an iframe or video tag
  Future<void> _checkAllSources() async {
    for (String base in _embedSources) {
      // Construct URL depending on source URL format
      final url = base.contains('multiembed')
          ? '$base${widget.movieId}&tmdb=1'
          : '$base${widget.movieId}';

      try {
        final res = await http.get(Uri.parse(url));

        if (res.statusCode == 200 && !res.body.contains('404')) {
          // Check for actual player tags in HTML response
          if (res.body.contains('<iframe') || res.body.contains('<video')) {
            setState(() {
              _finalUrl = url;
              _movieAvailable = true;
            });
            return; // Stop checking once a valid source is found
          }
        }
      } catch (e) {
        // Ignore errors and try next source
        continue;
      }
    }
    // No valid source found
    setState(() => _movieAvailable = false);
  }

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController with navigation delegate
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Intercept navigation requests to block unsupported URL schemes
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;

            // Block intent:// and market:// URL schemes that cause ERR_UNKNOWN_URL_SCHEME
            if (url.startsWith('intent://') || url.startsWith('market://')) {
              debugPrint('Blocked unsupported URL scheme: $url');
              return NavigationDecision.prevent; // Prevent loading these URLs
            }

            // Allow all other URLs to load normally
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) => debugPrint('Page started loading: $url'),
          onPageFinished: (url) => debugPrint('Page finished loading: $url'),
          onWebResourceError: (error) {
            debugPrint('Web resource error: ${error.description}');
          },
        ),
      );

    // Check for available streaming URLs, then load the first valid one
    _checkAllSources().then((_) {
      if (_movieAvailable && _finalUrl != null) {
        _webViewController.loadRequest(Uri.parse(_finalUrl!));
      }
      setState(() => _isLoading = false);
    });
  }

  /// Optional: Log stream failures for debugging or analytics
  void _logFailure() {
    debugPrint('Stream failed for TMDB ID: ${widget.movieId}');
    // Extend to send this info to Firebase or other analytics if needed
  }

  /// Shows an error screen if no valid stream was found
  Widget _buildErrorScreen() {
    _logFailure();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Movie not available from any source.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// Shows a modal loading dialog while searching for streams
  Widget _buildLoader() {
    return const Center(
      child: Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Finding best stream..."),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Watch: ${widget.title}')),
      body: _isLoading
          ? _buildLoader()
          : !_movieAvailable
          ? _buildErrorScreen()
          : WebViewWidget(controller: _webViewController),
    );
  }
}
