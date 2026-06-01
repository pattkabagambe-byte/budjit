import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ad unit IDs — test IDs used here; swap for real ones before release.
const _kInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

/// Max interstitials shown per calendar day for free users.
const _kDailyAdCap = 4;

/// Minimum minutes between consecutive interstitials.
const _kMinGapMinutes = 15;

/// How many qualifying actions before the first ad fires in a session.
const _kSessionThreshold = 3;

class AdTrigger {
  static const afterAddTransaction = 'add_tx';
  static const afterViewAnalytics = 'analytics';
  static const afterGoalComplete = 'goal';
  static const afterBudgetSession = 'budget';
}

class AdManager {
  static const _dailyCountKey = 'ad_daily_count_v2';
  static const _dailyDateKey = 'ad_daily_date_v2';
  static const _lastShownKey = 'ad_last_shown_v2';

  static AdManager? _instance;
  static AdManager get instance => _instance ??= AdManager._();
  AdManager._();

  bool _adsDisabled = false;
  InterstitialAd? _interstitialAd;
  bool _loading = false;
  final Map<String, int> _sessionCounts = {};

  /// Call once from main() after MobileAds.instance.initialize().
  Future<void> init({required bool isPremium}) async {
    _adsDisabled = isPremium;
    if (!_adsDisabled) _loadInterstitial();
  }

  /// Call when premium status changes (purchase or restore).
  void setAdsDisabled(bool disabled) {
    _adsDisabled = disabled;
    if (disabled) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
    } else {
      _loadInterstitial();
    }
  }

  void _loadInterstitial() {
    if (_loading || _interstitialAd != null) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: _kInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          _loading = false;
        },
      ),
    );
  }

  /// Call at natural breakpoints. Fires an ad if all conditions are met.
  Future<void> onTrigger(String trigger) async {
    if (_adsDisabled) return;

    // Increment session count for this trigger
    _sessionCounts[trigger] = (_sessionCounts[trigger] ?? 0) + 1;
    if ((_sessionCounts[trigger] ?? 0) < _kSessionThreshold) return;

    // Check daily cap
    if (!await _underDailyCap()) return;

    // Check minimum gap since last ad
    if (!await _gapElapsed()) return;

    await _show();
  }

  Future<bool> _underDailyCap() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDate = prefs.getString(_dailyDateKey);
    if (savedDate != today) {
      await prefs.setString(_dailyDateKey, today);
      await prefs.setInt(_dailyCountKey, 0);
      return true;
    }
    final count = prefs.getInt(_dailyCountKey) ?? 0;
    return count < _kDailyAdCap;
  }

  Future<bool> _gapElapsed() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_lastShownKey);
    if (lastMs == null) return true;
    final gap = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
    return gap.inMinutes >= _kMinGapMinutes;
  }

  Future<void> _show() async {
    if (_interstitialAd == null) return;
    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadInterstitial();
      },
    );

    await ad.show();

    // Record showing
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_dailyCountKey) ?? 0) + 1;
    await prefs.setInt(_dailyCountKey, count);
    await prefs.setInt(_lastShownKey, DateTime.now().millisecondsSinceEpoch);

    // Reset session count so the same trigger needs to warm up again
    _sessionCounts.clear();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
