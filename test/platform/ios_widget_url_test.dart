// home_widget's iOS plugin forwards a widget URL to Dart (initial launch and
// widgetClicked) only when it has a `homeWidget` query item. Without it a widget
// tap opened the app on its stored pointing instead of the one the widget showed.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS widget deep link carries the homeWidget query item', () {
    final swift = File('ios/PointerWidget/PointerWidget.swift').readAsStringSync();
    final urls = RegExp(r'URL\(string: "(dailypointer://[^"]*)"\)').allMatches(swift).map((m) => m.group(1)!).toList();
    expect(urls, isNotEmpty);
    for (final url in urls) {
      expect(Uri.parse(url.replaceAll(r'\(id)', 'x')).queryParameters.containsKey('homeWidget'), isTrue, reason: url);
    }
  });

  test('the app reads the pointing id from a widget URL with the query item', () {
    final uri = Uri.parse('dailypointer://pointing/ori-308?homeWidget');
    expect(uri.host, 'pointing');
    expect(uri.pathSegments.first, 'ori-308');
  });
}
