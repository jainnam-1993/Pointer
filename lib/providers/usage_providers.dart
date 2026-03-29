/**
 * Usage tracking providers (analytics only).
 *
 * All features are free. Premium gating has been removed.
 * Daily usage tracking via [DailyUsageNotifier] is retained for analytics.
 */
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/usage_tracking_service.dart';
import 'core_providers.dart';

// ============================================================
// Daily Usage Tracking (Analytics only)
// ============================================================

/** Provider for usage tracking service */
final usageTrackingServiceProvider = Provider<UsageTrackingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UsageTrackingService(prefs);
});

/** Daily usage state provider */
final dailyUsageProvider = StateNotifierProvider<DailyUsageNotifier, DailyUsage>((ref) {
  final service = ref.watch(usageTrackingServiceProvider);
  return DailyUsageNotifier(service);
});

/**
 * Manages [DailyUsage] state for analytics via [UsageTrackingService].
 *
 * Tracks daily pointing views for analytics.
 */
class DailyUsageNotifier extends StateNotifier<DailyUsage> {
  final UsageTrackingService _service;

  DailyUsageNotifier(this._service) : super(_service.getUsage());

  /** Record a pointing view (for analytics) */
  Future<void> recordView() async {
    state = await _service.incrementViewCount();
  }

  /** Reset for testing */
  Future<void> reset() async {
    await _service.resetUsage();
    state = _service.getUsage();
  }
}
