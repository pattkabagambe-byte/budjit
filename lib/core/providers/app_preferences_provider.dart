import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';
import '../services/user_profile_service.dart';

const appPreferencesKey = 'app_preferences_v1';

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  AppPreferencesNotifier({
    Future<SharedPreferences> Function()? preferencesLoader,
    UserProfileService? profileService,
  })  : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance,
        _profileService = profileService ?? UserProfileService.instance,
        super(const AppPreferences()) {
    _load();
  }

  final Future<SharedPreferences> Function() _preferencesLoader;
  final UserProfileService _profileService;

  Future<void> _load() async {
    final prefs = await _preferencesLoader();
    final raw = prefs.getString(appPreferencesKey);
    if (raw == null) return;
    try {
      state = AppPreferences.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      state = const AppPreferences();
    }
  }

  Future<void> update(AppPreferences preferences) async {
    state = preferences;
    final prefs = await _preferencesLoader();
    await prefs.setString(appPreferencesKey, jsonEncode(preferences.toJson()));
    await _profileService.syncAppPreferences(preferences);
  }
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferences>(
  (ref) => AppPreferencesNotifier(),
);
