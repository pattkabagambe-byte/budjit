import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/support/support_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../data/budget_repository.dart';
import '../../domain/budget_models.dart';

final _selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final _entriesProvider = FutureProvider.family<List<BudgetEntry>, DateTime>((ref, month) =>
    BudgetRepository().getEntries(month: month));

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  final _repo = BudgetRepository();

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (_) => setState(() => _bannerLoaded = true)),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  bool get _isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  void _signOut() => FirebaseAuth.instance.signOut();

  void _promptSignIn() {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const AuthScreen(isLinking: true),
    ));
  }

  String _fmtMoney(double v) {
    final fmt = NumberFormat('#,##0', 'en_US');
    return 'UGX ${fmt.format(v)}';
  }

  void _addEntry(bool isIncome) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'local';
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String? selectedCategory = isIncome ? IncomeCategory.salary.name : ExpenseCategory.groceries.name;
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(isIncome ? 'Add Income' : 'Add Expense',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Amount (UGX)', prefixText: 'UGX '),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: (isIncome ? IncomeCategory.values.map((c) => DropdownMenuItem(value: c.name, child: Text('${c.icon} ${c.label}')))
                    : ExpenseCategory.values.map((c) => DropdownMenuItem(value: c.name, child: Text('${c.icon} ${c.label}')))).toList(),
                onChanged: (v) => setModalState(() => selectedCategory = v),
              ),
              const SizedBox(height: 10),
              TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text);
                  if (titleCtrl.text.isEmpty || amount == null) return;
                  final entry = BudgetEntry(
                    id: const Uuid().v4(),
                    userId: uid,
                    title: titleCtrl.text.trim(),
                    amount: amount,
                    isIncome: isIncome,
                    category: selectedCategory!,
                    date: DateTime.now(),
                    note: noteCtrl.text.isEmpty ? null : noteCtrl.text.trim(),
                  );
                  await _repo.addEntry(entry);
                  ref.invalidate(_entriesProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(isIncome ? 'Add Income' : 'Add Expense'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = ref.watch(_selectedMonthProvider);
    final entriesAsync = ref.watch(_entriesProvider(month));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Cashflo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Get Help',
            onPressed: () => SupportSheet.show(context, appName: 'Cashflo'),
          ),
          if (_isGuest)
            TextButton(
              onPressed: _promptSignIn,
              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700)),
            )
          else
            IconButton(icon: const Icon(Icons.logout_rounded), onPressed: _signOut),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(theme, month),
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (entries) {
                final summary = _repo.computeSummary(entries);
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSummaryCard(theme, summary),
                    const SizedBox(height: 16),
                    if (entries.isEmpty)
                      _buildEmptyState(theme)
                    else ...[
                      Row(
                        children: [
                          _tab == 0 ? _buildTabChip('All', true, () {}) : _buildTabChip('All', false, () => setState(() => _tab = 0)),
                          const SizedBox(width: 8),
                          _tab == 1 ? _buildTabChip('Income', true, () {}) : _buildTabChip('Income', false, () => setState(() => _tab = 1)),
                          const SizedBox(width: 8),
                          _tab == 2 ? _buildTabChip('Expenses', true, () {}) : _buildTabChip('Expenses', false, () => setState(() => _tab = 2)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...entries.where((e) => _tab == 0 || (_tab == 1 && e.isIncome) || (_tab == 2 && !e.isIncome))
                          .map((e) => _EntryTile(entry: e, fmt: _fmtMoney, onDelete: () async {
                            await _repo.deleteEntry(e.id);
                            ref.invalidate(_entriesProvider);
                          })),
                    ],
                  ],
                );
              },
            ),
          ),
          if (_bannerLoaded && _bannerAd != null)
            SafeArea(child: SizedBox(height: _bannerAd!.size.height.toDouble(), child: AdWidget(ad: _bannerAd!))),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'income',
            backgroundColor: const Color(0xFF10B981),
            onPressed: () => _addEntry(true),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'expense',
            backgroundColor: AppTheme.primary,
            onPressed: () => _addEntry(false),
            icon: const Icon(Icons.remove_rounded, color: Colors.white),
            label: const Text('Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme, DateTime month) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => ref.read(_selectedMonthProvider.notifier).state =
                DateTime(month.year, month.month - 1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(month),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => ref.read(_selectedMonthProvider.notifier).state =
                DateTime(month.year, month.month + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme, BudgetSummary summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: summary.balance >= 0 ? const Color(0xFF10B981).withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text('Balance', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    _fmtMoney(summary.balance.abs()),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: summary.balance >= 0 ? const Color(0xFF10B981) : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _SummaryItem(label: 'Income', value: _fmtMoney(summary.totalIncome), color: const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _SummaryItem(label: 'Expenses', value: _fmtMoney(summary.totalExpenses), color: Colors.red)),
              ],
            ),
            if (summary.savingsRate > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 16),
                  const SizedBox(width: 4),
                  Text('${summary.savingsRate.toStringAsFixed(1)}% savings rate',
                      style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.black12),
        const SizedBox(height: 16),
        Text('No entries yet', style: theme.textTheme.titleMedium?.copyWith(color: Colors.black38, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Tap + to add your first income or expense', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black26), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildTabChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppTheme.primary : Colors.black.withOpacity(0.1)),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final BudgetEntry entry;
  final String Function(double) fmt;
  final VoidCallback onDelete;

  const _EntryTile({required this.entry, required this.fmt, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.isIncome;
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isIncome ? const Color(0xFF10B981).withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isIncome ? const Color(0xFF10B981) : Colors.red, size: 20),
          ),
          title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(entry.category, style: const TextStyle(fontSize: 12, color: Colors.black45)),
          trailing: Text(
            fmt(entry.amount),
            style: TextStyle(fontWeight: FontWeight.w900, color: isIncome ? const Color(0xFF10B981) : Colors.red),
          ),
        ),
      ),
    );
  }
}
