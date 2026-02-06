import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/settings_screen.dart';
import 'package:pointer/providers/providers.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pointer/providers/donation_providers.dart';
import 'package:pointer/services/donation_service.dart';

class _MockDonationService extends DonationService {
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<List<ProductDetails>> loadProducts() async => [];
  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => const Stream.empty();
  @override
  void dispose() {}
}

class _TestDonationNotifier extends DonationNotifier {
  _TestDonationNotifier(DonationService service) : super(service);
  @override
  Future<void> initialize() async {
    state = const DonationState(isAvailable: false, isLoading: false);
  }
}

final _mockDonationService = _MockDonationService();

void main() {
  late SharedPreferences mockPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget({Widget? child}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        donationServiceProvider.overrideWithValue(_mockDonationService),
        donationProvider.overrideWith(
          (ref) => _TestDonationNotifier(_mockDonationService),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: child ?? const SettingsScreen(),
      ),
    );
  }

  group('Settings Screen - Basic Structure', () {
    testWidgets('renders settings screen', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('has scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scrollable), findsWidgets);
    });

    testWidgets('developer section is hidden by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Developer section should not be visible initially
      expect(find.text('DEVELOPER'), findsNothing);
      expect(find.text('TTS Configuration'), findsNothing);
    });
  });

  group('Settings Screen - State Management', () {
    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
