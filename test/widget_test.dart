import 'package:budjit/core/database/app_database.dart';
import 'package:budjit/core/models/app_preferences.dart';
import 'package:budjit/core/models/layout_mode.dart';
import 'package:budjit/core/providers/app_preferences_provider.dart';
import 'package:budjit/core/providers/layout_provider.dart';
import 'package:budjit/core/services/user_profile_service.dart';
import 'package:budjit/core/theme/app_colors.dart';
import 'package:budjit/core/theme/app_theme.dart';
import 'package:budjit/core/theme/app_tokens.dart';
import 'package:budjit/core/widgets/shared_widgets.dart';
import 'package:budjit/features/budget_planner/domain/planner_report.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('premium theme', () {
    test('uses the tabbed burgundy and cream direction app-wide', () {
      expect(AppColors.primary, const Color(0xFF8A2638));
      expect(AppColors.background, const Color(0xFFFAF4EA));
      expect(AppColors.card, const Color(0xFFFFF9F2));
      expect(AppColors.blush, const Color(0xFFE9D7D9));
      expect(AppColors.gold, const Color(0xFFD7B679));
      expect(AppColors.textPrimary, const Color(0xFF241B1D));
      expect(AppColors.tabPrimary, AppColors.primary);
      expect(AppColors.tabBg, AppColors.background);
      expect(AppTheme.primary, AppColors.primary);
      expect(AppTheme.surface, AppColors.background);
      expect(AppRadius.lg, 22);
      expect(AppSpacing.md, 16);
      expect(AppComponents.buttonHeight, 58);
    });
  });

  group('layout mode preferences', () {
    test('existing users stay on default mode until they choose otherwise',
        () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = LayoutModeNotifier(
        profileService: _NoopProfileService(),
      );
      await _settle();

      expect(notifier.state.loaded, isTrue);
      expect(notifier.state.activeMode, LayoutMode.defaultMode);
      expect(notifier.state.preferredMode, LayoutMode.defaultMode);
      notifier.dispose();
    });

    test('preview switch does not overwrite the preferred mode', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = LayoutModeNotifier(
        profileService: _NoopProfileService(),
      );
      await _settle();

      await notifier.switchMode(LayoutMode.tabbedMode);

      expect(notifier.state.activeMode, LayoutMode.tabbedMode);
      expect(notifier.state.preferredMode, LayoutMode.defaultMode);
      notifier.dispose();
    });

    test('tabbed preference survives an app restart', () async {
      SharedPreferences.setMockInitialValues({});
      final profileService = _NoopProfileService();
      final notifier = LayoutModeNotifier(profileService: profileService);
      await _settle();

      await notifier.setPreferredMode(LayoutMode.tabbedMode);
      notifier.dispose();

      final restarted = LayoutModeNotifier(profileService: profileService);
      await _settle();
      expect(restarted.state.activeMode, LayoutMode.tabbedMode);
      expect(restarted.state.preferredMode, LayoutMode.tabbedMode);
      restarted.dispose();
    });

    test('migrates the earlier tabbed preference without changing it',
        () async {
      SharedPreferences.setMockInitialValues({
        legacyLayoutModePreferenceKey: LayoutMode.tabbedMode.name,
      });
      final notifier = LayoutModeNotifier(
        profileService: _NoopProfileService(),
      );
      await _settle();
      final preferences = await SharedPreferences.getInstance();

      expect(notifier.state.activeMode, LayoutMode.tabbedMode);
      expect(
        preferences.getString(layoutModePreferenceKey),
        LayoutMode.tabbedMode.name,
      );
      notifier.dispose();
    });
  });

  group('settings preferences', () {
    test('persist report, theme, delete, and feedback settings', () async {
      SharedPreferences.setMockInitialValues({});
      final profileService = _NoopProfileService();
      final notifier = AppPreferencesNotifier(profileService: profileService);
      await _settle();

      await notifier.update(
        notifier.state.copyWith(
          theme: AppThemePreference.dark,
          reportPeriod: PlannerReportPeriod.quarterly,
          showDecimals: true,
          confirmBeforeDelete: false,
          hapticFeedback: false,
        ),
      );
      notifier.dispose();

      final restarted = AppPreferencesNotifier(profileService: profileService);
      await _settle();
      expect(restarted.state.theme, AppThemePreference.dark);
      expect(restarted.state.reportPeriod, PlannerReportPeriod.quarterly);
      expect(restarted.state.showDecimals, isTrue);
      expect(restarted.state.confirmBeforeDelete, isFalse);
      expect(restarted.state.hapticFeedback, isFalse);
      restarted.dispose();
    });
  });

  group('shared planner data and reports', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('income, planned expense, actual expense, and delete share one store',
        () async {
      final date = DateTime(2026, 6, 2);
      await database.upsertTransaction(
        _transaction(
          id: 'income',
          title: 'Salary',
          amount: 1000,
          isIncome: true,
          category: 'salary',
          date: date,
        ),
      );
      await database.upsertBudget(
        Budget(
          id: 'food-plan',
          userId: 'user',
          label: 'Food plan',
          category: 'food',
          limitAmount: 400,
          period: 'monthly',
          createdAt: date,
        ),
      );
      await database.upsertTransaction(
        _transaction(
          id: 'expense',
          title: 'Lunch',
          amount: 125,
          isIncome: false,
          category: 'food',
          date: date,
        ),
      );

      final transactions = await database.getTransactions('user');
      final budgets = await database.getBudgets('user');
      final report = PlannerReportCalculator.calculate(
        transactions: transactions,
        budgets: budgets,
      );

      expect(report.income, 1000);
      expect(report.actualExpenses, 125);
      expect(report.totalBudgeted, 400);
      expect(report.unassignedCash, 600);
      expect(report.actualLeft, 875);
      expect(report.spendingByCategory['food'], 125);

      await database.deleteTransaction('expense');
      expect(await database.getTransactions('user'), hasLength(1));
    });

    test('report periods produce predictable ranges', () {
      final now = DateTime(2026, 6, 2);
      expect(
        PlannerReportPeriod.monthly.range(now: now),
        (DateTime(2026, 6), DateTime(2026, 7, 0)),
      );
      expect(
        PlannerReportPeriod.quarterly.range(now: now),
        (DateTime(2026, 4), DateTime(2026, 7, 0)),
      );
    });
  });

  group('profile avatars', () {
    test('profile metadata generates a two-letter initials fallback', () {
      final metadata = UserProfileMetadata(
        userId: 'user',
        displayName: 'Ada Lovelace',
        email: 'ada@example.com',
        photoUrl: null,
        updatedAt: DateTime(2026),
      );

      expect(metadata.initials, 'AL');
    });

    testWidgets('avatar shows initials when no Google photo exists',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              photoUrl: null,
              displayName: 'Ada Lovelace',
            ),
          ),
        ),
      );

      expect(find.text('AL'), findsOneWidget);
    });

    testWidgets('avatar renders a network image for a Google profile photo',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              photoUrl: 'https://example.com/ada.jpg',
              displayName: 'Ada Lovelace',
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });
}

TxEntry _transaction({
  required String id,
  required String title,
  required double amount,
  required bool isIncome,
  required String category,
  required DateTime date,
}) {
  return TxEntry(
    id: id,
    userId: 'user',
    title: title,
    amount: amount,
    isIncome: isIncome,
    category: category,
    date: date,
    currency: 'UGX',
    synced: false,
  );
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

class _NoopProfileService extends UserProfileService {
  @override
  Future<void> syncPreferredViewMode(LayoutMode mode) async {}

  @override
  Future<LayoutMode?> loadPreferredViewMode(String userId) async => null;

  @override
  Future<void> syncAppPreferences(AppPreferences preferences) async {}
}
