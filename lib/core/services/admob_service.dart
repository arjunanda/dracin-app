import 'dart:io';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Google Test Ad Unit IDs
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;

  /// Get the appropriate ad unit ID based on platform
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _testInterstitialAndroid;
    } else if (Platform.isIOS) {
      return _testInterstitialIOS;
    }
    return '';
  }

  /// Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    debugPrint('📱 AdMob initialized');
  }

  /// Load an interstitial ad
  Future<void> loadInterstitialAd() async {
    debugPrint('📱 Loading interstitial ad...');

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('📱 Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isAdLoaded = true;

          // Set fullscreen content callback
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  debugPrint('📱 Ad showed fullscreen');
                },
                onAdDismissedFullScreenContent: (ad) {
                  debugPrint('📱 Ad dismissed');
                  ad.dispose();
                  _interstitialAd = null;
                  _isAdLoaded = false;
                  // Preload next ad
                  loadInterstitialAd();
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  debugPrint('📱 Ad failed to show: $error');
                  ad.dispose();
                  _interstitialAd = null;
                  _isAdLoaded = false;
                },
              );
        },
        onAdFailedToLoad: (error) {
          debugPrint('📱 Failed to load interstitial ad: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Show the interstitial ad if loaded
  Future<bool> showInterstitialAd() async {
    if (_isAdLoaded && _interstitialAd != null) {
      debugPrint('📱 Showing interstitial ad');
      await _interstitialAd!.show();
      return true;
    } else {
      debugPrint('📱 Ad not ready to show');
      return false;
    }
  }

  /// Dispose the ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}

/// Helper class to manage ad display logic for shorts/reels
class ShortsAdManager {
  int? _nextAdAt;
  final Random _random = Random();

  ShortsAdManager() {
    // First ad at 10th scroll
    _nextAdAt = 10;
  }

  /// Check if ad should be shown at current scroll
  bool shouldShowAd(int currentIndex) {
    if (_nextAdAt == null) return false;

    if (currentIndex >= _nextAdAt!) {
      debugPrint('📱 Ad trigger at index $currentIndex (target: $_nextAdAt)');
      return true;
    }
    return false;
  }

  /// Update after showing an ad
  void onAdShown(int currentIndex) {
    // Next ad between 5-10 scrolls from now
    final nextInterval = 5 + _random.nextInt(6); // 5 to 10
    _nextAdAt = currentIndex + nextInterval;
    debugPrint(
      '📱 Next ad scheduled at index $_nextAdAt (in $nextInterval scrolls)',
    );
  }

  /// Reset the manager
  void reset() {}
}
