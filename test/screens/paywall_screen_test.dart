import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/providers/subscription_providers.dart';
import 'package:pointer/screens/paywall_screen.dart';
import 'package:pointer/services/revenue_cat_service.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockStorageService extends Mock implements StorageService {}

class MockPackage extends Mock implements Package {}

class MockStoreProduct extends Mock implements StoreProduct {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockStorageService mockStorageService;

  setUpAll(() {
    // Disable animations for testing
    AnimatedGradient.disableAnimations = true;
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockStorageService = MockStorageService();

    // Setup default mock returns
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);

    // Mock StorageService
    when(() => mockStorageService.settings).thenReturn(const AppSettings());
    when(() => mockStorageService.subscriptionTier).thenReturn('free');
    when(() => mockStorageService.setSubscriptionTier(any()))
        .thenAnswer((_) async {});
  });

  Widget createPaywallScreen({
    SubscriptionState? subscriptionState,
  }) {
    final state = subscriptionState ??
        const SubscriptionState(
          tier: SubscriptionTier.free,
          isLoading: false,
          products: [],
        );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        storageServiceProvider.overrideWithValue(mockStorageService),
        subscriptionProvider.overrideWith((ref) => _MockSubscriptionNotifier(state)),
        oledModeProvider.overrideWith((ref) => false),
        reduceMotionOverrideProvider.overrideWith((ref) => null),
        highContrastProvider.overrideWith((ref) => false),
      ],
      child: const MaterialApp(
        home: PaywallScreen(),
      ),
    );
  }

  // Helper to set screen size for tests - large enough to avoid overflow
  void setLargeScreenSize(WidgetTester tester) {
    // Use tablet-size to ensure no overflow
    tester.view.physicalSize = const Size(2048, 2732); // iPad Pro
    tester.view.devicePixelRatio = 2.0;
  }

  void resetScreenSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  group('PaywallScreen widget tree', () {
    testWidgets('screen renders and contains expected widget types', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      // Core widgets exist
      expect(find.byType(PaywallScreen), findsOneWidget);
      expect(find.byType(AnimatedGradient), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('contains header with icons', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      // Header icons
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('displays title text', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      // Both title and CTA button have "Unlock Here Now" text
      expect(find.text('Unlock Here Now'), findsNWidgets(2));
    });

    testWidgets('displays subtitle text', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('One-time purchase, yours forever'), findsOneWidget);
    });

    testWidgets('has restore button text', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Restore'), findsOneWidget);
    });
  });

  group('PaywallScreen features', () {
    testWidgets('displays all four feature items', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      // Feature titles
      expect(find.text('Unlimited Pointings'), findsOneWidget);
      expect(find.text('All Traditions'), findsOneWidget);
      expect(find.text('Audio Pointings'), findsOneWidget);
      expect(find.text('Guided Inquiries'), findsOneWidget);
    });

    testWidgets('displays feature descriptions', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      // Feature descriptions
      expect(find.text('No daily limits, explore freely'), findsOneWidget);
      expect(find.text('Access all 5 spiritual lineages'), findsOneWidget);
      expect(find.text('Listen to guided readings'), findsOneWidget);
      expect(find.text('Unlock all self-inquiry sessions'), findsOneWidget);
    });

    testWidgets('features are displayed in GlassCard', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(GlassCard), findsWidgets);
    });

    testWidgets('displays feature icons', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byIcon(Icons.all_inclusive), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
      expect(find.byIcon(Icons.headphones), findsOneWidget);
      expect(find.byIcon(Icons.spa), findsOneWidget);
    });
  });

  group('PaywallScreen purchase state', () {
    testWidgets('shows Loading when no products available', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen(
        subscriptionState: const SubscriptionState(
          tier: SubscriptionTier.free,
          isLoading: false,
          products: [],
        ),
      ));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('shows price when product available', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      final mockPackage = MockPackage();
      final mockStoreProduct = MockStoreProduct();
      when(() => mockPackage.packageType).thenReturn(PackageType.lifetime);
      when(() => mockPackage.storeProduct).thenReturn(mockStoreProduct);
      when(() => mockStoreProduct.identifier).thenReturn('pointer_premium_lifetime');
      when(() => mockStoreProduct.title).thenReturn('Pointer Premium');
      when(() => mockStoreProduct.description).thenReturn('Lifetime access');
      when(() => mockStoreProduct.priceString).thenReturn('\$9.99');
      when(() => mockStoreProduct.price).thenReturn(9.99);

      final product = SubscriptionProduct(
        id: 'pointer_premium_lifetime',
        title: 'Pointer Premium',
        description: 'Lifetime access',
        price: '\$9.99',
        priceValue: 9.99,
        packageType: PackageType.lifetime,
        package: mockPackage,
      );

      await tester.pumpWidget(createPaywallScreen(
        subscriptionState: SubscriptionState(
          tier: SubscriptionTier.free,
          isLoading: false,
          products: [product],
        ),
      ));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('lifetime'), findsOneWidget);
    });

    testWidgets('shows disclaimer text with product', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      final mockPackage = MockPackage();
      final mockStoreProduct = MockStoreProduct();
      when(() => mockPackage.packageType).thenReturn(PackageType.lifetime);
      when(() => mockPackage.storeProduct).thenReturn(mockStoreProduct);
      when(() => mockStoreProduct.identifier).thenReturn('pointer_premium_lifetime');
      when(() => mockStoreProduct.title).thenReturn('Pointer Premium');
      when(() => mockStoreProduct.description).thenReturn('Lifetime access');
      when(() => mockStoreProduct.priceString).thenReturn('\$9.99');
      when(() => mockStoreProduct.price).thenReturn(9.99);

      final product = SubscriptionProduct(
        id: 'pointer_premium_lifetime',
        title: 'Pointer Premium',
        description: 'Lifetime access',
        price: '\$9.99',
        priceValue: 9.99,
        packageType: PackageType.lifetime,
        package: mockPackage,
      );

      await tester.pumpWidget(createPaywallScreen(
        subscriptionState: SubscriptionState(
          tier: SubscriptionTier.free,
          isLoading: false,
          products: [product],
        ),
      ));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('One-time purchase • No subscription'), findsOneWidget);
    });

    testWidgets('CTA button shows loading state', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      final mockPackage = MockPackage();
      final mockStoreProduct = MockStoreProduct();
      when(() => mockPackage.packageType).thenReturn(PackageType.lifetime);
      when(() => mockPackage.storeProduct).thenReturn(mockStoreProduct);
      when(() => mockStoreProduct.identifier).thenReturn('pointer_premium_lifetime');
      when(() => mockStoreProduct.title).thenReturn('Pointer Premium');
      when(() => mockStoreProduct.description).thenReturn('Lifetime access');
      when(() => mockStoreProduct.priceString).thenReturn('\$9.99');
      when(() => mockStoreProduct.price).thenReturn(9.99);

      final product = SubscriptionProduct(
        id: 'pointer_premium_lifetime',
        title: 'Pointer Premium',
        description: 'Lifetime access',
        price: '\$9.99',
        priceValue: 9.99,
        packageType: PackageType.lifetime,
        package: mockPackage,
      );

      await tester.pumpWidget(createPaywallScreen(
        subscriptionState: SubscriptionState(
          tier: SubscriptionTier.free,
          isLoading: true,
          products: [product],
        ),
      ));
      await tester.pump(const Duration(seconds: 2));

      // Find GlassButton and verify its loading state
      final glassButtons = tester.widgetList<GlassButton>(find.byType(GlassButton));
      expect(glassButtons.any((b) => b.isLoading == true), true);
    });
  });

  group('PaywallScreen legal links', () {
    testWidgets('has Privacy policy text', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Privacy policy'), findsOneWidget);
    });

    testWidgets('has Terms of service text', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Terms of service'), findsOneWidget);
    });

    testWidgets('has bullet separator', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('•'), findsOneWidget);
    });
  });

  group('PaywallScreen accessibility', () {
    testWidgets('back button has Semantics wrapper', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      // Find Semantics widget that contains the back button
      final backButtonFinder = find.ancestor(
        of: find.byIcon(Icons.arrow_back),
        matching: find.byType(Semantics),
      );
      expect(backButtonFinder, findsWidgets);
    });

    testWidgets('restore button has Semantics wrapper', (tester) async {
      setLargeScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));

      await tester.pumpWidget(createPaywallScreen());
      await tester.pump(const Duration(seconds: 2));

      // Find Semantics widget that contains the restore button
      final restoreButtonFinder = find.ancestor(
        of: find.text('Restore'),
        matching: find.byType(Semantics),
      );
      expect(restoreButtonFinder, findsWidgets);
    });
  });
}

/// Mock subscription notifier for testing
class _MockSubscriptionNotifier extends SubscriptionNotifier {
  final SubscriptionState _initialState;

  _MockSubscriptionNotifier(this._initialState)
      : super(_MockStorageService()) {
    state = _initialState;
  }
}

class _MockStorageService extends Mock implements StorageService {
  @override
  AppSettings get settings => const AppSettings();

  @override
  String get subscriptionTier => 'free';

  @override
  Future<void> setSubscriptionTier(String tier) async {}
}
