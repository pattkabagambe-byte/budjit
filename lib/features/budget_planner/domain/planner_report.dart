import '../../../core/database/app_database.dart';
import '../../../core/models/app_preferences.dart';

class PlannerReportSummary {
  final double income;
  final double actualExpenses;
  final double totalBudgeted;
  final Map<String, double> spendingByCategory;
  final Map<String, double> budgetByCategory;

  const PlannerReportSummary({
    required this.income,
    required this.actualExpenses,
    required this.totalBudgeted,
    required this.spendingByCategory,
    required this.budgetByCategory,
  });

  double get unassignedCash => income - totalBudgeted;
  double get actualLeft => income - actualExpenses;
  double get budgetVsIncomePercent =>
      income > 0 ? totalBudgeted / income * 100 : 0;
  double get budgetUtilizationPercent => totalBudgeted > 0
      ? (actualExpenses / totalBudgeted * 100).clamp(0, 100)
      : 0;
}

class PlannerReportCalculator {
  static PlannerReportSummary calculate({
    required List<TxEntry> transactions,
    required List<Budget> budgets,
  }) {
    final income = transactions
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (total, transaction) => total + transaction.amount);
    final expenses = transactions
        .where((transaction) => !transaction.isIncome)
        .fold(0.0, (total, transaction) => total + transaction.amount);
    final budgeted =
        budgets.fold(0.0, (total, budget) => total + budget.limitAmount);
    final spendingByCategory = <String, double>{};
    final budgetByCategory = <String, double>{};

    for (final transaction in transactions.where((item) => !item.isIncome)) {
      spendingByCategory[transaction.category] =
          (spendingByCategory[transaction.category] ?? 0) + transaction.amount;
    }
    for (final budget in budgets) {
      budgetByCategory[budget.category] =
          (budgetByCategory[budget.category] ?? 0) + budget.limitAmount;
    }

    return PlannerReportSummary(
      income: income,
      actualExpenses: expenses,
      totalBudgeted: budgeted,
      spendingByCategory: spendingByCategory,
      budgetByCategory: budgetByCategory,
    );
  }
}

extension PlannerReportPeriodRange on PlannerReportPeriod {
  (DateTime, DateTime) range({DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    return switch (this) {
      PlannerReportPeriod.weekly => () {
          final monday = today.subtract(Duration(days: today.weekday - 1));
          return (monday, monday.add(const Duration(days: 6)));
        }(),
      PlannerReportPeriod.monthly => (
          DateTime(current.year, current.month),
          DateTime(current.year, current.month + 1, 0),
        ),
      PlannerReportPeriod.quarterly => () {
          final firstMonth = ((current.month - 1) ~/ 3) * 3 + 1;
          return (
            DateTime(current.year, firstMonth),
            DateTime(current.year, firstMonth + 3, 0),
          );
        }(),
      PlannerReportPeriod.annual => (
          DateTime(current.year),
          DateTime(current.year, 12, 31),
        ),
    };
  }
}
