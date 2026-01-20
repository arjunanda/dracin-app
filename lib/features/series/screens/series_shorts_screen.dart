import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_video_player.dart';
import '../../../core/services/admob_service.dart';
import '../providers/episodes_provider.dart';
import '../../series/models/episode_model.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/services/device_service.dart';
import '../../../core/utils/format_utils.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';

class SeriesShortsScreen extends ConsumerStatefulWidget {
  final String seriesId;
  final String title;
  final String bannerUrl;
  final bool showBackButton;
  final bool enableAds;
  final int initialIndex;

  const SeriesShortsScreen({
    super.key,
    required this.seriesId,
    required this.title,
    required this.bannerUrl,
    this.showBackButton = false,
    this.enableAds = true,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<SeriesShortsScreen> createState() => _SeriesShortsScreenState();
}

class _SeriesShortsScreenState extends ConsumerState<SeriesShortsScreen> {
  late PageController _pageController;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  // AdMob instances
  final AdMobService _adMobService = AdMobService();
  final ShortsAdManager _adManager = ShortsAdManager();
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndexNotifier.value = widget.initialIndex;

    // Force refresh episodes to get new HLS URLs
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.seriesId == 'fyp') {
        ref.invalidate(fypEpisodesProvider);
      } else {
        ref.invalidate(episodesProvider(widget.seriesId));
      }
      // Preload first ad if enabled
      if (widget.enableAds) {
        await _adMobService.loadRewardedAd();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFyp = widget.seriesId == 'fyp';
    final episodes = isFyp
        ? ref.watch(fypEpisodesProvider)
        : ref.watch(episodesProvider(widget.seriesId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          episodes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    if (isFyp) {
                      ref.invalidate(fypEpisodesProvider);
                    } else {
                      ref.invalidate(episodesProvider(widget.seriesId));
                    }
                  },
                  child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    controller: _pageController,
                    itemCount: episodes.length,
                    onPageChanged: (index) async {
                      _currentIndexNotifier.value = index;
                      _adManager.recordScroll(index);

                      // Check if we should show an ad (cumulative scrolls)
                      if (widget.enableAds &&
                          !_isLoadingAd &&
                          _adManager.shouldShowAd(index)) {
                        setState(() => _isLoadingAd = true);
                        final shown = await _adMobService.showRewardedAd(
                          onUserEarnedReward: (reward) {
                            debugPrint(
                              '🎁 User earned reward: ${reward.amount} ${reward.type}',
                            );
                          },
                        );
                        if (shown) {
                          _adManager.onAdShown(index);
                        }
                        setState(() => _isLoadingAd = false);
                      }
                    },
                    itemBuilder: (context, index) {
                      final episode = episodes[index];
                      return ValueListenableBuilder<int>(
                        valueListenable: _currentIndexNotifier,
                        builder: (context, currentIndex, _) {
                          return _ShortVideoItem(
                            key: ValueKey(episode.id),
                            episode: episode,
                            shouldPlay: index == currentIndex && !_isLoadingAd,
                            shouldLoad:
                                index == currentIndex ||
                                index == currentIndex + 1,
                            totalEpisodes: episodes.length,
                            seriesId: widget.seriesId,
                            seriesTitle: widget.title,
                            bannerUrl: widget.bannerUrl,
                            onLike: () {
                              if (isFyp) {
                                ref
                                    .read(fypEpisodesProvider.notifier)
                                    .toggleLike(episode.id);
                              } else {
                                ref
                                    .read(
                                      episodesProvider(
                                        widget.seriesId,
                                      ).notifier,
                                    )
                                    .toggleLike(episode.id);
                              }
                            },
                            onView: () async {
                              final deviceId = await DeviceService()
                                  .getDeviceId();
                              if (isFyp) {
                                ref
                                    .read(fypEpisodesProvider.notifier)
                                    .recordView(episode.id, deviceId);
                                ref
                                    .read(fypEpisodesProvider.notifier)
                                    .refreshLikeStatus(episode.id);
                              } else {
                                ref
                                    .read(
                                      episodesProvider(
                                        widget.seriesId,
                                      ).notifier,
                                    )
                                    .recordView(episode.id, deviceId);
                                ref
                                    .read(
                                      episodesProvider(
                                        widget.seriesId,
                                      ).notifier,
                                    )
                                    .refreshLikeStatus(episode.id);
                              }
                            },
                            pageController: _pageController,
                          );
                        },
                      );
                    },
                  ),
                ),

          // Top Gradient Overlay (Subtle)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Back Button & Title Overlay
          Positioned(
            top: 40,
            left: widget.showBackButton ? 8 : 20,
            right: 16,
            child: Row(
              children: [
                if (widget.showBackButton) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                ] else if (isFyp) ...[
                  Image.asset(
                    'assets/logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: IgnorePointer(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentIndexNotifier,
                      builder: (context, currentIndex, _) {
                        return Text(
                          episodes.isNotEmpty && currentIndex < episodes.length
                              ? 'Episode ${episodes[currentIndex].episodeNumber}'
                              : widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ),
                ),
                // Add a spacer to ensure we don't overlap with the player's top-right buttons
                const SizedBox(width: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortVideoItem extends ConsumerStatefulWidget {
  final Episode episode;
  final bool shouldPlay;
  final bool shouldLoad;
  final int totalEpisodes;
  final String seriesId;
  final String seriesTitle;
  final String bannerUrl;
  final VoidCallback onLike;
  final VoidCallback onView;
  final PageController pageController;

  const _ShortVideoItem({
    super.key,
    required this.episode,
    required this.shouldPlay,
    required this.shouldLoad,
    required this.totalEpisodes,
    required this.seriesId,
    required this.seriesTitle,
    required this.bannerUrl,
    required this.onLike,
    required this.onView,
    required this.pageController,
  });

  @override
  ConsumerState<_ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends ConsumerState<_ShortVideoItem>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

  // Local state to prevent blinking
  bool? _localIsLiked;
  int? _localLikeCount;
  bool _isLockingLike = false;
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _likeController, curve: Curves.easeInOut),
        );

    if (widget.shouldPlay) {
      widget.onView();
    }
  }

  @override
  void didUpdateWidget(_ShortVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPlay && !oldWidget.shouldPlay) {
      widget.onView();
    }

    // If the episode changed, reset local state
    if (widget.episode.id != oldWidget.episode.id) {
      _localIsLiked = null;
      _localLikeCount = null;
      _isLockingLike = false;
      _lockTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _likeController.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  void _handleLike() {
    final authState = ref.read(authProvider);
    print('AUTH_DEBUG: Like clicked. Current Status: ${authState.status}');

    if (authState.status != AuthStatus.authenticated) {
      print('AUTH_DEBUG: Not authenticated, showing popup');
      _showLoginRequiredDialog();
      return;
    }

    final currentIsLiked = _localIsLiked ?? widget.episode.isLiked;
    final currentCount = _localLikeCount ?? widget.episode.likeCount;

    setState(() {
      _localIsLiked = !currentIsLiked;
      _localLikeCount = _localIsLiked! ? currentCount + 1 : currentCount - 1;
      if (_localLikeCount! < 0) _localLikeCount = 0;
      _isLockingLike = true;
    });

    // Trigger animation
    if (_localIsLiked!) {
      _likeController.forward(from: 0.0);
    }

    // Call provider
    widget.onLike();

    // Lock local state for 3 seconds to ignore background refreshes
    _lockTimer?.cancel();
    _lockTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLockingLike = false;
        });
      }
    });
  }

