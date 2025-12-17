// Global test configuration for all Flutter tests
//
// This file is automatically loaded by Flutter's test framework.
// It runs before any test file executes.

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pointer_flutter/theme/app_theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Disable Google Fonts runtime fetching to prevent network errors
  GoogleFonts.config.allowRuntimeFetching = false;

  // Use system fonts instead of Google Fonts in tests
  // This prevents font loading issues and network errors
  AppTextStyles.useSystemFonts = true;

  await testMain();
}
