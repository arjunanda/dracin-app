import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/language_provider.dart';
import '../../home/models/series_model.dart';

import '../../series/screens/series_shorts_screen.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Dummy Watchlist Data
    final List<Series> watchlist = [
      Series(
        id: '1',
        title: 'The Silent Sea',
        description:
            'A space mission to the moon to retrieve samples from an abandoned research station.',
        thumbnailUrl: 'https://picsum.photos/seed/series_1/800/1200',
        episodesCount: 8,
        isLoved: true,
      ),
      Series(
        id: '2',
        title: 'All of Us Are Dead',
        description:
            'A high school becomes ground zero for a zombie virus outbreak.',
        thumbnailUrl: 'https://picsum.photos/seed/series_2/800/1200',
        episodesCount: 12,
        isLoved: true,
      ),
      Series(
        id: '3',
        title: 'Squid Game',
        description:
            'Hundreds of cash-strapped players accept a strange invitation to compete in children\'s games.',
        thumbnailUrl: 'https://picsum.photos/seed/series_3/800/1200',
        episodesCount: 9,
        isLoved: true,
      ),
      Series(
        id: '4',
        title: 'Kingdom',
        description:
            'While strange rumors about their ill King grip a kingdom, the crown prince becomes their only hope against a mysterious plague.',
        thumbnailUrl: 'https://picsum.photos/seed/series_4/800/1200',
        episodesCount: 12,
        isLoved: true,
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // Background Blobs for Depth
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: _buildBlurBlob(AppColors.accent.withOpacity(0.1), 250),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: _buildBlurBlob(Colors.purple.withOpacity(0.05), 300),
            ),
          ],

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverAppBar(
                expandedHeight: 170,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  title: Text(
                    AppStrings.get('my_watchlist', lang),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 24,
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  background: Container(
                    padding: const EdgeInsets.only(left: 20, top: 75),
                    child: Text(
                      AppStrings.get(
                        'watchlist_subtitle',
                        lang,
                      ).replaceAll('{count}', watchlist.length.toString()),
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.4 * 255).toInt()),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Watchlist Content
              if (watchlist.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context, lang))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildWatchlistCard(context, watchlist[index]),
                      childCount: watchlist.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLanguage lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.03 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: 80,
              color: AppColors.accent.withAlpha((0.2 * 255).toInt()),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppStrings.get('empty_watchlist_title', lang),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.get('empty_watchlist_subtitle', lang),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha((0.4 * 255).toInt()),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              elevation: 10,
              shadowColor: AppColors.accent.withAlpha((0.4 * 255).toInt()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              AppStrings.get('explore_dramas', lang),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(BuildContext context, Series series) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 175,
      child: Stack(
        children: [
          // Main Card Body (Glassmorphic)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 130,
                    right: 20,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              series.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: Colors.white.withOpacity(0.3),
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        series.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.4),
                          height: 1.4,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Ep 3",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      " / ${series.episodesCount}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.3),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.4,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.05,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accent,
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SeriesShortsScreen(
                                    seriesId: series.id,
                                    title: series.title,
                                    thumbnailUrl: series.thumbnailUrl,
                                    showBackButton: true,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating Image with Depth
          Positioned(
            top: 0,
            left: 12,
            child: Hero(
              tag: 'series_image_${series.id}',
              child: Container(
                width: 105,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(series.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
