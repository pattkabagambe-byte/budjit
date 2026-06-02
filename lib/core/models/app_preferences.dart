enum AppThemePreference { system, light, dark }

enum PlannerReportPeriod { weekly, monthly, quarterly, annual }

enum WeekStart { monday, sunday, saturday }

enum BudgetStyle { category, flexible }

extension AppThemePreferenceX on AppThemePreference {
  String get label => switch (this) {
        AppThemePreference.system => 'System',
        AppThemePreference.light => 'Light',
        AppThemePreference.dark => 'Dark',
      };
}

extension PlannerReportPeriodX on PlannerReportPeriod {
  String get label => switch (this) {
        PlannerReportPeriod.weekly => 'Weekly',
        PlannerReportPeriod.monthly => 'Monthly',
        PlannerReportPeriod.quarterly => 'Quarterly',
        PlannerReportPeriod.annual => 'Annual',
      };
}

extension WeekStartX on WeekStart {
  String get label => switch (this) {
        WeekStart.monday => 'Monday',
        WeekStart.sunday => 'Sunday',
        WeekStart.saturday => 'Saturday',
      };
}

extension BudgetStyleX on BudgetStyle {
  String get label => switch (this) {
        BudgetStyle.category => 'Category budgets',
        BudgetStyle.flexible => 'Flexible monthly plan',
      };
}

class AppPreferences {
  final AppThemePreference theme;
  final PlannerReportPeriod reportPeriod;
  final WeekStart weekStart;
  final BudgetStyle budgetStyle;
  final bool showDecimals;
  final bool confirmBeforeDelete;
  final bool hapticFeedback;
  final bool notifications;
  final bool compactMode;

  const AppPreferences({
    this.theme = AppThemePreference.system,
    this.reportPeriod = PlannerReportPeriod.monthly,
    this.weekStart = WeekStart.monday,
    this.budgetStyle = BudgetStyle.category,
    this.showDecimals = false,
    this.confirmBeforeDelete = true,
    this.hapticFeedback = true,
    this.notifications = true,
    this.compactMode = false,
  });

  AppPreferences copyWith({
    AppThemePreference? theme,
    PlannerReportPeriod? reportPeriod,
    WeekStart? weekStart,
    BudgetStyle? budgetStyle,
    bool? showDecimals,
    bool? confirmBeforeDelete,
    bool? hapticFeedback,
    bool? notifications,
    bool? compactMode,
  }) {
    return AppPreferences(
      theme: theme ?? this.theme,
      reportPeriod: reportPeriod ?? this.reportPeriod,
      weekStart: weekStart ?? this.weekStart,
      budgetStyle: budgetStyle ?? this.budgetStyle,
      showDecimals: showDecimals ?? this.showDecimals,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      notifications: notifications ?? this.notifications,
      compactMode: compactMode ?? this.compactMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'reportPeriod': reportPeriod.name,
        'weekStart': weekStart.name,
        'budgetStyle': budgetStyle.name,
        'showDecimals': showDecimals,
        'confirmBeforeDelete': confirmBeforeDelete,
        'hapticFeedback': hapticFeedback,
        'notifications': notifications,
        'compactMode': compactMode,
      };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    T parse<T extends Enum>(List<T> values, String? name, T fallback) {
      for (final value in values) {
        if (value.name == name) return value;
      }
      return fallback;
    }

    return AppPreferences(
      theme: parse(
        AppThemePreference.values,
        json['theme'] as String?,
        AppThemePreference.system,
      ),
      reportPeriod: parse(
        PlannerReportPeriod.values,
        json['reportPeriod'] as String?,
        PlannerReportPeriod.monthly,
      ),
      weekStart: parse(
        WeekStart.values,
        json['weekStart'] as String?,
        WeekStart.monday,
      ),
      budgetStyle: parse(
        BudgetStyle.values,
        json['budgetStyle'] as String?,
        BudgetStyle.category,
      ),
      showDecimals: json['showDecimals'] as bool? ?? false,
      confirmBeforeDelete: json['confirmBeforeDelete'] as bool? ?? true,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      notifications: json['notifications'] as bool? ?? true,
      compactMode: json['compactMode'] as bool? ?? false,
    );
  }
}
