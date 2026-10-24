// From the iOS 27 SDK, a UIKit app without the UIScene lifecycle stops at launch
// (SIGTRAP in UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption).
// Runner declares a scene manifest whose delegate is SceneDelegate, a
// FlutterSceneDelegate subclass.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final plist = File('ios/Runner/Info.plist').readAsStringSync();

  test('iOS Info.plist declares UIApplicationSceneManifest', () {
    expect(plist, contains('<key>UIApplicationSceneManifest</key>'), reason: 'the app crashes at launch on iOS 27 without a scene manifest');
    expect(plist, contains('<key>UIWindowSceneSessionRoleApplication</key>'));
  });

  test('the scene delegate is the Runner SceneDelegate', () {
    expect(
      RegExp(
        r'<key>UISceneDelegateClassName</key>\s*'
        r'<string>\$\(PRODUCT_MODULE_NAME\)\.SceneDelegate</string>',
      ).hasMatch(plist),
      isTrue,
    );
    final delegate = File('ios/Runner/SceneDelegate.swift').readAsStringSync();
    expect(delegate, contains('class SceneDelegate: FlutterSceneDelegate'));
  });
}
