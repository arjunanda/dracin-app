import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/language_provider.dart';
import '../../home/models/series_model.dart';
import '../../series/screens/series_shorts_screen.dart';
import '../providers/watchlist_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

import '../../navigation/providers/navigation_provider.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final watchlistAsync = ref.watch(watchlistProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // Background Blobs
          if (isDark) ...[
            Positioned(
              top: -100,
              right: -100,
              child: _buildBlurBlob(AppColors.primary.withOpacity(0.1), 300),
            ),
          ],

          if (authState.status != AuthStatus.authenticated)
            _buildLoginPrompt(
              context,
              lang,
              primaryTextColor,
              secondaryTextColor,
            )
          else
            watchlistAsync.when(
              data: (watchlist) => CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Premium Header
                  SliverAppBar(
                    expandedHeight: 180,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      title: Text(
                        AppStrings.get('my_watchlist', lang),
                        style: TextStyle(
                          fontSize: 28,
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                      ),
                      background: Container(
                        padding: const EdgeInsets.only(left: 24, top: 85),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                AppStrings.get(
                                  'watchlist_subtitle',
                                  lang,
                                ).replaceAll(
                                  '{count}',
                                  watchlist.length.toString(),
                                ),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      await ref
                          .read(watchlistProvider.notifier)
                          .loadWatchlist();
                    },
                  ),

                  // Watchlist Content
                  if (watchlist.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(
                        context,
                        ref,
                        lang,
                        primaryTextColor,
                        secondaryTextColor,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildWatchlistCard(
                            context,
                            watchlist[index],
                            primaryTextColor,
                            secondaryTextColor,
                            isDark,
                          ),
                          childCount: watchlist.length,
                        ),
                      ),
                    ),
                ],
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $error',
                      style: TextStyle(color: primaryTextColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(watchlistProvider.notifier).loadWatchlist(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(
    BuildContext context,
    AppLanguage lang,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppStrings.get('login_required', lang),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.get('watchlist_login_msg', lang),
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryTextColor, fontSize: 16),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  AppStrings.get('login', lang),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    AppLanguage lang,
    Color primaryTextColor,
    Color secondaryTextColor,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_add_rounded,
              size: 80,
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppStrings.get('empty_watchlist_title', lang),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: primaryTextColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              AppStrings.get('empty_watchlist_subtitle', lang),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                ref.read(navigationProvider.notifier).state = 0;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                AppStrings.get('explore_dramas', lang),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistCard(
    BuildContext context,
    Series series,
    Color primaryTextColor,
    Color secondaryTextColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 180,
      child: Stack(
        children: [
          // Main Card Body (Glassmorphic)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.only(
                left: 140,
                right: 20,
                top: 20,
                bottom: 20,
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white.withOpacity(0.2),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    series.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
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
                                const Text(
                                  "Episode 3",
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
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 0.4,
                                backgroundColor: Colors.white.withOpacity(0.05),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                minHeight: 6,
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
                                bannerUrl: series.bannerUrl,
                                showBackButton: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Floating Image with Depth
          Positioned(
            top: 0,
            left: 16,
            child: Hero(
              tag: 'series_image_${series.id}',
              child: Container(
                width: 110,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(series.bannerUrl, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
