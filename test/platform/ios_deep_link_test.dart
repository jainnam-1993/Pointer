// Widget taps open dailypointer://pointing/<id>. home_widget hands that URL to
// main.dart; if Flutter's default deep linking is on (the default since 3.27),
// GoRouter also receives it, finds no route, and shows "Page Not Found".
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS Info.plist turns off Flutter deep linking', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(RegExp(r'<key>FlutterDeepLinkingEnabled</key>\s*<false/>').hasMatch(plist), isTrue, reason: 'GoRouter would receive dailypointer:// widget URLs');
  });
}
