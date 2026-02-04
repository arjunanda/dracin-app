import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../player/screens/player_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/widgets/premium_upgrade_dialog.dart';
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
          style: const TextStyle(
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
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(episodesProvider(seriesId).notifier)
                    .loadEpisodes();
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: episodes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final e = episodes[index];
                  final user = ref.read(authProvider).user;
                  final isUserPremium = user?.isPremium ?? false;
                  final isWatched = e.isWatched;

                  return ListTile(
                    onTap: () {
                      if (e.isPremium && !isUserPremium) {
                        showDialog(
                          context: context,
                          builder: (context) => const PremiumUpgradeDialog(),
                        );
                        return;
                      }
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
                                .withOpacity(isWatched ? 0.05 : 0.1),
                      ),
                    ),
                    leading: Opacity(
                      opacity: isWatched ? 0.6 : 1.0,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(thumbnailUrl),
                          ),
                          if (e.isPremium && !isUserPremium)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.workspace_premium,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Episode ${e.episodeNumber}: ${e.title}',
                            style: TextStyle(
                              color: isWatched
                                  ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white38
                                        : Colors.black38)
                                  : null,
                              fontWeight: (e.isPremium && !isUserPremium)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isWatched)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'SELESAI',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary.withOpacity(0.5),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (e.isPremium && !isUserPremium)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('${e.viewCount} views'),
                    trailing: Icon(
                      e.isPremium && !isUserPremium
                          ? Icons.lock_outline
                          : Icons.play_arrow,
                      color: e.isPremium && !isUserPremium
                          ? Colors.grey
                          : AppColors.primary,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
