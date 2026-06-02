import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../categories/presentation/widgets/add_category_sheet.dart';
import '../../../transactions/domain/category_data.dart';
import '../../../transactions/presentation/widgets/add_transaction_sheet.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final month = ref.watch(selectedMonthProvider);
    final currency = ref.watch(currencyProvider);
    final budgetsAsync = ref.watch(budgetsStreamProvider(userId));
    final txAsync =
        ref.watch(transactionsStreamProvider((userId: userId, month: month)));
    final customCategories = ref.watch(customTxCategoriesProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            color: AppColors.primary,
            onPressed: () =>
                _showAddBudgetSheet(context, ref, userId, currency),
          ),
        ],
      ),
      body: budgetsAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No budgets yet',
              subtitle: 'Set spending limits by category to stay on track.',
              actionLabel: 'Create Budget',
              onAction: () =>
                  _showAddBudgetSheet(context, ref, userId, currency),
            );
          }

          return txAsync.when(
            loading: () => _buildSkeleton(),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (txs) {
              final totalBudget =
                  budgets.fold(0.0, (a, b) => a + b.limitAmount);
              final totalSpent = budgets.fold(0.0, (a, b) {
                return a +
                    txs
                        .where((t) => !t.isIncome && t.category == b.category)
                        .fold(0.0, (s, t) => s + t.amount);
              });
              final overallRatio =
                  totalBudget > 0 ? totalSpent / totalBudget : 0.0;

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                children: [
                  const SizedBox(height: 16),
                  // Overall budget summary
                  _OverallBudgetCard(
                    totalBudget: totalBudget,
                    totalSpent: totalSpent,
                    ratio: overallRatio,
                    currency: currency,
                    isDark: isDark,
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Category Budgets',
                    action: 'Add',
                    onAction: () =>
                        _showAddBudgetSheet(context, ref, userId, currency),
                  ),
                  ...budgets.asMap().entries.map((e) {
                    final b = e.value;
                    final spent = txs
                        .where((t) => !t.isIncome && t.category == b.category)
                        .fold(0.0, (a, t) => a + t.amount);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BudgetCard(
                        budget: b,
                        spent: spent,
                        currency: currency,
                        isDark: isDark,
                        customCategories: customCategories,
                        onDelete: () => _deleteBudget(ref, b.id),
                        onEdit: () =>
                            _showEditBudgetSheet(context, ref, b, currency),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (e.key * 50).ms),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTransactionSheet(context),
        backgroundColor: AppColors.navy,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Transaction',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Future<void> _deleteBudget(WidgetRef ref, String id) async {
    await ref.read(databaseProvider).deleteBudget(id);
    HapticFeedback.lightImpact();
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerBox(
            width: double.infinity,
            height: 100,
            borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  void _showAddBudgetSheet(
      BuildContext context, WidgetRef ref, String userId, String currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _BudgetSheet(userId: userId, currency: currency, ref: ref),
    );
  }

  void _showEditBudgetSheet(
      BuildContext context, WidgetRef ref, Budget budget, String currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BudgetSheet(
          userId: budget.userId,
          currency: currency,
          ref: ref,
          existing: budget),
    );
  }
}

// ── Overall Budget Card ───────────────────────────────────────────────────────

class _OverallBudgetCard extends StatelessWidget {
  final double totalBudget, totalSpent, ratio;
  final String currency;
  final bool isDark;

  const _OverallBudgetCard({
    required this.totalBudget,
    required this.totalSpent,
    required this.ratio,
    required this.currency,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = ratio > 0.9
        ? AppColors.rose
        : ratio > 0.7
            ? AppColors.amber
            : AppColors.emerald;
    final remaining = totalBudget - totalSpent;

    return GradientCard(
      gradient: AppColors.gradientNavy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Budget',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Fmt.money(totalSpent, currency: currency),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'of ${Fmt.money(totalBudget, currency: currency)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      Fmt.compact(remaining.abs(), currency: currency),
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 14),
                    ),
                    Text(
                      remaining >= 0 ? 'remaining' : 'over budget',
                      style: TextStyle(
                          color: color.withOpacity(0.8), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(ratio * 100).toStringAsFixed(0)}% of budget used',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Budget Card ───────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final String currency;
  final bool isDark;
  final List<TxCategory> customCategories;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.currency,
    required this.isDark,
    required this.customCategories,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cat =
        categoryByIdOrDefault(budget.category, custom: customCategories);
    final ratio = budget.limitAmount > 0
        ? (spent / budget.limitAmount).clamp(0.0, 1.0)
        : 0.0;
    final color = ratio > 0.9
        ? AppColors.rose
        : ratio > 0.7
            ? AppColors.amber
            : AppColors.emerald;
    final remaining = budget.limitAmount - spent;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit budget'),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.rose),
                  title: const Text('Delete budget',
                      style: TextStyle(color: AppColors.rose)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CategoryBadge(
                    category: cat.id,
                    emoji: cat.emoji,
                    color: cat.color,
                    size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.navy,
                        ),
                      ),
                      Text(
                        '${budget.period == 'monthly' ? 'Monthly' : 'Weekly'} budget',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Fmt.compact(spent, currency: currency),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: color),
                    ),
                    Text(
                      'of ${Fmt.compact(budget.limitAmount, currency: currency)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            BudgetProgressBar(
                spent: spent, limit: budget.limitAmount, color: color),
            if (remaining < 0) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 14, color: AppColors.rose),
                    const SizedBox(width: 4),
                    Text(
                      'Over by ${Fmt.compact(remaining.abs(), currency: currency)}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.rose,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Add/Edit Budget Sheet ─────────────────────────────────────────────────────

class _BudgetSheet extends StatefulWidget {
  final String userId;
  final String currency;
  final WidgetRef ref;
  final Budget? existing;

  const _BudgetSheet(
      {required this.userId,
      required this.currency,
      required this.ref,
      this.existing});

  @override
  State<_BudgetSheet> createState() => _BudgetSheetState();
}

class _BudgetSheetState extends State<_BudgetSheet> {
  final _amountCtrl = TextEditingController();
  String _selectedCategory = 'food';
  String _period = 'monthly';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _selectedCategory = widget.existing!.category;
      _period = widget.existing!.period;
      _amountCtrl.text = widget.existing!.limitAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    final budget = Budget(
      id: widget.existing?.id ?? const Uuid().v4(),
      userId: widget.userId,
      category: _selectedCategory,
      limitAmount: amount,
      period: _period,
      createdAt: DateTime.now(),
    );
    await widget.ref.read(databaseProvider).upsertBudget(budget);
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cats = widget.ref.watch(expenseCategoriesProvider(widget.userId));

    Future<void> addCategory() async {
      final id = await showAddCategorySheet(context);
      if (id != null && mounted) setState(() => _selectedCategory = id);
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Set Budget' : 'Edit Budget',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),

          // Amount
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Budget limit',
              prefixText: '${widget.currency} ',
              prefixStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),

          // Period
          Row(
            children: [
              Expanded(
                child: _PeriodChip(
                  label: 'Monthly',
                  selected: _period == 'monthly',
                  onTap: () => setState(() => _period = 'monthly'),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PeriodChip(
                  label: 'Weekly',
                  selected: _period == 'weekly',
                  onTap: () => setState(() => _period = 'weekly'),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category picker
          const Text('Category',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cats.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                if (i == cats.length) {
                  return GestureDetector(
                    onTap: addCategory,
                    child: Container(
                      width: 68,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.emerald.withOpacity(0.5),
                            width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded,
                              color: AppColors.emerald, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'New',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.emerald),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final cat = cats[i];
                final selected = cat.id == _selectedCategory;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    decoration: BoxDecoration(
                      color: selected
                          ? cat.color.withOpacity(0.2)
                          : (isDark ? AppColors.darkCard : AppColors.lightBg),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: selected ? cat.color : Colors.transparent,
                          width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          cat.label.split(' ').first,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: selected ? cat.color : Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _saving ? null : _save,
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(widget.existing == null ? 'Set Budget' : 'Save Changes',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _PeriodChip(
      {required this.label,
      required this.selected,
      required this.onTap,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.navy
              : (isDark ? AppColors.darkCard : AppColors.lightBg),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}
