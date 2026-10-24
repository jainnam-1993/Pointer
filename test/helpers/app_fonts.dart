import 'dart:convert';

import 'package:flutter/services.dart';

bool _loaded = false;

/// Loads every font family the app bundles, exactly as packaged.
///
/// flutter_test does not load FontManifest.json fonts on its own, so without
/// this every glyph from a bundled or package font (Inter, Newsreader, the
/// Phosphor icon fonts, Material Icons) renders as the test font's box.
/// Reading the manifest (rather than listing files) means a new font asset is
/// picked up automatically, and a font missing from the manifest stays visibly
/// broken in goldens, as it would be on a device.
Future<void> loadAppFonts() async {
  if (_loaded) return;
  final manifest = (jsonDecode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>).cast<Map<String, dynamic>>();
  for (final entry in manifest) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  _loaded = true;
}

/// Family names declared in the packaged FontManifest.json.
Future<Set<String>> manifestFontFamilies() async {
  final manifest = (jsonDecode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>).cast<Map<String, dynamic>>();
  return {for (final e in manifest) e['family'] as String};
}
