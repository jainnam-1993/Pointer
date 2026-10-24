// The Gradle wrapper version must live in git. When it was ignored, every machine
// built with whatever wrapper it already had (8.13, 8.14 and 8.14.3 were all seen),
// and Flutter 3.47.8 Android builds failed on the 8.13 ones.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const path = 'android/gradle/wrapper/gradle-wrapper.properties';

  test('the Gradle wrapper is pinned to 8.14 or newer', () {
    final match = RegExp(r'gradle-(\d+)\.(\d+)').firstMatch(File(path).readAsStringSync());
    expect(match, isNotNull, reason: 'distributionUrl is missing');
    final version = int.parse(match!.group(1)!) * 100 + int.parse(match.group(2)!);
    expect(version, greaterThanOrEqualTo(814), reason: 'Flutter 3.47.8 builds fail on Gradle 8.13');
  });

  test('git does not ignore the wrapper properties', () {
    final result = Process.runSync('git', ['check-ignore', '-q', path]);
    expect(result.exitCode, isNot(0), reason: 'an ignored wrapper lets each machine drift to its own Gradle');
  });
}
