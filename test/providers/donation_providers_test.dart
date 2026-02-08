import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/donation_providers.dart';
import 'package:pointer/services/donation_service.dart';

class MockDonationService extends Mock implements DonationService {}

class MockProductDetails extends Mock implements ProductDetails {}

class MockPurchaseDetails extends Mock implements PurchaseDetails {}

void main() {
  group('DonationResult', () {
    test('has correct values', () {
      expect(DonationResult.values.length, 3);
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
      final original = DonationState(
        isAvailable: true,
        isLoading: false,
        products: products,
        error: 'Error',
        lastResult: DonationResult.success,
      );

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

  group('DonationNotifier', () {
    late MockDonationService mockService;
    late DonationNotifier notifier;
    late StreamController<List<PurchaseDetails>> purchaseController;

    setUp(() {
      mockService = MockDonationService();
      purchaseController = StreamController<List<PurchaseDetails>>.broadcast();

      when(() => mockService.purchaseUpdates).thenAnswer((_) => purchaseController.stream);
      when(() => mockService.dispose()).thenReturn(null);
    });

    tearDown(() {
      purchaseController.close();
    });

    test('initializes and loads products when available', () async {
      final products = [_createMockProduct('tip_small', 0.99), _createMockProduct('tip_medium', 4.99)];

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => products);

      notifier = DonationNotifier(mockService);

      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.isAvailable, true);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.products, products);
      expect(notifier.state.error, isNull);
    });

    test('sets isAvailable false when IAP unavailable', () async {
      when(() => mockService.isAvailable()).thenAnswer((_) async => false);

      notifier = DonationNotifier(mockService);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.isAvailable, false);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.products, isEmpty);
      verifyNever(() => mockService.loadProducts());
    });

    test('handles initialization error gracefully', () async {
      when(() => mockService.isAvailable()).thenThrow(Exception('Init failed'));

      notifier = DonationNotifier(mockService);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.isAvailable, false);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, contains('Failed to load'));
    });

    test('purchaseTip initiates purchase', () async {
      final product = _createMockProduct('tip_small', 0.99);

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => [product]);
      when(() => mockService.purchaseProduct(product)).thenAnswer((_) async {});

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.purchaseTip(product);

      verify(() => mockService.purchaseProduct(product)).called(1);
    });

    test('purchaseTip sets loading state', () async {
      final product = _createMockProduct('tip_small', 0.99);
      final completer = Completer<void>();

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => [product]);
      when(() => mockService.purchaseProduct(product)).thenAnswer((_) => completer.future);

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      // Start purchase but don't complete
      final purchaseFuture = notifier.purchaseTip(product);

      // Should be loading
      expect(notifier.state.isLoading, true);

      completer.complete();
      await purchaseFuture;
    });

    test('handles purchase error', () async {
      final product = _createMockProduct('tip_small', 0.99);

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => [product]);
      when(() => mockService.purchaseProduct(product)).thenThrow(Exception('Purchase failed'));

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.purchaseTip(product);

      expect(notifier.state.isLoading, false);
      expect(notifier.state.lastResult, DonationResult.error);
      expect(notifier.state.error, contains('Failed to initiate'));
    });

    test('processes successful purchase from stream', () async {
      final purchase = MockPurchaseDetails();
      when(() => purchase.status).thenReturn(PurchaseStatus.purchased);
      when(() => purchase.pendingCompletePurchase).thenReturn(true);

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => []);
      when(() => mockService.completePurchase(purchase)).thenAnswer((_) async {});

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      // Simulate purchase update
      purchaseController.add([purchase]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.lastResult, DonationResult.success);
      expect(notifier.state.isLoading, false);
      verify(() => mockService.completePurchase(purchase)).called(1);
    });

    test('processes cancelled purchase from stream', () async {
      final purchase = MockPurchaseDetails();
      when(() => purchase.status).thenReturn(PurchaseStatus.canceled);

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => []);

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      purchaseController.add([purchase]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.lastResult, DonationResult.cancelled);
      expect(notifier.state.isLoading, false);
    });

    test('processes error purchase from stream', () async {
      final purchase = MockPurchaseDetails();
      final error = IAPError(source: 'test', code: 'error', message: 'Something went wrong');
      when(() => purchase.status).thenReturn(PurchaseStatus.error);
      when(() => purchase.error).thenReturn(error);

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => []);

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      purchaseController.add([purchase]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.lastResult, DonationResult.error);
      expect(notifier.state.error, 'Something went wrong');
      expect(notifier.state.isLoading, false);
    });

    test('handles pending purchase status', () async {
      final purchase = MockPurchaseDetails();
      when(() => purchase.status).thenReturn(PurchaseStatus.pending);

      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => []);

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      purchaseController.add([purchase]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.isLoading, true);
    });

    test('clearResult clears last result', () async {
      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.loadProducts()).thenAnswer((_) async => []);

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      // Manually set a result state
      final purchase = MockPurchaseDetails();
      when(() => purchase.status).thenReturn(PurchaseStatus.canceled);
      purchaseController.add([purchase]);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.lastResult, DonationResult.cancelled);

      notifier.clearResult();

      expect(notifier.state.lastResult, isNull);
    });

    test('clearError clears error state', () async {
      when(() => mockService.isAvailable()).thenThrow(Exception('Test error'));

      notifier = DonationNotifier(mockService);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.error, isNotNull);

      notifier.clearError();

      expect(notifier.state.error, isNull);
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
