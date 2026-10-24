import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

/**
 * App Store / Play Store product identifiers for tip jar consumable purchases.
 *
 * Each tier corresponds to a different donation amount configured in
 * App Store Connect and Google Play Console.
 */
class DonationProductIds {
  /** Smallest donation tier (e.g. "Buy me a tea"). */
  static const tipSmall = 'com.dailypointer.tip_small';

  /** Medium donation tier (e.g. "Buy me a cushion"). */
  static const tipMedium = 'com.dailypointer.tip_medium';

  /** Large donation tier (e.g. "Buy me incense"). */
  static const tipLarge = 'com.dailypointer.tip_large';

  /** Largest donation tier (e.g. "Fund a retreat"). */
  static const tipGenerous = 'com.dailypointer.tip_generous';

  /** Set of all product IDs, passed to [InAppPurchase.queryProductDetails]. */
  static const all = {tipSmall, tipMedium, tipLarge, tipGenerous};
}

/**
 * Service for handling tip jar donations via in-app purchases
 *
 * All donations are consumable products - they can be purchased multiple times.
 * CRITICAL: completePurchase() must be called after successful purchase
 * to acknowledge receipt with the store.
 */
class DonationService {
  final InAppPurchase _iap;

  DonationService([InAppPurchase? iap]) : _iap = iap ?? InAppPurchase.instance;

  /** Stream of purchase updates from the store */
  Stream<List<PurchaseDetails>> get purchaseUpdates => _iap.purchaseStream;

  /** Check if in-app purchases are available on this device */
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (e) {
      // Graceful degradation - return false on errors
      return false;
    }
  }

  /**
   * Load donation products from the store
   *
   * Returns empty list if products unavailable or on error.
   */
  Future<List<ProductDetails>> loadProducts() async {
    try {
      final available = await isAvailable();
      if (!available) return [];

      final response = await _iap.queryProductDetails(DonationProductIds.all);

      if (response.notFoundIDs.isNotEmpty) {
        // Some products not found - log but continue with available ones
        // In production, these would be configured in App Store Connect / Play Console
      }

      // Sort by price (assuming small < medium < large < generous)
      final products = response.productDetails.toList()..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

      return products;
    } catch (e) {
      // Graceful degradation - return empty on errors
      return [];
    }
  }

  /**
   * Initiate a donation purchase.
   *
   * Returns `false` when the store refused to start the purchase flow; the
   * caller must then clear any loading state itself, because no update will
   * arrive on [purchaseUpdates]. On Android the tip is consumed by
   * [finishPurchase] rather than by the plugin, so the same code path handles
   * a purchase delivered in this session, after a restart, or after a pending
   * payment is approved.
   */
  Future<bool> purchaseProduct(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: defaultTargetPlatform != TargetPlatform.android);
  }

  /**
   * Complete a purchase to acknowledge receipt with the store
   *
   * Called for every status, including error and canceled, whenever the
   * store reports [PurchaseDetails.pendingCompletePurchase]. An unfinished
   * StoreKit transaction is redelivered on every launch, and an
   * unacknowledged Play purchase is refunded after three days.
   */
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  /**
   * Deliver and finish one purchase update.
   *
   * On Android a paid tip is consumed first, which also acknowledges it and
   * lets the user buy the same tier again. If consumption fails, the purchase
   * is still acknowledged so Play does not refund it, and the next startup
   * recovery retries the consumption. Everything else goes to
   * [completePurchase].
   */
  Future<void> finishPurchase(PurchaseDetails purchase) async {
    // A purchase still waiting on payment cannot be acknowledged or consumed;
    // the store delivers it again once it is paid.
    if (isAwaitingPayment(purchase)) return;
    if (_isUnconsumedAndroidTip(purchase)) {
      final addition = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final result = await addition.consumePurchase(purchase);
      if (result.responseCode == BillingResponse.ok) return;
    }
    await completePurchase(purchase);
  }

  /**
   * Whether the store is still waiting on payment or approval for [purchase].
   *
   * Play reports a pending purchase found at startup as
   * [PurchaseStatus.restored], so its purchase state is checked too.
   */
  static bool isAwaitingPayment(PurchaseDetails purchase) {
    if (purchase.status == PurchaseStatus.pending) return true;
    return purchase is GooglePlayPurchaseDetails && purchase.billingClientPurchase.purchaseState == PurchaseStateWrapper.pending;
  }

  bool _isUnconsumedAndroidTip(PurchaseDetails purchase) {
    if (purchase is! GooglePlayPurchaseDetails) return false;
    if (purchase.status != PurchaseStatus.purchased && purchase.status != PurchaseStatus.restored) return false;
    if (!DonationProductIds.all.contains(purchase.productID)) return false;
    return purchase.billingClientPurchase.purchaseState == PurchaseStateWrapper.purchased;
  }

  /**
   * Ask the store to redeliver purchases left unfinished by an earlier run.
   *
   * Play does not push a purchase that completed while the app was not
   * running (an interrupted flow, or a pending payment approved later), so on
   * Android the owned purchases are queried and arrive on [purchaseUpdates]
   * as [PurchaseStatus.restored]. StoreKit redelivers unfinished transactions
   * by itself once the stream is listened to, and a restore there would ask
   * the user to sign in, so iOS does nothing here.
   */
  Future<void> recoverUnfinishedPurchases() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (!await isAvailable()) return;
    await _iap.restorePurchases();
  }

  /** Clean up resources */
  void dispose() {}
}
