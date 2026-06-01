import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import '../services/premium_service.dart';
import '../theme/app_colors.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';

/// Wraps [child] and shows a blurred lock overlay when the user is not on [requiredTier].
/// On tap of the overlay the PremiumScreen is pushed.
class PremiumGate extends ConsumerWidget {
  final Widget child;
  final PlanTier requiredTier;
  final String featureName;
  final String featureDescription;

  const PremiumGate({
    super.key,
    required this.child,
    this.requiredTier = PlanTier.plus,
    required this.featureName,
    this.featureDescription = 'Upgrade to unlock this feature.',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(planTierProvider);
    final unlocked = tier.index >= requiredTier.index;
    if (unlocked) return child;

    return Stack(
      children: [
        // Blurred/dimmed preview
        IgnorePointer(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Opacity(opacity: 0.4, child: child),
          ),
        ),
        // Lock overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: _LockBadge(
                  featureName: featureName,
                  requiredTier: requiredTier,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Inline lock banner — less intrusive, used inside list tiles or cards.
class PremiumLockBanner extends ConsumerWidget {
  final PlanTier requiredTier;
  final String featureName;

  const PremiumLockBanner({
    super.key,
    this.requiredTier = PlanTier.plus,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(planTierProvider);
    if (tier.index >= requiredTier.index) return const SizedBox.shrink();

    final color =
        requiredTier == PlanTier.premium ? AppColors.violet : AppColors.sky;
    final label = requiredTier == PlanTier.premium ? 'PREMIUM' : 'PLUS';

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PremiumScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_rounded, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$featureName is a $label feature. Tap to upgrade.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  final String featureName;
  final PlanTier requiredTier;

  const _LockBadge({required this.featureName, required this.requiredTier});

  @override
  Widget build(BuildContext context) {
    final color =
        requiredTier == PlanTier.premium ? AppColors.violet : AppColors.sky;
    final tierLabel =
        requiredTier == PlanTier.premium ? 'Premium' : 'Plus';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_rounded, color: color, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            featureName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Available on $tierLabel plan',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: requiredTier == PlanTier.premium
                  ? AppColors.gradientViolet
                  : const LinearGradient(
                      colors: [AppColors.sky, Color(0xFF0284C7)]),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Upgrade to $tierLabel →',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(
        begin: const Offset(0.85, 0.85),
        duration: 300.ms,
        curve: Curves.easeOut);
  }
}
