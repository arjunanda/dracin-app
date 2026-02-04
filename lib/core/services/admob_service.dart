import 'dart:async';
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

  // Google Test Ad Unit IDs for Interstitial Ads
  static const String _testInterstitialAndroid =
      'ca-app-pub-1590516571247789/1911035668';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool _isInterstitialAdLoading = false;

  /// Get the appropriate ad unit ID based on platform
  String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return _testRewardedAndroid;
    } else if (Platform.isIOS) {
      return _testRewardedIOS;
    }
    return '';
  }

  String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return _testInterstitialAndroid;
    } else if (Platform.isIOS) {
      return _testInterstitialIOS;
    }
    return '';
  }

  /// Initialize AdMob
  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('🌐 AdMob: Skipping initialization on Web');
      return;
    }
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

  /// Load an interstitial ad
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdLoaded || _isInterstitialAdLoading) {
      debugPrint(
        '📱 AdMob: Interstitial ad already loaded or loading, skipping load',
      );
      return;
    }

    _isInterstitialAdLoading = true;
    debugPrint('📱 AdMob: Loading interstitial ad...');

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('📱 AdMob: Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          _isInterstitialAdLoading = false;

          // Set fullscreen content callback
          _interstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('📱 AdMob: Interstitial ad showed fullscreen');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('📱 AdMob: Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              // Preload next ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('📱 AdMob: Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdLoaded = false;
              // Try to load again
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('📱 AdMob: Failed to load interstitial ad: $error');
          _isInterstitialAdLoaded = false;
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
          // Retry after a delay
          Future.delayed(
            const Duration(seconds: 10),
            () => loadInterstitialAd(),
          );
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
      final completer = Completer<bool>();

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
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('📱 AdMob: Ad failed to show: $error');
          ad.dispose();
          _rewardedAd = null;
          _isAdLoaded = false;
          // Try to load again
          loadRewardedAd();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('📱 User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward(reward);
        },
      );

      return completer.future;
    } else {
      debugPrint('📱 Ad not ready to show');
      return false;
    }
  }

  /// Show the interstitial ad if loaded
  Future<bool> showInterstitialAd() async {
    if (_isInterstitialAdLoaded && _interstitialAd != null) {
      debugPrint('📱 Showing interstitial ad');
      final completer = Completer<bool>();

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('📱 AdMob: Interstitial ad showed fullscreen');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('📱 AdMob: Interstitial ad dismissed');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          // Preload next ad
          loadInterstitialAd();
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('📱 AdMob: Interstitial ad failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
          _isInterstitialAdLoaded = false;
          // Try to load again
          loadInterstitialAd();
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      await _interstitialAd!.show();

      return completer.future;
    } else {
      debugPrint('📱 Interstitial ad not ready to show');
      return false;
    }
  }

  /// Dispose the ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdLoaded = false;
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
