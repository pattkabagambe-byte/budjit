import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../transactions/domain/category_data.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final month = ref.watch(selectedMonthProvider);
    final currency = ref.watch(currencyProvider);
    final txAsync = ref.watch(transactionsStreamProvider((userId: userId, month: month)));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                      DateTime(month.year, month.month - 1),
                ),
                Text(Fmt.monthShort(month), style: const TextStyle(fontWeight: FontWeight.w800)),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    final next = DateTime(month.year, month.month + 1);
                    if (!next.isAfter(DateTime.now())) {
                      ref.read(selectedMonthProvider.notifier).state = next;
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: txAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (txs) {
          if (txs.isEmpty) {
            return const EmptyState(
              icon: Icons.bar_chart_outlined,
              title: 'No data yet',
              subtitle: 'Add some transactions to see your spending analytics.',
            );
          }

          final income = txs.where((t) => t.isIncome).fold(0.0, (a, t) => a + t.amount);
          final expenses = txs.where((t) => !t.isIncome).fold(0.0, (a, t) => a + t.amount);
          final expByCategory = <String, double>{};
          for (final t in txs.where((t) => !t.isIncome)) {
            expByCategory[t.category] = (expByCategory[t.category] ?? 0) + t.amount;
          }
          final sorted = expByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
          final dailyData = _buildDailyData(txs, month);

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
            children: [
              const SizedBox(height: 16),

              // Income vs Expense bar chart
              _IncomeVsExpenseCard(
                income: income,
                expenses: expenses,
                currency: currency,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 16),

              // Daily spending trend
              _DailyTrendCard(
                data: dailyData,
                currency: currency,
                isDark: isDark,
                month: month,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 16),

              // Category breakdown
              _CategoryBreakdownCard(
                sorted: sorted,
                total: expenses,
                currency: currency,
                isDark: isDark,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 16),

              // Top spending categories (pie)
              if (sorted.isNotEmpty)
                _SpendingPieCard(
                  sorted: sorted.take(6).toList(),
                  total: expenses,
                  isDark: isDark,
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            ],
          );
        },
      ),
    );
  }

  List<({DateTime date, double income, double expense})> _buildDailyData(
      List<TxEntry> txs, DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(daysInMonth, (i) {
      final d = DateTime(month.year, month.month, i + 1);
      final dayTxs = txs.where((t) =>
          t.date.year == d.year && t.date.month == d.month && t.date.day == d.day);
      return (
        date: d,
        income: dayTxs.where((t) => t.isIncome).fold(0.0, (a, t) => a + t.amount),
        expense: dayTxs.where((t) => !t.isIncome).fold(0.0, (a, t) => a + t.amount),
      );
    });
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < 3; i++) ...[
          ShimmerBox(width: double.infinity, height: 200, borderRadius: BorderRadius.circular(20)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// ── Income vs Expense Card ────────────────────────────────────────────────────

class _IncomeVsExpenseCard extends StatelessWidget {
  final double income, expenses;
  final String currency;
  final bool isDark;

  const _IncomeVsExpenseCard({required this.income, required this.expenses, required this.currency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final balance = income - expenses;
    final savingsRate = income > 0 ? (balance / income * 100) : 0.0;
    return _AnalyticsCard(
      title: 'Income vs Expenses',
      isDark: isDark,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: StatChip(label: 'Income', value: Fmt.compact(income, currency: currency), color: AppColors.emerald, icon: Icons.trending_up_rounded)),
              const SizedBox(width: 10),
              Expanded(child: StatChip(label: 'Expenses', value: Fmt.compact(expenses, currency: currency), color: AppColors.rose, icon: Icons.trending_down_rounded)),
              const SizedBox(width: 10),
              Expanded(child: StatChip(label: 'Savings', value: '${savingsRate.toStringAsFixed(0)}%', color: AppColors.violet, icon: Icons.savings_outlined)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: [income, expenses].reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        v == 0 ? 'Income' : 'Expenses',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: income, color: AppColors.emerald, width: 40, borderRadius: BorderRadius.circular(8)),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: expenses, color: AppColors.rose, width: 40, borderRadius: BorderRadius.circular(8)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily Trend Card ──────────────────────────────────────────────────────────

class _DailyTrendCard extends StatelessWidget {
  final List<({DateTime date, double income, double expense})> data;
  final String currency;
  final bool isDark;
  final DateTime month;

  const _DailyTrendCard({required this.data, required this.currency, required this.isDark, required this.month});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxDay = month.month == now.month && month.year == now.year ? now.day : data.length;
    final visible = data.take(maxDay).toList();
    final maxVal = visible.fold(0.0, (a, e) => [a, e.expense, e.income].reduce((x, y) => x > y ? x : y));

    if (maxVal == 0) return const SizedBox();

    final spots = visible.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expense)).toList();

    return _AnalyticsCard(
      title: 'Daily Spending',
      isDark: isDark,
      child: SizedBox(
        height: 150,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxVal / 4,
              getDrawingHorizontalLine: (_) => FlLine(color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: (visible.length / 4).ceil().toDouble(),
                  getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx >= 0 && idx < visible.length) {
                      return Text(
                        '${visible[idx].date.day}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: AppColors.rose,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.rose.withOpacity(0.25), AppColors.rose.withOpacity(0)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Category Breakdown ────────────────────────────────────────────────────────

class _CategoryBreakdownCard extends StatelessWidget {
  final List<MapEntry<String, double>> sorted;
  final double total;
  final String currency;
  final bool isDark;

  const _CategoryBreakdownCard({required this.sorted, required this.total, required this.currency, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'By Category',
      isDark: isDark,
      child: Column(
        children: sorted.take(8).map((e) {
          final cat = categoryByIdOrDefault(e.key);
          final ratio = total > 0 ? e.value / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(cat.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.navy)),
                    ),
                    Text(Fmt.compact(e.value, currency: currency),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: cat.color)),
                    const SizedBox(width: 8),
                    Text('${(ratio * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 5,
                    backgroundColor: cat.color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(cat.color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Spending Pie ──────────────────────────────────────────────────────────────

class _SpendingPieCard extends StatefulWidget {
  final List<MapEntry<String, double>> sorted;
  final double total;
  final bool isDark;

  const _SpendingPieCard({required this.sorted, required this.total, required this.isDark});

  @override
  State<_SpendingPieCard> createState() => _SpendingPieCardState();
}

class _SpendingPieCardState extends State<_SpendingPieCard> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      title: 'Spending Distribution',
      isDark: widget.isDark,
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (ev, res) {
                      setState(() {
                        _touched = res?.touchedSection?.touchedSectionIndex ?? -1;
                      });
                    },
                  ),
                  sectionsSpace: 3,
                  centerSpaceRadius: 42,
                  sections: widget.sorted.asMap().entries.map((e) {
                    final cat = categoryByIdOrDefault(e.value.key);
                    final pct = widget.total > 0 ? e.value.value / widget.total * 100 : 0;
                    final isTouched = _touched == e.key;
                    return PieChartSectionData(
                      value: e.value.value,
                      color: cat.color,
                      radius: isTouched ? 55 : 45,
                      title: '${pct.toStringAsFixed(0)}%',
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 13 : 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.sorted.take(6).map((e) {
                  final cat = categoryByIdOrDefault(e.key);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(cat.label.split(' ').first,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.isDark ? Colors.white70 : Colors.black87)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Analytics Card shell ──────────────────────────────────────────────────────

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _AnalyticsCard({required this.title, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.navy)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
