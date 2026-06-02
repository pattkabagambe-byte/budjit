import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/ads/ad_manager.dart';
import '../../../../core/services/premium_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  int _selectedPlan = 1; // 0=Plus, 1=Premium, 2=Lifetime
  bool _purchasing = false;
  bool _restoring = false;
  String? _statusMessage;

  static const _plans = [
    _Plan(
      name: 'Plus',
      productId: kProductPlusMonthly,
      price: 'UGX 15,000',
      period: '/month',
      tagline: 'For the serious saver',
      color: AppColors.sky,
      tier: PlanTier.plus,
      features: [
        (Icons.bar_chart_rounded, 'Advanced insights & trends'),
        (Icons.sync_rounded, 'Multi-device sync'),
        (Icons.picture_as_pdf_outlined, 'Unlimited reports & export'),
        (Icons.repeat_rounded, 'Subscription tracker'),
        (Icons.trending_up_rounded, 'Spending forecasts'),
        (Icons.block_rounded, 'No ads, ever'),
      ],
    ),
    _Plan(
      name: 'Premium',
      productId: kProductPremiumMonthly,
      price: 'UGX 25,000',
      period: '/month',
      tagline: 'Your personal money coach',
      color: AppColors.violet,
      tier: PlanTier.premium,
      badge: 'Most Popular',
      features: [
        (Icons.auto_awesome_rounded, 'Everything in Plus'),
        (Icons.psychology_rounded, 'AI Financial Coach'),
        (Icons.analytics_rounded, 'Deep analytics dashboard'),
        (Icons.people_rounded, 'Family & shared budgets'),
        (Icons.candlestick_chart_rounded, 'Investment portfolio tracking'),
        (Icons.receipt_long_rounded, 'Tax-ready expense reports'),
        (Icons.account_balance_rounded, 'Wealth planning tools'),
        (Icons.block_rounded, 'No ads, ever'),
      ],
    ),
    _Plan(
      name: 'Lifetime',
      productId: kProductLifetime,
      price: 'UGX 150,000',
      period: ' once',
      tagline: 'Pay once, own forever',
      color: AppColors.amber,
      tier: PlanTier.premium,
      badge: 'Best Value',
      features: [
        (Icons.all_inclusive_rounded, 'All Premium features, forever'),
        (Icons.update_rounded, 'All future features included'),
        (Icons.support_agent_rounded, 'Priority support'),
        (Icons.savings_rounded, 'No monthly fee — ever'),
        (Icons.block_rounded, 'No ads, ever'),
      ],
    ),
  ];

  Future<void> _purchase() async {
    setState(() { _purchasing = true; _statusMessage = null; });
    final plan = _plans[_selectedPlan];
    final status = await PremiumService.purchase(plan.productId);
    if (!mounted) return;
    if (status != null && !status.isFree) {
      AdManager.instance.setAdsDisabled(status.isPremium);
      ref.invalidate(premiumStatusProvider);
      setState(() { _purchasing = false; _statusMessage = '🎉 Welcome to ${plan.name}!'; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.of(context).pop();
    } else {
      setState(() {
        _purchasing = false;
        _statusMessage = 'Purchase could not be completed. Please try again.';
      });
    }
  }

  Future<void> _restore() async {
    setState(() { _restoring = true; _statusMessage = null; });
    final status = await PremiumService.restore();
    if (!mounted) return;
    if (!status.isFree) {
      AdManager.instance.setAdsDisabled(status.isPremium);
      ref.invalidate(premiumStatusProvider);
      setState(() { _restoring = false; _statusMessage = '✅ Purchases restored — welcome back!'; });
    } else {
      setState(() { _restoring = false; _statusMessage = 'No previous purchases found.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTier = ref.watch(planTierProvider);
    final selected = _plans[_selectedPlan];

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientViolet),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 52)
                          .animate()
                          .scale(curve: Curves.elasticOut, duration: 600.ms),
                      const SizedBox(height: 12),
                      const Text(
                        'Cashflo Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 6),
                      const Text(
                        'Master your money. Own your future.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ).animate().fadeIn(delay: 250.ms),
                      const SizedBox(height: 12),
                      // Current plan pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Current plan: ${currentTier.name.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ).animate().fadeIn(delay: 350.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Plan tabs
                  _PlanSelector(
                    plans: _plans,
                    selected: _selectedPlan,
                    onSelect: (i) => setState(() {
                      _selectedPlan = i;
                      _statusMessage = null;
                    }),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Plan detail card
                  _PlanCard(
                    plan: selected,
                    isDark: isDark,
                    isCurrentPlan: selected.tier == currentTier,
                  ).animate(key: ValueKey(_selectedPlan))
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.96, 0.96)),

                  const SizedBox(height: 20),

                  // Status message
                  if (_statusMessage != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _statusMessage!.startsWith('🎉') || _statusMessage!.startsWith('✅')
                            ? AppColors.emerald.withValues(alpha: 0.12)
                            : AppColors.rose.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _statusMessage!.startsWith('🎉') || _statusMessage!.startsWith('✅')
                              ? AppColors.emerald
                              : AppColors.rose,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(),

                  if (_statusMessage != null) const SizedBox(height: 12),

                  // CTA button
                  if (selected.tier != currentTier)
                    FilledButton(
                      onPressed: _purchasing ? null : _purchase,
                      style: FilledButton.styleFrom(
                        backgroundColor: selected.color,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: _purchasing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Get ${selected.name} — ${selected.price}${selected.period}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'This is your current plan',
                            style: TextStyle(
                              color: AppColors.emerald,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Restore
                  TextButton(
                    onPressed: _restoring ? null : _restore,
                    child: _restoring
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text(
                            'Restore previous purchases',
                            style: TextStyle(
                                color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                  ),

                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Cancel anytime · Secure via Google/Apple Pay\nPrices shown in UGX — regional pricing available',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Free vs Paid comparison table
                  _ComparisonTable(isDark: isDark),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Plan selector tabs ────────────────────────────────────────────────────────

class _PlanSelector extends StatelessWidget {
  final List<_Plan> plans;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool isDark;

  const _PlanSelector({
    required this.plans,
    required this.selected,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: plans.asMap().entries.map((e) {
          final isSelected = e.key == selected;
          final plan = e.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? plan.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                    if (plan.badge != null)
                      Positioned(
                        top: 3,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.3)
                                : plan.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '★',
                            style: TextStyle(
                              fontSize: 8,
                              color: isSelected ? Colors.white : plan.color,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Plan detail card ──────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool isDark;
  final bool isCurrentPlan;

  const _PlanCard({
    required this.plan,
    required this.isDark,
    required this.isCurrentPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isCurrentPlan
                ? AppColors.emerald
                : plan.color.withValues(alpha: 0.4),
            width: isCurrentPlan ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: plan.color.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: plan.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  plan.name,
                  style: TextStyle(
                    color: plan.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              if (plan.badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: plan.color == AppColors.amber
                        ? AppColors.gradientAmber
                        : AppColors.gradientViolet,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    plan.badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              if (isCurrentPlan) ...[
                const SizedBox(width: 8),
                const PremiumBadge(),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.price,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.navy,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 2),
                child: Text(
                  plan.period,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ),
          Text(
            plan.tagline,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const Divider(height: 24),
          ...plan.features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(f.$1, size: 18, color: plan.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Comparison table ──────────────────────────────────────────────────────────

class _ComparisonTable extends StatelessWidget {
  final bool isDark;
  const _ComparisonTable({required this.isDark});

  static const _rows = [
    ('Expense tracking', true, true, true),
    ('Savings goals', true, true, true),
    ('Budget categories', true, true, true),
    ('Basic analytics', true, true, true),
    ('Interstitial ads', true, false, false),
    ('Advanced insights', false, true, true),
    ('Multi-device sync', false, true, true),
    ('Export (CSV / PDF)', false, true, true),
    ('Subscription tracker', false, true, true),
    ('AI Financial Coach', false, false, true),
    ('Deep analytics', false, false, true),
    ('Family budgets', false, false, true),
    ('Investment tracking', false, false, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan comparison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppColors.navy,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Column(
            children: [
              // Header row
              _TableRow(
                label: '',
                free: 'Free',
                plus: 'Plus',
                premium: 'Premium',
                isHeader: true,
                isDark: isDark,
              ),
              const Divider(height: 1),
              ..._rows.asMap().entries.map(
                (e) => Column(
                  children: [
                    _TableRow(
                      label: e.value.$1,
                      free: e.value.$2 ? '✓' : '–',
                      plus: e.value.$3 ? '✓' : '–',
                      premium: e.value.$4 ? '✓' : '–',
                      freeOk: e.value.$2,
                      plusOk: e.value.$3,
                      premiumOk: e.value.$4,
                      isDark: isDark,
                    ),
                    if (e.key < _rows.length - 1)
                      Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        indent: 16,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final String label, free, plus, premium;
  final bool isHeader;
  final bool freeOk, plusOk, premiumOk;
  final bool isDark;

  const _TableRow({
    required this.label,
    required this.free,
    required this.plus,
    required this.premium,
    this.isHeader = false,
    this.freeOk = false,
    this.plusOk = false,
    this.premiumOk = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isHeader ? 11 : 13,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                color: isHeader
                    ? Colors.grey
                    : (isDark ? Colors.white : AppColors.navy),
              ),
            ),
          ),
          _Cell(value: free, ok: freeOk, isHeader: isHeader, color: Colors.grey),
          _Cell(value: plus, ok: plusOk, isHeader: isHeader, color: AppColors.sky),
          _Cell(value: premium, ok: premiumOk, isHeader: isHeader, color: AppColors.violet),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final bool ok, isHeader;
  final Color color;

  const _Cell({
    required this.value,
    required this.ok,
    required this.isHeader,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Center(
        child: isHeader
            ? Text(value,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color))
            : Icon(
                ok ? Icons.check_circle_rounded : Icons.remove_rounded,
                size: 18,
                color: ok ? color : Colors.grey.withValues(alpha: 0.4),
              ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _Plan {
  final String name;
  final String productId;
  final String price;
  final String period;
  final String tagline;
  final Color color;
  final PlanTier tier;
  final String? badge;
  final List<(IconData, String)> features;

  const _Plan({
    required this.name,
    required this.productId,
    required this.price,
    required this.period,
    required this.tagline,
    required this.color,
    required this.tier,
    this.badge,
    required this.features,
  });
}
