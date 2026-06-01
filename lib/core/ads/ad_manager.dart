import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdManager {
  static const _calcCountKey = 'calc_count_v1';
  static const _removedAdsKey = 'removed_ads_v1';
  static const _interstitialThreshold = 5;

  static const String _bannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';

  static AdManager? _instance;
  static AdManager get instance => _instance ??= AdManager._();
  AdManager._();

  bool _adsRemoved = false;
  InterstitialAd? _interstitialAd;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _adsRemoved = prefs.getBool(_removedAdsKey) ?? false;
    if (!_adsRemoved) _loadInterstitial();
  }

  bool get adsRemoved => _adsRemoved;
  String get bannerAdUnitId => _bannerAndroid;

  Future<void> setAdsRemoved() async {
    _adsRemoved = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_removedAdsKey, true);
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialAndroid,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  Future<void> incrementCalcCount() async {
    if (_adsRemoved) return;
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_calcCountKey) ?? 0) + 1;
    await prefs.setInt(_calcCountKey, count);
    if (count % _interstitialThreshold == 0) await _showInterstitial();
  }

  Future<void> _showInterstitial() async {
    if (_interstitialAd == null) return;
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); _interstitialAd = null; _loadInterstitial(); },
      onAdFailedToShowFullScreenContent: (ad, _) { ad.dispose(); _interstitialAd = null; _loadInterstitial(); },
    );
    await _interstitialAd!.show();
    _interstitialAd = null;
  }
}
