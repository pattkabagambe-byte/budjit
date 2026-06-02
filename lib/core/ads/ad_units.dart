import 'package:flutter/foundation.dart';

/// AdMob identifiers for Cashflo.
abstract final class AdUnits {
  static const String appId = 'ca-app-pub-9402272089735179~8466069560';

  static const String appOpen = 'ca-app-pub-9402272089735179/2686139591';
  static const String interstitial = 'ca-app-pub-9402272089735179/7746894585';

  // Google sample ad units — used in debug builds only.
  static const String testAppOpen = 'ca-app-pub-3940256099942544/9257395921';
  static const String testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  static String get appOpenId => kDebugMode ? testAppOpen : appOpen;
  static String get interstitialId =>
      kDebugMode ? testInterstitial : interstitial;
}
