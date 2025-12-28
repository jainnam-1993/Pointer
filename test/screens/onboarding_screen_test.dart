import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/onboarding_screen.dart';
import 'package:pointer/services/notification_service.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockStorageService extends Mock implements StorageService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockNotificationService mockNotificationService;
  late MockStorageService mockStorageService;

  setUpAll(() {
    // Disable animations for testing
    AnimatedGradient.disableAnimations = true;
  });

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockNotificationService = MockNotificationService();
    mockStorageService = MockStorageService();

    // Setup default mock returns
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    
    // Mock StorageService to return default settings
    when(() => mockStorageService.settings).thenReturn(const AppSettings());
  });

  Widget createOnboardingScreen() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        storageServiceProvider.overrideWithValue(mockStorageService),
        oledModeProvider.overrideWith((ref) => false),
        reduceMotionOverrideProvider.overrideWith((ref) => null),
        highContrastProvider.overrideWith((ref) => false),
      ],
      child: const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
  }

  // Helper to set screen size for tests
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.0;
  }

  void resetScreenSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  group('OnboardingPage model', () {
    test('can create with required fields', () {
      const page = OnboardingPage(
        id: 'test',
        title: 'Test Title',
        subtitle: 'Test Subtitle',
        description: 'Test Description',
        icon: Icons.star,
      );

      expect(page.id, 'test');
      expect(page.title, 'Test Title');
      expect(page.subtitle, 'Test Subtitle');
      expect(page.description, 'Test Description');
      expect(page.icon, Icons.star);
    });

    test('all 4 pages defined in onboardingPages constant', () {
      expect(onboardingPages.length, 4);
      expect(onboardingPages[0].id, 'welcome');
      expect(onboardingPages[1].id, 'traditions');
      expect(onboardingPages[2].id, 'practice');
      expect(onboardingPages[3].id, 'notifications');
    });
  });

  group('OnboardingScreen rendering', () {
    testWidgets('screen renders without errors', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });

    testWidgets('shows first page content (Welcome to Pointer)',
        (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Pointer'), findsOneWidget);
      expect(find.text('Direct invitations to recognize what you already are'),
          findsOneWidget);
      expect(
          find.textContaining(
              'Each pointing is a finger pointing at the moon'),
          findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('has AnimatedGradient background', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedGradient), findsOneWidget);
    });

    testWidgets('has page indicators (4 dots)', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Find all AnimatedContainers used as page indicators
      final indicators = find.byWidgetPredicate((widget) =>
          widget is AnimatedContainer &&
          widget.constraints?.maxHeight == 8 &&
          widget.constraints?.maxWidth != null);

      expect(indicators, findsNWidgets(4));
    });

    testWidgets('has Continue button on first page', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Enable Notifications'), findsNothing);
      expect(find.text('Maybe Later'), findsNothing);
    });
  });

  group('OnboardingScreen navigation', () {
    testWidgets('tapping Continue advances to next page', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Verify first page
      expect(find.text('Welcome to Pointer'), findsOneWidget);

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify second page
      expect(find.text('Multiple Traditions'), findsOneWidget);
      expect(find.text('One truth, many expressions'), findsOneWidget);
    });

    testWidgets('last page shows Enable Notifications and Maybe Later buttons',
        (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Navigate to last page
      await tester.tap(find.text('Continue')); // Page 2
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue')); // Page 3
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue')); // Page 4
      await tester.pumpAndSettle();

      // Verify last page buttons
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.text('Maybe Later'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });
  });

  group('OnboardingScreen page content', () {
    testWidgets('welcome page has correct content', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Pointer'), findsOneWidget);
      expect(find.text('Direct invitations to recognize what you already are'),
          findsOneWidget);
      expect(
          find.textContaining(
              'Each pointing is a finger pointing at the moon'),
          findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('traditions page has correct content', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Navigate to traditions page
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Multiple Traditions'), findsOneWidget);
      expect(find.text('One truth, many expressions'), findsOneWidget);
      expect(
          find.textContaining('Explore pointings from Advaita, Zen'),
          findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
    });

    testWidgets('practice page has correct content', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Navigate to practice page
      await tester.tap(find.text('Continue')); // Page 2
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue')); // Page 3
      await tester.pumpAndSettle();

      expect(find.text('Daily Pointings'), findsOneWidget);
      expect(find.text('Gentle reminders throughout your day'), findsOneWidget);
      expect(
          find.textContaining('Receive notifications that invite you to pause'),
          findsOneWidget);
      expect(find.byIcon(Icons.all_inclusive), findsOneWidget);
    });

    testWidgets('notifications page has correct content', (tester) async {
      setScreenSize(tester);
      addTearDown(() => resetScreenSize(tester));
      
      await tester.pumpWidget(createOnboardingScreen());
      await tester.pumpAndSettle();

      // Navigate to notifications page
      await tester.tap(find.text('Continue')); // Page 2
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue')); // Page 3
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue')); // Page 4
      await tester.pumpAndSettle();

      expect(find.text('Stay Connected'), findsOneWidget);
      expect(find.text('Would you like daily reminders?'), findsOneWidget);
      expect(
          find.textContaining('Enable notifications to receive gentle pointing'),
          findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
    });
  });
}
