import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/app_colors.dart';

const kCategoryEmojis = [
  '🍽️', '🛒', '🚗', '🏠', '💡', '🏥', '📚', '🎓', '🎬', '🛍️', '💆', '📱',
  '📞', '⛽', '👶', '💳', '🐷', '📦', '💼', '🏢', '💻', '⚡', '🏘️', '📈',
  '📲', '🎁', '💰', '🎯', '✈️', '💍', '🏖️', '🎮', '🎸', '🌍', '🏋️', '🐾',
  '🎨', '🧸', '☕', '🍕', '🌿', '🔧', '💊', '🚌', '🎵', '📺',
];

const kCategoryColors = [
  '#10B981', '#8B5CF6', '#F59E0B', '#EF4444', '#0EA5E9', '#EC4899',
  '#F97316', '#14B8A6', '#6366F1', '#84CC16',
];

class AddCategorySheet extends ConsumerStatefulWidget {
  const AddCategorySheet({super.key, this.isIncome = false});

  final bool isIncome;

  @override
  ConsumerState<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends ConsumerState<AddCategorySheet> {
  final _labelCtrl = TextEditingController();
  String _emoji = '📦';
  String _colorHex = '#6366F1';
  bool _saving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final label = _labelCtrl.text.trim();
    if (label.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a category name')));
      return;
    }

    setState(() => _saving = true);
    final userId = ref.read(currentUserIdProvider);
    final entry = CustomCategoryEntry(
      id: 'custom_${const Uuid().v4()}',
      userId: userId,
      label: label,
      emoji: _emoji,
      colorHex: _colorHex,
      isIncome: widget.isIncome,
      createdAt: DateTime.now(),
    );
    await ref.read(databaseProvider).upsertCustomCategory(entry);
    HapticFeedback.mediumImpact();
    if (mounted) Navigator.pop(context, entry.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = categoryHexColor(_colorHex);

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
            widget.isIncome ? 'New Income Category' : 'New Expense Category',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _labelCtrl,
            decoration: const InputDecoration(
              labelText: 'Category name',
              prefixIcon: Icon(Icons.label_outline, size: 20),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          const Text('Choose emoji', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kCategoryEmojis.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final emoji = kCategoryEmojis[i];
                final selected = _emoji == emoji;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _emoji = emoji);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? selectedColor.withOpacity(0.2)
                          : (isDark ? AppColors.darkCard : AppColors.lightBg),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? selectedColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text('Choose color', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kCategoryColors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final hex = kCategoryColors[i];
                final color = categoryHexColor(hex);
                final selected = _colorHex == hex;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _colorHex = hex);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                          : null,
                    ),
                    child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

Future<String?> showAddCategorySheet(BuildContext context, {bool isIncome = false}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddCategorySheet(isIncome: isIncome),
  );
}
