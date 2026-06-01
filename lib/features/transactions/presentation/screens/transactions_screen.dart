import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/category_data.dart';
import '../widgets/add_transaction_sheet.dart';

enum _Filter { all, income, expense }

final _filterProvider = StateProvider<_Filter>((ref) => _Filter.all);
final _searchProvider = StateProvider<String>((ref) => '');

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final month = ref.watch(selectedMonthProvider);
    final filter = ref.watch(_filterProvider);
    final search = ref.watch(_searchProvider);
    final currency = ref.watch(currencyProvider);
    final txAsync = ref.watch(transactionsStreamProvider((userId: userId, month: month)));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            color: AppColors.emerald,
            onPressed: () => showAddTransactionSheet(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(112),
          child: Column(
            children: [
              // Month selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                          DateTime(month.year, month.month - 1),
                    ),
                    Text(
                      Fmt.month(month),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
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
              // Filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    _FilterChip(label: 'All', filter: _Filter.all, current: filter, ref: ref),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Income', filter: _Filter.income, current: filter, ref: ref),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Expense', filter: _Filter.expense, current: filter, ref: ref),
                    const Spacer(),
                    txAsync.whenOrNull(
                      data: (txs) {
                        final filtered = _applyFilter(txs, filter, search);
                        final total = filtered.fold(0.0, (a, t) => a + (t.isIncome ? t.amount : -t.amount));
                        return Text(
                          Fmt.compact(total.abs(), currency: currency),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: total >= 0 ? AppColors.emerald : AppColors.rose,
                          ),
                        );
                      },
                    ) ?? const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: txAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (txs) {
          final filtered = _applyFilter(txs, filter, search);
          if (filtered.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No transactions',
              subtitle: filter == _Filter.all
                  ? 'Add your first transaction to get started.'
                  : 'No ${filter.name} transactions this month.',
              actionLabel: 'Add Transaction',
              onAction: () => showAddTransactionSheet(context),
            );
          }
          // Group by date
          final grouped = <String, List<TxEntry>>{};
          for (final t in filtered) {
            final key = _groupKey(t.date);
            (grouped[key] ??= []).add(t);
          }
          final groups = grouped.entries.toList();

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: groups.length,
            itemBuilder: (_, gi) {
              final group = groups[gi];
              final dayTotal = group.value.fold(0.0, (a, t) => a + (t.isIncome ? t.amount : -t.amount));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          group.key,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        Text(
                          Fmt.compact(dayTotal.abs(), currency: currency),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: dayTotal >= 0 ? AppColors.emerald : AppColors.rose,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...group.value.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TxCard(
                      entry: e.value,
                      currency: currency,
                      isDark: isDark,
                      onDelete: () => _delete(e.value.id),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: (e.key * 30).ms)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTransactionSheet(context),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }

  String _groupKey(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(d.year, d.month, d.day);
    final diff = today.difference(txDay).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEEE, d MMM').format(d);
  }

  List<TxEntry> _applyFilter(List<TxEntry> txs, _Filter filter, String search) {
    var result = txs;
    if (filter == _Filter.income) result = result.where((t) => t.isIncome).toList();
    if (filter == _Filter.expense) result = result.where((t) => !t.isIncome).toList();
    if (search.isNotEmpty) {
      result = result.where((t) => t.title.toLowerCase().contains(search.toLowerCase())).toList();
    }
    return result;
  }

  Future<void> _delete(String id) async {
    await ref.read(databaseProvider).deleteTransaction(id);
    HapticFeedback.lightImpact();
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ShimmerBox(width: double.infinity, height: 68, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final _Filter filter;
  final _Filter current;
  final WidgetRef ref;

  const _FilterChip({required this.label, required this.filter, required this.current, required this.ref});

  @override
  Widget build(BuildContext context) {
    final selected = filter == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(_filterProvider.notifier).state = filter;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.navy : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _TxCard extends StatelessWidget {
  final TxEntry entry;
  final String currency;
  final bool isDark;
  final VoidCallback onDelete;

  const _TxCard({required this.entry, required this.currency, required this.isDark, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cat = categoryByIdOrDefault(entry.category, isIncome: entry.isIncome);
    final amtColor = entry.isIncome ? AppColors.emerald : AppColors.rose;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.rose.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.rose),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete transaction?'),
            content: Text('Remove "${entry.title}" from your records?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.rose),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            CategoryBadge(category: cat.id, emoji: cat.emoji, color: cat.color, size: 44),
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
                      color: isDark ? Colors.white : AppColors.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(cat.label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      if (entry.note != null) ...[
                        const Text(' · ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Flexible(
                          child: Text(
                            entry.note!,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.isIncome ? '+' : '-'}${Fmt.compact(entry.amount, currency: currency)}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: amtColor),
                ),
                Text(Fmt.dateShort(entry.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
