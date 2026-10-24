/**
 * Donation providers - Tip jar via in-app purchases.
 *
 * Provides state management for the donation/tip jar feature via
 * [DonationNotifier]. All donations are consumable products (can be
 * purchased multiple times) using the `in_app_purchase` package directly
 * (not RevenueCat). Four tiers: Tea, Cushion, Incense, and Retreat.
 *
 * [DonationState] tracks product availability, loading state, and
 * purchase results. [DonationService] handles platform IAP communication.
 */
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../services/donation_service.dart';
import '../services/tip_purchase_listener.dart';

export '../services/tip_purchase_listener.dart' show DonationResult, TipPurchaseOutcome, TipPurchaseListener;

/**
 * Immutable state for the donation/tip jar feature.
 *
 * Tracks IAP availability, loading state during product fetch or purchase,
 * available [ProductDetails] sorted by price, and the result of the last
 * purchase attempt for UI feedback (success toast, cancellation, or error).
 */
class DonationState {
  /** Whether in-app purchases are available on this device */
  final bool isAvailable;

  /** Whether we're loading products or processing a purchase */
  final bool isLoading;

  /** Available donation products (sorted by price) */
  final List<ProductDetails> products;

  /** Error message if something went wrong */
  final String? error;

  /** Result of the last purchase attempt (null if no attempt yet) */
  final DonationResult? lastResult;

  /** Store message for a failed purchase, shown with [DonationResult.error]. */
  final String? resultMessage;

  const DonationState({this.isAvailable = false, this.isLoading = true, this.products = const [], this.error, this.lastResult, this.resultMessage});

  /**
   * Creates a copy with selectively overridden fields.
   *
   * Use [clearError] to explicitly set [error] to `null`, and [clearResult]
   * to reset [lastResult] to `null` (since passing `null` preserves the current value).
   */
  DonationState copyWith({
    bool? isAvailable,
    bool? isLoading,
    List<ProductDetails>? products,
    String? error,
    DonationResult? lastResult,
    String? resultMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return DonationState(
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: clearError ? null : (error ?? this.error),
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      resultMessage: clearResult ? null : (resultMessage ?? this.resultMessage),
    );
  }
}

/** Provider for the donation service */
final donationServiceProvider = Provider<DonationService>((ref) {
  final service = DonationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/**
 * App-lifetime purchase listener.
 *
 * Read once at app start by `AppInitializer.initialize`, so interrupted,
 * Ask to Buy and Play pending tips are finished with the store even when the
 * tip jar is never opened. Reading it also recovers purchases an earlier run
 * left unfinished.
 */
final tipPurchaseListenerProvider = Provider<TipPurchaseListener>((ref) {
  final listener = TipPurchaseListener(ref.watch(donationServiceProvider));
  ref.onDispose(listener.dispose);
  listener.start(recoverUnfinished: true);
  return listener;
});

/** Provider for donation state and actions */
final donationProvider = StateNotifierProvider<DonationNotifier, DonationState>((ref) {
  final service = ref.watch(donationServiceProvider);
  return DonationNotifier(service, ref.watch(tipPurchaseListenerProvider));
});

/**
 * Manages [DonationState] for the tip jar UI.
 *
 * Loads products through [DonationService] and turns [TipPurchaseListener]
 * outcomes into UI state. It never finishes purchases itself; the
 * app-lifetime listener does that. Every path, including a purchase the
 * store refuses to start, ends with `isLoading == false`.
 */
class DonationNotifier extends StateNotifier<DonationState> {
  final DonationService _service;
  final TipPurchaseListener _listener;
  final bool _ownsListener;
  StreamSubscription<TipPurchaseOutcome>? _outcomeSubscription;

  /**
   * Without [listener] the notifier starts and owns a private one, which
   * keeps standalone use (tests, previews) finishing purchases too.
   */
  DonationNotifier(this._service, [TipPurchaseListener? listener])
    : _listener = listener ?? TipPurchaseListener(_service),
      _ownsListener = listener == null,
      super(const DonationState()) {
    _outcomeSubscription = _listener.outcomes.listen(_applyOutcome);
    _listener.start();
    initialize();
  }

  /**
   * Initialize the donation system
   *
   * Checks availability and loads products.
   */
  Future<void> initialize() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final available = await _service.isAvailable();

      if (!mounted) return;

      if (!available) {
        state = state.copyWith(isAvailable: false, isLoading: false, products: []);
        return;
      }

      final products = await _service.loadProducts();

      if (!mounted) return;

      state = state.copyWith(isAvailable: true, isLoading: false, products: products);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isAvailable: false, isLoading: false, error: 'Failed to load donation options: $e');
    }
  }

  /** Purchase a tip/donation */
  Future<void> purchaseTip(ProductDetails product) async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, clearError: true, clearResult: true);

    bool started;
    try {
      started = await _service.purchaseProduct(product);
    } catch (e) {
      started = false;
    }
    if (!mounted || started) return; // The outcome arrives through the listener.
    state = state.copyWith(isLoading: false, lastResult: DonationResult.error, resultMessage: 'The store could not start this purchase.');
  }

  /** Clear the last purchase result */
  void clearResult() {
    if (!mounted) return;
    state = state.copyWith(clearResult: true);
  }

  /** Clear any error state */
  void clearError() {
    if (!mounted) return;
    state = state.copyWith(clearError: true);
  }

  void _applyOutcome(TipPurchaseOutcome outcome) {
    if (!mounted) return;
    state = state.copyWith(isLoading: false, clearResult: true).copyWith(lastResult: outcome.result, resultMessage: outcome.message);
  }

  @override
  void dispose() {
    _outcomeSubscription?.cancel();
    if (_ownsListener) _listener.dispose();
    super.dispose();
  }
}
