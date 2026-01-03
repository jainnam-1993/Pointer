// Golden Test Helpers for Visual Regression Testing
//
// Golden tests compare screenshots pixel-by-pixel against baseline images.
// Any visual change will fail the test until explicitly approved.
//
// Usage:
//   Generate baselines: flutter test --update-goldens
//   Run tests: flutter test test/golden/
//
// CI Integration:
//   Golden tests run as part of `flutter test` and will fail if
//   screenshots don't match baselines.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/services/notification_service.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:mocktail/mocktail.dart';

/// Mock NotificationService for testing
class MockNotificationService extends Mock implements NotificationService {}

/// Mock notification service instance - created once during setup
late MockNotificationService _mockNotificationService;

/// Standard device sizes for golden tests
class GoldenDevices {
  // iPhone 14 Pro
  static const iPhone14Pro = Size(393, 852);
  // iPhone SE (small screen)
  static const iPhoneSE = Size(375, 667);
  // Pixel 7
  static const pixel7 = Size(412, 915);
  // iPad Mini
  static const iPadMini = Size(744, 1133);
}

/// Setup for golden tests - call in setUpAll
Future<void> setupGoldenTests() async {
  // Disable animations for consistent screenshots
  AnimatedGradient.disableAnimations = true;

  // Create and configure mock notification service
  _mockNotificationService = MockNotificationService();
  when(() => _mockNotificationService.checkPermissions())
      .thenAnswer((_) async => true);
  when(() => _mockNotificationService.isNotificationsEnabled).thenReturn(false);
  when(() => _mockNotificationService.getSchedule())
      .thenReturn(const NotificationSchedule());

  // Mock home_widget plugin to prevent MissingPluginException
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('home_widget'),
    (MethodCall methodCall) async {
      // Return null for all home_widget calls - they're no-ops in tests
      return null;
    },
  );

  // Mock flutter_local_notifications plugin
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dexterous.com/flutter/local_notifications'),
    (MethodCall methodCall) async {
      // Return appropriate values for notification plugin calls
      switch (methodCall.method) {
        case 'initialize':
          return true;
        case 'getNotificationAppLaunchDetails':
          return null;
        case 'requestNotificationsPermission':
        case 'requestPermissions':
          return true;
        case 'checkPermissions':
          return {'isEnabled': true};
        default:
          return null;
      }
    },
  );
}

/// Teardown for golden tests
void teardownGoldenTests() {
  AnimatedGradient.disableAnimations = false;
}

/// Test-friendly theme that uses system fonts instead of Google Fonts
/// This avoids network requests and ensures consistent cross-platform rendering
ThemeData get goldenTestTheme {
  const colors = PointerColors.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colors.background,
    fontFamily: 'Roboto', // Flutter's default font, always available
    colorScheme: ColorScheme.dark(
      primary: colors.primary,
      secondary: colors.secondary,
      surface: colors.surface,
      error: const Color(0xFFEF4444),
    ),
    extensions: const [PointerColors.dark],
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: colors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: colors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colors.textMuted,
        letterSpacing: 1,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

/// Creates a testable app wrapper with consistent theming
Widget createGoldenTestApp({
  required Widget child,
  Size size = GoldenDevices.iPhone14Pro,
  SharedPreferences? prefs,
  Pointing? initialPointing,
  bool highContrast = false,
}) {
  return ProviderScope(
    overrides: [
      if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
      if (prefs != null)
        storageServiceProvider.overrideWith((ref) => StorageService(prefs)),
      if (prefs != null)
        settingsProvider.overrideWith((ref) {
          final storage = StorageService(prefs);
          return SettingsNotifier(storage);
        }),
      if (prefs != null)
        themeModeProvider.overrideWith((ref) {
          final settings = ref.watch(settingsProvider);
          return AppThemeMode.fromString(settings.theme);
        }),
      if (prefs != null)
        subscriptionProvider.overrideWith((ref) {
          final storage = StorageService(prefs);
          return SubscriptionNotifier(storage);
        }),
      // Mock notification service to avoid platform plugin issues
      notificationServiceProvider.overrideWithValue(_mockNotificationService),
      highContrastProvider.overrideWith((ref) => highContrast),
      // Override dependent providers to avoid dependency chain issues
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      zenModeProvider.overrideWith((ref) => false),
      if (initialPointing != null)
        currentPointingProvider.overrideWith((ref) {
          final storage = ref.watch(storageServiceProvider);
          final notifier = CurrentPointingNotifier(storage);
          notifier.setPointing(initialPointing);
          return notifier;
        }),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: goldenTestTheme,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          devicePixelRatio: 3.0,
          padding: const EdgeInsets.only(top: 47, bottom: 34), // Safe area
        ),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: child,
        ),
      ),
    ),
  );
}

