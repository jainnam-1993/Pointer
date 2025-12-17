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
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/widgets/animated_gradient.dart';

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

  // Mock home_widget plugin to prevent MissingPluginException
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('home_widget'),
    (MethodCall methodCall) async {
      // Return null for all home_widget calls - they're no-ops in tests
      return null;
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
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto', // Flutter's default font, always available
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: Color(0xFFEF4444),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
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
      highContrastProvider.overrideWith((ref) => false),
      // Override dependent providers to avoid dependency chain issues
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      if (initialPointing != null)
        currentPointingProvider.overrideWith((ref) {
          final notifier = CurrentPointingNotifier();
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
/// This function wraps the widget with ProviderScope to ensure all
/// ConsumerWidgets (like GlassCard, GlassButton) have access to providers.
Future<void> pumpForGolden(
  WidgetTester tester,
  Widget widget, {
  Size size = GoldenDevices.iPhone14Pro,
  bool highContrast = false,
}) async {
  // Set surface size
  tester.view.physicalSize = size * 3.0; // Account for pixel ratio
  tester.view.devicePixelRatio = 3.0;

  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  // Check if widget already has ProviderScope (e.g., from createGoldenTestApp)
  // If it does, don't double-wrap; otherwise wrap with ProviderScope
  Widget wrappedWidget;
  if (widget is ProviderScope) {
    // Widget already has ProviderScope - just add our overrides by wrapping again
    // Note: nested ProviderScope is fine in Riverpod 2.x
    wrappedWidget = ProviderScope(
      overrides: [
        highContrastProvider.overrideWith((ref) => highContrast),
      ],
      child: widget,
    );
  } else {
    // Widget needs ProviderScope
    wrappedWidget = ProviderScope(
      overrides: [
        highContrastProvider.overrideWith((ref) => highContrast),
      ],
      child: widget,
    );
  }

  await tester.pumpWidget(wrappedWidget);
  await tester.pumpAndSettle();

  // Extra pump to ensure all frames are rendered
  await tester.pump(const Duration(milliseconds: 100));
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
