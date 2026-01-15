import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../player/screens/player_screen.dart';
import '../providers/episodes_provider.dart';

class SeriesEpisodesScreen extends ConsumerWidget {
  final String seriesId;
  final String title;
  final String thumbnailUrl;

  const SeriesEpisodesScreen({
    super.key,
    required this.seriesId,
    required this.title,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(episodesProvider(seriesId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.accent,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      body: episodes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: episodes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final e = episodes[index];
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(episode: e),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withOpacity(0.1),
                    ),
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(thumbnailUrl),
                  ),
                  title: Text('Episode ${e.episodeNumber}: ${e.title}'),
                  subtitle: e.duration != null
                      ? Text('${(e.duration! / 60).floor()} min')
                      : null,
                  trailing: const Icon(Icons.play_arrow),
                );
              },
            ),
    );
  }
}
