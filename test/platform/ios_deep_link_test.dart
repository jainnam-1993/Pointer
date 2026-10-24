// Widget taps open dailypointer://pointing/<id>. home_widget hands that URL to
// main.dart; if Flutter's default deep linking is on (the default since 3.27),
// GoRouter also receives it, finds no route, and shows "Page Not Found".
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  _widgetUrlTests();

  test('iOS Info.plist turns off Flutter deep linking', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(
      RegExp(r'<key>FlutterDeepLinkingEnabled</key>\s*<false/>').hasMatch(plist),
      isTrue,
      reason: 'GoRouter would receive dailypointer:// widget URLs',
    );
  });
}

/** The URL template PointerWidget.swift builds for a widget tap, with `\(id)` in place. */
String _swiftWidgetUrlTemplate() {
  final swift = File('ios/PointerWidget/PointerWidget.swift').readAsStringSync();
  final match = RegExp(r'URL\(string: "(dailypointer://pointing/[^"]*)"\)').firstMatch(swift);
  expect(match, isNotNull, reason: 'PointerWidget.swift no longer builds a dailypointer://pointing URL');
  return match!.group(1)!;
}

void _widgetUrlTests() {
  test('iOS widget URL carries the homeWidget marker home_widget requires', () {
    final uri = Uri.parse(_swiftWidgetUrlTemplate().replaceAll(r'\(id)', 'adv-337'));
    expect(
      uri.queryParameters.containsKey('homeWidget'),
      isTrue,
      reason: 'home_widget ignores URLs without ?homeWidget, so taps never reach main.dart',
    );
  });

  test('main.dart reads the pointing id from the widget URL with the marker present', () {
    // Same rule as _drainPendingWidgetUri: host "pointing", first path segment is the id.
    final uri = Uri.parse(_swiftWidgetUrlTemplate().replaceAll(r'\(id)', 'adv-337'));
    expect(uri.host, 'pointing');
    expect(uri.pathSegments.first, 'adv-337');
  });
}
