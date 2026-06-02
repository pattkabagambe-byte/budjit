import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/shared_widgets.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final currency = ref.watch(currencyProvider);
    final goalsAsync = ref.watch(goalsStreamProvider(userId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            color: AppColors.primary,
            onPressed: () => _showAddGoalSheet(context, ref, userId, currency),
          ),
        ],
      ),
      body: goalsAsync.when(
        loading: () => _buildSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (goals) {
          if (goals.isEmpty) {
            return EmptyState(
              icon: Icons.savings_outlined,
              title: 'Start saving today',
              subtitle:
                  'Create your first savings goal and watch your money grow.',
              actionLabel: 'Create Goal',
              onAction: () => _showAddGoalSheet(context, ref, userId, currency),
            );
          }

          final active = goals.where((g) => !g.isCompleted).toList();
          final completed = goals.where((g) => g.isCompleted).toList();
          final totalSaved = goals.fold(0.0, (a, g) => a + g.currentAmount);
          final totalTarget = goals.fold(0.0, (a, g) => a + g.targetAmount);

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            children: [
              const SizedBox(height: 16),
              // Summary card
              _SummaryCard(
                totalSaved: totalSaved,
                totalTarget: totalTarget,
                activeCount: active.length,
                completedCount: completed.length,
                currency: currency,
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 20),

              if (active.isNotEmpty) ...[
                const SectionHeader(title: 'Active Goals'),
                ...active.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(
                        goal: e.value,
                        currency: currency,
                        isDark: isDark,
                        onDelete: () => _deleteGoal(ref, e.value.id),
                        onAddFunds: () =>
                            _showAddFundsSheet(context, ref, e.value, currency),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (e.key * 60).ms),
                    )),
              ],

              if (completed.isNotEmpty) ...[
                const SizedBox(height: 8),
                const SectionHeader(title: 'Completed 🎉'),
                ...completed.map((g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _GoalCard(
                        goal: g,
                        currency: currency,
                        isDark: isDark,
                        onDelete: () => _deleteGoal(ref, g.id),
                        onAddFunds: null,
                      ),
                    )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(context, ref, userId, currency),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Goal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Future<void> _deleteGoal(WidgetRef ref, String id) async {
    await ref.read(databaseProvider).deleteGoal(id);
    HapticFeedback.lightImpact();
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ShimmerBox(
            width: double.infinity,
            height: 140,
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showAddGoalSheet(
      BuildContext context, WidgetRef ref, String userId, String currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _GoalSheet(userId: userId, currency: currency, ref: ref),
    );
  }

  void _showAddFundsSheet(
      BuildContext context, WidgetRef ref, GoalEntry goal, String currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddFundsSheet(goal: goal, currency: currency, ref: ref),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double totalSaved, totalTarget;
  final int activeCount, completedCount;
  final String currency;

  const _SummaryCard({
    required this.totalSaved,
    required this.totalTarget,
    required this.activeCount,
    required this.completedCount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = totalTarget > 0 ? totalSaved / totalTarget : 0.0;
    return GradientCard(
      gradient: AppColors.gradientEmerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saved',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            Fmt.money(totalSaved, currency: currency),
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(
            'of ${Fmt.money(totalTarget, currency: currency)} target',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Pill(label: '$activeCount Active', color: Colors.white24),
              const SizedBox(width: 8),
              _Pill(
                  label: '$completedCount Completed 🏆', color: Colors.white24),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final GoalEntry goal;
  final String currency;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback? onAddFunds;

  const _GoalCard({
    required this.goal,
    required this.currency,
    required this.isDark,
    required this.onDelete,
    this.onAddFunds,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = goal.targetAmount - goal.currentAmount;
    final colorHex = goal.colorHex;
    final color = _hexColor(colorHex);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          builder: (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onAddFunds != null)
                  ListTile(
                    leading: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.emerald),
                    title: const Text('Add funds'),
                    onTap: () {
                      Navigator.pop(context);
                      onAddFunds!();
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.rose),
                  title: const Text('Delete goal',
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                      child: Text(goal.emoji,
                          style: const TextStyle(fontSize: 28))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.navy,
                              ),
                            ),
                          ),
                          if (goal.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text('Done 🎉',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.emerald,
                                      fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                      if (goal.deadline != null)
                        Text(
                          'By ${Fmt.date(goal.deadline!)}',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${(ratio * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900, color: color),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 10,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Fmt.money(goal.currentAmount, currency: currency),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color)),
                    const Text('saved',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(Fmt.money(goal.targetAmount, currency: currency),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.navy)),
                    const Text('target',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            if (!goal.isCompleted && onAddFunds != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddFunds,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(
                    'Add savings  ·  ${Fmt.compact(remaining, currency: currency)} to go',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _hexColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.emerald;
    }
  }
}

// ── Goal Sheet ────────────────────────────────────────────────────────────────

const _goalEmojis = [
  '🎯',
  '🏠',
  '✈️',
  '🚗',
  '💍',
  '🎓',
  '🏥',
  '🏖️',
  '💼',
  '🐷',
  '📱',
  '🎮',
  '🎸',
  '🌍',
  '🏋️'
];
const _goalColors = [
  '#10B981',
  '#8B5CF6',
  '#F59E0B',
  '#EF4444',
  '#0EA5E9',
  '#EC4899',
  '#F97316',
  '#14B8A6'
];

class _GoalSheet extends StatefulWidget {
  final String userId;
  final String currency;
  final WidgetRef ref;

  const _GoalSheet(
      {required this.userId, required this.currency, required this.ref});

  @override
  State<_GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<_GoalSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  String _emoji = '🎯';
  String _colorHex = '#10B981';
  DateTime? _deadline;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final target = double.tryParse(_targetCtrl.text.replaceAll(',', ''));
    if (_nameCtrl.text.trim().isEmpty || target == null || target <= 0) return;

    setState(() => _saving = true);
    final goal = GoalEntry(
      id: const Uuid().v4(),
      userId: widget.userId,
      name: _nameCtrl.text.trim(),
      targetAmount: target,
      currentAmount: 0,
      deadline: _deadline,
      emoji: _emoji,
      colorHex: _colorHex,
      createdAt: DateTime.now(),
      isCompleted: false,
    );
    await widget.ref.read(databaseProvider).upsertGoal(goal);
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDeadline() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    if (d != null) setState(() => _deadline = d);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          const Text('New Savings Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),

          // Emoji picker
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _goalEmojis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => _emoji = _goalEmojis[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _emoji == _goalEmojis[i]
                        ? _hexColor(_colorHex).withOpacity(0.2)
                        : (isDark ? AppColors.darkCard : AppColors.lightBg),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _emoji == _goalEmojis[i]
                          ? _hexColor(_colorHex)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                      child: Text(_goalEmojis[i],
                          style: const TextStyle(fontSize: 22))),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Color picker
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _goalColors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = _hexColor(_goalColors[i]);
                final selected = _colorHex == _goalColors[i];
                return GestureDetector(
                  onTap: () => setState(() => _colorHex = _goalColors[i]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: selected ? Colors.white : Colors.transparent,
                          width: 3),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: c.withOpacity(0.5), blurRadius: 6)
                            ]
                          : [],
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Goal name', hintText: 'e.g. Emergency Fund'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _targetCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Target amount',
              prefixText: '${widget.currency} ',
            ),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _pickDeadline,
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(_deadline != null
                ? 'Deadline: ${Fmt.date(_deadline!)}'
                : 'Set deadline (optional)'),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: _hexColor(_colorHex),
              minimumSize: const Size.fromHeight(52),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Create Goal',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.emerald;
    }
  }
}

// ── Add Funds Sheet ───────────────────────────────────────────────────────────

class _AddFundsSheet extends StatefulWidget {
  final GoalEntry goal;
  final String currency;
  final WidgetRef ref;

  const _AddFundsSheet(
      {required this.goal, required this.currency, required this.ref});

  @override
  State<_AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<_AddFundsSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;
  double _enteredAmount = 0;

  // Quick-pick amounts scaled to currency
  List<double> get _quickAmounts {
    final remaining = widget.goal.targetAmount - widget.goal.currentAmount;
    final r = remaining.clamp(1, double.infinity);
    // Sensible presets: 10%, 25%, 50% of remaining, and round thousands
    return [5000, 10000, 25000, 50000, 100000]
        .where((v) => v.toDouble() <= r * 1.1) // allow slight overshoot
        .take(4)
        .map((v) => v.toDouble())
        .toList();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _setAmount(double v) {
    _ctrl.text = v.toInt().toString();
    setState(() => _enteredAmount = v);
  }

  Future<void> _add() async {
    final amount = double.tryParse(_ctrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    await widget.ref.read(databaseProvider).addToGoal(widget.goal.id, amount);
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.pop(context);
  }

  Color _goalColor() {
    try {
      return Color(int.parse('FF${widget.goal.colorHex.replaceAll('#', '')}',
          radix: 16));
    } catch (_) {
      return AppColors.emerald;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goal = widget.goal;
    final color = _goalColor();
    final current = goal.currentAmount;
    final target = goal.targetAmount;
    final remaining = (target - current).clamp(0, double.infinity);
    final preview = (current + _enteredAmount).clamp(0, target);
    final previewRatio = target > 0 ? (preview / target).clamp(0.0, 1.0) : 0.0;
    final currentRatio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

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
          // Goal header
          Row(
            children: [
              Text(goal.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    Text(
                      '${Fmt.money(current, currency: widget.currency)} saved of ${Fmt.money(target, currency: widget.currency)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live progress preview
          Stack(
            children: [
              // Base bar (current)
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: previewRatio,
                  minHeight: 12,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(
                    _enteredAmount > 0 ? color.withValues(alpha: 0.4) : color,
                  ),
                ),
              ),
              // Preview overlay (added amount in solid)
              if (_enteredAmount > 0)
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: currentRatio,
                    minHeight: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Fmt.money(current, currency: widget.currency),
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color),
              ),
              Text(
                _enteredAmount > 0
                    ? '→ ${Fmt.money((current + _enteredAmount).clamp(0, target), currency: widget.currency)} (${(previewRatio * 100).toStringAsFixed(0)}%)'
                    : '${(currentRatio * 100).toStringAsFixed(0)}% saved',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _enteredAmount > 0 ? color : Colors.grey,
                ),
              ),
              Text(
                Fmt.money(target, currency: widget.currency),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick-amount chips
          if (_quickAmounts.isNotEmpty) ...[
            Text(
              'Quick add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._quickAmounts.map((v) => GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _setAmount(v);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _enteredAmount == v
                              ? color
                              : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _enteredAmount == v
                                ? color
                                : color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          Fmt.compact(v, currency: widget.currency),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _enteredAmount == v ? Colors.white : color,
                          ),
                        ),
                      ),
                    )),
                // "Full remaining" chip
                if (remaining > 0)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _setAmount(remaining.toDouble());
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _enteredAmount == remaining
                            ? AppColors.navy
                            : (isDark ? AppColors.darkCard : AppColors.lightBg),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        'Complete it 🏆',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _enteredAmount == remaining
                              ? Colors.white
                              : (isDark ? Colors.white : AppColors.navy),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Custom amount input
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            autofocus: _quickAmounts.isEmpty,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              ThousandsSeparatorInputFormatter(),
            ],
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '')) ?? 0;
              setState(() => _enteredAmount = parsed);
            },
            decoration: InputDecoration(
              labelText: 'Or enter custom amount',
              prefixText: '${widget.currency} ',
            ),
          ),
          const SizedBox(height: 20),

          FilledButton(
            onPressed: (_saving || _enteredAmount <= 0) ? null : _add,
            style: FilledButton.styleFrom(
              backgroundColor: color,
              minimumSize: const Size.fromHeight(54),
            ),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _enteredAmount > 0
                        ? 'Add ${Fmt.compact(_enteredAmount, currency: widget.currency)} to goal'
                        : 'Add Savings',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
