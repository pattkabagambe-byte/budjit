import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportSheet extends StatelessWidget {
  final String appName;
  const SupportSheet({super.key, required this.appName});

  static void show(BuildContext context, {required String appName}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SupportSheet(appName: appName),
    );
  }

  Future<void> _openEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'motuspotentia@gmail.com',
      queryParameters: {
        'subject': '$appName — Support Request',
      },
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/256772844881'
      '?text=${Uri.encodeComponent('Hi, I need help with $appName.')}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get Help',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Potentia Motus Ventures',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _ContactTile(
              icon: Icons.email_rounded,
              label: 'Send us an email',
              sublabel: 'We reply within 24 hours',
              onTap: () => _openEmail(context),
            ),
            const SizedBox(height: 12),
            _ContactTile(
              icon: Icons.chat_rounded,
              label: 'Chat on WhatsApp',
              sublabel: 'Quick support via WhatsApp',
              onTap: () => _openWhatsApp(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Material(
      color: primary.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    Text(sublabel, style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
