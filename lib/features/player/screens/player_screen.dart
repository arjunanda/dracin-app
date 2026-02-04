import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../series/models/episode_model.dart';
import '../../../core/widgets/custom_video_player.dart';
import '../../../core/network/ad_service.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Episode episode;

  const PlayerScreen({super.key, required this.episode});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final isAnyAdShowing = ref.watch(isAnyAdShowingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: CustomVideoPlayer(
              sources: [
                VideoSource(label: 'Auto', url: widget.episode.hlsMasterUrl),
                ...widget.episode.renditions.map(
                  (r) => VideoSource(label: r.resolution, url: r.url),
                ),
              ],
              subtitles: widget.episode.subtitles
                  .map((s) => SubtitleSource(label: s.lang, url: s.file))
                  .toList(),
              autoPlay: !isAnyAdShowing,
              aspectRatio: 16 / 9,
            ),
          ),
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
                            color: AppColors.accent,
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
