import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/layout_mode.dart';
import '../../../../core/navigation/app_shell.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../../core/widgets/planner_menu_sheet.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../transactions/domain/category_data.dart';
import '../../../transactions/presentation/widgets/add_transaction_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final month = ref.watch(selectedMonthProvider);
    final currency = ref.watch(currencyProvider);
    final txAsync =
        ref.watch(transactionsStreamProvider((userId: userId, month: month)));
    final budgetsAsync = ref.watch(budgetsStreamProvider(userId));
    final goalsAsync = ref.watch(goalsStreamProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: txAsync.when(
          loading: () => _buildSkeleton(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (txs) {
            final income =
                txs.where((t) => t.isIncome).fold(0.0, (a, t) => a + t.amount);
            final expenses =
                txs.where((t) => !t.isIncome).fold(0.0, (a, t) => a + t.amount);
            final balance = income - expenses;
            final savingsRate = income > 0
                ? ((income - expenses) / income * 100).clamp(0, 100)
                : 0.0;
            final score = _computeHealthScore(income, expenses, txs.length);
            final recent = txs.take(5).toList();
            return _buildBody(
              context,
              ref,
              txs,
              recent,
              income,
              expenses,
              balance,
              savingsRate.toDouble(),
              score,
              currency,
              month,
              isDark,
              userId,
              budgetsAsync,
              goalsAsync,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTransactionSheet(context),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<TxEntry> txs,
    List<TxEntry> recent,
    double income,
    double expenses,
    double balance,
    double savingsRate,
    int score,
    String currency,
    DateTime month,
    bool isDark,
    String userId,
    AsyncValue<List<Budget>> budgetsAsync,
    AsyncValue<List<GoalEntry>> goalsAsync,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App bar
        SliverToBoxAdapter(
          child: _buildHeader(context, ref, isDark),
        ),

        // Balance card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: _BalanceCard(
              balance: balance,
              income: income,
              expenses: expenses,
              savingsRate: savingsRate,
              score: score,
              currency: currency,
              month: month,
              ref: ref,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
        ),

        // Safe to spend
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _SafeToSpendCard(
              expenses: expenses,
              income: income,
              currency: currency,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
        ),

        // Quick stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _QuickStats(
                income: income,
                expenses: expenses,
                currency: currency,
                txCount: txs.length),
          ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
        ),

        // Spending by category (donut)
        if (txs.any((t) => !t.isIncome))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SpendingChart(
                  txs: txs.where((t) => !t.isIncome).toList(),
                  currency: currency,
                  isDark: isDark),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ),

        // Budget progress
        budgetsAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
          data: (budgets) => budgets.isEmpty
              ? const SliverToBoxAdapter(child: SizedBox())
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _BudgetOverview(
                        budgets: budgets,
                        txs: txs,
                        currency: currency,
                        ref: ref),
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                ),
        ),

        // Goals preview
        goalsAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox()),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
          data: (goals) => goals.isEmpty
              ? const SliverToBoxAdapter(child: SizedBox())
              : SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _GoalsPreview(
                        goals: goals.take(3).toList(),
                        currency: currency,
                        ref: ref),
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                ),
        ),

        // Recent transactions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SectionHeader(
              title: 'Recent Transactions',
              action: recent.isNotEmpty ? 'See all' : null,
              onAction: () => navigateToTab(ref, 0),
            ),
          ),
        ),

        if (recent.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions yet',
              subtitle:
                  'Tap the button below to add your first income or expense.',
              actionLabel: 'Add Transaction',
              onAction: () => showAddTransactionSheet(context),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _TxTile(
                    entry: recent[i], currency: currency, isDark: isDark),
              ).animate().fadeIn(duration: 300.ms, delay: (350 + i * 50).ms),
              childCount: recent.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.split(' ').first ?? 'there';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final month = ref.watch(selectedMonthProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $name 👋',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Fmt.month(month),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left_rounded,
                    color: isDark ? Colors.white70 : AppColors.navy),
                onPressed: () => ref
                    .read(selectedMonthProvider.notifier)
                    .state = DateTime(month.year, month.month - 1),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right_rounded,
                    color: isDark ? Colors.white70 : AppColors.navy),
                onPressed: () {
                  final next = DateTime(month.year, month.month + 1);
                  if (!next.isAfter(DateTime.now())) {
                    ref.read(selectedMonthProvider.notifier).state = next;
                  }
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
                tooltip: 'Budget Planner menu',
                onPressed: () => PlannerMenuSheet.show(
                  context,
                  currentMode: LayoutMode.defaultMode,
                  onOpenSettings: () => navigateToTab(ref, 4),
                  onExportReport: () => navigateToTab(ref, 3),
                ),
              ),
              _ProfileMenu(user: user, name: name, isDark: isDark, ref: ref),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const ShimmerBox(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(24))),
        const SizedBox(height: 16),
        const ShimmerBox(
            width: double.infinity,
            height: 80,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        const SizedBox(height: 16),
        Row(children: const [
          Expanded(
              child: ShimmerBox(
                  width: double.infinity,
                  height: 80,
                  borderRadius: BorderRadius.all(Radius.circular(16)))),
          SizedBox(width: 12),
          Expanded(
              child: ShimmerBox(
                  width: double.infinity,
                  height: 80,
                  borderRadius: BorderRadius.all(Radius.circular(16)))),
        ]),
      ],
    );
  }

  int _computeHealthScore(double income, double expenses, int txCount) {
    if (income == 0) return 0;
    int score = 50;
    final savingsRate = (income - expenses) / income;
    if (savingsRate >= 0.2)
      score += 20;
    else if (savingsRate >= 0.1)
      score += 10;
    else if (savingsRate < 0) score -= 20;
    if (expenses <= income) score += 15;
    if (txCount >= 5) score += 10;
    if (txCount >= 15) score += 5;
    return score.clamp(0, 100);
  }
}

