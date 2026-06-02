import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entitlement IDs that must match what's configured in RevenueCat dashboard.
const _kEntitlementPlus = 'plus';
const _kEntitlementPremium = 'premium';

/// RevenueCat product identifiers (must match Play Console / App Store).
const kProductPlusMonthly = 'budjit_plus_monthly';
const kProductPremiumMonthly = 'budjit_premium_monthly';
const kProductLifetime = 'budjit_lifetime';

enum PlanTier { free, plus, premium }

class PremiumStatus {
  final PlanTier tier;
  final DateTime? expiresAt;

  const PremiumStatus({required this.tier, this.expiresAt});

  bool get isFree => tier == PlanTier.free;
  bool get isPlus => tier == PlanTier.plus || tier == PlanTier.premium;
  bool get isPremium => tier == PlanTier.premium;

  String get displayName => switch (tier) {
        PlanTier.free => 'Free',
        PlanTier.plus => 'Plus',
        PlanTier.premium => 'Premium',
      };
}

class PremiumService {
  static const _cacheKey = 'premium_tier_v1';

  /// Fetch current subscription status from RevenueCat.
  /// Falls back to SharedPreferences cache on network failure.
  static Future<PremiumStatus> fetchStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final active = info.entitlements.active;

      PlanTier tier;
      if (active.containsKey(_kEntitlementPremium)) {
        tier = PlanTier.premium;
      } else if (active.containsKey(_kEntitlementPlus)) {
        tier = PlanTier.plus;
      } else {
        tier = PlanTier.free;
      }

      // Cache for offline use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, tier.name);

      return PremiumStatus(tier: tier);
    } catch (e) {
      if (kDebugMode) debugPrint('[PremiumService] fetchStatus error: $e');
      // Use cached tier if RevenueCat unavailable
      return _fromCache();
    }
  }

  static Future<PremiumStatus> _fromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_cacheKey) ?? 'free';
    final tier = PlanTier.values.firstWhere(
      (t) => t.name == name,
      orElse: () => PlanTier.free,
    );
    return PremiumStatus(tier: tier);
  }

  /// Attempt a purchase. Returns updated status on success.
  static Future<PremiumStatus?> purchase(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return null;

      Package? pkg;
      for (final p in current.availablePackages) {
        if (p.storeProduct.identifier == productId) {
          pkg = p;
          break;
        }
      }
      if (pkg == null) return null;

      await Purchases.purchasePackage(pkg);
      return await fetchStatus();
    } catch (e) {
      if (kDebugMode) debugPrint('[PremiumService] purchase error: $e');
      return null;
    }
  }

  /// Restore previous purchases (e.g. after reinstall).
  static Future<PremiumStatus> restore() async {
    try {
      await Purchases.restorePurchases();
      return fetchStatus();
    } catch (e) {
      if (kDebugMode) debugPrint('[PremiumService] restore error: $e');
      return const PremiumStatus(tier: PlanTier.free);
    }
  }
}
