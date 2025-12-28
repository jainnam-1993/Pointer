import 'package:shared_preferences/shared_preferences.dart';

/// Daily usage tracking model
class DailyUsage {
  final int viewCount;
  final String lastResetDate;
  static const int freeUserLimit = 2;

  const DailyUsage({
    this.viewCount = 0,
    required this.lastResetDate,
  });

  bool get limitReached => viewCount >= freeUserLimit;
  int get remaining => freeUserLimit - viewCount;

  DailyUsage copyWith({int? viewCount, String? lastResetDate}) {
    return DailyUsage(
      viewCount: viewCount ?? this.viewCount,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'viewCount': viewCount,
        'lastResetDate': lastResetDate,
      };

  factory DailyUsage.fromJson(Map<String, dynamic> json) {
    return DailyUsage(
      viewCount: json['viewCount'] ?? 0,
      lastResetDate: json['lastResetDate'] ?? _todayString(),
    );
  }

  factory DailyUsage.initial() {
    return DailyUsage(viewCount: 0, lastResetDate: _todayString());
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

/// Service for tracking daily pointing usage for freemium model
class UsageTrackingService {
  final SharedPreferences _prefs;
  static const _usageKey = 'pointer_daily_usage';

  UsageTrackingService(this._prefs);

  /// Get current daily usage, resetting if new day
  DailyUsage getUsage() {
    final json = _prefs.getString(_usageKey);
    if (json == null) {
      return DailyUsage.initial();
    }

    try {
      final usage = DailyUsage.fromJson(
        Map<String, dynamic>.from(
          Uri.splitQueryString(json).map((k, v) => MapEntry(k, _parseValue(v))),
        ),
      );

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

  /// Increment view count
  Future<DailyUsage> incrementViewCount() async {
    final current = getUsage();
    final updated = current.copyWith(viewCount: current.viewCount + 1);
    await _saveUsage(updated);
    return updated;
  }

  /// Reset usage (for testing or premium restore)
  Future<void> resetUsage() async {
    await _saveUsage(DailyUsage.initial());
  }

  Future<void> _saveUsage(DailyUsage usage) async {
    final encoded =
        'viewCount=${usage.viewCount}&lastResetDate=${usage.lastResetDate}';
    await _prefs.setString(_usageKey, encoded);
  }

  dynamic _parseValue(String value) {
    final intVal = int.tryParse(value);
    if (intVal != null) return intVal;
    return value;
  }
}
