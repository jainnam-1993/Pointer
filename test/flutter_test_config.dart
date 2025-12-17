// Global test configuration for all Flutter tests
//
// This file is automatically loaded by Flutter's test framework.
// It runs before any test file executes.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer/theme/app_theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable Google Fonts runtime fetching to prevent network errors
  GoogleFonts.config.allowRuntimeFetching = false;

  // Use system fonts instead of Google Fonts in tests
  // This prevents font loading issues and network errors
  AppTextStyles.useSystemFonts = true;

  // Mock home_widget plugin to prevent MissingPluginException
  // The home_widget plugin requires native iOS/Android implementation
  // which isn't available in unit tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('home_widget'),
    (MethodCall methodCall) async {
      // Return appropriate mock responses for home_widget methods
      switch (methodCall.method) {
        case 'saveWidgetData':
        case 'updateWidget':
        case 'setAppGroupId':
        case 'registerBackgroundCallback':
          return true;
        case 'getWidgetData':
          return null;
        case 'initiallyLaunchedFromHomeWidget':
          return null;
        case 'isRequestPinWidgetSupported':
          return false;
        default:
          return null;
      }
    },
  );

  await testMain();
}
