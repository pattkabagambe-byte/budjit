import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final _tabProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_balance_wallet_outlined),
      selectedIcon: Icon(Icons.account_balance_wallet_rounded),
      label: 'Budget',
    ),
    NavigationDestination(
      icon: Icon(Icons.savings_outlined),
      selectedIcon: Icon(Icons.savings_rounded),
      label: 'Goals',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart_rounded),
      label: 'Analytics',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  static const _screens = [
    DashboardScreen(),
    BudgetsScreen(),
    GoalsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(_tabProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: IndexedStack(index: tab, children: _screens),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) {
            HapticFeedback.selectionClick();
            ref.read(_tabProvider.notifier).state = i;
          },
          destinations: _destinations,
          animationDuration: const Duration(milliseconds: 300),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
      ),
    );
  }
}

// Expose tab controller so child screens can navigate tabs
void navigateToTab(WidgetRef ref, int tab) {
  ref.read(_tabProvider.notifier).state = tab;
}
