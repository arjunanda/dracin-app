import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';

class VideoSource {
  final String label;
  final String url;
  const VideoSource({required this.label, required this.url});
}

class SubtitleSource {
  final String label;
  final String url;
  const SubtitleSource({required this.label, required this.url});
}

class CustomVideoPlayer extends StatefulWidget {
  final List<VideoSource> sources;
  final List<SubtitleSource>? subtitles;
  final bool autoPlay;
  final double aspectRatio;
  final BoxFit fit;
  final bool showDefaultProgressBar;
  final bool
  forceAspectRatio; // Force use of aspectRatio instead of video's native ratio
  final Alignment alignment; // Alignment for video positioning
  final double scale; // Scale factor for video (1.0 = normal, >1.0 = zoom in)
  final Function(VideoPlayerController)? onControllerInitialized;
  final VoidCallback? onControllerWillDispose;
  final VoidCallback? onEnded;
  final bool looping;
  final ValueChanged<bool>? onControlsVisibilityChanged;
  final bool disableControlsToggle;
  final bool showControlsOnInit;

  const CustomVideoPlayer({
    super.key,
    required this.sources,
    this.subtitles,
    this.autoPlay = false,
    this.aspectRatio = 9 / 16,
    this.fit = BoxFit.contain,
    this.showDefaultProgressBar = true,
    this.forceAspectRatio = false,
    this.alignment = Alignment.center,
    this.scale = 1.0,
    this.onControllerInitialized,
    this.onControllerWillDispose,
    this.onEnded,
    this.looping = true,
    this.onControlsVisibilityChanged,
    this.disableControlsToggle = false,
    this.showControlsOnInit = false,
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
  int _selectedSubtitleIndex = -1; // -1 means Off
  bool _isAutoQuality = true; // Auto quality mode by default
  String _detectedQuality = 'Auto'; // Current detected quality
  bool _isSwitchingQuality = false; // Flag to prevent multiple initializations
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 CustomVideoPlayer: initState');

    // Subtitle selection moved to after initialization to save bandwidth
    if (widget.subtitles != null && widget.subtitles!.isNotEmpty) {
      final idIndex = widget.subtitles!.indexWhere(
        (s) =>
            s.label.toLowerCase().contains('id') ||
            s.label.toLowerCase().contains('indo'),
      );
      if (idIndex != -1) {
        _selectedSubtitleIndex = idIndex;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPlayer();
    });
  }

  Future<void> _initPlayer() async {
    if (_isSwitchingQuality) return;
    if (_isDragging) return; // Don't reinit while user is scrubbing

    final bool isFirstInit = _controller == null;
    debugPrint(
      '🎬 CustomVideoPlayer: _initPlayer started (isFirstInit: $isFirstInit)',
    );

    if (isFirstInit) {
      Future.microtask(() {
        if (mounted) {
          setState(() {
            _isInitialized = false;
          });
        }
      });
    }

    _isSwitchingQuality = true;
    VideoPlayerController? nextController;

    try {
      // Auto-detect quality based on available sources
      if (_isAutoQuality && widget.sources.length > 1) {
        _currentSourceIndex = _detectBestQuality();
      }

      final url = widget.sources[_currentSourceIndex].url;
      debugPrint('🎬 CustomVideoPlayer: Initializing with URL: $url');

      nextController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // Add timeout to prevent infinite hang
      await nextController.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('❌ CustomVideoPlayer: Initialization timeout after 20s');
          throw TimeoutException('Video initialization timeout');
        },
      );

      if (!mounted) {
        await nextController.dispose();
        return;
      }

      // Swap controllers
      final oldController = _controller;
      final wasPlaying = oldController?.value.isPlaying ?? widget.autoPlay;
      final position = oldController?.value.position ?? Duration.zero;

      _controller = nextController;
      _controller!.setLooping(widget.looping);

      if (widget.onEnded != null) {
        _controller!.addListener(_videoListener);
      }

      // Restore state
      if (position > Duration.zero) {
        await _controller!.seekTo(position);
      }
      if (wasPlaying) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _detectedQuality = widget.sources[_currentSourceIndex].label;
        });

        if (widget.onControllerInitialized != null) {
          widget.onControllerInitialized!(_controller!);
        }

        // Show controls on init if requested
        if (widget.showControlsOnInit && isFirstInit) {
          _showControls = true;
          widget.onControlsVisibilityChanged?.call(true);
          _resetHideTimer();
        }

        // Load subtitles ONLY after video is ready
        if (_selectedSubtitleIndex != -1 && widget.subtitles != null) {
          _loadSubtitle(widget.subtitles![_selectedSubtitleIndex].url);
        }
      }

      // Dispose old controller AFTER swap and rebuild.
      // IMPORTANT: null out _controller reference first so Flutter's render
      // tree never holds two live VideoPlayer controllers simultaneously,
      // which is what causes frames to visually "stack" on screen.
      if (oldController != null) {
        debugPrint('🎬 CustomVideoPlayer: Disposing old controller');
        // Pause old controller immediately to release audio resources
        if (oldController.value.isPlaying) {
          oldController.pause();
        }

        if (widget.onControllerWillDispose != null) {
          widget.onControllerWillDispose!();
        }
        // Delay dispose to let the UI fully switch to the new controller,
        // but do NOT reassign _controller after this point.
        // Future.delayed(const Duration(milliseconds: 500), () {
        //   oldController.dispose();
        // });

        if (oldController.value.isPlaying) {
          oldController.pause();
        }
        if (widget.onControllerWillDispose != null) {
          widget.onControllerWillDispose!();
        }
        oldController.dispose();
      }

      debugPrint('🎬 CustomVideoPlayer: Ready! Quality: $_detectedQuality');
    } catch (e, stackTrace) {
      debugPrint('❌ CustomVideoPlayer Error: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      // If it fails, we should ensure the failed controller is disposed
      if (nextController != null) {
        await nextController.dispose();
      }

      if (isFirstInit && mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSwitchingQuality = false;
        });
      }
    }
  }

  /// Auto-detect best quality based on simple heuristic
  /// In production, this should use actual bandwidth measurement
  int _detectBestQuality() {
    // For HLS, index 0 is always the Master Playlist (Auto)
    // which handles adaptive streaming automatically
    return 0;
  }

  void _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;

    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }

    if (mounted) {
      setState(() {});
    }
    _resetHideTimer();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    widget.onControlsVisibilityChanged?.call(_showControls);
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
        widget.onControlsVisibilityChanged?.call(false);
      }
    });
  }

  void _changeQuality(int index) {
    if (_isSwitchingQuality) return;

    if (index == _currentSourceIndex && !_isAutoQuality) return;

    setState(() {
      _currentSourceIndex = index;
      _isAutoQuality = false;
    });

    _initPlayer();
  }

  String? _currentSubtitleText;
  Timer? _subtitleUpdateTimer;

  Future<void> _loadSubtitle(String url) async {
    try {
      debugPrint('🎬 Loading subtitle from: $url');

      if (url.isEmpty) {
        setState(() => _currentSubtitleText = null);
        return;
      }

      // Fetch subtitle file
      final response = await Dio().get(url);
      final subtitleContent = response.data as String;

      debugPrint('🎬 Subtitle loaded successfully');

      // Start subtitle update timer
      _subtitleUpdateTimer?.cancel();
      _subtitleUpdateTimer = Timer.periodic(const Duration(milliseconds: 250), (
        _,
      ) {
        if (_controller != null && _controller!.value.isInitialized) {
          final position = _controller!.value.position;
          final text = _getSubtitleTextAtPosition(subtitleContent, position);
          if (_currentSubtitleText != text) {
            setState(() => _currentSubtitleText = text);
          }
        }
      });
    } catch (e) {
      debugPrint('❌ Error loading subtitle: $e');
    }
  }

  String? _getSubtitleTextAtPosition(String vttContent, Duration position) {
    // Simple VTT parser
    final lines = vttContent.split('\n');
    final positionMs = position.inMilliseconds;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Check if line contains timestamp (e.g., "00:00:01.000 --> 00:00:03.000")
      if (line.contains('-->')) {
        final parts = line.split('-->');
        if (parts.length == 2) {
          final startMs = _parseVttTimestamp(parts[0].trim());
          final endMs = _parseVttTimestamp(parts[1].trim());

          if (positionMs >= startMs && positionMs <= endMs) {
            // Get subtitle text (next non-empty lines)
            final textLines = <String>[];
            for (int j = i + 1; j < lines.length; j++) {
              final textLine = lines[j].trim();
              if (textLine.isEmpty) break;
              if (!textLine.contains('-->') && !textLine.startsWith('WEBVTT')) {
                textLines.add(textLine);
              }
            }
            return textLines.join('\n');
          }
        }
      }
    }
    return null;
  }

  int _parseVttTimestamp(String timestamp) {
    // Parse timestamp like "00:00:01.000" or "00:01:23.456"
    try {
      final parts = timestamp.split(':');
      if (parts.length >= 2) {
        final hours = parts.length == 3 ? int.parse(parts[0]) : 0;
        final minutes = int.parse(parts[parts.length - 2]);
        final secondsParts = parts[parts.length - 1].split('.');
        final seconds = int.parse(secondsParts[0]);
        final milliseconds = secondsParts.length > 1
            ? int.parse(secondsParts[1].padRight(3, '0').substring(0, 3))
            : 0;

        return (hours * 3600000) +
            (minutes * 60000) +
            (seconds * 1000) +
            milliseconds;
      }
    } catch (e) {
      debugPrint('Error parsing timestamp: $timestamp - $e');
    }
    return 0;
  }

  void _enableAutoQuality() {
    debugPrint('🎬 CustomVideoPlayer: Enabling auto quality');
    setState(() {
      _isAutoQuality = true;
      _detectedQuality = 'Auto';
    });
    _initPlayer();
  }

  void _videoListener() {
    if (_controller == null || !mounted) return;

    final value = _controller!.value;
    if (value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration) {
      widget.onEnded?.call();
    }
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🎬 CustomVideoPlayer: didUpdateWidget');

    // Never reinitialize during a scrub — it causes the old and new
    // controllers to both render to the screen in the same frame.
    if (_isDragging) return;

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
        final controller = _controller!;
        Future.microtask(() async {
          if (mounted) {
            if (widget.autoPlay) {
              controller.play();
            } else {
              controller.pause();
            }
          }
        });
      }
    } else if (widget.autoPlay != oldWidget.autoPlay &&
        !_isInitialized &&
        !_isSwitchingQuality) {
      // If autoPlay changes while not initialized and not currently initializing, trigger init
      _initPlayer();
    }
  }

  @override
  void dispose() {
    debugPrint('🎬 CustomVideoPlayer: dispose');
    _hideTimer?.cancel();
    _subtitleUpdateTimer?.cancel();

    if (_controller != null) {
      final controllerToDispose = _controller;
      _controller = null; // Clear reference

      if (widget.onControllerWillDispose != null) {
        widget.onControllerWillDispose!();
      }

      controllerToDispose!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.disableControlsToggle ? null : _toggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          widget.fit == BoxFit.cover
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    alignment: widget.alignment,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                )
              : ClipRect(
                  child: Align(
                    alignment: widget.alignment,
                    child: Transform.scale(
                      scale: widget.scale,
                      alignment: widget.alignment,
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: widget.forceAspectRatio
                                ? widget.aspectRatio
                                : (_controller!.value.aspectRatio > 0
                                      ? _controller!.value.aspectRatio
                                      : widget.aspectRatio),
                            child: VideoPlayer(_controller!),
                          ),
                          // Pause Shadow - Matches video scale perfectly
                          if (!_controller!.value.isPlaying)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

          // Subtitles
          if (_selectedSubtitleIndex != -1 && _currentSubtitleText != null)
            Positioned.fill(
              child: Align(
                alignment: const Alignment(0, 0.4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _currentSubtitleText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Loading Overlay when switching quality
          if (_isSwitchingQuality)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Switching quality...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
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
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.2, 0.4, 1.0],
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

                          // Subtitle Button
                          if (widget.subtitles != null &&
                              widget.subtitles!.isNotEmpty)
                            _buildControlButton(
                              icon: Icons.closed_caption,
                              isActive: _selectedSubtitleIndex != -1,
                              onTap: () => _showSubtitleMenu(context),
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
                    if (widget.showDefaultProgressBar)
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
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final bool isCircle = label == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCircle ? 40 : null,
        height: isCircle ? 40 : null,
        padding: isCircle
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor.withOpacity(0.8)
              : Colors.black.withOpacity(0.7),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_controller == null) return const SizedBox.shrink();

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _controller!,
      builder: (context, value, child) {
        if (!value.isInitialized) return const SizedBox.shrink();

        final duration = value.duration;
        // Gunakan posisi dari controller atau nilai drag jika sedang dragging
        final position = _isDragging ? duration * _dragValue : value.position;

        final progress = _isDragging
            ? _dragValue
            : (duration.inMilliseconds > 0
                  ? position.inMilliseconds / duration.inMilliseconds
                  : 0.0);

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
                onChanged: (val) {
                  setState(() {
                    _isDragging = true;
                    _dragValue = val;
                  });
                  _resetHideTimer();
                },
                onChangeEnd: (val) {
                  final newPosition = duration * val;
                  _controller!.seekTo(newPosition);
                  setState(() {
                    _isDragging = false;
                  });
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
      isScrollControlled: true,
      builder: (context) => _buildPremiumBottomSheet(
        context: context,
        title: 'Video Quality',
        icon: Icons.high_quality,
        onBack: () {
          Navigator.pop(context);
          _showMoreOptions(context);
        },
        children: [
          _buildMenuOption(
            icon: Icons.auto_awesome,
            label: 'Auto',
            subtitle: _isAutoQuality ? 'Currently: $_detectedQuality' : null,
            isSelected: _isAutoQuality,
            onTap: () {
              Navigator.pop(context);
              _enableAutoQuality();
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: Colors.white10),
          ),
          ...List.generate(widget.sources.length, (index) {
            final source = widget.sources[index];
            final isSelected = index == _currentSourceIndex && !_isAutoQuality;
            return _buildMenuOption(
              icon: Icons.hd_outlined,
              label: source.label,
              isSelected: isSelected,
              onTap: () {
                Navigator.pop(context);
                _changeQuality(index);
              },
            );
          }),
        ],
      ),
    );
  }

  void _showSubtitleMenu(BuildContext context) {
    if (widget.subtitles == null || widget.subtitles!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subtitles available for this video')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPremiumBottomSheet(
        context: context,
        title: 'Subtitles',
        icon: Icons.subtitles,
        onBack: () {
          Navigator.pop(context);
          _showMoreOptions(context);
        },
        children: [
          _buildMenuOption(
            icon: Icons.subtitles_off_outlined,
            label: 'Off',
            isSelected: _selectedSubtitleIndex == -1,
            onTap: () {
              setState(() => _selectedSubtitleIndex = -1);
              Navigator.pop(context);
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: Colors.white10),
          ),
          ...List.generate(widget.subtitles!.length, (index) {
            final sub = widget.subtitles![index];
            final isSelected = index == _selectedSubtitleIndex;
            return _buildMenuOption(
              icon: Icons.language,
              label: sub.label,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedSubtitleIndex = index);
                _loadSubtitle(sub.url);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPremiumBottomSheet(
        context: context,
        title: 'Settings',
        icon: Icons.settings,
        children: [
          _buildMenuOption(
            icon: Icons.hd,
            label: 'Quality',
            trailing: Text(
              _isAutoQuality
                  ? 'Auto ($_detectedQuality)'
                  : widget.sources[_currentSourceIndex].label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showQualityMenu(context);
            },
          ),
          _buildMenuOption(
            icon: Icons.subtitles,
            label: 'Subtitles',
            trailing: Text(
              _selectedSubtitleIndex == -1
                  ? 'Off'
                  : widget.subtitles![_selectedSubtitleIndex].label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showSubtitleMenu(context);
            },
          ),
          _buildMenuOption(
            icon: Icons.speed,
            label: 'Playback Speed',
            trailing: Text(
              'Normal',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement speed menu
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Divider(color: Colors.white10),
          ),
          _buildMenuOption(
            icon: Icons.report_problem_outlined,
            label: 'Report Issue',
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement report
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBottomSheet({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    VoidCallback? onBack,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: onBack,
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance the back button
              ],
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    String? subtitle,
    Widget? trailing,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.red.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.red : Colors.white.withOpacity(0.8),
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.white,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              )
            : null,
        trailing:
            trailing ??
            (isSelected
                ? const Icon(Icons.check_circle, color: Colors.red, size: 22)
                : null),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
