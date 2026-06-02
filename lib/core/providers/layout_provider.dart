import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/layout_mode.dart';

const _kLayoutKey = 'layout_mode_v1';

class LayoutModeNotifier extends StateNotifier<LayoutMode> {
  LayoutModeNotifier() : super(LayoutMode.defaultMode) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLayoutKey);
    if (saved == LayoutMode.tabbedMode.name) {
      state = LayoutMode.tabbedMode;
    }
  }

  Future<void> setMode(LayoutMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLayoutKey, mode.name);
  }

  void toggle() => setMode(
        state == LayoutMode.defaultMode ? LayoutMode.tabbedMode : LayoutMode.defaultMode,
      );
}

final layoutModeProvider =
    StateNotifierProvider<LayoutModeNotifier, LayoutMode>(
  (ref) => LayoutModeNotifier(),
);
