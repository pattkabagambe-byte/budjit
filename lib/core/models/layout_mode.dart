enum LayoutMode { defaultMode, tabbedMode }

extension LayoutModeX on LayoutMode {
  String get label => switch (this) {
        LayoutMode.defaultMode => 'Default Mode',
        LayoutMode.tabbedMode => 'Tabbed Mode',
      };

  String get description => switch (this) {
        LayoutMode.defaultMode => 'Dashboard, budgets, goals, and analytics',
        LayoutMode.tabbedMode => 'Focused actual, budget, and reports planner',
      };
}
