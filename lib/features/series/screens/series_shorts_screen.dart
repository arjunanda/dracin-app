import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_video_player.dart';
import '../../../core/services/admob_service.dart';
import '../providers/episodes_provider.dart';
import '../../series/models/episode_model.dart';

class SeriesShortsScreen extends ConsumerStatefulWidget {
  final String seriesId;
  final String title;

  const SeriesShortsScreen({
    super.key,
    required this.seriesId,
    required this.title,
  });

  @override
  ConsumerState<SeriesShortsScreen> createState() => _SeriesShortsScreenState();
}

class _SeriesShortsScreenState extends ConsumerState<SeriesShortsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // AdMob instances
  final AdMobService _adMobService = AdMobService();
  final ShortsAdManager _adManager = ShortsAdManager();
  bool _isLoadingAd = false;

  @override
  void initState() {
    super.initState();
    // Force refresh episodes to get new HLS URLs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(episodesProvider(widget.seriesId));
      // Preload first ad
      _adMobService.loadInterstitialAd();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _adMobService.dispose();
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
                      setState(() {
                        _currentIndex = index;
                      });

                      // Check if we should show an ad
                      if (!_isLoadingAd && _adManager.shouldShowAd(index)) {
                        setState(() => _isLoadingAd = true);
                        final shown = await _adMobService.showInterstitialAd();
                        if (shown) {
                          _adManager.onAdShown(index);
                        }
                        setState(() => _isLoadingAd = false);
                      }
                    },
                    itemBuilder: (context, index) {
                      final episode = episodes[index];
                      return _ShortVideoItem(
                        episode: episode,
                        shouldPlay: index == _currentIndex && !_isLoadingAd,
                      );
                    },
                  ),
                ),

          // Back Button & Title Overlay
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 70,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                episodes.isNotEmpty && _currentIndex < episodes.length
                    ? 'Episode ${episodes[_currentIndex].episodeNumber}'
                    : widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortVideoItem extends StatefulWidget {
  final Episode episode;
  final bool shouldPlay;

  const _ShortVideoItem({required this.episode, required this.shouldPlay});

  @override
  State<_ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends State<_ShortVideoItem> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Player
        Positioned.fill(
          child: CustomVideoPlayer(
            key: ValueKey(widget.episode.id),
            sources: [VideoSource(label: 'Auto', url: widget.episode.videoUrl)],
            autoPlay: widget.shouldPlay,
            aspectRatio: 9 / 16,
            fit: BoxFit.cover,
          ),
        ),

        // Top Gradient Overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom Gradient Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Episode Info (Bottom) - No container, just text with shadow
        Positioned(
          bottom: 60,
          left: 20,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Episode ${widget.episode.episodeNumber}',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.episode.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
