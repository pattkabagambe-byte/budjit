import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_units.dart';

/// Max interstitials shown per calendar day for free users.
const _kDailyAdCap = 4;

/// Minimum minutes between consecutive interstitials.
const _kMinGapMinutes = 15;

/// How many qualifying actions before the first ad fires in a session.
const _kSessionThreshold = 3;

/// App open ads expire four hours after load (AdMob policy).
const _kAppOpenMaxCacheAge = Duration(hours: 4);

/// Max app open ads per calendar day.
const _kAppOpenDailyCap = 2;

/// Minimum time between app open ads.
const _kAppOpenMinGap = Duration(hours: 2);

/// Only show after the user was away at least this long.
const _kMinBackgroundDuration = Duration(seconds: 30);

/// Ignore [resumed] briefly after dismiss (ad close triggers resume).
const _kPostDismissSuppress = Duration(seconds: 12);

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
  static const _appOpenDailyCountKey = 'ad_app_open_daily_count_v1';
  static const _appOpenDailyDateKey = 'ad_app_open_daily_date_v1';
  static const _appOpenLastShownKey = 'ad_app_open_last_shown_v1';

  static AdManager? _instance;
  static AdManager get instance => _instance ??= AdManager._();
  AdManager._();

  bool _adsDisabled = false;
  bool _isShowingFullScreenAd = false;

  InterstitialAd? _interstitialAd;
  bool _loadingInterstitial = false;

  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadTime;
  bool _loadingAppOpen = false;

  bool _hasBeenBackgrounded = false;
  DateTime? _backgroundedAt;
  DateTime? _suppressAppOpenUntil;

  final Map<String, int> _sessionCounts = {};

  /// Call once from main() after [MobileAds.instance.initialize].
  Future<void> init({required bool isPremium}) async {
    _adsDisabled = isPremium;
    if (!_adsDisabled) {
      _loadInterstitial();
      _preloadAppOpenAd();
    }
  }

  /// Call when premium status changes (purchase or restore).
  void setAdsDisabled(bool disabled) {
    _adsDisabled = disabled;
    if (disabled) {
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadTime = null;
    } else {
      _loadInterstitial();
      _preloadAppOpenAd();
    }
  }

  // ── App open ───────────────────────────────────────────────────────────────

  /// User left the app (paused / inactive).
  void onAppBackgrounded() {
    _hasBeenBackgrounded = true;
    _backgroundedAt = DateTime.now();
  }

  /// User returned — show at most one app open ad when eligible.
  Future<void> onAppForegrounded() async {
    if (_adsDisabled || _isShowingFullScreenAd) return;

    if (_suppressAppOpenUntil != null &&
        DateTime.now().isBefore(_suppressAppOpenUntil!)) {
      return;
    }

    // Skip the initial [resumed] on cold start (no prior background).
    if (!_hasBeenBackgrounded) return;

    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null) return;

    final awayFor = DateTime.now().difference(backgroundedAt);
    if (awayFor < _kMinBackgroundDuration) return;

    if (!await _appOpenDailyCapOk()) return;
    if (!await _appOpenGapElapsed()) return;

    await _showAppOpenAd();
  }

  bool get _isAppOpenAdAvailable {
    final ad = _appOpenAd;
    final loadedAt = _appOpenLoadTime;
    if (ad == null || loadedAt == null) return false;
    return DateTime.now().difference(loadedAt) < _kAppOpenMaxCacheAge;
  }

  /// Preload only — never shows automatically when load completes.
  void _preloadAppOpenAd() {
    if (_adsDisabled || _loadingAppOpen || _isAppOpenAdAvailable) return;
    _loadingAppOpen = true;
    AppOpenAd.load(
      adUnitId: AdUnits.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          _loadingAppOpen = false;
        },
        onAdFailedToLoad: (_) {
          _appOpenAd = null;
          _appOpenLoadTime = null;
          _loadingAppOpen = false;
        },
      ),
    );
  }

  Future<void> _showAppOpenAd() async {
    if (_adsDisabled || _isShowingFullScreenAd || !_isAppOpenAdAvailable) {
      return;
    }

    final ad = _appOpenAd!;
    _appOpenAd = null;
    _appOpenLoadTime = null;
    _isShowingFullScreenAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissedAd) {
        _onAppOpenAdFinished(dismissedAd);
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        _onAppOpenAdFinished(failedAd);
      },
    );

    try {
      await ad.show();
      await _recordAppOpenShown();
    } catch (_) {
      _onAppOpenAdFinished(ad);
    }
  }

  void _onAppOpenAdFinished(Ad ad) {
    _isShowingFullScreenAd = false;
    _suppressAppOpenUntil = DateTime.now().add(_kPostDismissSuppress);
    ad.dispose();
    _preloadAppOpenAd();
  }

  Future<bool> _appOpenDailyCapOk() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final savedDate = prefs.getString(_appOpenDailyDateKey);
    if (savedDate != today) {
      await prefs.setString(_appOpenDailyDateKey, today);
      await prefs.setInt(_appOpenDailyCountKey, 0);
      return true;
    }
    final count = prefs.getInt(_appOpenDailyCountKey) ?? 0;
    return count < _kAppOpenDailyCap;
  }

  Future<bool> _appOpenGapElapsed() async {
    final prefs = await SharedPreferences.getInstance();
    final lastMs = prefs.getInt(_appOpenLastShownKey);
    if (lastMs == null) return true;
    final gap = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
    return gap >= _kAppOpenMinGap;
  }

  Future<void> _recordAppOpenShown() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    if (prefs.getString(_appOpenDailyDateKey) != today) {
      await prefs.setString(_appOpenDailyDateKey, today);
      await prefs.setInt(_appOpenDailyCountKey, 0);
    }
    final count = (prefs.getInt(_appOpenDailyCountKey) ?? 0) + 1;
    await prefs.setInt(_appOpenDailyCountKey, count);
    await prefs.setInt(
      _appOpenLastShownKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // ── Interstitial ───────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (_adsDisabled || _loadingInterstitial || _interstitialAd != null) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdUnits.interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  /// Call at natural breakpoints. Fires an ad if all conditions are met.
  Future<void> onTrigger(String trigger) async {
    if (_adsDisabled) return;

    _sessionCounts[trigger] = (_sessionCounts[trigger] ?? 0) + 1;
    if ((_sessionCounts[trigger] ?? 0) < _kSessionThreshold) return;
    if (!await _underDailyCap()) return;
    if (!await _gapElapsed()) return;

    await _showInterstitial();
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

  Future<void> _showInterstitial() async {
    if (_interstitialAd == null || _isShowingFullScreenAd) return;

    final ad = _interstitialAd!;
    _interstitialAd = null;
    _isShowingFullScreenAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (dismissedAd) {
        _isShowingFullScreenAd = false;
        _suppressAppOpenUntil = DateTime.now().add(_kPostDismissSuppress);
        dismissedAd.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (failedAd, _) {
        _isShowingFullScreenAd = false;
        _suppressAppOpenUntil = DateTime.now().add(_kPostDismissSuppress);
        failedAd.dispose();
        _loadInterstitial();
      },
    );

    await ad.show();

    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_dailyCountKey) ?? 0) + 1;
    await prefs.setInt(_dailyCountKey, count);
    await prefs.setInt(_lastShownKey, DateTime.now().millisecondsSinceEpoch);

    _sessionCounts.clear();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}
