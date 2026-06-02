import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import '../services/premium_service.dart';

// ── Database ─────────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── Auth ─────────────────────────────────────────────────────────────────────

final currentUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  return user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'local';
});

// ── Preferences ──────────────────────────────────────────────────────────────

final prefsProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

// ── Currency ─────────────────────────────────────────────────────────────────

final currencyProvider = StateProvider<String>((ref) {
  return 'UGX'; // Will be overridden from prefs on startup
});

// ── Onboarding ───────────────────────────────────────────────────────────────

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete_v2') ?? false;
});

// ── Selected Month ───────────────────────────────────────────────────────────

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ── Transactions ─────────────────────────────────────────────────────────────

final transactionsStreamProvider =
    StreamProvider.family<List<TxEntry>, ({String userId, DateTime month})>(
  (ref, params) => ref
      .watch(databaseProvider)
      .watchTransactions(params.userId, month: params.month),
);

final allTransactionsStreamProvider =
    StreamProvider.family<List<TxEntry>, String>(
  (ref, userId) =>
      ref.watch(databaseProvider).watchTransactions(userId),
);

// ── Budgets ───────────────────────────────────────────────────────────────────

final budgetsStreamProvider = StreamProvider.family<List<Budget>, String>(
  (ref, userId) => ref.watch(databaseProvider).watchBudgets(userId),
);

// ── Goals ─────────────────────────────────────────────────────────────────────

final goalsStreamProvider = StreamProvider.family<List<GoalEntry>, String>(
  (ref, userId) => ref.watch(databaseProvider).watchGoals(userId),
);

// ── Subscriptions ─────────────────────────────────────────────────────────────

final subscriptionsStreamProvider = StreamProvider.family<List<SubEntry>, String>(
  (ref, userId) => ref.watch(databaseProvider).watchSubscriptions(userId),
);

// ── Premium status ────────────────────────────────────────────────────────────

/// Fetched once at startup; invalidate to re-check after a purchase.
final premiumStatusProvider = FutureProvider<PremiumStatus>((ref) {
  return PremiumService.fetchStatus();
});

final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(premiumStatusProvider).valueOrNull?.isPremium ?? false;
});

final isPlusProvider = Provider<bool>((ref) {
  return ref.watch(premiumStatusProvider).valueOrNull?.isPlus ?? false;
});

final planTierProvider = Provider<PlanTier>((ref) {
  return ref.watch(premiumStatusProvider).valueOrNull?.tier ?? PlanTier.free;
});
