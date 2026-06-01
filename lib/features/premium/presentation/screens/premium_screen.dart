import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // 0=Plus, 1=Premium, 2=Lifetime

  static const _plans = [
    _Plan(name: 'Plus', price: 'UGX 15,000/mo', color: AppColors.sky, features: [
      'Advanced insights', 'Multi-device sync', 'Unlimited reports',
      'Subscription tracker', 'Forecasting', 'No ads',
    ]),
    _Plan(name: 'Premium', price: 'UGX 25,000/mo', color: AppColors.violet, features: [
      'Everything in Plus',
      'AI Financial Coach',
      'Deep analytics',
      'Family budgeting',
      'Investment tracking',
      'Tax support',
      'Wealth planning',
      'No ads',
    ]),
    _Plan(name: 'Lifetime', price: 'UGX 150,000', color: AppColors.amber, features: [
      'All Premium features',
      'Forever access',
      'Future features included',
      'Priority support',
      'No monthly fee',
      'No ads, ever',
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = _plans[_selectedPlan];

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientViolet),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 48)
                          .animate().scale(curve: Curves.elasticOut, duration: 600.ms),
                      const SizedBox(height: 12),
                      const Text(
                        'Budjit Premium',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                      ).animate().fadeIn(delay: 200.ms),
                      const Text(
                        'Master your money. Own your future.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Plan selector
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: _plans.asMap().entries.map((e) {
                        final selected = e.key == _selectedPlan;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: selected ? e.value.color : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  e.value.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: selected ? Colors.white : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Plan card
                  _PlanCard(plan: selected, isDark: isDark)
                      .animate(key: ValueKey(_selectedPlan))
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  // CTA
                  FilledButton(
                    onPressed: () => _purchase(context, selected),
                    style: FilledButton.styleFrom(
                      backgroundColor: selected.color,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: Text(
                      'Get ${selected.name} — ${selected.price}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    child: const Text('Maybe later'),
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'Cancel anytime · Secure payment via Google/Apple Pay',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Features comparison
                  _FeaturesGrid(isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _purchase(BuildContext context, _Plan plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening payment for ${plan.name}...')),
    );
  }
}

class _Plan {
  final String name, price;
  final Color color;
  final List<String> features;

  const _Plan({required this.name, required this.price, required this.color, required this.features});
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool isDark;

  const _PlanCard({required this.plan, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: plan.color, width: 2),
        boxShadow: [BoxShadow(color: plan.color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: plan.color.withOpacity(0.15), borderRadius: BorderRadius.circular(999)),
                child: Text(plan.name, style: TextStyle(color: plan.color, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              const SizedBox(width: 8),
              if (plan.name == 'Premium') const PremiumBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.price,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy),
          ),
          const Divider(height: 24),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 18, color: plan.color),
                const SizedBox(width: 10),
                Expanded(child: Text(f, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.navy))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  final bool isDark;
  const _FeaturesGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.savings_rounded, 'Savings Goals', 'Free'),
      (Icons.account_balance_wallet_rounded, 'Budgets', 'Free'),
      (Icons.receipt_long_rounded, 'Transactions', 'Free'),
      (Icons.bar_chart_rounded, 'Basic Analytics', 'Free'),
      (Icons.psychology_rounded, 'AI Coach', 'Premium'),
      (Icons.people_rounded, 'Family Budget', 'Premium'),
      (Icons.trending_up_rounded, 'Investments', 'Premium'),
      (Icons.file_download_rounded, 'Data Export', 'Plus'),
      (Icons.sync_rounded, 'Multi-device Sync', 'Plus'),
      (Icons.campaign_rounded, 'No Ads', 'Plus'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What you get', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.navy)),
        const SizedBox(height: 16),
        ...features.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Icon(f.$1, size: 20, color: AppColors.emerald),
              const SizedBox(width: 12),
              Expanded(child: Text(f.$2, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDark ? Colors.white : AppColors.navy))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: f.$3 == 'Free'
                      ? AppColors.emerald.withOpacity(0.15)
                      : f.$3 == 'Plus'
                          ? AppColors.sky.withOpacity(0.15)
                          : AppColors.violet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  f.$3,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: f.$3 == 'Free' ? AppColors.emerald : f.$3 == 'Plus' ? AppColors.sky : AppColors.violet,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
