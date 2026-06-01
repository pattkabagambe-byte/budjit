enum ExpenseCategory {
  groceries, food, entertainment, personalCare, utilityBills,
  transport, healthcare, education, housing, childcare,
  subscriptions, miscellaneous
}

enum IncomeCategory {
  salary, business, rentals, freelance, sideHustle, investments,
  pensionOrBenefits, otherIncome
}

extension ExpenseCategoryExt on ExpenseCategory {
  String get label => switch (this) {
    ExpenseCategory.groceries => 'Groceries',
    ExpenseCategory.food => 'Food & Dining',
    ExpenseCategory.entertainment => 'Entertainment',
    ExpenseCategory.personalCare => 'Personal Care',
    ExpenseCategory.utilityBills => 'Utility Bills',
    ExpenseCategory.transport => 'Transport',
    ExpenseCategory.healthcare => 'Healthcare',
    ExpenseCategory.education => 'Education',
    ExpenseCategory.housing => 'Housing',
    ExpenseCategory.childcare => 'Childcare',
    ExpenseCategory.subscriptions => 'Subscriptions',
    ExpenseCategory.miscellaneous => 'Miscellaneous',
  };

  String get icon => switch (this) {
    ExpenseCategory.groceries => '🛒',
    ExpenseCategory.food => '🍽️',
    ExpenseCategory.entertainment => '🎬',
    ExpenseCategory.personalCare => '💆',
    ExpenseCategory.utilityBills => '💡',
    ExpenseCategory.transport => '🚗',
    ExpenseCategory.healthcare => '🏥',
    ExpenseCategory.education => '📚',
    ExpenseCategory.housing => '🏠',
    ExpenseCategory.childcare => '👶',
    ExpenseCategory.subscriptions => '📱',
    ExpenseCategory.miscellaneous => '📦',
  };
}

extension IncomeCategoryExt on IncomeCategory {
  String get label => switch (this) {
    IncomeCategory.salary => 'Salary',
    IncomeCategory.business => 'Business',
    IncomeCategory.rentals => 'Rentals',
    IncomeCategory.freelance => 'Freelance',
    IncomeCategory.sideHustle => 'Side Hustle',
    IncomeCategory.investments => 'Investments',
    IncomeCategory.pensionOrBenefits => 'Pension/Benefits',
    IncomeCategory.otherIncome => 'Other Income',
  };
  String get icon => switch (this) {
    IncomeCategory.salary => '💼',
    IncomeCategory.business => '🏢',
    IncomeCategory.rentals => '🏘️',
    IncomeCategory.freelance => '💻',
    IncomeCategory.sideHustle => '⚡',
    IncomeCategory.investments => '📈',
    IncomeCategory.pensionOrBenefits => '🏛️',
    IncomeCategory.otherIncome => '💰',
  };
}

class BudgetEntry {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;
  final String? note;

  const BudgetEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'amount': amount,
    'isIncome': isIncome,
    'category': category,
    'date': date.millisecondsSinceEpoch,
    'note': note,
  };

  factory BudgetEntry.fromJson(Map<String, dynamic> j) => BudgetEntry(
    id: j['id'] as String,
    userId: j['userId'] as String,
    title: j['title'] as String,
    amount: (j['amount'] as num).toDouble(),
    isIncome: j['isIncome'] as bool,
    category: j['category'] as String,
    date: DateTime.fromMillisecondsSinceEpoch(j['date'] as int),
    note: j['note'] as String?,
  );
}

class BudgetSummary {
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomeByCategory;

  const BudgetSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.expensesByCategory,
    required this.incomeByCategory,
  });

  double get balance => totalIncome - totalExpenses;
  double get savingsRate => totalIncome > 0 ? (balance / totalIncome) * 100 : 0;
}
