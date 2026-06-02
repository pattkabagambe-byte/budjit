import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/layout_mode.dart';
import '../services/user_profile_service.dart';

const layoutModePreferenceKey = 'layout_mode_v2';
const legacyLayoutModePreferenceKey = 'layout_mode_v1';

class LayoutModeState {
  final LayoutMode activeMode;
  final LayoutMode preferredMode;
  final bool loaded;

  const LayoutModeState({
    this.activeMode = LayoutMode.defaultMode,
    this.preferredMode = LayoutMode.defaultMode,
    this.loaded = false,
  });

  LayoutModeState copyWith({
    LayoutMode? activeMode,
    LayoutMode? preferredMode,
    bool? loaded,
  }) {
    return LayoutModeState(
      activeMode: activeMode ?? this.activeMode,
      preferredMode: preferredMode ?? this.preferredMode,
      loaded: loaded ?? this.loaded,
    );
  }
}

class LayoutModeNotifier extends StateNotifier<LayoutModeState> {
  LayoutModeNotifier({
    Future<SharedPreferences> Function()? preferencesLoader,
    UserProfileService? profileService,
  })  : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance,
        _profileService = profileService ?? UserProfileService.instance,
        super(const LayoutModeState()) {
    _loadFuture = _load();
  }

  final Future<SharedPreferences> Function() _preferencesLoader;
  final UserProfileService _profileService;
  late final Future<void> _loadFuture;
  String? _syncedUserId;

  Future<void> _load() async {
    final prefs = await _preferencesLoader();
    final saved = prefs.getString(layoutModePreferenceKey) ??
        prefs.getString(legacyLayoutModePreferenceKey);
    final preferred = _parse(saved);
    if (saved != null && !prefs.containsKey(layoutModePreferenceKey)) {
      await prefs.setString(layoutModePreferenceKey, preferred.name);
    }
    state = LayoutModeState(
      activeMode: preferred,
      preferredMode: preferred,
      loaded: true,
    );
  }

  LayoutMode _parse(String? value) {
    return value == LayoutMode.tabbedMode.name
        ? LayoutMode.tabbedMode
        : LayoutMode.defaultMode;
  }

  Future<void> switchMode(LayoutMode mode) async {
    state = state.copyWith(activeMode: mode);
  }

  Future<void> setPreferredMode(
    LayoutMode mode, {
    bool switchNow = true,
  }) async {
    state = state.copyWith(
      activeMode: switchNow ? mode : state.activeMode,
      preferredMode: mode,
    );
    final prefs = await _preferencesLoader();
    await prefs.setString(layoutModePreferenceKey, mode.name);
    await _profileService.syncPreferredViewMode(mode);
  }

  Future<void> setCurrentModeAsPreferred() =>
      setPreferredMode(state.activeMode, switchNow: false);

  Future<void> syncWithUser(String userId) async {
    await _loadFuture;
    if (_syncedUserId == userId) return;
    _syncedUserId = userId;
    final prefs = await _preferencesLoader();
    final hasLocalPreference = prefs.containsKey(layoutModePreferenceKey);
    if (hasLocalPreference) {
      await _profileService.syncPreferredViewMode(state.preferredMode);
      return;
    }
    final remote = await _profileService.loadPreferredViewMode(userId);
    if (remote == null) return;
    await prefs.setString(layoutModePreferenceKey, remote.name);
    state = state.copyWith(activeMode: remote, preferredMode: remote);
  }
}

final layoutModeProvider =
    StateNotifierProvider<LayoutModeNotifier, LayoutModeState>(
  (ref) => LayoutModeNotifier(),
);
