import 'dart:io';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Google Test Ad Unit IDs for Rewarded Ads
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  /// Get the appropriate ad unit ID based on platform
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _testRewardedAndroid;
    } else if (Platform.isIOS) {
      return _testRewardedIOS;
    }
    return '';
  }

  /// Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('📱 AdMob: Initialized');
  }

  /// Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (_isAdLoaded || _isAdLoading) {
      debugPrint('📱 AdMob: Ad already loaded or loading, skipping load');
      return;
    }

    _isAdLoading = true;
    debugPrint('📱 AdMob: Loading rewarded ad...');

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('📱 AdMob: Rewarded ad loaded successfully');
          _rewardedAd = ad;
          _isAdLoaded = true;
          _isAdLoading = false;

          // Set fullscreen content callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('📱 AdMob: Ad showed fullscreen');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('📱 AdMob: Ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              // Preload next ad
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('📱 AdMob: Ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              // Try to load again
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('📱 AdMob: Failed to load rewarded ad: $error');
          _isAdLoaded = false;
          _isAdLoading = false;
          _rewardedAd = null;
          // Retry after a delay
          Future.delayed(const Duration(seconds: 10), () => loadRewardedAd());
        },
      ),
    );
  }

  /// Show the rewarded ad if loaded
  Future<bool> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
  }) async {
    if (_isAdLoaded && _rewardedAd != null) {
      debugPrint('📱 Showing rewarded ad');
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('📱 User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );
      return true;
    } else {
      debugPrint('📱 Ad not ready to show');
      return false;
    }
  }

  /// Dispose the ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
  }
}

/// Helper class to manage ad display logic for shorts/reels
class ShortsAdManager {
  int _adsShownCount = 0;
  int _lastAdVideoIndex = -1;
  int _scrollsSinceLastAd = 0;
  int _nextInterval = 0;
  int _lastIndex = -1;
  final Random _random = Random();

  ShortsAdManager() {
    reset();
  }

  /// Record a scroll event to track cumulative movement
  void recordScroll(int currentIndex) {
    if (_lastIndex != currentIndex) {
      if (_lastIndex != -1) {
        _scrollsSinceLastAd++;
      }
      _lastIndex = currentIndex;
    }
  }

  /// Check if ad should be shown
  bool shouldShowAd(int currentVideoIndex) {
    // Ad 1: When reaching the 10th slide (index 9)
    if (_adsShownCount == 0) {
      return currentVideoIndex >= 9;
    }

    // Subsequent ads: After 5-10 cumulative scrolls
    return _scrollsSinceLastAd >= _nextInterval &&
        _lastAdVideoIndex != currentVideoIndex;
  }

  /// Update after showing an ad
  void onAdShown(int currentVideoIndex) {
    _adsShownCount++;
    _lastAdVideoIndex = currentVideoIndex;
    _scrollsSinceLastAd = 0;
    _nextInterval = _random.nextInt(6) + 5; // 5 to 10 scrolls

    debugPrint(
      '📱 AdMob: Ad $_adsShownCount shown at index $currentVideoIndex. Next ad in $_nextInterval scrolls.',
    );
  }

  /// Reset the manager
  void reset() {
    _adsShownCount = 0;
    _lastAdVideoIndex = -1;
    _scrollsSinceLastAd = 0;
    _nextInterval = 0;
    _lastIndex = -1;
  }
}
