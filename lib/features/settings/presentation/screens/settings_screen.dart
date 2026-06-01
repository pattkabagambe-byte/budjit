import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/review/review_service.dart';
import '../../../../core/support/support_sheet.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../premium/presentation/screens/premium_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isPremium = ref.watch(isPremiumProvider);
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
                  // Premium banner
                  if (!isPremium)
                    _PremiumBanner(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const PremiumScreen(),
                      )),
                    ),

                  const SizedBox(height: 20),

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
                        icon: Icons.file_download_outlined,
                        title: 'Export Data',
                        subtitle: 'Download as CSV or PDF',
                        iconColor: AppColors.teal,
                        onTap: () => _showExportSheet(context),
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

  void _showExportSheet(BuildContext context) {
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
              title: const Text('Export as CSV'),
              subtitle: const Text('Open in Excel or Sheets'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export — upgrade to Premium')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.rose),
              title: const Text('Export as PDF'),
              subtitle: const Text('Monthly report'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export — upgrade to Premium')),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.emerald.withOpacity(0.2),
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.emerald))
                : null,
          ),
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

class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.gradientViolet,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade to Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('AI coach, deep analytics, no ads', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Text('Upgrade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
