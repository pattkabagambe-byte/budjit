import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const _openCountKey = 'review_open_count_v1';
  static const _lastShownKey = 'review_last_shown_unix_v1';
  static const _minOpens = 7;
  static const _minDaysBetweenPrompts = 60;

  static ReviewService? _instance;
  static ReviewService get instance => _instance ??= ReviewService._();
  ReviewService._();

  final _review = InAppReview.instance;

  /// Call once from the root screen's initState.
  Future<void> onAppOpened() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_openCountKey) ?? 0) + 1;
    await prefs.setInt(_openCountKey, count);

    if (count < _minOpens) return;
    if (!await _cooldownElapsed(prefs)) return;
    if (!await _review.isAvailable()) return;

    await _review.requestReview();
    await prefs.setInt(
      _lastShownKey,
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }

  Future<bool> _cooldownElapsed(SharedPreferences prefs) async {
    final lastShown = prefs.getInt(_lastShownKey);
    if (lastShown == null) return true;
    final daysSince = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastShown * 1000))
        .inDays;
    return daysSince >= _minDaysBetweenPrompts;
  }
}