/// Pumps a widget and prepares it for golden comparison
///
/// This function sets up the test environment and pumps the widget.
/// When using createGoldenTestApp(), the widget already has ProviderScope,
/// so we don't add another one.
Future<void> pumpForGolden(
  WidgetTester tester,
  Widget widget, {
  Size size = GoldenDevices.iPhone14Pro,
}) async {
  // Set surface size
  tester.view.physicalSize = size * 3.0; // Account for pixel ratio
  tester.view.devicePixelRatio = 3.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  // Widget from createGoldenTestApp already has ProviderScope - use directly
  await tester.pumpWidget(widget);

  // Use pump with duration instead of pumpAndSettle for continuous animations
  // pumpAndSettle times out on AnimatedGradient's continuous animation
  await tester.pump(const Duration(seconds: 2));
}

/// Compares widget against golden file
///
/// Golden files are stored in test/golden/goldens/
///
/// To update baselines:
///   flutter test --update-goldens test/golden/
Future<void> expectGoldenMatches(
  WidgetTester tester,
  String goldenName, {
  String? reason,
}) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$goldenName.png'),
    reason: reason,
  );
}

/// Test a screen at multiple device sizes
Future<void> testScreenAtSizes(
  WidgetTester tester,
  String screenName,
  Widget Function() screenBuilder,
) async {
  final sizes = {
    'iphone14pro': GoldenDevices.iPhone14Pro,
    'iphonese': GoldenDevices.iPhoneSE,
    'pixel7': GoldenDevices.pixel7,
  };

  for (final entry in sizes.entries) {
    final deviceName = entry.key;
    final size = entry.value;

    await pumpForGolden(
      tester,
      createGoldenTestApp(
        child: screenBuilder(),
        size: size,
      ),
      size: size,
    );

    await expectGoldenMatches(
      tester,
      '${screenName}_$deviceName',
      reason: '$screenName on $deviceName should match golden',
    );
  }
}

/// Creates mock SharedPreferences for testing
Future<SharedPreferences> createMockPrefs({
  bool onboardingCompleted = true,
  bool isPremium = false,
  bool notificationsEnabled = false,
  int notificationHour = 9,
  int notificationMinute = 0,
}) async {
  final values = <String, Object>{
    'pointer_onboarding_completed': onboardingCompleted,
    'pointer_notifications_enabled': notificationsEnabled,
    'pointer_notification_hour': notificationHour,
    'pointer_notification_minute': notificationMinute,
  };

  if (isPremium) {
    values['pointer_subscription'] = 'premium';
  }

  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

/// Creates a simple widget wrapper for component-level golden tests
/// that don't need full screen setup but need ProviderScope
Widget createComponentTestWrapper({
  required Widget child,
  Size size = const Size(400, 200),
  Color backgroundColor = const Color(0xFF0F0524),
}) {
  return ProviderScope(
    overrides: [
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: goldenTestTheme,
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: child),
      ),
    ),
  );
}

/// Standard test pointing for consistent golden tests
const goldenTestPointing = Pointing(
  id: 'golden-test-1',
  content: 'What is aware of this moment right now?',
  instruction: 'Simply notice.',
  tradition: Tradition.advaita,
  contexts: [PointingContext.general],
  teacher: 'Ramana Maharshi',
);

/// Another test pointing for variety tests
const goldenTestPointing2 = Pointing(
  id: 'golden-test-2',
  content: 'Before the next thought arises, what are you?',
  tradition: Tradition.zen,
  contexts: [PointingContext.morning],
);
