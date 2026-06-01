import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../../features/transactions/domain/category_data.dart';
import 'core_providers.dart';

Color categoryHexColor(String hex) {
  try {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  } catch (_) {
    return const Color(0xFF6366F1);
  }
}

extension CustomCategoryEntryX on CustomCategoryEntry {
  TxCategory toTxCategory() => TxCategory(
        id: id,
        label: label,
        emoji: emoji,
        color: categoryHexColor(colorHex),
        isIncome: isIncome,
      );
}

final customCategoriesStreamProvider =
    StreamProvider.family<List<CustomCategoryEntry>, String>(
  (ref, userId) => ref.watch(databaseProvider).watchCustomCategories(userId),
);

final customTxCategoriesProvider = Provider.family<List<TxCategory>, String>(
  (ref, userId) {
    final custom = ref.watch(customCategoriesStreamProvider(userId)).valueOrNull ?? [];
    return custom.map((c) => c.toTxCategory()).toList();
  },
);

final expenseCategoriesProvider = Provider.family<List<TxCategory>, String>(
  (ref, userId) {
    final custom = ref.watch(customTxCategoriesProvider(userId));
    return allExpenseCategories(custom: custom);
  },
);

final incomeCategoriesProvider = Provider.family<List<TxCategory>, String>(
  (ref, userId) {
    final custom = ref.watch(customTxCategoriesProvider(userId));
    return allIncomeCategories(custom: custom);
  },
);

TxCategory resolveCategory(
  String id, {
  bool isIncome = false,
  List<TxCategory>? custom,
}) =>
    categoryByIdOrDefault(id, isIncome: isIncome, custom: custom);
