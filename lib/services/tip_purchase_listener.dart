/**
 * App-lifetime listener for tip jar purchase updates.
 *
 * `in_app_purchase` delivers interrupted, Ask to Buy and Play pending
 * purchases on the purchase stream at any time, often right after launch.
 * This listener is started once at app start (see `AppInitializer`), so
 * every update is finished with the store even if Settings is never opened.
 * The tip jar UI subscribes to [outcomes] for feedback only.
 */
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'donation_service.dart';

/** What one purchase update means for the tip jar UI. */
enum DonationResult {
  /** The tip was paid and finished with the store. */
  success,

  /** The store is waiting on approval or payment (Ask to Buy, Play pending). */
  pending,

  /** The user cancelled the purchase sheet. */
  cancelled,

  /** The purchase failed or the store could not be reached. */
  error,
}

/** A purchase update after it has been finished with the store. */
class TipPurchaseOutcome {
  /** The UI result for this update. */
  final DonationResult result;

  /** Store product id, or null for a stream-level error. */
  final String? productId;

  /** Store error message for [DonationResult.error], if any. */
  final String? message;

  const TipPurchaseOutcome(this.result, {this.productId, this.message});
}

/**
 * Subscribes to the purchase stream, finishes every update with the store,
 * and republishes each one as a [TipPurchaseOutcome].
 *
 * Finishing happens for every status when the store asks for it, including
 * error and canceled, and a failure to finish never escapes the listener.
 */
class TipPurchaseListener {
  final DonationService _service;
  final StreamController<TipPurchaseOutcome> _outcomes = StreamController<TipPurchaseOutcome>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  TipPurchaseListener(this._service);

  /** Outcomes of purchase updates, after they were finished with the store. */
  Stream<TipPurchaseOutcome> get outcomes => _outcomes.stream;

  /** Whether [start] has subscribed to the purchase stream. */
  bool get isListening => _subscription != null;

  /**
   * Subscribe to the purchase stream. Safe to call more than once.
   *
   * With [recoverUnfinished], also asks the store to redeliver purchases an
   * earlier run never finished; use it once at app start.
   */
  void start({bool recoverUnfinished = false}) {
    if (_subscription != null) return;
    _subscription = _service.purchaseUpdates.listen(_handleBatch, onError: _handleStreamError);
    if (recoverUnfinished) {
      unawaited(_service.recoverUnfinishedPurchases().catchError((Object e) => debugPrint('[Tips] Recovering unfinished purchases failed: $e')));
    }
  }

  Future<void> _handleBatch(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      await _handle(purchase);
    }
  }

  Future<void> _handle(PurchaseDetails purchase) async {
    try {
      await _service.finishPurchase(purchase);
    } catch (e) {
      // The store redelivers an unfinished purchase, so it is retried on the
      // next launch; the user still gets feedback for this update.
      debugPrint('[Tips] Finishing ${purchase.productID} (${purchase.status.name}) failed: $e');
    }
    final result = switch (purchase.status) {
      _ when DonationService.isAwaitingPayment(purchase) => DonationResult.pending,
      PurchaseStatus.pending => DonationResult.pending,
      PurchaseStatus.purchased || PurchaseStatus.restored => DonationResult.success,
      PurchaseStatus.canceled => DonationResult.cancelled,
      PurchaseStatus.error => DonationResult.error,
    };
    _emit(TipPurchaseOutcome(result, productId: purchase.productID, message: purchase.error?.message));
  }

  void _handleStreamError(Object error) {
    debugPrint('[Tips] Purchase stream error: $error');
    _emit(TipPurchaseOutcome(DonationResult.error, message: '$error'));
  }

  void _emit(TipPurchaseOutcome outcome) {
    if (!_outcomes.isClosed) _outcomes.add(outcome);
  }

  /** Stop listening. */
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _outcomes.close();
  }
}
