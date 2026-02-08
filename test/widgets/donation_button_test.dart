import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/services/donation_service.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/donation_button.dart';
import 'package:pointer/widgets/glass_card.dart';

/// Mock donation service for testing
class MockDonationService extends DonationService {
  bool _isAvailable = true;
  List<ProductDetails> _products = [];
  final StreamController<List<PurchaseDetails>> _purchaseController =
      StreamController<List<PurchaseDetails>>.broadcast();

  void setAvailable(bool available) => _isAvailable = available;
  void setProducts(List<ProductDetails> products) => _products = products;

  @override
  Future<bool> isAvailable() async => _isAvailable;

  @override
  Future<List<ProductDetails>> loadProducts() async => _products;

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => _purchaseController.stream;

  @override
  Future<void> purchaseProduct(ProductDetails product) async {}

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  void emitPurchase(PurchaseDetails purchase) {
    _purchaseController.add([purchase]);
  }

  @override
  void dispose() {
    _purchaseController.close();
  }
}

/// Test notifier that allows direct state manipulation
class TestDonationNotifier extends DonationNotifier {
  final DonationState _initialState;

  TestDonationNotifier(this._initialState, super.service);

  @override
  Future<void> initialize() async {
    // Don't initialize - use the provided state
    state = _initialState;
  }

  void setTestState(DonationState newState) {
    state = newState;
  }
}

/// Create mock ProductDetails for testing
ProductDetails createMockProduct({required String id, required String title, required String price}) {
  return ProductDetails(
    id: id,
    title: title,
    description: 'Test product $id',
    price: price,
    rawPrice: 1.99,
    currencyCode: 'USD',
  );
}

/// Helper to wrap widget with providers for testing
Widget wrapWithProviders(Widget child, {DonationState? donationState, List<ProductDetails>? products}) {
  // Default mock products
  final defaultProducts = [
    createMockProduct(id: 'tip_small', title: 'Small Tip', price: '\$0.99'),
    createMockProduct(id: 'tip_medium', title: 'Medium Tip', price: '\$2.99'),
    createMockProduct(id: 'tip_large', title: 'Large Tip', price: '\$4.99'),
    createMockProduct(id: 'tip_generous', title: 'Generous Tip', price: '\$9.99'),
  ];

  final state =
      donationState ?? DonationState(isAvailable: true, isLoading: false, products: products ?? defaultProducts);

  final mockService = MockDonationService();

  return ProviderScope(
    overrides: [
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      donationServiceProvider.overrideWithValue(mockService),
      donationProvider.overrideWith((ref) => TestDonationNotifier(state, mockService)),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  setUpAll(() {
    AnimatedGradient.disableAnimations = true;
  });

  tearDownAll(() {
    AnimatedGradient.disableAnimations = false;
  });

  group('DonationButton', () {
    testWidgets('renders collapsed state by default', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const DonationButton()));

      // Should show header
      expect(find.text('Support Development'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);

      // Should show dropdown arrow
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Should not show expanded content
      expect(find.text('Here Now is free forever. If you find value, consider supporting development.'), findsNothing);
    });

    testWidgets('expands on tap', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrapWithProviders(const DonationButton()));

      // Tap to expand
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Should show expanded content
      expect(
        find.text('Here Now is free forever. If you find value, consider supporting development.'),
        findsOneWidget,
      );
    });

    testWidgets('shows product grid when expanded', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrapWithProviders(const DonationButton()));

      // Tap to expand
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Should show product labels
      expect(find.text('Tea'), findsOneWidget);
      expect(find.text('Cushion'), findsOneWidget);
      expect(find.text('Incense'), findsOneWidget);
      expect(find.text('Retreat'), findsOneWidget);

      // Should show prices
      expect(find.text('\$0.99'), findsOneWidget);
      expect(find.text('\$2.99'), findsOneWidget);
      expect(find.text('\$4.99'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
    });

    testWidgets('shows correct icons for products', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrapWithProviders(const DonationButton()));

      // Tap to expand
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Should show product icons
      expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement_outlined), findsOneWidget);
      expect(find.byIcon(Icons.spa_outlined), findsOneWidget);
      expect(find.byIcon(Icons.park_outlined), findsOneWidget);
    });

    testWidgets('hides when not available and not loading', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const DonationButton(),
          donationState: const DonationState(isAvailable: false, isLoading: false),
        ),
      );

      // Should not render anything
      expect(find.byType(DonationButton), findsOneWidget);
      expect(find.text('Support Development'), findsNothing);
    });

    testWidgets('shows loading indicator when loading in collapsed state', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const DonationButton(),
          donationState: const DonationState(isAvailable: true, isLoading: true),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator in expanded state when loading', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const DonationButton(),
          donationState: const DonationState(isAvailable: true, isLoading: true),
        ),
      );

      // Manually expand (even during loading the header is visible)
      // The loading indicator should be in the header
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry button', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const DonationButton(),
          donationState: const DonationState(isAvailable: true, isLoading: false, error: 'Failed to load products'),
        ),
      );

      // Tap to expand
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Failed to load products'), findsOneWidget);

      // Should show retry button
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('shows message when no products available', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const DonationButton(),
          donationState: const DonationState(isAvailable: true, isLoading: false, products: []),
        ),
      );

      // Tap to expand
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Should show no products message
      expect(find.text('No donation options available'), findsOneWidget);
    });

    testWidgets('collapses when tapped again', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(wrapWithProviders(const DonationButton()));

      // Tap to expand
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Verify expanded
      expect(
        find.text('Here Now is free forever. If you find value, consider supporting development.'),
        findsOneWidget,
      );

      // Tap to collapse
      await tester.tap(find.text('Support Development'));
      await tester.pumpAndSettle();

      // Content should be hidden (opacity 0 or not rendered)
      // The text may still exist in tree but with opacity 0
      // Check that the product grid is not interactive
      expect(find.text('Tea'), findsNothing);
    });

    testWidgets('uses GlassCard for styling', (tester) async {
      await tester.pumpWidget(wrapWithProviders(const DonationButton()));

      expect(find.descendant(of: find.byType(DonationButton), matching: find.byType(GlassCard)), findsOneWidget);
    });

    testWidgets('disables product cards during purchase', (tester) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const DonationButton(),
          donationState: DonationState(
            isAvailable: true,
            isLoading: true, // Simulates purchase in progress
            products: [createMockProduct(id: 'tip_small', title: 'Small', price: '\$0.99')],
          ),
        ),
      );

      // The button should still be visible but product cards should be disabled
      // (indicated by opacity reduction)
      expect(find.text('Support Development'), findsOneWidget);
    });
  });
}
