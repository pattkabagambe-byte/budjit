import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

// ── User Avatar (handles network image + fallback initials) ───────────────────

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String displayName;
  final double radius;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.displayName,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final fontSize = radius * 0.7;

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.emerald.withValues(alpha: 0.18),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                // While loading — show initial behind it
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _Initial(initial, fontSize),
                // On error — show initial
                errorBuilder: (_, __, ___) => _Initial(initial, fontSize),
              )
            : _Initial(initial, fontSize),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String letter;
  final double fontSize;
  const _Initial(this.letter, this.fontSize);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.emerald.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: AppColors.emerald,
          fontWeight: FontWeight.w800,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

// ── Gradient Card ─────────────────────────────────────────────────────────────

class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.gradientNavy,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.emerald,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Stat Chip ────────────────────────────────────────────────────────────────

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.emerald,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Amount Badge ──────────────────────────────────────────────────────────────

class AmountBadge extends StatelessWidget {
  final double amount;
  final bool isIncome;
  final String currency;

  const AmountBadge({
    super.key,
    required this.amount,
    required this.isIncome,
    this.currency = 'UGX',
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? AppColors.emerald : AppColors.rose;
    final sign = isIncome ? '+' : '-';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$sign$currency ${_fmt(amount)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}

// ── Category Badge ────────────────────────────────────────────────────────────

class CategoryBadge extends StatelessWidget {
  final String category;
  final String emoji;
  final Color color;
  final double size;

  const CategoryBadge({
    super.key,
    required this.category,
    required this.emoji,
    required this.color,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Center(
        child: Text(emoji, style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────────────────────

class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double limit;
  final Color? color;

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.limit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final barColor = color ??
        (ratio > 0.9
            ? AppColors.rose
            : ratio > 0.7
                ? AppColors.amber
                : AppColors.emerald);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 6,
            backgroundColor: barColor.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(ratio * 100).toStringAsFixed(0)}% used',
          style: TextStyle(
            fontSize: 11,
            color: barColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 36, color: AppColors.emerald),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

// ── Shimmer Loader ────────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1A2540) : const Color(0xFFEEEEEE),
      highlightColor: isDark ? const Color(0xFF2A3A5C) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ── Premium Badge ─────────────────────────────────────────────────────────────

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppColors.gradientAmber,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 11, color: Colors.white),
          SizedBox(width: 3),
          Text(
            'PRO',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Health Score Ring ─────────────────────────────────────────────────────────

class HealthScoreRing extends StatelessWidget {
  final int score;
  final double size;

  const HealthScoreRing({super.key, required this.score, this.size = 80});

  Color get _color {
    if (score >= 80) return AppColors.emerald;
    if (score >= 60) return AppColors.sky;
    if (score >= 40) return AppColors.amber;
    return AppColors.rose;
  }

  String get _grade {
    if (score >= 80) return 'A';
    if (score >= 60) return 'B';
    if (score >= 40) return 'C';
    if (score >= 20) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: size * 0.1,
            backgroundColor: _color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(_color),
            strokeCap: StrokeCap.round,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w900,
                  color: _color,
                ),
              ),
              Text(
                _grade,
                style: TextStyle(
                  fontSize: size * 0.15,
                  fontWeight: FontWeight.w700,
                  color: _color.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info Tile ─────────────────────────────────────────────────────────────────

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBg;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? AppTheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg ?? color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  if (subtitle != null)
                    Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            if (trailing != null) trailing!
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
