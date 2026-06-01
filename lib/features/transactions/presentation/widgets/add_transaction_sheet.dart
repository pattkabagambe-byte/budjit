import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/category_data.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _selectedCategoryId = 'food';
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {
          _selectedCategoryId =
              _tabCtrl.index == 0 ? 'food' : 'salary';
        }));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _isIncome => _tabCtrl.index == 1;

  List<TxCategory> get _cats =>
      _isIncome ? kIncomeCategories : kExpenseCategories;

  Future<void> _submit() async {
    final raw = _amountCtrl.text.replaceAll(',', '');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }
    final title = _titleCtrl.text.trim().isEmpty
        ? categoryByIdOrDefault(_selectedCategoryId, isIncome: _isIncome).label
        : _titleCtrl.text.trim();

    setState(() => _saving = true);
    final userId = ref.read(currentUserIdProvider);
    final currency = ref.read(currencyProvider);

    final entry = TxEntry(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      amount: amount,
      isIncome: _isIncome,
      category: _selectedCategoryId,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      currency: currency,
      synced: false,
    );

    await ref.read(databaseProvider).upsertTransaction(entry);
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.of(context).pop();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = ref.watch(currencyProvider);

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
          // Tab switcher
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicator: BoxDecoration(
                color: _isIncome ? AppColors.emerald : AppColors.rose,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: 'Expense'), Tab(text: 'Income')],
            ),
          ),
          const SizedBox(height: 20),

          // Amount input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  currency,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: _isIncome ? AppColors.emerald : AppColors.rose,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintText: '0',
                    hintStyle: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black12),
                    contentPadding: EdgeInsets.zero,
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Category picker
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _cats[i];
                final selected = cat.id == _selectedCategoryId;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategoryId = cat.id);
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
                        width: 2,
                      ),
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
                            color: selected ? cat.color : Colors.grey,
                          ),
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
          const SizedBox(height: 16),

          // Title field
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              prefixIcon: Icon(
                Icons.edit_outlined,
                color: isDark ? Colors.white38 : Colors.black38,
                size: 20,
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),

          // Date & note row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(Fmt.dateShort(_date), style: const TextStyle(fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    prefixIcon: Icon(Icons.note_outlined, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit
          FilledButton(
            onPressed: _saving ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _isIncome ? AppColors.emerald : AppColors.rose,
              minimumSize: const Size.fromHeight(52),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _isIncome ? 'Add Income' : 'Add Expense',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

void showAddTransactionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const AddTransactionSheet(),
  );
}
