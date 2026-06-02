import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const _openCountKey = 'review_open_count_v2';
  static const _lastPromptKey = 'review_last_prompt_unix_v2';

  /// Opens before the first rating dialog.
  static const _minOpens = 5;

  /// Minimum days between rating prompts.
  static const _minDaysBetweenPrompts = 21;

  static ReviewService? _instance;
  static ReviewService get instance => _instance ??= ReviewService._();
  ReviewService._();

  final _review = InAppReview.instance;

  /// Increments session count — call when the main app UI is shown.
  Future<void> recordSessionOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_openCountKey) ?? 0) + 1;
    await prefs.setInt(_openCountKey, count);
  }

  /// Shows a friendly dialog, then the store review flow when eligible.
  Future<void> maybeShowRatingPrompt(BuildContext context) async {
    if (!await _isEligibleForPrompt()) return;
    if (!context.mounted) return;

    final rate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enjoying Cashflo?'),
        content: const Text(
          'If Cashflo is helping you stay on track, a quick rating '
          'helps others discover the app. Thank you!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rate Cashflo'),
          ),
        ],
      ),
    );

    await _markPromptShown();

    if (rate == true) {
      await requestReview();
    }
  }

  /// Settings → Rate Cashflo (always available).
  Future<void> requestReviewFromSettings(BuildContext context) async {
    final rate = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rate Cashflo'),
        content: const Text(
          'Your feedback on the App Store or Google Play means a lot to us.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (rate == true) {
      await requestReview();
    }
  }

  Future<void> requestReview() async {
    if (await _review.isAvailable()) {
      await _review.requestReview();
      return;
    }
    await _review.openStoreListing();
  }

  Future<bool> _isEligibleForPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_openCountKey) ?? 0;
    if (count < _minOpens) return false;
    return _cooldownElapsed(prefs);
  }

  Future<void> _markPromptShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastPromptKey,
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  Future<bool> _cooldownElapsed(SharedPreferences prefs) async {
    final lastShown = prefs.getInt(_lastPromptKey);
    if (lastShown == null) return true;
    final daysSince = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastShown * 1000))
        .inDays;
    return daysSince >= _minDaysBetweenPrompts;
  }

}
