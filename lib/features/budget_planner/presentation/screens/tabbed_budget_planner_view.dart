import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/app_preferences.dart';
import '../../../../core/models/layout_mode.dart';
import '../../../../core/providers/app_preferences_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/planner_menu_sheet.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../transactions/domain/category_data.dart';
import '../../domain/planner_report.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

// ── Root scaffold ─────────────────────────────────────────────────────────────

class TabbedBudgetPlannerView extends ConsumerStatefulWidget {
  const TabbedBudgetPlannerView({super.key});

  @override
  ConsumerState<TabbedBudgetPlannerView> createState() =>
      _TabbedBudgetPlannerViewState();
}

class _TabbedBudgetPlannerViewState
    extends ConsumerState<TabbedBudgetPlannerView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bg => _isDark ? AppColors.tabBgDark : AppColors.tabBg;
  Color get _primary => AppColors.tabPrimary;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final currency = ref.watch(currencyProvider);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Guest User';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _isDark ? AppColors.tabCardDark : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Budget Planner',
          style: TextStyle(
            color: _primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Tooltip(
            message: 'Budget Planner menu',
            child: Semantics(
              button: true,
              label: 'Open Budget Planner menu',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => PlannerMenuSheet.show(
                  context,
                  currentMode: LayoutMode.tabbedMode,
                  onOpenSettings: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                  onExportReport: () => _tabCtrl.animateTo(2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: UserAvatar(
                    photoUrl: user?.photoURL,
                    displayName: displayName,
                    radius: 17,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: _primary,
          unselectedLabelColor:
              _isDark ? AppColors.tabMutedDark : AppColors.tabMuted,
          indicatorColor: _primary,
          indicatorWeight: 2.5,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          dividerColor: _isDark ? AppColors.tabBorderDark : AppColors.tabBorder,
          tabs: const [
            Tab(
                icon: Icon(Icons.receipt_long_outlined, size: 20),
                text: 'Actual'),
            Tab(
                icon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                text: 'Budget'),
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 20), text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ActualTab(userId: userId, currency: currency, isDark: _isDark),
          _BudgetTab(userId: userId, currency: currency, isDark: _isDark),
          _ReportsTab(userId: userId, currency: currency, isDark: _isDark),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTUAL TAB — track real spending
// ═══════════════════════════════════════════════════════════════════════════════

class _ActualTab extends ConsumerStatefulWidget {
  final String userId;
  final String currency;
  final bool isDark;

  const _ActualTab(
      {required this.userId, required this.currency, required this.isDark});

  @override
  ConsumerState<_ActualTab> createState() => _ActualTabState();
}

class _ActualTabState extends ConsumerState<_ActualTab> {
  final _labelCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _categoryId = 'food';
  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount greater than zero');
      return;
    }
    setState(() => _submitting = true);
    final entry = TxEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      title: _labelCtrl.text.trim().isEmpty
          ? categoryByIdOrDefault(_categoryId).label
          : _labelCtrl.text.trim(),
      amount: amount,
      isIncome: false,
      category: _categoryId,
      date: _date,
      note: null,
      currency: widget.currency,
      synced: false,
    );
    await ref.read(databaseProvider).upsertTransaction(entry);
    _labelCtrl.clear();
    _amountCtrl.clear();
    setState(() {
      _submitting = false;
      _date = DateTime.now();
    });
    _mediumHaptic(ref);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added')),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.rose),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(allTransactionsStreamProvider(widget.userId));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Form card ──
          _TCard(
            isDark: widget.isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TCardTitle('Track actual spending', widget.isDark),
                const SizedBox(height: 16),
                _TField(
                  ctrl: _labelCtrl,
                  hint: 'Expense label',
                  icon: Icons.label_outline_rounded,
                  isDark: widget.isDark,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 10),
                _TField(
                  ctrl: _amountCtrl,
                  hint: 'Actual amount',
                  icon: Icons.payment_rounded,
                  isDark: widget.isDark,
                  isNumber: true,
                  prefix: widget.currency,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 10),
                _TCategoryPicker(
                  label: 'Category',
                  selectedId: _categoryId,
                  categories: kExpenseCategories,
                  isDark: widget.isDark,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 10),
                _TDateField(
                  label: 'Expense date',
                  date: _date,
                  isDark: widget.isDark,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                _TButton(
                  label: 'Add expense',
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: 16),

          // ── Expense list ──
          txAsync.when(
            loading: () => const ShimmerBox(
                width: double.infinity,
                height: 120,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            error: (e, _) => Text('Error: $e'),
            data: (all) {
              final expenses = all.where((t) => !t.isIncome).toList();
              return _TCard(
                isDark: widget.isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TCardTitle(
                        'Actual expenses (${expenses.length})', widget.isDark),
                    const SizedBox(height: 8),
                    if (expenses.isEmpty)
                      _TEmptyState('No actual expenses yet')
                    else
                      ...expenses.map((e) => _TEntryRow(
                            id: e.id,
                            emoji: categoryByIdOrDefault(e.category).emoji,
                            label: e.title,
                            sub: categoryByIdOrDefault(e.category).label,
                            amount:
                                Fmt.money(e.amount, currency: widget.currency),
                            isDark: widget.isDark,
                            onDelete: () => _delete(e.id),
                          )),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    final confirmed = await _confirmDelete(context, ref);
    if (confirmed) {
      await ref.read(databaseProvider).deleteTransaction(id);
      _lightHaptic(ref);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Expense deleted')));
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BUDGET TAB — income + planned expenses sub-tabs
// ═══════════════════════════════════════════════════════════════════════════════

class _BudgetTab extends ConsumerStatefulWidget {
  final String userId;
  final String currency;
  final bool isDark;

  const _BudgetTab(
      {required this.userId, required this.currency, required this.isDark});

  @override
  ConsumerState<_BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends ConsumerState<_BudgetTab>
    with SingleTickerProviderStateMixin {
  late final TabController _sub;

  @override
  void initState() {
    super.initState();
    _sub = TabController(length: 2, vsync: this);
    _sub.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _sub.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tab bar
        Container(
          color: widget.isDark ? AppColors.tabCardDark : Colors.white,
          child: TabBar(
            controller: _sub,
            labelColor: AppColors.tabPrimary,
            unselectedLabelColor:
                widget.isDark ? AppColors.tabMutedDark : AppColors.tabMuted,
            indicatorColor: AppColors.tabPrimary,
            indicatorWeight: 2,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            dividerColor:
                widget.isDark ? AppColors.tabBorderDark : AppColors.tabBorder,
            tabs: const [
              Tab(
                  icon: Icon(Icons.arrow_downward_rounded, size: 18),
                  text: 'Income'),
              Tab(
                  icon: Icon(Icons.arrow_upward_rounded, size: 18),
                  text: 'Planned expense'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _sub,
            children: [
              _IncomeSubTab(
                  userId: widget.userId,
                  currency: widget.currency,
                  isDark: widget.isDark),
              _PlannedExpenseSubTab(
                  userId: widget.userId,
                  currency: widget.currency,
                  isDark: widget.isDark),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Income sub-tab ───────────────────────────────────────────────────────────

class _IncomeSubTab extends ConsumerStatefulWidget {
  final String userId;
  final String currency;
  final bool isDark;

  const _IncomeSubTab(
      {required this.userId, required this.currency, required this.isDark});

  @override
  ConsumerState<_IncomeSubTab> createState() => _IncomeSubTabState();
}

class _IncomeSubTabState extends ConsumerState<_IncomeSubTab> {
  final _labelCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _categoryId = 'salary';
  bool _submitting = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid amount'),
            backgroundColor: AppColors.rose),
      );
      return;
    }
    setState(() => _submitting = true);
    final entry = TxEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      title: _labelCtrl.text.trim().isEmpty
          ? categoryByIdOrDefault(_categoryId, isIncome: true).label
          : _labelCtrl.text.trim(),
      amount: amount,
      isIncome: true,
      category: _categoryId,
      date: DateTime.now(),
      note: null,
      currency: widget.currency,
      synced: false,
    );
    await ref.read(databaseProvider).upsertTransaction(entry);
    _labelCtrl.clear();
    _amountCtrl.clear();
    setState(() => _submitting = false);
    _mediumHaptic(ref);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Income added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(allTransactionsStreamProvider(widget.userId));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TCard(
            isDark: widget.isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TCardTitle('Budgeted income', widget.isDark),
                const SizedBox(height: 16),
                _TField(
                  ctrl: _labelCtrl,
                  hint: 'Label (optional)',
                  icon: Icons.label_outline_rounded,
                  isDark: widget.isDark,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 10),
                _TField(
                  ctrl: _amountCtrl,
                  hint: 'Amount',
                  icon: Icons.payment_rounded,
                  isDark: widget.isDark,
                  isNumber: true,
                  prefix: widget.currency,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 10),
                _TCategoryPicker(
                  label: 'Income category',
                  selectedId: _categoryId,
                  categories: kIncomeCategories,
                  isDark: widget.isDark,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 16),
                _TButton(
                  label: 'Add income',
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),
          const SizedBox(height: 16),
          txAsync.when(
            loading: () => const ShimmerBox(
                width: double.infinity,
                height: 100,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            error: (e, _) => Text('Error: $e'),
            data: (all) {
              final income = all.where((t) => t.isIncome).toList();
              return _TCard(
                isDark: widget.isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TCardTitle(
                        'Income lines (${income.length})', widget.isDark),
                    const SizedBox(height: 8),
                    if (income.isEmpty)
                      _TEmptyState('No income added yet')
                    else
                      ...income.map((e) => _TEntryRow(
                            id: e.id,
                            emoji: categoryByIdOrDefault(e.category,
                                    isIncome: true)
                                .emoji,
                            label: e.title,
                            sub: categoryByIdOrDefault(e.category,
                                    isIncome: true)
                                .label,
                            amount:
                                Fmt.money(e.amount, currency: widget.currency),
                            isDark: widget.isDark,
                            onDelete: () => _delete(e.id),
                          )),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    final confirmed = await _confirmDelete(context, ref);
    if (confirmed) {
      await ref.read(databaseProvider).deleteTransaction(id);
      _lightHaptic(ref);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Income deleted')));
      }
    }
  }
}

// ─── Planned expense sub-tab ──────────────────────────────────────────────────

class _PlannedExpenseSubTab extends ConsumerStatefulWidget {
  final String userId;
  final String currency;
  final bool isDark;

  const _PlannedExpenseSubTab(
      {required this.userId, required this.currency, required this.isDark});

  @override
  ConsumerState<_PlannedExpenseSubTab> createState() =>
      _PlannedExpenseSubTabState();
}

class _PlannedExpenseSubTabState extends ConsumerState<_PlannedExpenseSubTab> {
  final _labelCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _categoryId = 'food';
  bool _submitting = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '').trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter a valid amount'),
            backgroundColor: AppColors.rose),
      );
      return;
    }
    setState(() => _submitting = true);
    final budget = Budget(
      id: const Uuid().v4(),
      userId: widget.userId,
      label: _labelCtrl.text.trim().isEmpty ? null : _labelCtrl.text.trim(),
      category: _categoryId,
      limitAmount: amount,
      period: 'monthly',
      createdAt: DateTime.now(),
    );
    await ref.read(databaseProvider).upsertBudget(budget);
    _labelCtrl.clear();
    _amountCtrl.clear();
    setState(() => _submitting = false);
    _mediumHaptic(ref);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Budget line added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetsStreamProvider(widget.userId));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TCard(
            isDark: widget.isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TCardTitle(
                  'Plan your expenses',
                  widget.isDark,
                  subtitle: 'Set a monthly amount for each spending category.',
                ),
                const SizedBox(height: 16),
                _TField(
                  ctrl: _labelCtrl,
                  hint: 'Label (optional)',
                  icon: Icons.label_outline_rounded,
                  isDark: widget.isDark,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 10),
                _TField(
                  ctrl: _amountCtrl,
                  hint: 'Budget amount',
                  icon: Icons.payment_rounded,
                  isDark: widget.isDark,
                  isNumber: true,
                  prefix: widget.currency,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 10),
                _TCategoryPicker(
                  label: 'Expense category',
                  selectedId: _categoryId,
                  categories: kExpenseCategories,
                  isDark: widget.isDark,
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 16),
                _TButton(
                  label: 'Add to budget',
                  loading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),
          const SizedBox(height: 16),
          budgetsAsync.when(
            loading: () => const ShimmerBox(
                width: double.infinity,
                height: 100,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            error: (e, _) => Text('Error: $e'),
            data: (budgets) => _TCard(
              isDark: widget.isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TCardTitle('Expense budget lines (${budgets.length})',
                      widget.isDark),
                  const SizedBox(height: 8),
                  if (budgets.isEmpty)
                    _TEmptyState(
                      'No planned expenses yet',
                      icon: Icons.playlist_add_rounded,
                    )
                  else
                    ...budgets.map((b) => _TEntryRow(
                          id: b.id,
                          emoji: categoryByIdOrDefault(b.category).emoji,
                          label: b.label ??
                              categoryByIdOrDefault(b.category).label,
                          sub: categoryByIdOrDefault(b.category).label,
                          amount: Fmt.money(b.limitAmount,
                              currency: widget.currency),
                          isDark: widget.isDark,
                          onDelete: () => _deleteBudget(b.id),
                        )),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBudget(String id) async {
    final confirmed = await _confirmDelete(context, ref);
    if (confirmed) {
      await ref.read(databaseProvider).deleteBudget(id);
      _lightHaptic(ref);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Budget line deleted')));
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// REPORTS TAB
// ═══════════════════════════════════════════════════════════════════════════════

class _ReportsTab extends ConsumerStatefulWidget {
  final String userId;
  final String currency;
  final bool isDark;

  const _ReportsTab(
      {required this.userId, required this.currency, required this.isDark});

  @override
  ConsumerState<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<_ReportsTab> {
  late PlannerReportPeriod _period;

  @override
  void initState() {
    super.initState();
    _period = ref.read(appPreferencesProvider).reportPeriod;
  }

  String get _periodRangeLabel {
    final (start, end) = _period.range();
    return '${DateFormat('d MMM yyyy').format(start)} - '
        '${DateFormat('d MMM yyyy').format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(allTransactionsStreamProvider(widget.userId));
    final budgetsAsync = ref.watch(budgetsStreamProvider(widget.userId));

    return allAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allTx) => budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (budgets) => _buildReport(allTx, budgets),
      ),
    );
  }

  Widget _buildReport(List<TxEntry> allTx, List<Budget> budgets) {
    final (start, end) = _period.range();

    // Filter transactions to period
    final periodTx = allTx.where((t) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      return !d.isBefore(start) && !d.isAfter(end);
    }).toList();

    final report = PlannerReportCalculator.calculate(
      transactions: periodTx,
      budgets: budgets,
    );
    final income = report.income;
    final actualExpenses = report.actualExpenses;
    final totalBudgeted = report.totalBudgeted;
    final unassigned = report.unassignedCash;
    final actualLeft = report.actualLeft;
    final budgetVsIncomePct = report.budgetVsIncomePercent;
    final budgetUtilPct = report.budgetUtilizationPercent;
    final sortedCats = report.spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final budgetByCategory = report.budgetByCategory;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      physics: const BouncingScrollPhysics(),
      children: [
        // Period selector
        _TCard(
          isDark: widget.isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report period',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: widget.isDark ? Colors.white : AppColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: PlannerReportPeriod.values.map((p) {
                  final selected = p == _period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _selectionHaptic(ref);
                        setState(() => _period = p);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.tabPrimary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? AppColors.tabPrimary
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          p.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            color: selected
                                ? AppColors.tabPrimary
                                : (widget.isDark
                                    ? AppColors.tabMutedDark
                                    : AppColors.tabMuted),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Text(
                _periodRangeLabel,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms),

        const SizedBox(height: 16),

        // Unassigned cash (hero dark card)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.tabDarkSurface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UNASSIGNED CASH',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Fmt.money(unassigned.abs(), currency: widget.currency),
                style: TextStyle(
                  color: unassigned >= 0 ? Colors.white : AppColors.rose,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value:
                      income > 0 ? (totalBudgeted / income).clamp(0.0, 1.0) : 0,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(AppColors.amber),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              _ReportRow('Income', Fmt.money(income, currency: widget.currency),
                  bold: true),
              _ReportRow('Budgeted',
                  Fmt.money(totalBudgeted, currency: widget.currency)),
              _ReportRow('Monthly actual',
                  Fmt.money(actualExpenses, currency: widget.currency),
                  bold: true),
              _ReportRow('Actual left',
                  Fmt.money(actualLeft, currency: widget.currency),
                  bold: true,
                  valueColor: actualLeft >= 0 ? Colors.white : AppColors.rose),
              const Divider(color: Colors.white12, height: 24),
              _ReportRow(
                'Expense budget vs income',
                '${budgetVsIncomePct.toStringAsFixed(1)}%',
              ),
              _ReportRow(
                'Budget utilisation',
                '${budgetUtilPct.toStringAsFixed(1)}%',
                valueColor: budgetUtilPct > 90
                    ? AppColors.rose
                    : budgetUtilPct > 70
                        ? AppColors.amber
                        : AppColors.emeraldLight,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

        // Spending by category
        if (sortedCats.isNotEmpty) ...[
          const SizedBox(height: 16),
          _TCard(
            isDark: widget.isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TCardTitle('Spending by category', widget.isDark),
                const SizedBox(height: 12),
                ...sortedCats.take(8).map((e) {
                  final cat = categoryByIdOrDefault(e.key);
                  final budget = budgetByCategory[e.key] ?? 0;
                  final overBudget = budget > 0 && e.value > budget;
                  final ratio =
                      budget > 0 ? (e.value / budget).clamp(0.0, 1.0) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(cat.emoji,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cat.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark
                                      ? Colors.white
                                      : AppColors.navy,
                                ),
                              ),
                            ),
                            if (overBudget)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.rose.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Over',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.rose,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              Fmt.compact(e.value, currency: widget.currency),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: overBudget
                                    ? AppColors.rose
                                    : (widget.isDark
                                        ? Colors.white
                                        : AppColors.navy),
                              ),
                            ),
                          ],
                        ),
                        if (budget > 0) ...[
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 4,
                              backgroundColor:
                                  cat.color.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation(
                                overBudget ? AppColors.rose : cat.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Budget: ${Fmt.compact(budget, currency: widget.currency)}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],

        // Empty state when no data
        if (income == 0 && actualExpenses == 0 && totalBudgeted == 0)
          _TCard(
            isDark: widget.isDark,
            child: _TEmptyState(
                'No data for this period. Add income and expenses to see your report.'),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED UI COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════════

class _TCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _TCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.tabCardDark : AppColors.tabCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.tabBorderDark : AppColors.tabBorder,
        ),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: child,
    );
  }
}

class _TCardTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  final String? subtitle;

  const _TCardTitle(this.text, this.isDark, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.navy,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: isDark ? AppColors.tabMutedDark : AppColors.tabMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _TField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool isNumber;
  final String? prefix;
  final ValueChanged<String> onChanged;

  const _TField({
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.isNumber = false,
    this.prefix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.tabBgDark.withValues(alpha: 0.6)
            : AppColors.lightBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.tabBorderDark : AppColors.tabBorder,
        ),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [
                FilteringTextInputFormatter.digitsOnly,
                ThousandsSeparatorInputFormatter(),
              ]
            : null,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppColors.navy,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon,
              size: 20,
              color: isDark ? AppColors.tabMutedDark : AppColors.tabMuted),
          prefixText: prefix != null ? '$prefix ' : null,
          prefixStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.tabMuted,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? AppColors.tabMutedDark : AppColors.tabMuted,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _TCategoryPicker extends StatelessWidget {
  final String label;
  final String selectedId;
  final List<TxCategory> categories;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _TCategoryPicker({
    required this.label,
    required this.selectedId,
    required this.categories,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? AppColors.tabMutedDark : AppColors.tabMuted;
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.tabBgDark.withValues(alpha: 0.6)
              : AppColors.lightBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.tabBorderDark : AppColors.tabBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 2),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedId,
                isExpanded: true,
                isDense: true,
                dropdownColor: isDark ? AppColors.tabCardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.navy,
                ),
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: muted),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                selectedItemBuilder: (_) => categories
                    .map((c) => Row(
                          children: [
                            Text(c.emoji, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isDark ? Colors.white : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              Text(c.emoji,
                                  style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 10),
                              Expanded(child: Text(c.label)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TDateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isDark;
  final VoidCallback onTap;

  const _TDateField({
    required this.label,
    required this.date,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.tabBgDark.withValues(alpha: 0.6)
              : AppColors.lightBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.tabBorderDark : AppColors.tabBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 20,
                color: isDark ? AppColors.tabMutedDark : AppColors.tabMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          isDark ? AppColors.tabMutedDark : AppColors.tabMuted,
                    ),
                  ),
                  Text(
                    DateFormat('d MMM yyyy').format(date),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_calendar_rounded,
                size: 18,
                color: isDark ? AppColors.tabMutedDark : AppColors.tabMuted),
          ],
        ),
      ),
    );
  }
}

class _TButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;

  const _TButton(
      {required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.tabPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TEntryRow extends StatelessWidget {
  final String id;
  final String emoji;
  final String label;
  final String sub;
  final String amount;
  final bool isDark;
  final VoidCallback onDelete;

  const _TEntryRow({
    required this.id,
    required this.emoji,
    required this.label,
    required this.sub,
    required this.amount,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tabPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(sub,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: isDark ? Colors.white : AppColors.navy,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

class _TEmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;

  const _TEmptyState(this.message, {this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            if (icon != null) ...[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 21),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _ReportRow(this.label, this.value,
      {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final vColor = valueColor ?? Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: bold ? Colors.white70 : Colors.white54,
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: vColor,
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Future<bool> _confirmDelete(BuildContext context, WidgetRef ref) async {
  if (!ref.read(appPreferencesProvider).confirmBeforeDelete) return true;
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete entry?'),
          content: const Text('This cannot be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.rose),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;
}

void _selectionHaptic(WidgetRef ref) {
  if (ref.read(appPreferencesProvider).hapticFeedback) {
    HapticFeedback.selectionClick();
  }
}

void _mediumHaptic(WidgetRef ref) {
  if (ref.read(appPreferencesProvider).hapticFeedback) {
    HapticFeedback.mediumImpact();
  }
}

void _lightHaptic(WidgetRef ref) {
  if (ref.read(appPreferencesProvider).hapticFeedback) {
    HapticFeedback.lightImpact();
  }
}
