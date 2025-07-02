// lib/screens/working_stream_screen.dart
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class WorkingStreamScreen extends StatefulWidget {
  final String title;

  const WorkingStreamScreen({super.key, required this.title});

  @override
  State<WorkingStreamScreen> createState() => _WorkingStreamScreenState();
}

class _WorkingStreamScreenState extends State<WorkingStreamScreen> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    // A clean and reliable demo MP4 URL (free to use)
    final videoUrl =
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      subtitles: [
        BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: "English",
          urls: [
            "https://raw.githubusercontent.com/johnsonas/demo-subs/main/bbb-en.vtt",
          ],
        ),
      ],
    );

    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        fullScreenByDefault: true,
        allowedScreenSleep: false,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePlaybackSpeed: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Watch: ${widget.title}")),
      body: AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(controller: _betterPlayerController),
      ),
    );
  }
}
