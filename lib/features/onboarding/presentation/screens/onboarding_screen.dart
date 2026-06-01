import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  String _selectedCurrency = 'UGX';
  String _selectedGoal = 'track';
  String _selectedIncome = 'monthly';

  static const _goals = [
    (id: 'track', emoji: '📊', label: 'Track expenses'),
    (id: 'save', emoji: '🐷', label: 'Save more money'),
    (id: 'budget', emoji: '🎯', label: 'Manage budgets'),
    (id: 'debt', emoji: '💳', label: 'Pay off debt'),
    (id: 'invest', emoji: '📈', label: 'Grow wealth'),
    (id: 'control', emoji: '🧘', label: 'Financial peace'),
  ];

  static const _incomeTypes = [
    (id: 'monthly', emoji: '💼', label: 'Monthly salary'),
    (id: 'weekly', emoji: '🗓️', label: 'Weekly pay'),
    (id: 'gig', emoji: '⚡', label: 'Gig / Freelance'),
    (id: 'business', emoji: '🏢', label: 'Business owner'),
    (id: 'student', emoji: '🎓', label: 'Student'),
    (id: 'irregular', emoji: '🔀', label: 'Irregular income'),
  ];

  void _next() {
    if (_page < 3) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    ref.read(currencyProvider.notifier).state = _selectedCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete_v2', true);
    await prefs.setString('currency', _selectedCurrency);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(4, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _page ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.emerald : AppColors.emerald.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                )),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _WelcomePage(isDark: isDark),
                  _GoalPage(
                    goals: _goals,
                    selected: _selectedGoal,
                    onSelect: (id) => setState(() => _selectedGoal = id),
                    isDark: isDark,
                  ),
                  _IncomePage(
                    types: _incomeTypes,
                    selected: _selectedIncome,
                    onSelect: (id) => setState(() => _selectedIncome = id),
                    isDark: isDark,
                  ),
                  _CurrencyPage(
                    selected: _selectedCurrency,
                    onSelect: (c) => setState(() => _selectedCurrency = c),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // CTA
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _next();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: Text(
                        _page < 3 ? 'Continue' : "Let's Go! 🚀",
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                    ),
                  ),
                  if (_page < 3) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _complete,
                      child: const Text(
                        'Skip setup',
                        style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1: Welcome ───────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final bool isDark;
  const _WelcomePage({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.gradientNavy,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12))],
            ),
            child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 52),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          Text(
            'Welcome to Budjit',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.navy,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

          const SizedBox(height: 12),

          Text(
            'The smartest way to track your money,\nbuild savings, and reach your goals.',
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white60 : Colors.black45, height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 48),

          ...[
            (Icons.offline_bolt_rounded, 'Works offline', 'Your data is always available'),
            (Icons.lock_rounded, 'Private & secure', 'Your data stays on your device'),
            (Icons.bar_chart_rounded, 'Beautiful insights', 'Understand your money'),
          ].map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(f.$1, color: AppColors.emerald, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.$2, style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.navy)),
                      Text(f.$3, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1)),
        ],
      ),
    );
  }
}

// ── Page 2: Goal ──────────────────────────────────────────────────────────────

class _GoalPage extends StatelessWidget {
  final List<({String id, String emoji, String label})> goals;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isDark;

  const _GoalPage({required this.goals, required this.selected, required this.onSelect, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your main goal?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 6),
          Text('We\'ll personalize your experience', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black45)).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: goals.asMap().entries.map((e) {
                final goal = e.value;
                final isSelected = goal.id == selected;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(goal.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.navy : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.navy : (isDark ? AppColors.darkBorder : AppColors.lightBorder), width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Text(goal.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(goal.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.navy))),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (e.key * 40).ms);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Income Type ───────────────────────────────────────────────────────

class _IncomePage extends StatelessWidget {
  final List<({String id, String emoji, String label})> types;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isDark;

  const _IncomePage({required this.types, required this.selected, required this.onSelect, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you earn?',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 6),
          Text('Helps us set up the right budget style', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black45)).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: types.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = types[i];
                final isSelected = t.id == selected;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(t.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.emerald.withOpacity(0.12) : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.emerald : (isDark ? AppColors.darkBorder : AppColors.lightBorder), width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Text(t.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(child: Text(t.label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.navy))),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 22),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (i * 40).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 4: Currency ──────────────────────────────────────────────────────────

class _CurrencyPage extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final bool isDark;

  const _CurrencyPage({required this.selected, required this.onSelect, required this.isDark});

  static const _featured = [
    (code: 'UGX', flag: '🇺🇬', name: 'Uganda Shilling'),
    (code: 'KES', flag: '🇰🇪', name: 'Kenyan Shilling'),
    (code: 'TZS', flag: '🇹🇿', name: 'Tanzania Shilling'),
    (code: 'NGN', flag: '🇳🇬', name: 'Nigerian Naira'),
    (code: 'GHS', flag: '🇬🇭', name: 'Ghanaian Cedi'),
    (code: 'ZAR', flag: '🇿🇦', name: 'South African Rand'),
    (code: 'USD', flag: '🇺🇸', name: 'US Dollar'),
    (code: 'EUR', flag: '🇪🇺', name: 'Euro'),
    (code: 'GBP', flag: '🇬🇧', name: 'British Pound'),
    (code: 'INR', flag: '🇮🇳', name: 'Indian Rupee'),
    (code: 'PHP', flag: '🇵🇭', name: 'Philippine Peso'),
    (code: 'EGP', flag: '🇪🇬', name: 'Egyptian Pound'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your currency',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.navy),
          ).animate().fadeIn().slideY(begin: 0.1),
          const SizedBox(height: 6),
          Text('You can change this later in settings', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black45)).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _featured.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final c = _featured[i];
                final isSelected = c.code == selected;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelect(c.code);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.navy : (isDark ? AppColors.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppColors.navy : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                    ),
                    child: Row(
                      children: [
                        Text(c.flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.code, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.navy))),
                              Text(c.name, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white60 : Colors.grey)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 250.ms, delay: (i * 30).ms);
              },
            ),
          ),
        ],
      ),
    );
  }
}
