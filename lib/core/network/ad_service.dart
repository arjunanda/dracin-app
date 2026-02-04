import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Provider to track globally if an interstitial ad is currently showing
final isAnyAdShowingProvider = StateProvider<bool>((ref) => false);

class AdService {
  InterstitialAd? _interstitialAd;
  int _playCount = 0;
  DateTime? _lastAdTime;
  bool _isCountdownRunning = false;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1590516571247789/1911035668', // official test id
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('DEBUG_AD: Interstitial Ad LOADED');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          debugPrint('DEBUG_AD: Failed to load: ${err.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  void initAdTimer() {
    if (_lastAdTime == null) {
      _lastAdTime = DateTime.now();
    }
  }

  Future<void> _startAdCountdown(InterstitialAd ad, WidgetRef ref) async {
    if (_isCountdownRunning) return;
    _isCountdownRunning = true;

    debugPrint('DEBUG_AD: --- AD COUNTDOWN STARTED ---');
    for (int i = 3; i > 0; i--) {
      debugPrint('DEBUG_AD: Iklan akan muncul dalam $i...');
      await Future.delayed(const Duration(seconds: 1));
    }
    debugPrint('DEBUG_AD: --- SHOWING AD NOW ---');

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        ref.read(isAnyAdShowingProvider.notifier).state = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        ref.read(isAnyAdShowingProvider.notifier).state = false;
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        _isCountdownRunning = false;
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ref.read(isAnyAdShowingProvider.notifier).state = false;
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        _isCountdownRunning = false;
      },
    );

    await ad.show();
    _lastAdTime = DateTime.now();
  }

  void showTimedAd(WidgetRef ref) {
    // 1. Only for non-premium
    final authState = ref.read(authProvider);
    if (authState.user?.isPremium ?? false) return;

    // 2. Check if initialized
    if (_lastAdTime == null) {
      debugPrint('DEBUG_AD: Initializing timer');
      initAdTimer();
      return;
    }

    // 3. Check if interval has passed
    final now = DateTime.now();
    final difference = now.difference(_lastAdTime!);

    debugPrint(
      'DEBUG_AD: Time since last ad: ${difference.inSeconds}s (Need 20s for testing)',
    );

    if (difference.inSeconds >= 20) {
      // Changed to 20s for testing
      if (_interstitialAd != null && !_isCountdownRunning) {
        _startAdCountdown(_interstitialAd!, ref);
      } else if (_interstitialAd == null) {
        debugPrint('DEBUG_AD: Interval reached but ad is NULL, loading...');
        loadInterstitialAd();
      }
    }
  }

  void showAdIfNecessary(WidgetRef ref) {
    _playCount++;
    debugPrint('DEBUG_AD: Play count: $_playCount (Shows every 2 clicks)');

    if (_playCount % 2 == 0) {
      if (_interstitialAd != null && !_isCountdownRunning) {
        _startAdCountdown(_interstitialAd!, ref);
      } else {
        debugPrint(
          'DEBUG_AD: Should show ad but ad is ${_interstitialAd == null ? 'NULL' : 'BUSY'}',
        );
        loadInterstitialAd();
      }
    }
  }
}

final adServiceProvider = Provider((ref) => AdService()..loadInterstitialAd());
