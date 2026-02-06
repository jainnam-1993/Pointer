/// Subscription providers - All features free (no IAP)
///
/// Simplified from RevenueCat-based subscription system.
/// Retained for API compatibility with widget service and other consumers.
///
/// To restore IAP functionality: git checkout v1.0-with-auth
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import 'core_providers.dart';

// ============================================================
// Subscription State (Always Premium)
// ============================================================

/// Subscription tier enum (kept for API compatibility)
enum SubscriptionTier { free, premium }

/// Subscription state (always premium)
class SubscriptionState {
  final SubscriptionTier tier;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.tier = SubscriptionTier.premium,
    this.isLoading = false,
    this.error,
  });

  bool get isPremium => true; // Always premium

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Subscription provider (always premium)
final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SubscriptionNotifier(storage);
});

/// Subscription notifier (stub - all features free)
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(StorageService storage)
      : super(const SubscriptionState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (mounted) {
      state = state.copyWith(tier: SubscriptionTier.premium, isLoading: false);
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}
