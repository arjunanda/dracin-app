import 'dart:io';
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
    debugPrint('📱 AdMob initialized');
  }

  /// Load a rewarded ad
  Future<void> loadRewardedAd() async {
    debugPrint('📱 Loading rewarded ad...');

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('📱 Rewarded ad loaded successfully');
          _rewardedAd = ad;
          _isAdLoaded = true;

          // Set fullscreen content callback
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('📱 Ad showed fullscreen');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('📱 Ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
              // Preload next ad
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('📱 Ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isAdLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('📱 Failed to load rewarded ad: $error');
          _isAdLoaded = false;
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
  DateTime? _nextAdAllowedAt;
  bool _isFirstAd = true;

  ShortsAdManager() {
    // First ad is allowed immediately
    _nextAdAllowedAt = DateTime.now();
  }

  /// Check if ad should be shown based on time cooldown
  bool shouldShowAd() {
    if (_isFirstAd) return true;

    if (_nextAdAllowedAt == null) return false;

    final now = DateTime.now();
    final shouldShow = now.isAfter(_nextAdAllowedAt!);

    if (!shouldShow) {
      final remaining = _nextAdAllowedAt!.difference(now).inSeconds;
      debugPrint('📱 Ad cooldown: $remaining seconds remaining');
    }

    return shouldShow;
  }

  /// Update after showing an ad
  void onAdShown() {
    _isFirstAd = false;
    // Next ad allowed after 2 minutes
    _nextAdAllowedAt = DateTime.now().add(const Duration(minutes: 2));
    debugPrint(
      '📱 Next ad scheduled at $_nextAdAllowedAt (2 minutes cooldown)',
    );
  }

  /// Reset the manager
  void reset() {
    _isFirstAd = true;
    _nextAdAllowedAt = DateTime.now();
  }
}
