import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/series_model.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/episodes_provider.dart';
import '../../home/providers/series_provider.dart';
import '../../player/screens/player_screen.dart';
import '../../../core/network/ad_service.dart';
import '../../comment/widgets/comment_section.dart';

import '../../watchlist/providers/watchlist_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

class SeriesDetailScreen extends ConsumerStatefulWidget {
  final Series series;

  const SeriesDetailScreen({super.key, required this.series});

  @override
  ConsumerState<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends ConsumerState<SeriesDetailScreen> {
  bool? _isLoved;

  @override
  void initState() {
    super.initState();
    _isLoved = widget.series.isLoved;
    _fetchWatchlistStatus();
  }

  Future<void> _fetchWatchlistStatus() async {
    try {
      final response = await ref
          .read(seriesServiceProvider)
          .getWatchlistStatus(widget.series.id);
      if (response.success && mounted) {
        setState(() {
          _isLoved = response.data;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final episodes = ref.watch(episodesProvider(widget.series.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final series = widget.series;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          // Background Blobs for Depth
          if (isDark) ...[
            Positioned(
              top: 400,
              right: -100,
              child: _buildBlurBlob(AppColors.primary.withOpacity(0.1), 300),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: _buildBlurBlob(AppColors.accent.withOpacity(0.05), 250),
            ),
          ],

          CustomScrollView(
            slivers: [
              // Cinematic Banner
              SliverAppBar(
                expandedHeight: 500,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(series.bannerUrl, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.2),
                              isDark
                                  ? AppColors.darkBackground
                                  : AppColors.lightBackground,
                            ],
                            stops: const [0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 32,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              series.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.0,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${series.episodesCount} Episodes',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: AppColors.accent,
                                      size: 22,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
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

              // Action Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
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
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 28,
                            ),
                            label: const Text(
                              'Watch Now',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final authState = ref.watch(authProvider);
                            final isAuthenticated =
                                authState.status == AuthStatus.authenticated;

                            final watchlist = ref.watch(myWatchlistProvider);
                            final inWatchlist = isAuthenticated
                                ? watchlist.maybeWhen(
                                    data: (list) => list.any(
                                      (item) => item.seriesId == series.id,
                                    ),
                                    orElse: () => false,
                                  )
                                : false;
                            final isSeriesLoved = isAuthenticated
                                ? (_isLoved ?? inWatchlist)
                                : false;

                            return IconButton(
                              onPressed: () async {
                                if (!isAuthenticated) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                  return;
                                }

                                final newState = !isSeriesLoved;
                                setState(() {
                                  _isLoved = newState;
                                });
                                try {
                                  await ref
                                      .read(seriesServiceProvider)
                                      .toggleLove(series.id, newState);
                                  // Refresh watchlist to stay in sync
                                  ref.invalidate(myWatchlistProvider);
                                } catch (e) {
                                  if (mounted) {
                                    setState(() {
                                      _isLoved = isSeriesLoved;
                                    });
                                  }
                                }
                              },
                              icon: Icon(
                                isSeriesLoved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_outline_rounded,
                                color: isSeriesLoved
                                    ? AppColors.primary
                                    : (isDark ? Colors.white : Colors.black),
                                size: 28,
                              ),
                              padding: const EdgeInsets.all(16),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Synopsis
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Synopsis'),
                      const SizedBox(height: 12),
                      Text(
                        series.description,
                        style: TextStyle(
                          color: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.7),
                          fontSize: 15,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSectionHeader('Episodes'),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Episode List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final episode = episodes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${episode.episodeNumber}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          episode.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_rounded,
                                color: Colors.white.withOpacity(0.3),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${episode.viewCount} views',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        onTap: () {
                          ref.read(adServiceProvider).showAdIfNecessary();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlayerScreen(episode: episode),
                            ),
                          );
                        },
                      ),
                    );
                  }, childCount: episodes.length),
                ),
              ),

              // Comments Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildSectionHeader('Comments'),
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.accent,
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 2.0,
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
}