// ── Balance Card ───────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final double balance, income, expenses, savingsRate;
  final int score;
  final String currency;
  final DateTime month;
  final WidgetRef ref;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expenses,
    required this.savingsRate,
    required this.score,
    required this.currency,
    required this.month,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppColors.gradientNavy,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Balance',
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              HealthScoreRing(score: score, size: 52),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Fmt.money(balance.abs(), currency: currency),
            style: TextStyle(
              color: balance >= 0 ? Colors.white : AppColors.rose,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          if (balance < 0)
            const Text(
              'You\'re over budget this month',
              style: TextStyle(
                  color: AppColors.rose,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            )
          else
            Text(
              '${Fmt.percent(savingsRate)} savings rate',
              style: const TextStyle(
                  color: AppColors.emerald,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 20),
          // Income vs Expenses bar
          Row(
            children: [
              Expanded(
                  child: _MiniStat(
                      label: 'Income',
                      value: Fmt.compact(income, currency: currency),
                      color: AppColors.emeraldLight,
                      icon: Icons.arrow_downward_rounded)),
              const SizedBox(width: 12),
              Expanded(
                  child: _MiniStat(
                      label: 'Expenses',
                      value: Fmt.compact(expenses, currency: currency),
                      color: AppColors.coral,
                      icon: Icons.arrow_upward_rounded)),
            ],
          ),
          if (income > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (expenses / income).clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(
                  expenses / income > 0.9 ? AppColors.rose : AppColors.emerald,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${Fmt.percent((expenses / income * 100).clamp(0, 100))} of income spent',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _MiniStat(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Safe to Spend ─────────────────────────────────────────────────────────────

class _SafeToSpendCard extends StatelessWidget {
  final double income;
  final double expenses;
  final String currency;

  const _SafeToSpendCard(
      {required this.income, required this.expenses, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day + 1;
    final remaining = income - expenses;
    final safeToday =
        remaining > 0 && daysLeft > 0 ? remaining / daysLeft : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.emerald.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.today_rounded,
                color: AppColors.emerald, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe to spend today',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  safeToday > 0
                      ? Fmt.money(safeToday, currency: currency)
                      : 'Over budget',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: safeToday > 0
                        ? (isDark ? Colors.white : AppColors.navy)
                        : AppColors.rose,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$daysLeft days left',
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                'in ${DateFormat('MMM').format(now)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats ───────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  final double income, expenses;
  final int txCount;
  final String currency;

  const _QuickStats(
      {required this.income,
      required this.expenses,
      required this.txCount,
      required this.currency});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'This Month'),
        Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'Income',
                    value: Fmt.compact(income, currency: currency),
                    color: AppColors.emerald,
                    icon: Icons.trending_up_rounded,
                    isDark: isDark)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Expenses',
                    value: Fmt.compact(expenses, currency: currency),
                    color: AppColors.rose,
                    icon: Icons.trending_down_rounded,
                    isDark: isDark)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Entries',
                    value: '$txCount',
                    color: AppColors.violet,
                    icon: Icons.receipt_long_rounded,
                    isDark: isDark)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.navy)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Spending Donut Chart ──────────────────────────────────────────────────────

class _SpendingChart extends StatelessWidget {
  final List<TxEntry> txs;
  final String currency;
  final bool isDark;

  const _SpendingChart(
      {required this.txs, required this.currency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final byCategory = <String, double>{};
    for (final t in txs) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final total = top.fold(0.0, (a, e) => a + e.value);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Spending Breakdown'),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 36,
                    sections: top.asMap().entries.map((e) {
                      final cat = categoryByIdOrDefault(e.value.key);
                      return PieChartSectionData(
                        value: e.value.value,
                        color: cat.color,
                        radius: 20,
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: top.map((e) {
                    final cat = categoryByIdOrDefault(e.key);
                    final pct = total > 0 ? e.value / total * 100 : 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: cat.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(cat.emoji, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              cat.label.split(' ').first,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cat.color),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Budget Overview ───────────────────────────────────────────────────────────

class _BudgetOverview extends StatelessWidget {
  final List<Budget> budgets;
  final List<TxEntry> txs;
  final String currency;
  final WidgetRef ref;

  const _BudgetOverview(
      {required this.budgets,
      required this.txs,
      required this.currency,
      required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Budgets',
          action: 'Manage',
          onAction: () => navigateToTab(ref, 1),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: budgets.take(5).length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final b = budgets[i];
              final spent = txs
                  .where((t) => !t.isIncome && t.category == b.category)
                  .fold(0.0, (a, t) => a + t.amount);
              final cat = categoryByIdOrDefault(b.category);
              final ratio = b.limitAmount > 0
                  ? (spent / b.limitAmount).clamp(0.0, 1.0)
                  : 0.0;
              final color = ratio > 0.9
                  ? AppColors.rose
                  : ratio > 0.7
                      ? AppColors.amber
                      : AppColors.emerald;

              return Container(
                width: 140,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            cat.label.split(' ').first,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.navy),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 5,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Fmt.compact(spent, currency: currency),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: color),
                    ),
                    Text(
                      'of ${Fmt.compact(b.limitAmount, currency: currency)}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Goals Preview ─────────────────────────────────────────────────────────────

class _GoalsPreview extends StatelessWidget {
  final List<GoalEntry> goals;
  final String currency;
  final WidgetRef ref;

  const _GoalsPreview(
      {required this.goals, required this.currency, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Savings Goals',
          action: 'See all',
          onAction: () => navigateToTab(ref, 2),
        ),
        ...goals.map((g) {
          final ratio = g.targetAmount > 0
              ? (g.currentAmount / g.targetAmount).clamp(0.0, 1.0)
              : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Text(g.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.name,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.navy)),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: AppColors.emerald.withOpacity(0.15),
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.emerald),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Fmt.compact(g.currentAmount, currency: currency)} of ${Fmt.compact(g.targetAmount, currency: currency)}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.emerald),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Transaction Tile ──────────────────────────────────────────────────────────

class _TxTile extends StatelessWidget {
  final TxEntry entry;
  final String currency;
  final bool isDark;

  const _TxTile(
      {required this.entry, required this.currency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cat = categoryByIdOrDefault(entry.category, isIncome: entry.isIncome);
    final color = entry.isIncome ? AppColors.emerald : AppColors.rose;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: [
          CategoryBadge(
              category: cat.id, emoji: cat.emoji, color: cat.color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.navy),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  Fmt.timeAgo(entry.date),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${entry.isIncome ? '+' : '-'}${Fmt.compact(entry.amount, currency: currency)}',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Profile Menu ──────────────────────────────────────────────────────────────

class _ProfileMenu extends StatelessWidget {
  final User? user;
  final String name;
  final bool isDark;
  final WidgetRef ref;

  const _ProfileMenu({
    required this.user,
    required this.name,
    required this.isDark,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          UserAvatar(photoUrl: user?.photoURL, displayName: name, radius: 20),
          // Online / guest indicator dot
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: (user != null && !user!.isAnonymous)
                    ? AppColors.emerald
                    : AppColors.amber,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBg : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final isGuest = user == null || user!.isAnonymous;
    final email = user?.email ?? user?.displayName ?? 'Guest';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileSheet(
        user: user,
        email: email,
        isGuest: isGuest,
        isDark: isDark,
        ref: ref,
      ),
    );
  }
}

class _ProfileSheet extends StatelessWidget {
  final User? user;
  final String email;
  final bool isGuest;
  final bool isDark;
  final WidgetRef ref;

  const _ProfileSheet({
    required this.user,
    required this.email,
    required this.isGuest,
    required this.isDark,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? (isGuest ? 'Guest User' : 'User');
    final bgColor = isDark ? AppColors.darkCard : Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Profile info header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                UserAvatar(
                    photoUrl: user?.photoURL, displayName: name, radius: 26),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.navy,
                        ),
                      ),
                      Text(
                        isGuest ? 'Guest — data on this device only' : email,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (!isGuest)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Signed in',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),

          // Menu items
          if (isGuest) ...[
            _MenuItem(
              icon: Icons.login_rounded,
              label: 'Sign in with Google',
              subtitle: 'Sync data across devices',
              color: AppColors.sky,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AuthScreen(isLinking: true),
                ));
              },
            ),
            _MenuItem(
              icon: Icons.email_rounded,
              label: 'Sign in with Email',
              subtitle: 'Create or log into an account',
              color: AppColors.violet,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AuthScreen(isLinking: true),
                ));
              },
            ),
          ] else ...[
            _MenuItem(
              icon: Icons.switch_account_rounded,
              label: 'Switch account',
              subtitle: 'Sign in with a different Google account',
              color: AppColors.sky,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AuthScreen(),
                ));
              },
            ),
            _MenuItem(
              icon: Icons.person_outline_rounded,
              label: 'View profile',
              subtitle: 'Settings, currency, premium',
              color: AppColors.violet,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                navigateToTab(ref, 4);
              },
            ),
            _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Sign out',
              subtitle: 'Your data stays on this device',
              color: AppColors.rose,
              isDark: isDark,
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sign out?'),
                  content: const Text('Your local data will be preserved.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        Navigator.pop(context); // close sheet
                        FirebaseAuth.instance.signOut();
                      },
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.rose),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    ).animate().slideY(begin: 0.1, duration: 250.ms, curve: Curves.easeOut);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : AppColors.navy,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
