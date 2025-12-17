// Test driver for running integration tests on a device
// This file is required for running tests via flutter drive
//
// Usage:
//   flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
