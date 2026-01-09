import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../series/models/episode_model.dart';

class PlayerScreen extends StatefulWidget {
  final Episode episode;

  const PlayerScreen({super.key, required this.episode});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();
    BetterPlayerConfiguration betterPlayerConfiguration =
        const BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          fit: BoxFit.contain,
          autoPlay: true,
          looping: false,
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableSkips: true,
            enableFullscreen: true,
            enableMute: true,
            enableProgressText: true,
            showControlsOnInitialize: false,
            backgroundColor: Colors.black26,
            controlBarColor: Colors.transparent,
          ),
        );
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.episode.videoUrl,
    );
    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _betterPlayerController.setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(child: BetterPlayer(controller: _betterPlayerController)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  // Custom Title Info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Episode ${widget.episode.episodeNumber}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.episode.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
