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

class SeriesShortsScreen extends ConsumerStatefulWidget {
  final String seriesId;
  final String title;
  final String thumbnailUrl;
  final bool showBackButton;
  final bool enableAds;

  const SeriesShortsScreen({
    super.key,
    required this.seriesId,
    required this.title,
    required this.thumbnailUrl,
    this.showBackButton = false,
    this.enableAds = true,
  });

  @override
  ConsumerState<SeriesShortsScreen> createState() => _SeriesShortsScreenState();
}

class _SeriesShortsScreenState extends ConsumerState<SeriesShortsScreen> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

  // AdMob instances
  final AdMobService _adMobService = AdMobService();
  final ShortsAdManager _adManager = ShortsAdManager();
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    // Force refresh episodes to get new HLS URLs
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.invalidate(episodesProvider(widget.seriesId));
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
    final episodes = ref.watch(episodesProvider(widget.seriesId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Content
          episodes.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(episodesProvider(widget.seriesId));
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
                            episode: episode,
                            shouldPlay: index == currentIndex && !_isLoadingAd,
                            totalEpisodes: episodes.length,
                            seriesId: widget.seriesId,
                            seriesTitle: widget.title,
                            thumbnailUrl: widget.thumbnailUrl,
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
  final int totalEpisodes;
  final String seriesId;
  final String seriesTitle;
  final String thumbnailUrl;

  const _ShortVideoItem({
    required this.episode,
    required this.shouldPlay,
    required this.totalEpisodes,
    required this.seriesId,
    required this.seriesTitle,
    required this.thumbnailUrl,
  });

  @override
  ConsumerState<_ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends ConsumerState<_ShortVideoItem>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isLiked = false;
  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

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
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Player
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomVideoPlayer(
              key: ValueKey(widget.episode.id),
              sources: [
                VideoSource(label: 'Auto', url: widget.episode.videoUrl),
              ],
              subtitles: const [
                SubtitleSource(label: 'Indonesia', url: ''),
                SubtitleSource(label: 'English', url: ''),
              ],
              autoPlay: widget.shouldPlay,
              aspectRatio: 9 / 16,
              fit: BoxFit.cover,
              showDefaultProgressBar: false,
              onControllerInitialized: (controller) {
                if (mounted) {
                  setState(() {
                    _videoController = controller;
                  });
                }
              },
            ),
          ),
        ),

        // Side Actions (TikTok Style)
        Positioned(
          right: 12,
          bottom: 120,
          child: RepaintBoundary(
            child: Column(
              children: [
                _buildSideAction(
                  icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                  label: '1.2k',
                  color: _isLiked ? const Color(0xFFFFD700) : Colors.white,
                  animation: _likeAnimation,
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                      _likeController.forward(from: 0.0);
                    });
                  },
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

        // Episode Info (Bottom)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Episode ${widget.episode.episodeNumber}',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    widget.episode.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                // Custom Progress Bar & Total Episodes Container
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background Container for Total Episodes (Not clickable)
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
                          // Only this part is clickable
                          GestureDetector(
                            onTap: _showEpisodesBottomSheet,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.video_library,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Total ${widget.totalEpisodes} Episode',
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
                    // Interactive Progress Bar (Slidable & Clickable)
                    if (_videoController != null)
                      Positioned(
                        top: -16, // Moved lower as requested
                        left: -15,
                        right: -15,
                        child: _buildCustomProgressBar(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEpisodesBottomSheet() {
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
                          widget.thumbnailUrl,
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
                            widget.seriesTitle,
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
                              '${widget.totalEpisodes} Episodes',
                              style: TextStyle(
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
                  itemCount: widget.totalEpisodes,
                  itemBuilder: (context, index) {
                    final isCurrent = widget.episode.episodeNumber == index + 1;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // In a real app, we would navigate to that episode
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
      accentColor: AppColors.accent,
    );
  }
}

class _InteractiveProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final Color accentColor;

  const _InteractiveProgressBar({
    super.key,
    required this.controller,
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
            activeTrackColor: widget.accentColor,
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
