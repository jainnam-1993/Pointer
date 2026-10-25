// Xcode 27 refuses to build any target whose IPHONEOS_DEPLOYMENT_TARGET is
// below iOS 15 ("Target Integrity" error). The app targets, the Podfile
// platform, and the Podfile post_install clamp for pods must agree on the
// minimum, or `flutter build ios` fails on current Xcode.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _minimumIos = 15.0;

void main() {
  test('Runner and widget extension targets are at least iOS 15', () {
    final pbx = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final targets = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);').allMatches(pbx).map((m) => double.parse(m.group(1)!)).toList();
    expect(targets, isNotEmpty);
    expect(targets.where((v) => v < _minimumIos), isEmpty, reason: 'project.pbxproj targets: $targets');
  });

  test('Podfile platform and pod clamp are at least iOS 15', () {
    final podfile = File('ios/Podfile').readAsStringSync();
    final platform = RegExp(r"^platform :ios, '([0-9.]+)'", multiLine: true).firstMatch(podfile);
    expect(platform, isNotNull);
    expect(double.parse(platform!.group(1)!), greaterThanOrEqualTo(_minimumIos));
    // Pods such as CocoaAsyncSocket declare 9.0; post_install must raise them.
    expect(podfile, contains("config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'"));
  });
}
