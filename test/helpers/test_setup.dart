import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/widgets/animated_gradient.dart';

/// Mock SharedPreferences for testing
class MockSharedPreferences extends Mock implements SharedPreferences {}

/// Test setup utilities to reduce boilerplate across test files
class TestSetup {
  final MockSharedPreferences mockPrefs;

  TestSetup() : mockPrefs = MockSharedPreferences() {
    _setupDefaultMocks();
  }

  /// Initialize test environment - disables animations to prevent timer issues
  static void initializeTestEnvironment() {
    AnimatedGradient.disableAnimations = true;
  }

  /// Cleanup test environment - re-enables animations
  static void cleanupTestEnvironment() {
    AnimatedGradient.disableAnimations = false;
  }

  /// Setup default mock returns for SharedPreferences methods
  void _setupDefaultMocks() {
    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.getDouble(any())).thenReturn(null);
    when(() => mockPrefs.getStringList(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setDouble(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setStringList(any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockPrefs.remove(any())).thenAnswer((_) async => true);
    when(() => mockPrefs.clear()).thenAnswer((_) async => true);
  }

  /// Standard provider overrides for common test scenarios
  List<Override> get standardOverrides => [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        oledModeProvider.overrideWith((ref) => false),
        reduceMotionOverrideProvider.overrideWith((ref) => null),
      ];

  /// Wrap a widget with ProviderScope and MaterialApp for testing
  Widget wrapWithProviders(
    Widget child, {
    List<Override>? additionalOverrides,
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: [
        ...standardOverrides,
        if (additionalOverrides != null) ...additionalOverrides,
      ],
      child: MaterialApp(
        theme: theme ?? ThemeData.dark(),
        home: child,
      ),
    );
  }
}

/// Helper to pump a screen widget with phone-sized surface and runAsync
///
/// This helper:
/// - Sets up a phone-sized test surface (1080x1920, 2.0 pixel ratio)
/// - Uses runAsync to avoid timer issues with animations
/// - Automatically resets the test surface on teardown
Future<void> pumpScreen(WidgetTester tester, Widget widget) async {
  // Use a phone-sized surface to avoid overflow in tests
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.runAsync(() async {
    await tester.pumpWidget(widget);
  });
  await tester.pump();
}

/// Helper to tap a widget and clear animation timers
///
/// This helper:
/// - Taps the widget found by the finder
/// - Pumps and settles with a 500ms timeout to clear all animation timers
Future<void> tapAndPump(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}