  void _showLoginRequiredDialog() {
    final lang = ref.read(languageProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        title: Text(
          AppStrings.get('login_required', lang),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        content: Text(
          AppStrings.get('watchlist_login_msg', lang),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.get('cancel', lang),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(AppStrings.get('login', lang)),
          ),
        ],
      ),
    );
  }

  bool get _isLiked => _isLockingLike
      ? (_localIsLiked ?? widget.episode.isLiked)
      : widget.episode.isLiked;

  int get _likeCount => _isLockingLike
      ? (_localLikeCount ?? widget.episode.likeCount)
      : widget.episode.likeCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video Player Area (Top)
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: !widget.shouldLoad
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : CustomVideoPlayer(
                          key: ValueKey(widget.episode.id),
                          sources: [
                            VideoSource(
                              label: 'Auto',
                              url: widget.episode.hlsMasterUrl,
                            ),
                            ...widget.episode.renditions.map(
                              (r) =>
                                  VideoSource(label: r.resolution, url: r.url),
                            ),
                          ],
                          subtitles: widget.episode.subtitles
                              .map(
                                (s) =>
                                    SubtitleSource(label: s.lang, url: s.file),
                              )
                              .toList(),
                          autoPlay: widget.shouldPlay,
                          aspectRatio: 9 / 16,
                          forceAspectRatio: true,
                          alignment: Alignment.center,
                          scale: 1.08,
                          fit: BoxFit.contain,
                          showDefaultProgressBar: false,
                          onControllerInitialized: (controller) {
                            if (mounted) {
                              Future.microtask(() {
                                if (mounted) {
                                  setState(() {
                                    _videoController = controller;
                                  });
                                }
                              });
                            }
                          },
                          onControllerWillDispose: () {
                            if (mounted) {
                              Future.microtask(() {
                                if (mounted) {
                                  setState(() {
                                    _videoController = null;
                                  });
                                }
                              });
                            }
                          },
                        ),
                ),
              ),

              // Episode Info (Absolute over video)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 80, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Judul Drama (Diatasnya Judul)
                        Text(
                          widget.episode.seriesTitle ?? widget.seriesTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19, // Slightly larger for prominence
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.9),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // 2. Episode Saja (Dibawahnya)
                        Text(
                          'Episode ${widget.episode.episodeNumber}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Side Actions (TikTok Style) - Positioned relative to video area
              Positioned(
                right: 12,
                bottom: 20,
                child: RepaintBoundary(
                  child: Column(
                    children: [
                      _buildSideAction(
                        icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                        label: FormatUtils.formatNumber(_likeCount),
                        color: _isLiked
                            ? const Color(0xFFFFD700)
                            : Colors.white,
                        animation: _likeAnimation,
                        onTap: _handleLike,
                      ),
                      const SizedBox(height: 20),
                      _buildSideAction(
                        icon: Icons.share,
                        label: 'Share',
                        color: Colors.white,
                        onTap: _showShareBottomSheet,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Bar (Total Episodes & Progress) - Not Positioned
        RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom Progress Bar & Total Episodes Container
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background Container for Total Episodes
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showEpisodesBottomSheet(
                            widget.pageController,
                            widget.episode.episodesCount ??
                                widget.totalEpisodes,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.video_library,
                                color: AppColors.accent,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Total ${widget.episode.episodesCount ?? widget.totalEpisodes} Episode',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  // Interactive Progress Bar
                  if (_videoController != null)
                    Positioned(
                      top: -16,
                      left: -15,
                      right: -15,
                      child: _buildCustomProgressBar(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEpisodesBottomSheet(
    PageController pageController,
    int totalEpisodes,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Header with Banner and Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.episode.seriesBannerUrl ?? widget.bannerUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[900],
                                child: const Icon(
                                  Icons.movie,
                                  color: Colors.white24,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.episode.seriesTitle ?? widget.seriesTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${widget.episode.episodesCount ?? totalEpisodes} Episodes',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Select an episode to watch',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white10, height: 1),
              // Episode Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: widget.episode.episodesCount ?? totalEpisodes,
                  itemBuilder: (context, index) {
                    final isCurrent = widget.episode.episodeNumber == index + 1;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.seriesId == 'fyp') {
                          // If in FYP, navigate to the specific drama's shorts screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeriesShortsScreen(
                                seriesId: widget.episode.seriesId,
                                title: widget.episode.seriesTitle ?? '',
                                bannerUrl: widget.episode.seriesBannerUrl ?? '',
                                showBackButton: true,
                                initialIndex: index,
                              ),
                            ),
                          );
                        } else {
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.accent
                                : Colors.white.withOpacity(0.1),
                            width: isCurrent ? 2 : 1,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent
                                ? AppColors.accent
                                : Colors.white70,
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSideAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    Animation<double>? animation,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: animation != null
                ? ScaleTransition(
                    scale: animation,
                    child: Icon(icon, color: color, size: 30),
                  )
                : Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final lang = ref.watch(languageProvider);
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('share_to', lang),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 32),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildShareOption(
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                    ),
                    _buildShareOption(
                      icon: FontAwesomeIcons.instagram,
                      label: 'Instagram',
                      color: const Color(0xFFE4405F),
                    ),
                    _buildShareOption(
                      icon: FontAwesomeIcons.telegram,
                      label: 'Telegram',
                      color: const Color(0xFF0088CC),
                    ),
                    _buildShareOption(
                      icon: FontAwesomeIcons.facebook,
                      label: 'Facebook',
                      color: const Color(0xFF1877F2),
                    ),
                    _buildShareOption(
                      icon: FontAwesomeIcons.link,
                      label: AppStrings.get('copy_link', lang),
                      color: Colors.grey,
                    ),
                    _buildShareOption(
                      icon: FontAwesomeIcons.ellipsis,
                      label: 'More',
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.withOpacity(0.1),
                  ),
                  child: Text(
                    AppStrings.get('cancel', lang),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomProgressBar() {
    return _InteractiveProgressBar(
      key: ValueKey(widget.episode.id),
      controller: _videoController!,
      activeColor: AppColors.primary,
      accentColor: AppColors.accent,
    );
  }
}

class _InteractiveProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final Color activeColor;
  final Color accentColor;

  const _InteractiveProgressBar({
    super.key,
    required this.controller,
    required this.activeColor,
    required this.accentColor,
  });

  @override
  State<_InteractiveProgressBar> createState() =>
      _InteractiveProgressBarState();
}

class _InteractiveProgressBarState extends State<_InteractiveProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, VideoPlayerValue value, child) {
        if (!value.isInitialized) return const SizedBox.shrink();

        final duration = value.duration.inMilliseconds.toDouble();
        final position = value.position.inMilliseconds.toDouble();
        final progress = duration > 0 ? position / duration : 0.0;

        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: widget.activeColor,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: widget.accentColor,
            overlayColor: widget.accentColor.withOpacity(0.2),
            trackShape: const RectangularSliderTrackShape(),
          ),
          child: Slider(
            value: (_isDragging ? _dragValue : progress).clamp(0.0, 1.0),
            onChangeStart: (val) {
              setState(() {
                _isDragging = true;
                _dragValue = val;
              });
            },
            onChanged: (val) {
              setState(() {
                _dragValue = val;
              });
            },
            onChangeEnd: (val) {
              final newPosition = Duration(
                milliseconds: (val * duration).toInt(),
              );
              widget.controller.seekTo(newPosition).then((_) {
                if (mounted) {
                  setState(() {
                    _isDragging = false;
                  });
                }
              });
            },
          ),
        );
      },
    );
  }
}
