// Time-of-Day Aware Pointing Selection Service
//
// Provides contextually appropriate pointing selection based on time of day.
// Time boundaries:
// - Morning: 5am - 11am (awakening, presence themes)
// - Midday: 11am - 5pm (action, engagement themes)
// - Evening: 5pm - 10pm (reflection, release themes)
// - Night: 10pm - 5am (rest, surrender themes)

import 'dart:math';
import '../data/pointings.dart';

/// Time context for pointing selection based on clock time.
/// Separate from PointingContext to allow mapping flexibility.
enum TimeContext {
  morning, // 5am - 11am
  midday, // 11am - 5pm
  evening, // 5pm - 10pm
  night, // 10pm - 5am
  general, // Any time (override mode)
}

/// Returns the TimeContext for the current time.
TimeContext getCurrentTimeContext() {
  return getTimeContextForHour(DateTime.now().hour);
}

/// Returns the TimeContext for a given hour (0-23).
/// Exposed for testing.
TimeContext getTimeContextForHour(int hour) {
  if (hour >= 5 && hour < 11) return TimeContext.morning;
  if (hour >= 11 && hour < 17) return TimeContext.midday;
  if (hour >= 17 && hour < 22) return TimeContext.evening;
  return TimeContext.night; // 22-4 (10pm - 5am)
}

/// Maps a TimeContext to the corresponding PointingContext values.
/// Returns a list since night falls back to evening themes.
List<PointingContext> timeContextToPointingContexts(TimeContext timeContext) {
  switch (timeContext) {
    case TimeContext.morning:
      return [PointingContext.morning, PointingContext.general];
    case TimeContext.midday:
      return [PointingContext.midday, PointingContext.general];
    case TimeContext.evening:
      return [PointingContext.evening, PointingContext.general];
    case TimeContext.night:
      // Night uses evening contexts as fallback (rest/surrender themes)
      return [PointingContext.evening, PointingContext.general];
    case TimeContext.general:
      // Return all contexts when in override mode
      return PointingContext.values.toList();
  }
}

/// Service for selecting pointings with time-of-day awareness.
class PointingSelector {
  final Random _random;

  PointingSelector({Random? random}) : _random = random ?? Random();

  /// Selects a pointing with optional time context awareness.
  ///
  /// Parameters:
  /// - [all]: List of all available pointings
  /// - [viewedToday]: Set of pointing IDs already viewed today
  /// - [respectTimeContext]: If true (default), prefers contextually appropriate pointings
  ///
  /// Returns a pointing that:
  /// 1. Has not been viewed today (if possible)
  /// 2. Matches the current time context (if respectTimeContext is true)
  Pointing selectPointing({
    required List<Pointing> all,
    required Set<String> viewedToday,
    bool respectTimeContext = true,
  }) {
    if (respectTimeContext) {
      return selectPointingForTime(
        all: all,
        viewedToday: viewedToday,
        timeContext: getCurrentTimeContext(),
      );
    }

    // No time context - simple random selection excluding viewed
    return _selectFromCandidates(all, viewedToday);
  }

  /// Selects a pointing for a specific time context.
  ///
  /// Selection algorithm:
  /// 1. Filter out already viewed pointings
  /// 2. Filter to matching time contexts
  /// 3. 30% chance to prefer time-specific pointings over general
  /// 4. If no matches, fall back to any unviewed pointing
  /// 5. If all viewed, reset and select from all
  Pointing selectPointingForTime({
    required List<Pointing> all,
    required Set<String> viewedToday,
    required TimeContext timeContext,
  }) {
    // Get valid PointingContext values for this TimeContext
    final validContexts = timeContextToPointingContexts(timeContext);

    // Filter out viewed pointings
    var candidates = all.where((p) => !viewedToday.contains(p.id)).toList();

    // If all viewed, reset to all pointings
    if (candidates.isEmpty) {
      candidates = all.toList();
    }

    // Filter to matching contexts
    final contextual = candidates.where((p) {
      return p.contexts.any((c) => validContexts.contains(c));
    }).toList();

    // If no contextual matches, return any candidate
    if (contextual.isEmpty) {
      return candidates[_random.nextInt(candidates.length)];
    }

    // Prefer time-specific pointings (30% chance) over general
    // This gives variety while respecting context
    if (timeContext != TimeContext.general) {
      final primaryContext = _getPrimaryPointingContext(timeContext);
      final timeSpecific = contextual.where((p) {
        return p.contexts.contains(primaryContext);
      }).toList();

      if (timeSpecific.isNotEmpty && _random.nextDouble() < 0.3) {
        return timeSpecific[_random.nextInt(timeSpecific.length)];
      }
    }

    return contextual[_random.nextInt(contextual.length)];
  }

  /// Gets the primary PointingContext for a TimeContext.
  PointingContext _getPrimaryPointingContext(TimeContext timeContext) {
    switch (timeContext) {
      case TimeContext.morning:
        return PointingContext.morning;
      case TimeContext.midday:
        return PointingContext.midday;
      case TimeContext.evening:
      case TimeContext.night:
        return PointingContext.evening;
      case TimeContext.general:
        return PointingContext.general;
    }
  }

  /// Simple selection from candidates, excluding viewed pointings.
  Pointing _selectFromCandidates(List<Pointing> all, Set<String> viewedToday) {
    var candidates = all.where((p) => !viewedToday.contains(p.id)).toList();

    // If all viewed, reset to all pointings
    if (candidates.isEmpty) {
      candidates = all.toList();
    }

    return candidates[_random.nextInt(candidates.length)];
  }
}
