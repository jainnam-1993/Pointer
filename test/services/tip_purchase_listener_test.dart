import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:pointer/providers/donation_providers.dart';
import 'package:pointer/services/donation_service.dart';

import '../helpers/fake_in_app_purchase.dart';

void main() {
  const tea = DonationProductIds.tipSmall;
  late FakeInAppPurchase iap;
  late TipPurchaseListener listener;
  late List<TipPurchaseOutcome> outcomes;

  setUp(() {
    iap = FakeInAppPurchase();
    listener = TipPurchaseListener(DonationService(iap));
    outcomes = [];
    listener.outcomes.listen(outcomes.add);
    listener.start();
  });

  tearDown(() async {
    listener.dispose();
    await iap.close();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('purchased: completes the purchase and reports success', () async {
    final p = purchaseUpdate(tea, PurchaseStatus.purchased);
    iap.emit([p]);
    await settle();
    expect(iap.completed, [p]);
    expect(outcomes.single.result, DonationResult.success);
  });

  test('pending then purchased: waits, then completes exactly once', () async {
    iap.emit([purchaseUpdate(tea, PurchaseStatus.pending, pendingComplete: false)]);
    await settle();
    expect(outcomes.single.result, DonationResult.pending);
    expect(iap.completed, isEmpty);

    final paid = purchaseUpdate(tea, PurchaseStatus.purchased);
    iap.emit([paid]);
    await settle();
    expect(outcomes.map((o) => o.result), [DonationResult.pending, DonationResult.success]);
    expect(iap.completed, [paid]);
  });

  test('error: still finishes the transaction and reports the store message', () async {
    final p = purchaseUpdate(tea, PurchaseStatus.error, errorMessage: 'Card declined');
    iap.emit([p]);
    await settle();
    expect(iap.completed, [p]);
    expect(outcomes.single.result, DonationResult.error);
    expect(outcomes.single.message, 'Card declined');
  });

  test('canceled: still finishes the transaction', () async {
    final p = purchaseUpdate(tea, PurchaseStatus.canceled);
    iap.emit([p]);
    await settle();
    expect(iap.completed, [p]);
    expect(outcomes.single.result, DonationResult.cancelled);
  });

  test('a completePurchase failure does not escape and still reports', () async {
    iap.completeError = Exception('store offline');
    iap.emit([purchaseUpdate(tea, PurchaseStatus.purchased)]);
    await settle();
    expect(outcomes.single.result, DonationResult.success);
  });

  test('a stream error is reported and the listener keeps working', () async {
    iap.emitError(Exception('channel broke'));
    await settle();
    iap.emit([purchaseUpdate(tea, PurchaseStatus.purchased)]);
    await settle();
    expect(outcomes.map((o) => o.result), [DonationResult.error, DonationResult.success]);
  });

  test('Android: a paid tip is consumed instead of only acknowledged', () async {
    final p = playPurchase(tea, status: PurchaseStatus.purchased);
    iap.emit([p]);
    await settle();
    expect(iap.consumed, [p]);
    expect(iap.completed, isEmpty);
  });

  test('Android: when consumption fails the purchase is still acknowledged', () async {
    iap.consumeResponse = BillingResponse.error;
    final p = playPurchase(tea, status: PurchaseStatus.purchased);
    iap.emit([p]);
    await settle();
    expect(iap.completed, [p]);
  });

  group('startup wiring (tipPurchaseListenerProvider)', () {
    late FakeInAppPurchase startupIap;
    late ProviderContainer container;

    setUp(() {
      startupIap = FakeInAppPurchase();
      container = ProviderContainer(overrides: [donationServiceProvider.overrideWithValue(DonationService(startupIap))]);
    });

    tearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      container.dispose();
      await startupIap.close();
    });

    test('Android: an interrupted tip is recovered, consumed and reported at startup', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final interrupted = playPurchase(DonationProductIds.tipGenerous);
      startupIap.restorable = [interrupted];

      final startup = container.read(tipPurchaseListenerProvider);
      final seen = <TipPurchaseOutcome>[];
      startup.outcomes.listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(startup.isListening, isTrue);
      expect(startupIap.restoreCalls, 1);
      expect(startupIap.consumed, [interrupted]);
      expect(seen.single.result, DonationResult.success);
    });

    test('Android: a still-pending Play purchase is left alone and reported as pending', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      startupIap.restorable = [playPurchase(tea, state: PurchaseStateWrapper.pending)];

      final startup = container.read(tipPurchaseListenerProvider);
      final seen = <TipPurchaseOutcome>[];
      startup.outcomes.listen(seen.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(startupIap.consumed, isEmpty);
      expect(startupIap.completed, isEmpty);
      expect(seen.single.result, DonationResult.pending);
    });

    test('iOS: listens without a restore (StoreKit redelivers on its own)', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final startup = container.read(tipPurchaseListenerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(startup.isListening, isTrue);
      expect(startupIap.restoreCalls, 0);

      startupIap.emit([purchaseUpdate(tea, PurchaseStatus.purchased)]);
      await Future<void>.delayed(Duration.zero);
      expect(startupIap.completed, hasLength(1));
    });

    test('the tip jar shares the startup listener instead of starting a second one', () async {
      final startup = container.read(tipPurchaseListenerProvider);
      container.read(donationProvider);
      startupIap.emit([purchaseUpdate(tea, PurchaseStatus.purchased)]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(startup.isListening, isTrue);
      expect(startupIap.completed, hasLength(1)); // finished once, not twice
      expect(container.read(donationProvider).lastResult, DonationResult.success);
    });
  });
}
