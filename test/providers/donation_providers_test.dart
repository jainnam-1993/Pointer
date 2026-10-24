import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/donation_providers.dart';
import 'package:pointer/services/donation_service.dart';

import '../helpers/fake_in_app_purchase.dart';

class MockProductDetails extends Mock implements ProductDetails {}

void main() {
  group('DonationResult', () {
    test('has correct values', () {
      expect(DonationResult.values.length, 4);
      expect(DonationResult.values, contains(DonationResult.pending));
      expect(DonationResult.values, contains(DonationResult.success));
      expect(DonationResult.values, contains(DonationResult.cancelled));
      expect(DonationResult.values, contains(DonationResult.error));
    });
  });

  group('DonationState', () {
    test('default values are correct', () {
      const state = DonationState();
      expect(state.isAvailable, false);
      expect(state.isLoading, true);
      expect(state.products, isEmpty);
      expect(state.error, isNull);
      expect(state.lastResult, isNull);
    });

    test('copyWith creates modified copy', () {
      const original = DonationState();
      final products = [_createMockProduct('test', 1.99)];

      final modified = original.copyWith(
        isAvailable: true,
        isLoading: false,
        products: products,
        error: 'Test error',
        lastResult: DonationResult.success,
      );

      expect(modified.isAvailable, true);
      expect(modified.isLoading, false);
      expect(modified.products, products);
      expect(modified.error, 'Test error');
      expect(modified.lastResult, DonationResult.success);
    });

    test('copyWith preserves unmodified fields', () {
      final products = [_createMockProduct('test', 1.99)];
      final original = DonationState(isAvailable: true, isLoading: false, products: products, error: 'Error', lastResult: DonationResult.success);

      final modified = original.copyWith(isLoading: true);

      expect(modified.isAvailable, true); // preserved
      expect(modified.isLoading, true); // changed
      expect(modified.products, products); // preserved
      expect(modified.error, 'Error'); // preserved
      expect(modified.lastResult, DonationResult.success); // preserved
    });

    test('copyWith can clear error', () {
      const original = DonationState(error: 'Test error');
      final modified = original.copyWith(clearError: true);
      expect(modified.error, isNull);
    });

    test('copyWith can clear result', () {
      const original = DonationState(lastResult: DonationResult.success);
      final modified = original.copyWith(clearResult: true);
      expect(modified.lastResult, isNull);
    });
  });

  group('DonationNotifier (real service over a fake store)', () {
    late FakeInAppPurchase iap;
    late DonationNotifier notifier;
    final tea = tipProduct(DonationProductIds.tipSmall);

    setUp(() async {
      iap = FakeInAppPurchase()..products = [tea, tipProduct(DonationProductIds.tipMedium, price: 4.99)];
      notifier = DonationNotifier(DonationService(iap));
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() async {
      notifier.dispose();
      await iap.close();
    });

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('initializes and loads products sorted by price', () {
      expect(notifier.state.isAvailable, isTrue);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.products.map((p) => p.id), [DonationProductIds.tipSmall, DonationProductIds.tipMedium]);
    });

    test('unavailable store hides the tip jar without an error', () async {
      iap.available = false;
      await notifier.initialize();
      expect(notifier.state.isAvailable, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('is loading while the purchase sheet is up, then success', () async {
      await notifier.purchaseTip(tea);
      expect(notifier.state.isLoading, isTrue);

      iap.emit([purchaseUpdate(tea.id, PurchaseStatus.purchased)]);
      await settle();
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.lastResult, DonationResult.success);
      expect(iap.completed, hasLength(1));
    });

    test('buyConsumable returning false clears loading and reports an error', () async {
      iap.buyResult = false;
      await notifier.purchaseTip(tea);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.lastResult, DonationResult.error);
      expect(notifier.state.resultMessage, isNotNull);
    });

    test('buyConsumable throwing clears loading and reports an error', () async {
      iap.buyError = Exception('billing unavailable');
      await notifier.purchaseTip(tea);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.lastResult, DonationResult.error);
    });

    test('pending does not lock the card, and a later approval succeeds', () async {
      await notifier.purchaseTip(tea);
      iap.emit([purchaseUpdate(tea.id, PurchaseStatus.pending, pendingComplete: false)]);
      await settle();
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.lastResult, DonationResult.pending);

      iap.emit([purchaseUpdate(tea.id, PurchaseStatus.purchased)]);
      await settle();
      expect(notifier.state.lastResult, DonationResult.success);
    });

    test('error from the store is surfaced with its message, products stay', () async {
      await notifier.purchaseTip(tea);
      iap.emit([purchaseUpdate(tea.id, PurchaseStatus.error, errorMessage: 'Card declined')]);
      await settle();
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.lastResult, DonationResult.error);
      expect(notifier.state.resultMessage, 'Card declined');
      expect(notifier.state.error, isNull);
      expect(notifier.state.products, isNotEmpty);
    });

    test('cancelled, then clearResult', () async {
      await notifier.purchaseTip(tea);
      iap.emit([purchaseUpdate(tea.id, PurchaseStatus.canceled)]);
      await settle();
      expect(notifier.state.lastResult, DonationResult.cancelled);
      expect(notifier.state.isLoading, isFalse);

      notifier.clearResult();
      expect(notifier.state.lastResult, isNull);
      expect(notifier.state.resultMessage, isNull);
    });

    test('a new purchase clears the previous result', () async {
      iap.emit([purchaseUpdate(tea.id, PurchaseStatus.canceled)]);
      await settle();
      await notifier.purchaseTip(tea);
      expect(notifier.state.lastResult, isNull);
    });
  });
}

ProductDetails _createMockProduct(String id, double price) {
  final product = MockProductDetails();
  when(() => product.id).thenReturn(id);
  when(() => product.rawPrice).thenReturn(price);
  when(() => product.title).thenReturn(id);
  when(() => product.description).thenReturn('Test product');
  when(() => product.price).thenReturn('\$$price');
  when(() => product.currencyCode).thenReturn('USD');
  when(() => product.currencySymbol).thenReturn('\$');
  return product;
}
