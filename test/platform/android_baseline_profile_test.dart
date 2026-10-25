/**
 * The Android Baseline Profile keeps the cold start path compiled ahead of time.
 * Without it a fresh install runs the dex unverified from the APK, about 350 ms
 * slower per cold start on the user-device emulator.
 */
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final profile = File('android/app/src/main/baseline-prof.txt');

  test('the baseline profile covers the app and the Flutter embedding', () {
    expect(profile.existsSync(), isTrue);
    final rules = profile.readAsLinesSync().where((l) => l.isNotEmpty && !l.startsWith('#'));
    expect(rules, containsAll(['HSPLcom/dailypointer/**->**(**)**', 'HSPLio/flutter/**->**(**)**']));
  });

  test('profileinstaller ships the profile to sideloaded installs', () {
    expect(File('android/app/build.gradle.kts').readAsStringSync(), contains('androidx.profileinstaller:profileinstaller:'));
  });
}
