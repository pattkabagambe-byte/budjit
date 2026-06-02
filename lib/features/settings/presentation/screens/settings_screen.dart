import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/app_preferences.dart';
import '../../../../core/models/layout_mode.dart';
import '../../../../core/providers/app_preferences_provider.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/layout_provider.dart';
import '../../../../core/services/premium_service.dart';
import '../../../../core/engagement/app_share_service.dart';
import '../../../../core/review/review_service.dart';
import '../../../../core/support/support_sheet.dart';
import '../../../../core/widgets/made_in_kasese.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../categories/presentation/screens/categories_screen.dart';
import '../../../export/analytics_export_service.dart';
import '../../../premium/presentation/screens/premium_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull ??
        FirebaseAuth.instance.currentUser;
    final isPremium = ref.watch(isPremiumProvider);
    final planTier = ref.watch(planTierProvider);
    final currency = ref.watch(currencyProvider);
    final layoutState = ref.watch(layoutModeProvider);
    final preferences = ref.watch(appPreferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBg : AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(
                  user: user, isPremium: isPremium, isDark: isDark),
            ),
            title: const Text('Settings'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  // Current plan card — always visible
                  _CurrentPlanCard(
                    tier: planTier,
                    onUpgrade: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PremiumScreen()),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account section
                  _SettingsSection(
                    title: 'Account',
                    isDark: isDark,
                    items: [
                      if (user == null || user.isAnonymous)
                        InfoTile(
                          icon: Icons.login_rounded,
                          title: 'Sign In',
                          subtitle: 'Sync your data across devices',
                          iconColor: AppColors.sky,
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const AuthScreen(isLinking: true),
                          )),
                        )
                      else ...[
                        InfoTile(
                          icon: Icons.person_rounded,
                          title: user.displayName ?? 'Account',
                          subtitle: user.email ?? 'Anonymous',
                          iconColor: AppColors.emerald,
                        ),
                        InfoTile(
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          iconColor: AppColors.rose,
                          onTap: () => _signOut(context),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Appearance
                  _SettingsSection(
                    title: 'Appearance',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title: 'Theme',
                        subtitle: preferences.theme.label,
                        iconColor: AppColors.violet,
                        onTap: () => _showChoicePicker<AppThemePreference>(
                          context,
                          title: 'Theme',
                          values: AppThemePreference.values,
                          selected: preferences.theme,
                          label: (value) => value.label,
                          onSelected: (value) => ref
                              .read(appPreferencesProvider.notifier)
                              .update(preferences.copyWith(theme: value)),
                        ),
                      ),
                      InfoTile(
                        icon: Icons.density_medium_rounded,
                        title: 'Compact mode',
                        subtitle: 'Fit more information on each screen',
                        iconColor: AppColors.primary,
                        trailing: Switch(
                          value: preferences.compactMode,
                          onChanged: (value) => ref
                              .read(appPreferencesProvider.notifier)
                              .update(preferences.copyWith(compactMode: value)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Planner preferences
                  _SettingsSection(
                    title: 'Budget Planner',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.view_quilt_outlined,
                        title: 'View Mode',
                        subtitle:
                            '${layoutState.preferredMode.label} opens by default',
                        iconColor: AppColors.primary,
                        onTap: () =>
                            _showViewModePicker(context, ref, layoutState),
                      ),
                      InfoTile(
                        icon: Icons.play_circle_outline_rounded,
                        title: 'Switch now',
                        subtitle: layoutState.activeMode ==
                                layoutState.preferredMode
                            ? '${layoutState.activeMode.label} is currently open'
                            : 'Open ${layoutState.preferredMode.label}',
                        iconColor: AppColors.sky,
                        onTap:
                            layoutState.activeMode == layoutState.preferredMode
                                ? null
                                : () => _switchMode(
                                      context,
                                      ref,
                                      layoutState.preferredMode,
                                    ),
                      ),
                      InfoTile(
                        icon: Icons.calendar_view_month_rounded,
                        title: 'Default report period',
                        subtitle: preferences.reportPeriod.label,
                        iconColor: AppColors.amber,
                        onTap: () => _showChoicePicker<PlannerReportPeriod>(
                          context,
                          title: 'Default report period',
                          values: PlannerReportPeriod.values,
                          selected: preferences.reportPeriod,
                          label: (value) => value.label,
                          onSelected: (value) =>
                              ref.read(appPreferencesProvider.notifier).update(
                                    preferences.copyWith(reportPeriod: value),
                                  ),
                        ),
                      ),
                      InfoTile(
                        icon: Icons.event_note_rounded,
                        title: 'Starting day of week',
                        subtitle: preferences.weekStart.label,
                        iconColor: AppColors.teal,
                        onTap: () => _showChoicePicker<WeekStart>(
                          context,
                          title: 'Starting day of week',
                          values: WeekStart.values,
                          selected: preferences.weekStart,
                          label: (value) => value.label,
                          onSelected: (value) => ref
                              .read(appPreferencesProvider.notifier)
                              .update(preferences.copyWith(weekStart: value)),
                        ),
                      ),
                      InfoTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Budget style',
                        subtitle: preferences.budgetStyle.label,
                        iconColor: AppColors.violet,
                        onTap: () => _showChoicePicker<BudgetStyle>(
                          context,
                          title: 'Budget style',
                          values: BudgetStyle.values,
                          selected: preferences.budgetStyle,
                          label: (value) => value.label,
                          onSelected: (value) => ref
                              .read(appPreferencesProvider.notifier)
                              .update(preferences.copyWith(budgetStyle: value)),
                        ),
                      ),
                      InfoTile(
                        icon: Icons.pin_outlined,
                        title: 'Show decimals',
                        subtitle: 'Use precise values where supported',
                        iconColor: AppColors.orange,
                        trailing: Switch(
                          value: preferences.showDecimals,
                          onChanged: (value) => ref
                              .read(appPreferencesProvider.notifier)
                              .update(
                                  preferences.copyWith(showDecimals: value)),
                        ),
                      ),
                      InfoTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Confirm before delete',
                        subtitle: 'Ask before removing planner entries',
                        iconColor: AppColors.rose,
                        trailing: Switch(
                          value: preferences.confirmBeforeDelete,
                          onChanged: (value) =>
                              ref.read(appPreferencesProvider.notifier).update(
                                    preferences.copyWith(
                                      confirmBeforeDelete: value,
                                    ),
                                  ),
                        ),
                      ),
                      InfoTile(
                        icon: Icons.vibration_rounded,
                        title: 'Haptic feedback',
                        subtitle: 'Gentle feedback for key actions',
                        iconColor: AppColors.sky,
                        trailing: Switch(
                          value: preferences.hapticFeedback,
                          onChanged: (value) =>
                              ref.read(appPreferencesProvider.notifier).update(
                                    preferences.copyWith(hapticFeedback: value),
                                  ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _SettingsSection(
                    title: 'Currency',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.attach_money_rounded,
                        title: 'Default currency',
                        subtitle: currency,
                        iconColor: AppColors.amber,
                        onTap: () =>
                            _showCurrencyPicker(context, ref, currency),
                        trailing: Text(
                          currency,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Data
                  _SettingsSection(
                    title: 'Data & Backup',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.cloud_sync_rounded,
                        title: 'Sync Status',
                        subtitle: 'Data backed up',
                        iconColor: AppColors.sky,
                        trailing: const Icon(Icons.check_circle_rounded,
                            color: AppColors.emerald, size: 18),
                      ),
                      InfoTile(
                        icon: Icons.category_outlined,
                        title: 'Manage Categories',
                        subtitle: 'Add custom categories with emoji',
                        iconColor: AppColors.violet,
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        )),
                      ),
                      InfoTile(
                        icon: Icons.file_download_outlined,
                        title: 'Export Data',
                        subtitle: 'Download as Excel or PDF',
                        iconColor: AppColors.teal,
                        onTap: () => _showExportSheet(context, ref),
                      ),
                      InfoTile(
                        icon: Icons.backup_outlined,
                        title: 'Backup',
                        subtitle: 'Keep a secure copy of your data',
                        iconColor: AppColors.sky,
                        onTap: () => _showMessage(
                          context,
                          'Cloud backup will be available for signed-in accounts',
                        ),
                      ),
                      InfoTile(
                        icon: Icons.restore_rounded,
                        title: 'Restore',
                        subtitle: 'Recover a previous backup',
                        iconColor: AppColors.teal,
                        onTap: () => _showMessage(
                          context,
                          'Restore tools will appear when a backup is available',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _SettingsSection(
                    title: 'Notifications',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.notifications_outlined,
                        title: 'Budget alerts and reminders',
                        subtitle:
                            'Helpful nudges when spending needs attention',
                        iconColor: AppColors.orange,
                        trailing: Switch(
                          value: preferences.notifications,
                          onChanged: (value) =>
                              ref.read(appPreferencesProvider.notifier).update(
                                    preferences.copyWith(notifications: value),
                                  ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _SettingsSection(
                    title: 'Privacy & Security',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How Cashflo protects your data',
                        iconColor: AppColors.violet,
                        onTap: () =>
                            launchUrl(Uri.parse('https://cashflo.app/privacy')),
                      ),
                      InfoTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'App security',
                        subtitle:
                            'Your local data stays private on this device',
                        iconColor: AppColors.teal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Support
                  _SettingsSection(
                    title: 'Help & Support',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.star_rate_rounded,
                        title: 'Rate Cashflo',
                        subtitle: 'Share your experience on the store',
                        iconColor: AppColors.amber,
                        onTap: () => ReviewService.instance
                            .requestReviewFromSettings(context),
                      ),
                      InfoTile(
                        icon: Icons.ios_share_rounded,
                        title: 'Share Cashflo',
                        subtitle: 'Invite friends to try the app',
                        iconColor: AppColors.emerald,
                        onTap: () => AppShareService.shareApp(),
                      ),
                      InfoTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'Email or WhatsApp — contact details stay private',
                        iconColor: AppColors.sky,
                        onTap: () =>
                            SupportSheet.show(context, appName: 'Cashflo'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Version
                  const Text(
                    'ABOUT',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (_, snap) => Text(
                      snap.hasData ? 'Cashflo v${snap.data!.version}' : 'Cashflo',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const MadeInKaseseLabel(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showViewModePicker(
    BuildContext context,
    WidgetRef ref,
    LayoutModeState layoutState,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'View Mode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose which Budget Planner layout opens by default.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              for (final mode in LayoutMode.values)
                ListTile(
                  minTileHeight: 68,
                  leading: Icon(
                    mode == LayoutMode.defaultMode
                        ? Icons.view_agenda_rounded
                        : Icons.tab_rounded,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    mode.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(mode.description),
                  trailing: layoutState.preferredMode == mode
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.emerald,
                        )
                      : null,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await ref
                        .read(layoutModeProvider.notifier)
                        .setPreferredMode(mode, switchNow: false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${mode.label} is now your preferred view',
                          ),
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _switchMode(
    BuildContext context,
    WidgetRef ref,
    LayoutMode mode,
  ) async {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to ${mode.label}')),
    );
    await ref.read(layoutModeProvider.notifier).switchMode(mode);
  }

  void _showChoicePicker<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required T selected,
    required String Function(T value) label,
    required Future<void> Function(T value) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final value in values)
                ListTile(
                  title: Text(
                    label(value),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: value == selected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.emerald,
                        )
                      : null,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await onSelected(value);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your data will remain on this device.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.rose),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(
      BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kCurrencies.length,
        itemBuilder: (_, i) {
          final c = kCurrencies[i];
          return ListTile(
            title: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: c == current
                ? const Icon(Icons.check_rounded, color: AppColors.emerald)
                : null,
            onTap: () async {
              HapticFeedback.selectionClick();
              ref.read(currencyProvider.notifier).state = c;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('currency', c);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Export Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined,
                  color: AppColors.emerald),
              title: const Text('Export as Excel'),
              subtitle: const Text('Open in Excel or Sheets'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAllData(context, ref, asPdf: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined,
                  color: AppColors.rose),
              title: const Text('Export as PDF'),
              subtitle: const Text('Monthly analytics report'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAllData(context, ref, asPdf: true);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllData(BuildContext context, WidgetRef ref,
      {required bool asPdf}) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(asPdf ? 'Generating PDF…' : 'Generating Excel…')),
    );
    try {
      final userId = ref.read(currentUserIdProvider);
      final month = ref.read(selectedMonthProvider);
      final currency = ref.read(currencyProvider);
      final customCategories = ref.read(customTxCategoriesProvider(userId));
      final txs = await ref
          .read(databaseProvider)
          .getTransactions(userId, month: month);
      final income =
          txs.where((t) => t.isIncome).fold(0.0, (a, t) => a + t.amount);
      final expenses =
          txs.where((t) => !t.isIncome).fold(0.0, (a, t) => a + t.amount);
      final report = AnalyticsReport(
        month: month,
        currency: currency,
        income: income,
        expenses: expenses,
        transactions: txs,
        customCategories: customCategories,
      );
      if (asPdf) {
        await AnalyticsExportService.exportPdf(report);
      } else {
        await AnalyticsExportService.exportExcel(report);
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;
  final bool isPremium;
  final bool isDark;

  const _ProfileHeader(
      {required this.user, required this.isPremium, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'Guest User';
    final email = user?.email;
    return Container(
      color: isDark ? AppColors.darkBg : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          UserAvatar(photoUrl: user?.photoURL, displayName: name, radius: 40),
          const SizedBox(height: 12),
          Text(name,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.navy)),
          if (email != null)
            Text(email,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          if (isPremium) const PremiumBadge(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final bool isDark;

  const _SettingsSection(
      {required this.title, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => items[i],
          ),
        ),
      ],
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  final PlanTier tier;
  final VoidCallback onUpgrade;

  const _CurrentPlanCard({required this.tier, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    if (tier == PlanTier.free) return _FreePlanCard(onUpgrade: onUpgrade);
    if (tier == PlanTier.plus)
      return _PaidPlanCard(tier: tier, onUpgrade: onUpgrade, label: 'Plus');
    return _PaidPlanCard(tier: tier, onUpgrade: onUpgrade, label: 'Premium');
  }
}

class _FreePlanCard extends StatelessWidget {
  final VoidCallback onUpgrade;
  const _FreePlanCard({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpgrade,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.gradientViolet,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'FREE PLAN',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 22),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Unlock the full Cashflo experience',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'AI coach · Deep analytics · No ads · Export · Sync',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'See plans & pricing →',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.violet,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaidPlanCard extends StatelessWidget {
  final PlanTier tier;
  final VoidCallback onUpgrade;
  final String label;

  const _PaidPlanCard(
      {required this.tier, required this.onUpgrade, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = tier == PlanTier.premium ? AppColors.violet : AppColors.sky;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cashflo $label',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15, color: color),
                ),
                const Text(
                  'You have full access — enjoy!',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.emerald, size: 22),
        ],
      ),
    );
  }
}
