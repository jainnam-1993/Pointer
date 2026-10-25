// Global test configuration for all Flutter tests
//
// This file is automatically loaded by Flutter's test framework.
// It runs before any test file executes.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointer/theme/app_theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Use system fonts instead of Google Fonts in tests
  // This prevents font loading issues and network errors
  AppTextStyles.useSystemFonts = true;

  // Fixed package info so the Settings version label is deterministic. The
  // value is test data, chosen to match the label already in the goldens.
  PackageInfo.setMockInitialValues(appName: 'Here Now', packageName: 'com.dailypointer', version: '1.1.0', buildNumber: '15', buildSignature: '');

  // Mock home_widget plugin to prevent MissingPluginException
  // The home_widget plugin requires native iOS/Android implementation
  // which isn't available in unit tests
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('home_widget'), (MethodCall methodCall) async {
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
  });

  await testMain();
}
