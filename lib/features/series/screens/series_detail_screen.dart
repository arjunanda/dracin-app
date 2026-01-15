import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/series_model.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/episodes_provider.dart';
import '../../home/providers/series_provider.dart';
import '../../player/screens/player_screen.dart';
import '../../../core/network/ad_service.dart';
import '../../comment/widgets/comment_section.dart';

class SeriesDetailScreen extends ConsumerWidget {
  final Series series;

  const SeriesDetailScreen({super.key, required this.series});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodes = ref.watch(episodesProvider(series.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Cinematic Banner
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(series.thumbnailUrl, fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          series.title,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 32,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${series.episodesCount} Episodes',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '4.8',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (episodes.isNotEmpty) {
                              ref.read(adServiceProvider).showAdIfNecessary();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlayerScreen(episode: episodes.first),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Watch Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filledTonal(
                        onPressed: () {
                          ref
                              .read(seriesServiceProvider)
                              .toggleLove(series.id, !series.isLoved);
                        },
                        icon: Icon(
                          series.isLoved
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: series.isLoved ? Colors.red : null,
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Synopsis',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    series.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Episodes',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Episode List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final episode = episodes[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${episode.episodeNumber}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  episode.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  episode.duration != null
                      ? '${episode.duration! ~/ 60}m ${episode.duration! % 60}s'
                      : 'Premium',
                ),
                trailing: const Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary,
                ),
                onTap: () {
                  ref.read(adServiceProvider).showAdIfNecessary();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerScreen(episode: episode),
                    ),
                  );
                },
              );
            }, childCount: episodes.length),
          ),

          // Comments Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CommentSection(seriesId: series.id),
                ],
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
