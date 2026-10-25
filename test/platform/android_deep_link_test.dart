// Android twin of ios_deep_link_test. Widget taps reach MainActivity with the pointing id as an Intent extra
// (WidgetRenderer.EXTRA_POINTING_ID), and main.dart offers dailypointer://pointing/<id> itself. If an activity also
// accepted a VIEW intent with a data URI while Flutter deep linking is on (the default since 3.27), the embedding
// would push that URI into GoRouter, which finds no route and shows "Page Not Found".
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  final deepLinking = RegExp(r'android:name="flutter_deeplinking_enabled"\s+android:value="(\w+)"').firstMatch(manifest)?.group(1);

  test('Android manifest never turns Flutter deep linking on', () {
    expect(deepLinking, isNot('true'), reason: 'GoRouter would receive dailypointer:// widget URLs');
  });

  test('an activity that accepts VIEW URLs must turn Flutter deep linking off', () {
    final filters = RegExp(r'<intent-filter[^>]*>(.*?)</intent-filter>', dotAll: true).allMatches(manifest).map((m) => m.group(1)!);
    final viewWithData = filters.where((f) => f.contains('android.intent.action.VIEW') && f.contains('android:scheme'));
    if (viewWithData.isEmpty) return;
    expect(deepLinking, 'false', reason: 'an intent-filter accepts VIEW URLs, so flutter_deeplinking_enabled must be "false"');
  });
}
