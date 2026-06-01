import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/premium_service.dart';
import '../../../../core/review/review_service.dart';
import '../../../../core/support/support_sheet.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    final isPremium = ref.watch(isPremiumProvider);
    final planTier = ref.watch(planTierProvider);
    final currency = ref.watch(currencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBg : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHeader(user: user, isPremium: isPremium, isDark: isDark),
            ),
            title: const Text('Profile'),
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
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
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

                  // Preferences
                  _SettingsSection(
                    title: 'Preferences',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.attach_money_rounded,
                        title: 'Currency',
                        subtitle: currency,
                        iconColor: AppColors.amber,
                        onTap: () => _showCurrencyPicker(context, ref, currency),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(currency, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey)),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                      InfoTile(
                        icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        title: 'Appearance',
                        subtitle: isDark ? 'Dark mode' : 'Light mode',
                        iconColor: AppColors.violet,
                        trailing: const Text('System', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                      InfoTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Budget alerts and reminders',
                        iconColor: AppColors.orange,
                        trailing: Switch(
                          value: true,
                          onChanged: (_) {},
                          activeColor: AppColors.emerald,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Data
                  _SettingsSection(
                    title: 'Data',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.cloud_sync_rounded,
                        title: 'Sync Status',
                        subtitle: 'Data backed up',
                        iconColor: AppColors.sky,
                        trailing: const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                      ),
                      InfoTile(
                        icon: Icons.category_outlined,
                        title: 'Manage Categories',
                        subtitle: 'Add custom categories with emoji',
                        iconColor: AppColors.violet,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
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
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Support
                  _SettingsSection(
                    title: 'Support',
                    isDark: isDark,
                    items: [
                      InfoTile(
                        icon: Icons.star_rate_rounded,
                        title: 'Rate Budjit',
                        subtitle: 'Leave us a review',
                        iconColor: AppColors.amber,
                        onTap: () => ReviewService.instance.onAppOpened(),
                      ),
                      InfoTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        iconColor: AppColors.sky,
                        onTap: () => SupportSheet.show(context, appName: 'Budjit'),
                      ),
                      InfoTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        iconColor: AppColors.violet,
                        onTap: () => launchUrl(Uri.parse('https://budjit.app/privacy')),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Version
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (_, snap) => Text(
                      snap.hasData ? 'Budjit v${snap.data!.version}' : 'Budjit',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Made with ❤️ for Africa & beyond', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your data will remain on this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kCurrencies.length,
        itemBuilder: (_, i) {
          final c = kCurrencies[i];
          return ListTile(
            title: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: c == current ? const Icon(Icons.check_rounded, color: AppColors.emerald) : null,
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(currencyProvider.notifier).state = c;
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
              child: Text('Export Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined, color: AppColors.emerald),
              title: const Text('Export as Excel'),
              subtitle: const Text('Open in Excel or Sheets'),
              onTap: () async {
                Navigator.pop(context);
                await _exportAllData(context, ref, asPdf: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.rose),
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

  Future<void> _exportAllData(BuildContext context, WidgetRef ref, {required bool asPdf}) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(asPdf ? 'Generating PDF…' : 'Generating Excel…')),
    );
    try {
      final userId = ref.read(currentUserIdProvider);
      final month = ref.read(selectedMonthProvider);
      final currency = ref.read(currencyProvider);
      final customCategories = ref.read(customTxCategoriesProvider(userId));
      final txs = await ref.read(databaseProvider).getTransactions(userId, month: month);
      final income = txs.where((t) => t.isIncome).fold(0.0, (a, t) => a + t.amount);
      final expenses = txs.where((t) => !t.isIncome).fold(0.0, (a, t) => a + t.amount);
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

  const _ProfileHeader({required this.user, required this.isPremium, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'Guest User';
    final email = user?.email;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return Container(
      color: isDark ? AppColors.darkBg : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          UserAvatar(photoUrl: user?.photoURL, displayName: name, radius: 40),
          const SizedBox(height: 12),
          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.navy)),
          if (email != null) Text(email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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

  const _SettingsSection({required this.title, required this.items, required this.isDark});

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
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
    if (tier == PlanTier.plus) return _PaidPlanCard(tier: tier, onUpgrade: onUpgrade, label: 'Plus');
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'FREE PLAN',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Unlock the full Budjit experience',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
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

  const _PaidPlanCard({required this.tier, required this.onUpgrade, required this.label});

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
                  'Budjit $label',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
                ),
                const Text(
                  'You have full access — enjoy!',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 22),
        ],
      ),
    );
  }
}
