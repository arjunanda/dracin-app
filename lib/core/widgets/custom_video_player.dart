import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoSource {
  final String label;
  final String url;
  const VideoSource({required this.label, required this.url});
}

class CustomVideoPlayer extends StatefulWidget {
  final List<VideoSource> sources;
  final bool autoPlay;
  final double aspectRatio;
  final BoxFit fit;

  const CustomVideoPlayer({
    super.key,
    required this.sources,
    this.autoPlay = false,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.contain,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showControls = false;
  Timer? _hideTimer;
  int _currentSourceIndex = 0;
  bool _isAutoQuality = true; // Auto quality mode by default
  String _detectedQuality = 'Auto'; // Current detected quality

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 CustomVideoPlayer: initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayer();
    });
  }

  Future<void> _initPlayer() async {
    debugPrint('🎬 CustomVideoPlayer: _initPlayer started');

    // Dispose previous controller
    if (_controller != null) {
      debugPrint('🎬 CustomVideoPlayer: Disposing previous controller');
      await _controller!.dispose();
      _controller = null;
    }

    if (!mounted) {
      debugPrint('🎬 CustomVideoPlayer: Widget not mounted, aborting');
      return;
    }

    setState(() {
      _isInitialized = false;
    });

    try {
      // Auto-detect quality based on available sources
      if (_isAutoQuality && widget.sources.length > 1) {
        _currentSourceIndex = _detectBestQuality();
        debugPrint(
          '🎬 CustomVideoPlayer: Auto quality selected index $_currentSourceIndex',
        );
      }

      final url = widget.sources[_currentSourceIndex].url;
      debugPrint('🎬 CustomVideoPlayer: Initializing with URL: $url');

      _controller = VideoPlayerController.networkUrl(Uri.parse(url));

      debugPrint('🎬 CustomVideoPlayer: Starting initialization...');

      // Add timeout to prevent infinite hang
      await _controller!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('❌ CustomVideoPlayer: Initialization timeout after 30s');
          throw TimeoutException('Video initialization timeout');
        },
      );

      debugPrint('🎬 CustomVideoPlayer: Initialization complete');

      if (!mounted) {
        debugPrint('🎬 CustomVideoPlayer: Widget unmounted after init');
        return;
      }

      _controller!.setLooping(true);
      debugPrint('🎬 CustomVideoPlayer: Looping enabled');

      if (widget.autoPlay) {
        debugPrint('🎬 CustomVideoPlayer: Starting autoplay');
        await _controller!.play();
      }

      setState(() {
        _isInitialized = true;
        _detectedQuality = widget.sources[_currentSourceIndex].label;
      });

      debugPrint('🎬 CustomVideoPlayer: Ready! Quality: $_detectedQuality');
    } on TimeoutException catch (e) {
      debugPrint('❌ CustomVideoPlayer Timeout: $e');
      debugPrint('❌ This might be a network issue or invalid video URL');

      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ CustomVideoPlayer Init Error: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  /// Auto-detect best quality based on simple heuristic
  /// In production, this should use actual bandwidth measurement
  int _detectBestQuality() {
    // Simple heuristic: prefer middle quality for auto mode
    // In real app, measure bandwidth and choose accordingly
    if (widget.sources.length >= 3) {
      return 1; // Middle quality (usually 720p)
    } else if (widget.sources.length == 2) {
      return 0; // Lower quality for 2 options
    }
    return 0;
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
    _resetHideTimer();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetHideTimer();
    }
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _changeQuality(int index) {
    debugPrint('🎬 CustomVideoPlayer: _changeQuality to index $index');
    if (index == _currentSourceIndex && !_isAutoQuality) {
      debugPrint('🎬 CustomVideoPlayer: Same quality, skipping');
      return;
    }

    final position = _controller?.value.position ?? Duration.zero;
    final wasPlaying = _controller?.value.isPlaying ?? false;

    setState(() {
      _currentSourceIndex = index;
      _isAutoQuality = false; // Disable auto when manually selected
      _detectedQuality = widget.sources[index].label;
    });

    debugPrint(
      '🎬 CustomVideoPlayer: Switching to ${widget.sources[index].label} at position $position',
    );

    _initPlayer().then((_) {
      if (_isInitialized) {
        debugPrint('🎬 CustomVideoPlayer: Seeking to $position');
        _controller?.seekTo(position);
        if (wasPlaying) {
          debugPrint('🎬 CustomVideoPlayer: Resuming playback');
          _controller?.play();
        }
      }
    });
  }

  void _enableAutoQuality() {
    debugPrint('🎬 CustomVideoPlayer: Enabling auto quality');
    setState(() {
      _isAutoQuality = true;
      _detectedQuality = 'Auto';
    });
    _initPlayer();
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🎬 CustomVideoPlayer: didUpdateWidget');

    if (widget.sources.first.url != oldWidget.sources.first.url) {
      debugPrint('🎬 CustomVideoPlayer: URL changed, reinitializing');
      _initPlayer();
      return;
    }

    if (_controller != null && _isInitialized) {
      if (widget.autoPlay != oldWidget.autoPlay) {
        debugPrint(
          '🎬 CustomVideoPlayer: AutoPlay changed to ${widget.autoPlay}',
        );
        if (widget.autoPlay) {
          _controller!.play();
        } else {
          _controller!.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🎬 CustomVideoPlayer: dispose');
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),

          // Custom Controls Overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !_showControls,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Center Play/Pause Button
                    Center(
                      child: GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                    ),

                    // Top Right Controls
                    Positioned(
                      top: 40,
                      right: 16,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quality Button
                          if (widget.sources.length > 1)
                            _buildControlButton(
                              icon: Icons.hd,
                              label: _detectedQuality,
                              onTap: () => _showQualityMenu(context),
                            ),
                          const SizedBox(width: 12),

                          // Subtitle Button (placeholder)
                          _buildControlButton(
                            icon: Icons.closed_caption,
                            onTap: () {
                              // TODO: Implement subtitle selection
                            },
                          ),
                          const SizedBox(width: 12),

                          // More Options Button
                          _buildControlButton(
                            icon: Icons.more_vert,
                            onTap: () => _showMoreOptions(context),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Progress Bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildProgressBar(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (_controller == null || !_isInitialized) {
          return const SizedBox.shrink();
        }

        final position = _controller!.value.position;
        final duration = _controller!.value.duration;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    _formatDuration(position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: Colors.red,
              ),
              child: Slider(
                value: progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final newPosition = duration * value;
                  _controller!.seekTo(newPosition);
                  _resetHideTimer();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showQualityMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Video Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Auto Quality Option
            ListTile(
              leading: Icon(
                Icons.auto_awesome,
                color: _isAutoQuality ? Colors.red : Colors.white,
              ),
              title: Text(
                'Auto',
                style: TextStyle(
                  color: _isAutoQuality ? Colors.red : Colors.white,
                  fontWeight: _isAutoQuality
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              subtitle: _isAutoQuality
                  ? Text(
                      'Currently: ${widget.sources[_currentSourceIndex].label}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    )
                  : null,
              trailing: _isAutoQuality
                  ? const Icon(Icons.check, color: Colors.red)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _enableAutoQuality();
              },
            ),
            const Divider(color: Colors.white24),
            // Manual Quality Options
            ...List.generate(widget.sources.length, (index) {
              final source = widget.sources[index];
              final isSelected =
                  index == _currentSourceIndex && !_isAutoQuality;

              return ListTile(
                leading: Icon(
                  Icons.hd,
                  color: isSelected ? Colors.red : Colors.white,
                ),
                title: Text(
                  source.label,
                  style: TextStyle(
                    color: isSelected ? Colors.red : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.red)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _changeQuality(index);
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.speed, color: Colors.white),
              title: const Text(
                'Playback Speed',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement playback speed
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.white),
              title: const Text(
                'Report',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
