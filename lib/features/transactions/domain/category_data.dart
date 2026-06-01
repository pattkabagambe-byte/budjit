import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TxCategory {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  final bool isIncome;

  const TxCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
    this.isIncome = false,
  });
}

const kExpenseCategories = [
  TxCategory(id: 'food', label: 'Food & Dining', emoji: '🍽️', color: AppColors.catFood),
  TxCategory(id: 'groceries', label: 'Groceries', emoji: '🛒', color: AppColors.catGroceries),
  TxCategory(id: 'transport', label: 'Transport', emoji: '🚗', color: AppColors.catTransport),
  TxCategory(id: 'housing', label: 'Housing / Rent', emoji: '🏠', color: AppColors.catHousing),
  TxCategory(id: 'utilitybills', label: 'Utility Bills', emoji: '💡', color: AppColors.catUtilities),
  TxCategory(id: 'healthcare', label: 'Healthcare', emoji: '🏥', color: AppColors.catHealth),
  TxCategory(id: 'education', label: 'Education', emoji: '📚', color: AppColors.catEducation),
  TxCategory(id: 'schoolfees', label: 'School Fees', emoji: '🎓', color: AppColors.catSchoolFees),
  TxCategory(id: 'entertainment', label: 'Entertainment', emoji: '🎬', color: AppColors.catEntertainment),
  TxCategory(id: 'shopping', label: 'Shopping', emoji: '🛍️', color: AppColors.catShopping),
  TxCategory(id: 'personalcare', label: 'Personal Care', emoji: '💆', color: AppColors.catPersonalCare),
  TxCategory(id: 'subscriptions', label: 'Subscriptions', emoji: '📱', color: AppColors.catSubscriptions),
  TxCategory(id: 'airtime', label: 'Airtime & Data', emoji: '📞', color: AppColors.catAirtime),
  TxCategory(id: 'fuel', label: 'Fuel', emoji: '⛽', color: AppColors.catFuel),
  TxCategory(id: 'childcare', label: 'Childcare', emoji: '👶', color: AppColors.catPersonalCare),
  TxCategory(id: 'debt', label: 'Debt Repayment', emoji: '💳', color: AppColors.catDebt),
  TxCategory(id: 'savings', label: 'Savings', emoji: '🐷', color: AppColors.catSavings),
  TxCategory(id: 'miscellaneous', label: 'Miscellaneous', emoji: '📦', color: AppColors.catMisc),
];

const kIncomeCategories = [
  TxCategory(id: 'salary', label: 'Salary', emoji: '💼', color: AppColors.catSavings, isIncome: true),
  TxCategory(id: 'business', label: 'Business', emoji: '🏢', color: AppColors.sky, isIncome: true),
  TxCategory(id: 'freelance', label: 'Freelance', emoji: '💻', color: AppColors.violet, isIncome: true),
  TxCategory(id: 'sidehustle', label: 'Side Hustle', emoji: '⚡', color: AppColors.amber, isIncome: true),
  TxCategory(id: 'rentals', label: 'Rentals', emoji: '🏘️', color: AppColors.teal, isIncome: true),
  TxCategory(id: 'investments', label: 'Investments', emoji: '📈', color: AppColors.emeraldLight, isIncome: true),
  TxCategory(id: 'mobilemoney', label: 'Mobile Money', emoji: '📲', color: AppColors.catAirtime, isIncome: true),
  TxCategory(id: 'gift', label: 'Gift / Transfer', emoji: '🎁', color: AppColors.pink, isIncome: true),
  TxCategory(id: 'otherincome', label: 'Other Income', emoji: '💰', color: AppColors.catSavings, isIncome: true),
];

TxCategory? categoryById(String id, {bool isIncome = false}) {
  final list = isIncome ? kIncomeCategories : kExpenseCategories;
  try {
    return list.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

TxCategory categoryByIdOrDefault(String id, {bool isIncome = false}) {
  return categoryById(id, isIncome: isIncome) ??
      (isIncome ? kIncomeCategories.last : kExpenseCategories.last);
}
