import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdService {
  InterstitialAd? _interstitialAd;
  int _playCount = 0;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-1590516571247789/1911035668',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showAdIfNecessary() {
    _playCount++;
    if (_playCount % 2 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();
      loadInterstitialAd(); // Load next one
    } else if (_interstitialAd == null) {
      loadInterstitialAd(); // Ensure we have one
    }
  }
}

final adServiceProvider = Provider((ref) => AdService()..loadInterstitialAd());
