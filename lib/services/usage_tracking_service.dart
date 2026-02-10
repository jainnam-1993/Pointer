import 'package:shared_preferences/shared_preferences.dart';

/**
 * Immutable snapshot of the user's daily pointing view count.
 *
 * Resets automatically at midnight (based on [lastResetDate]).
 * Used for analytics tracking of daily engagement.
 */
class DailyUsage {
  /** Number of pointings viewed today. */
  final int viewCount;

  /** ISO date string (`YYYY-MM-DD`) of the last reset, used to detect day rollover. */
  final String lastResetDate;

  const DailyUsage({this.viewCount = 0, required this.lastResetDate});

  DailyUsage copyWith({int? viewCount, String? lastResetDate}) {
    return DailyUsage(viewCount: viewCount ?? this.viewCount, lastResetDate: lastResetDate ?? this.lastResetDate);
  }

  Map<String, dynamic> toJson() => {'viewCount': viewCount, 'lastResetDate': lastResetDate};

  factory DailyUsage.fromJson(Map<String, dynamic> json) {
    return DailyUsage(viewCount: json['viewCount'] ?? 0, lastResetDate: json['lastResetDate'] ?? _todayString());
  }

  factory DailyUsage.initial() {
    return DailyUsage(viewCount: 0, lastResetDate: _todayString());
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

/**
 * Service for tracking daily pointing view counts for analytics.
 *
 * Persists [DailyUsage] to [SharedPreferences] and auto-resets when a new
 * calendar day is detected.
 */
class UsageTrackingService {
  final SharedPreferences _prefs;
  static const _usageKey = 'pointer_daily_usage';

  UsageTrackingService(this._prefs);

  /** Get current daily usage, resetting if new day */
  DailyUsage getUsage() {
    final json = _prefs.getString(_usageKey);
    if (json == null) {
      return DailyUsage.initial();
    }

    try {
      final usage = DailyUsage.fromJson(Map<String, dynamic>.from(Uri.splitQueryString(json).map((k, v) => MapEntry(k, _parseValue(v)))));

      // Check if we need to reset for a new day
      final today = DailyUsage._todayString();
      if (usage.lastResetDate != today) {
        final reset = DailyUsage.initial();
        _saveUsage(reset);
        return reset;
      }

      return usage;
    } catch (_) {
      return DailyUsage.initial();
    }
  }

  /** Increment today's view count by one and return the updated [DailyUsage]. */
  Future<DailyUsage> incrementViewCount() async {
    final current = getUsage();
    final updated = current.copyWith(viewCount: current.viewCount + 1);
    await _saveUsage(updated);
    return updated;
  }

  /** Reset usage counters to zero. Used for testing. */
  Future<void> resetUsage() async {
    await _saveUsage(DailyUsage.initial());
  }

  Future<void> _saveUsage(DailyUsage usage) async {
    final encoded = 'viewCount=${usage.viewCount}&lastResetDate=${usage.lastResetDate}';
    await _prefs.setString(_usageKey, encoded);
  }

  dynamic _parseValue(String value) {
    final intVal = int.tryParse(value);
    if (intVal != null) return intVal;
    return value;
  }
}
