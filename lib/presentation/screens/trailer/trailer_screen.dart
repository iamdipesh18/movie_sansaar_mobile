import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/repositories/movie_repository.dart';
import '../../../data/repositories/series_repository.dart';
import '../player/player_screen.dart';

class TrailerScreen extends StatefulWidget {
  final int contentId;
  final String contentTitle;
  final String posterUrl;
  final bool isSeries;

  const TrailerScreen({
    super.key,
    required this.contentId,
    required this.contentTitle,
    required this.posterUrl,
    this.isSeries = false,
  });

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  final MovieRepository _movieRepo = MovieRepository();
  final SeriesRepository _seriesRepo = SeriesRepository();

  bool _isLoading = true;
  bool _hasError = false;
  bool _noTrailer = false;
  bool _isLandscape = false;
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fetchTrailerKey();
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

  Future<void> _fetchTrailerKey() async {
    try {
      final videoKey = widget.isSeries
          ? await _seriesRepo.getTrailerKey(widget.contentId)
          : await _movieRepo.getTrailerKey(widget.contentId);

      if (videoKey == null) {
        if (mounted) setState(() => _noTrailer = true);
        return;
      }

      if (mounted) {
        setState(() {
          _videoUrl =
              'https://m.youtube.com/watch?v=$videoKey&autoplay=1';
          _isLoading = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
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

  void _navigateToPlayer() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          contentId: widget.contentId,
          contentTitle: widget.contentTitle,
          isSeries: widget.isSeries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        if (_isLandscape) _toggleOrientation();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _noTrailer
            ? _buildMessageUI("Trailer not available")
            : _hasError
                ? _buildMessageUI("Unable to load trailer")
                : _buildPlayerView(),
      ),
    );
  }

  Widget _buildMessageUI(String message) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.posterUrl,
          fit: BoxFit.cover,
          color: Colors.black.withValues(alpha: 0.7),
          colorBlendMode: BlendMode.darken,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _noTrailer = false;
                    _videoUrl = null;
                  });
                  _fetchTrailerKey();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _navigateToPlayer,
                icon: const Icon(Icons.videocam),
                label: Text(widget.isSeries ? 'Watch S1E1' : 'Watch Movie'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerView() {
    final bool showWebView = _videoUrl != null && !_hasError;

    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: widget.posterUrl,
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.6),
            colorBlendMode: BlendMode.darken,
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: showWebView
                    ? InAppWebView(
                        key: ValueKey(_videoUrl),
                        initialUrlRequest:
                            URLRequest(url: WebUri(_videoUrl!)),
                        initialSettings: InAppWebViewSettings(
                          javaScriptEnabled: true,
                          mediaPlaybackRequiresUserGesture: false,
                          allowsInlineMediaPlayback: true,
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
                      )
                    : _buildLoadingShimmer(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _navigateToPlayer,
                icon: const Icon(Icons.videocam),
                label: Text(widget.isSeries ? 'Watch Series' : 'Watch Movie'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading && showWebView)
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

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade700,
      highlightColor: Colors.grey.shade500,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
