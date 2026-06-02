import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';
import '../models/layout_mode.dart';

class UserProfileMetadata {
  final String userId;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final DateTime updatedAt;

  const UserProfileMetadata({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.updatedAt,
  });

  String get initials {
    final words = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toCloudJson() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory UserProfileMetadata.fromJson(Map<String, dynamic> json) {
    return UserProfileMetadata(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String? ?? 'User',
      email: json['email'] as String?,
      photoUrl: json['photoUrl'] as String?,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class UserProfileService {
  UserProfileService({
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static final instance = UserProfileService();

  final Future<SharedPreferences> Function() _preferencesLoader;
  final Set<String> _capturedProfiles = {};

  String _profileKey(String userId) => 'profile_metadata_$userId';

  Future<UserProfileMetadata?> captureAndSync(
    User user, {
    String? displayName,
    String? email,
    String? photoUrl,
  }) async {
    if (user.isAnonymous) return null;
    final signature = [
      user.uid,
      displayName ?? user.displayName,
      email ?? user.email,
      photoUrl ?? user.photoURL,
    ].join('|');
    if (_capturedProfiles.contains(signature)) {
      return loadCached(user.uid);
    }
    _capturedProfiles.add(signature);
    final metadata = UserProfileMetadata(
      userId: user.uid,
      displayName: displayName ?? user.displayName ?? 'User',
      email: email ?? user.email,
      photoUrl: photoUrl ?? user.photoURL,
      updatedAt: DateTime.now(),
    );
    final prefs = await _preferencesLoader();
    await prefs.setString(_profileKey(user.uid), jsonEncode(metadata.toJson()));
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'profile': metadata.toCloudJson()},
        SetOptions(merge: true),
      );
    } catch (_) {
      await prefs.setBool('profile_sync_pending_${user.uid}', true);
    }
    return metadata;
  }

  Future<UserProfileMetadata?> loadCached(String userId) async {
    final prefs = await _preferencesLoader();
    final raw = prefs.getString(_profileKey(userId));
    if (raw == null) return null;
    try {
      return UserProfileMetadata.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> syncPreferredViewMode(LayoutMode mode) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) return;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'preferences': {'plannerViewMode': mode.name},
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // The local preference remains authoritative while offline.
    }
  }

  Future<LayoutMode?> loadPreferredViewMode(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final preferences =
          snapshot.data()?['preferences'] as Map<String, dynamic>?;
      final saved = preferences?['plannerViewMode'] as String?;
      if (saved == LayoutMode.tabbedMode.name) return LayoutMode.tabbedMode;
      if (saved == LayoutMode.defaultMode.name) return LayoutMode.defaultMode;
    } catch (_) {
      // Local preference is used when cloud profile data is unavailable.
    }
    return null;
  }

  Future<void> syncAppPreferences(AppPreferences preferences) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) return;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'appPreferences': preferences.toJson(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Settings are already persisted locally and can sync next time.
    }
  }
}
