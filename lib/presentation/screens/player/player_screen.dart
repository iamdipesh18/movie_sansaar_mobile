import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PlayerScreen extends StatefulWidget {
  final int contentId;
  final String contentTitle;
  final bool isSeries;
  final int seasonNumber;
  final int episodeNumber;

  const PlayerScreen({
    super.key,
    required this.contentId,
    required this.contentTitle,
    this.isSeries = false,
    this.seasonNumber = 1,
    this.episodeNumber = 1,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLandscape = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _restorePortraitMode();
    super.dispose();
  }

  void _restorePortraitMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  String _buildUrl() {
    if (widget.isSeries) {
      return 'https://vidsrc.to/embed/tv/${widget.contentId}/${widget.seasonNumber}/${widget.episodeNumber}';
    }
    return 'https://vidsrc.to/embed/movie/${widget.contentId}';
  }

  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);
    if (_isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      _restorePortraitMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        if (_isLandscape) _toggleOrientation();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _hasError ? _buildErrorUI() : _buildPlayerView(),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text('Unable to load player',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isLoading = true;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerView() {
    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_buildUrl())),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            domStorageEnabled: true,
          ),
          onLoadStart: (controller, url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onLoadStop: (controller, url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onReceivedError: (controller, request, error) {
            if (request.isForMainFrame == true && mounted) {
              setState(() => _hasError = true);
            }
          },
          onReceivedServerTrustAuthRequest:
              (controller, challenge) async {
            return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED,
            );
          },
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    if (_isLandscape) _toggleOrientation();
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  widget.contentTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: Icon(
                    _isLandscape
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: _toggleOrientation,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
