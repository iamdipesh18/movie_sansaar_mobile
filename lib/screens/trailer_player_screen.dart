// 📂 trailer_player_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/movie_api_service.dart';

class TrailerPlayerScreen extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String posterUrl;

  const TrailerPlayerScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.posterUrl,
  });

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen>
    with WidgetsBindingObserver {
  YoutubePlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isLandscape = false;
  late MovieApiService _apiService;
  Timer? _controlsTimer;
  Duration _resumePosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apiService = MovieApiService();

    // Force portrait mode at the start
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _initializePlayer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controlsTimer?.cancel();
    _controller?.dispose();
    _restorePortraitMode();
    super.dispose();
  }

  void _restorePortraitMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller?.pause();
    }
  }

  // Initializes YouTube player with resume time
  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt('resume_${widget.movieId}') ?? 0;
      _resumePosition = Duration(milliseconds: millis);

      final videoKey = await _apiService.fetchTrailerKey(widget.movieId);

      if (videoKey == null) {
        setState(() => _hasError = true);
        return;
      }

      _controller =
          YoutubePlayerController(
            initialVideoId: videoKey,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              enableCaption: true,
              forceHD: true,
            ),
          )..addListener(() {
            setState(() {});
          });

      await Future.delayed(const Duration(milliseconds: 300));

      if (_resumePosition.inMilliseconds > 0) {
        _controller?.seekTo(_resumePosition);
      }
    } catch (e) {
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Save video resume position using SharedPreferences
  Future<void> _saveResumeTime() async {
    if (_controller == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'resume_${widget.movieId}',
      _controller!.value.position.inMilliseconds,
    );
  }

  // Toggle screen orientation between portrait & landscape
  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);

    if (_isLandscape) {
      // Enter full landscape mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Return to portrait
      _restorePortraitMode();
    }
  }

  // Shimmer shown while trailer is loading
  Widget _buildLoadingShimmer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade700,
          highlightColor: Colors.grey.shade500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Container(height: 20, width: 150, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Fallback UI if trailer fetch fails
  Widget _buildErrorUI() {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.posterUrl,
          fit: BoxFit.cover,
          color: Colors.black.withOpacity(0.7),
          colorBlendMode: BlendMode.darken,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              const Text(
                "Trailer not available",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _initializePlayer,
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Actual YouTube player with controls and orientation toggle
  Widget _buildPlayerView() {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        onEnded: (meta) => _saveResumeTime(),
      ),
      builder: (context, player) {
        return Stack(
          children: [
            // Background poster with dim
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.posterUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.6),
                colorBlendMode: BlendMode.darken,
              ),
            ),

            // YouTube Player in fixed 16:9 box
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(controller: _controller!),
              ),
            ),

            // Top controls: Back on the left, Toggle on the right
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔙 Back Button (left side)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {
                        if (_isLandscape) {
                          _toggleOrientation();
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                        }
                        Navigator.of(context).pop();
                      },
                    ),

                    // 🔄 Orientation Toggle (right side)
                    IconButton(
                      icon: Icon(
                        _isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLandscape) {
          _toggleOrientation();
          await Future.delayed(const Duration(milliseconds: 300));
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: null, // AppBar not needed due to custom controls
        body: _isLoading
            ? _buildLoadingShimmer()
            : _hasError
            ? _buildErrorUI()
            : _buildPlayerView(),
      ),
    );
  }
}
