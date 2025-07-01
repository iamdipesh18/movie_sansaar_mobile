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
import '../services/series_api_service.dart';

/// A full-featured trailer player screen supporting both movies and TV series
class TrailerPlayerScreen extends StatefulWidget {
  final int contentId; // Can be a movie ID or series ID
  final String contentTitle; // Title to show on screen
  final String posterUrl; // Poster used as background / fallback
  final bool isSeries; // Whether it's a series or a movie

  const TrailerPlayerScreen({
    super.key,
    required this.contentId,
    required this.contentTitle,
    required this.posterUrl,
    this.isSeries = false, // default to movie if not specified
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
  Timer? _controlsTimer;
  Duration _resumePosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start in portrait mode
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

  /// Restore portrait mode on exit
  void _restorePortraitMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  /// Pause video when app goes background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller?.pause();
    }
  }

  /// Initializes the trailer by fetching the YouTube video key
  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt('resume_${widget.contentId}') ?? 0;
      _resumePosition = Duration(milliseconds: millis);

      // Fetch video key using the right API service
      final videoKey = widget.isSeries
          ? await SeriesApiService().fetchTrailerKey(widget.contentId)
          : await MovieApiService().fetchTrailerKey(widget.contentId);

      if (videoKey == null) {
        setState(() => _hasError = true);
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoKey,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          forceHD: true,
        ),
      )..addListener(() => setState(() {}));

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

  /// Saves current playback time to preferences
  Future<void> _saveResumeTime() async {
    if (_controller == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'resume_${widget.contentId}',
      _controller!.value.position.inMilliseconds,
    );
  }

  /// Switch between portrait and landscape
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

  /// Shimmer while loading video
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
              Container(height: 200, color: Colors.white),
              const SizedBox(height: 20),
              Container(height: 20, width: 150, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  /// Error fallback if video fails to load
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
              const Text("Trailer not available", style: TextStyle(color: Colors.white)),
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

  /// Main YouTube player with backdrop, fullscreen toggle
  Widget _buildPlayerView() {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        onEnded: (_) => _saveResumeTime(),
      ),
      builder: (context, player) {
        return Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.posterUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.6),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: player,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {
                        if (_isLandscape) {
                          _toggleOrientation();
                          await Future.delayed(const Duration(milliseconds: 300));
                        }
                        Navigator.of(context).pop();
                      },
                    ),
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

  /// Entry point of screen
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
        body: _isLoading
            ? _buildLoadingShimmer()
            : _hasError
                ? _buildErrorUI()
                : _buildPlayerView(),
      ),
    );
  }
}
