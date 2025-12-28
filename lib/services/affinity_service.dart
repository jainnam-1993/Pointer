import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/pointings.dart';

/// Service for learning user tradition affinity based on interactions.
///
/// Tracks:
/// - View counts per tradition
/// - Save counts per tradition
/// - Time spent per tradition
/// - Calculated affinity scores
class AffinityService {
  final SharedPreferences _prefs;

  static const _viewCountsKey = 'affinity_view_counts';
  static const _saveCountsKey = 'affinity_save_counts';
  static const _lastUpdatedKey = 'affinity_last_updated';

  AffinityService(this._prefs);

  /// Record that user viewed a pointing from this tradition
  Future<void> recordView(Tradition tradition) async {
    final counts = _getViewCounts();
    counts[tradition.name] = (counts[tradition.name] ?? 0) + 1;
    await _prefs.setString(_viewCountsKey, jsonEncode(counts));
    await _prefs.setString(_lastUpdatedKey, DateTime.now().toIso8601String());
  }

  /// Record that user saved/favorited a pointing from this tradition
  Future<void> recordSave(Tradition tradition) async {
    final counts = _getSaveCounts();
    counts[tradition.name] = (counts[tradition.name] ?? 0) + 1;
    await _prefs.setString(_saveCountsKey, jsonEncode(counts));
  }

  /// Get view counts for all traditions
  Map<String, int> _getViewCounts() {
    final stored = _prefs.getString(_viewCountsKey);
    if (stored == null) return {};
    return Map<String, int>.from(jsonDecode(stored));
  }

  /// Get save counts for all traditions
  Map<String, int> _getSaveCounts() {
    final stored = _prefs.getString(_saveCountsKey);
    if (stored == null) return {};
    return Map<String, int>.from(jsonDecode(stored));
  }

  /// Calculate affinity score for a tradition (0.0 - 1.0)
  /// Weights: views = 1x, saves = 3x (saves indicate stronger preference)
  double getAffinityScore(Tradition tradition) {
    final viewCounts = _getViewCounts();
    final saveCounts = _getSaveCounts();

    final views = viewCounts[tradition.name] ?? 0;
    final saves = saveCounts[tradition.name] ?? 0;

    // Weighted score: views + saves*3
    final score = views + (saves * 3);

    // Normalize against total interactions
    final totalViews = viewCounts.values.fold(0, (a, b) => a + b);
    final totalSaves = saveCounts.values.fold(0, (a, b) => a + b);
    final totalScore = totalViews + (totalSaves * 3);

    if (totalScore == 0) return 0.2; // Default equal affinity
    return score / totalScore;
  }

  /// Get all tradition affinity scores sorted by preference
  List<TraditionAffinity> getAllAffinities() {
    final affinities = <TraditionAffinity>[];

    for (final tradition in Tradition.values) {
      affinities.add(TraditionAffinity(
        tradition: tradition,
        score: getAffinityScore(tradition),
        viewCount: _getViewCounts()[tradition.name] ?? 0,
        saveCount: _getSaveCounts()[tradition.name] ?? 0,
      ));
    }

    // Sort by score descending
    affinities.sort((a, b) => b.score.compareTo(a.score));
    return affinities;
  }

  /// Get user's top preferred tradition (or null if no data)
  Tradition? getTopTradition() {
    final affinities = getAllAffinities();
    if (affinities.isEmpty) return null;

    final top = affinities.first;
    // Only return if there's meaningful data
    if (top.viewCount == 0 && top.saveCount == 0) return null;
    return top.tradition;
  }

  /// Get traditions ordered by user preference for smarter selection
  List<Tradition> getTraditionsByPreference() {
    return getAllAffinities().map((a) => a.tradition).toList();
  }

  /// Reset all affinity data
  Future<void> reset() async {
    await _prefs.remove(_viewCountsKey);
    await _prefs.remove(_saveCountsKey);
    await _prefs.remove(_lastUpdatedKey);
  }
}

/// Affinity data for a single tradition
class TraditionAffinity {
  final Tradition tradition;
  final double score;
  final int viewCount;
  final int saveCount;

  const TraditionAffinity({
    required this.tradition,
    required this.score,
    required this.viewCount,
    required this.saveCount,
  });

  /// Human-readable preference level
  String get preferenceLevel {
    if (score >= 0.4) return 'High';
    if (score >= 0.25) return 'Medium';
    if (score >= 0.15) return 'Low';
    return 'Minimal';
  }
}
