import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../transactions/domain/category_data.dart';
import '../widgets/add_category_sheet.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final customAsync = ref.watch(customCategoriesStreamProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expense'),
              Tab(text: 'Income'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final tab = DefaultTabController.of(context).index;
            await showAddCategorySheet(context, isIncome: tab == 1);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Category'),
        ),
        body: customAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (custom) {
            final customTx = custom.map((c) => c.toTxCategory()).toList();
            return TabBarView(
              children: [
                _CategoryList(
                  builtIn: kExpenseCategories,
                  custom: customTx.where((c) => !c.isIncome).toList(),
                  isDark: isDark,
                  onDelete: (id) => _deleteCategory(context, ref, id),
                ),
                _CategoryList(
                  builtIn: kIncomeCategories,
                  custom: customTx.where((c) => c.isIncome).toList(),
                  isDark: isDark,
                  onDelete: (id) => _deleteCategory(context, ref, id),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category?'),
        content: const Text('Transactions using this category will show as Miscellaneous.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.rose),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteCustomCategory(id);
      HapticFeedback.mediumImpact();
    }
  }
}

class _CategoryList extends StatelessWidget {
  final List<TxCategory> builtIn;
  final List<TxCategory> custom;
  final bool isDark;
  final ValueChanged<String> onDelete;

  const _CategoryList({
    required this.builtIn,
    required this.custom,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (custom.isNotEmpty) ...[
          _SectionHeader(title: 'Your Categories', isDark: isDark),
          const SizedBox(height: 8),
          ...custom.map((c) => _CategoryTile(
                category: c,
                isDark: isDark,
                deletable: true,
                onDelete: () => onDelete(c.id),
              )),
          const SizedBox(height: 24),
        ],
        _SectionHeader(title: 'Built-in Categories', isDark: isDark),
        const SizedBox(height: 8),
        ...builtIn.map((c) => _CategoryTile(category: c, isDark: isDark)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white54 : Colors.black45,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final TxCategory category;
  final bool isDark;
  final bool deletable;
  final VoidCallback? onDelete;

  const _CategoryTile({
    required this.category,
    required this.isDark,
    this.deletable = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: ListTile(
        leading: CategoryBadge(
          category: category.label,
          emoji: category.emoji,
          color: category.color,
          size: 40,
        ),
        title: Text(category.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: deletable
            ? IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.rose),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
