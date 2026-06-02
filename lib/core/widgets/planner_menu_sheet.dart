import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engagement/app_share_service.dart';
import '../models/layout_mode.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/layout_provider.dart';
import '../support/support_sheet.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class PlannerMenuSheet {
  static Future<void> show(
    BuildContext context, {
    required LayoutMode currentMode,
    required VoidCallback onOpenSettings,
    required VoidCallback onExportReport,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PlannerMenuContent(
        currentMode: currentMode,
        onOpenSettings: onOpenSettings,
        onExportReport: onExportReport,
      ),
    );
  }
}

class _PlannerMenuContent extends ConsumerWidget {
  const _PlannerMenuContent({
    required this.currentMode,
    required this.onOpenSettings,
    required this.onExportReport,
  });

  final LayoutMode currentMode;
  final VoidCallback onOpenSettings;
  final VoidCallback onExportReport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferred = ref.watch(layoutModeProvider).preferredMode;
    final otherMode = currentMode == LayoutMode.defaultMode
        ? LayoutMode.tabbedMode
        : LayoutMode.defaultMode;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget Planner', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${currentMode.label} is open',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionTile(
              icon: Icons.swap_horiz_rounded,
              title: 'Switch to ${otherMode.label}',
              subtitle: 'Preview the other planner layout now',
              onTap: () => _switchMode(context, ref, otherMode),
            ),
            _ActionTile(
              icon: Icons.push_pin_outlined,
              title: 'Set current mode as default',
              subtitle: preferred == currentMode
                  ? '${currentMode.label} is already preferred'
                  : 'Always open Budget Planner in ${currentMode.label}',
              onTap: preferred == currentMode
                  ? null
                  : () => _setCurrentAsDefault(context, ref),
            ),
            const Divider(height: AppSpacing.lg),
            _ActionTile(
              icon: Icons.ios_share_rounded,
              title: 'Export report',
              subtitle: 'Open reporting and export options',
              onTap: () => _run(context, onExportReport),
            ),
            _ActionTile(
              icon: Icons.share_rounded,
              title: 'Share Budjit',
              subtitle: 'Tell friends about the app',
              onTap: () {
                Navigator.pop(context);
                AppShareService.shareApp();
              },
            ),
            _ActionTile(
              icon: Icons.cloud_upload_outlined,
              title: 'Backup and restore',
              subtitle: 'Manage local and cloud data tools',
              onTap: () => _showUnavailable(
                context,
                'Backup tools are managed in Settings',
              ),
            ),
            _ActionTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'Planner preferences, currency, and account',
              onTap: () => _run(context, onOpenSettings),
            ),
            _ActionTile(
              icon: Icons.help_outline_rounded,
              title: 'Help',
              subtitle: 'Get support and answers',
              onTap: () {
                Navigator.pop(context);
                SupportSheet.show(context, appName: 'Budjit');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchMode(
    BuildContext context,
    WidgetRef ref,
    LayoutMode mode,
  ) async {
    if (ref.read(appPreferencesProvider).hapticFeedback) {
      HapticFeedback.selectionClick();
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('Switched to ${mode.label}')),
    );
    await ref.read(layoutModeProvider.notifier).switchMode(mode);
  }

  Future<void> _setCurrentAsDefault(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (ref.read(appPreferencesProvider).hapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    await ref.read(layoutModeProvider.notifier).setCurrentModeAsPreferred();
    messenger.showSnackBar(
      SnackBar(
          content: Text('${currentMode.label} is now your preferred view')),
    );
  }

  void _run(BuildContext context, VoidCallback callback) {
    Navigator.pop(context);
    callback();
  }

  void _showUnavailable(BuildContext context, String message) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: onTap != null,
      contentPadding: EdgeInsets.zero,
      minTileHeight: 58,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: AppColors.primary, size: 21),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded, size: 19),
      onTap: onTap,
    );
  }
}
