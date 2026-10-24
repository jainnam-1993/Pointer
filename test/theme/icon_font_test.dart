import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_icons.dart';

import '../helpers/app_fonts.dart';

/// Renders [icon] at 48 px and returns its RGBA bytes.
Future<Uint8List> _render(WidgetTester tester, IconData icon) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: Icon(icon, size: 48, color: const Color(0xFF000000)),
        ),
      ),
    ),
  );
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData();
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return bytes!;
}

/// A codepoint in a family that does not exist: what a missing icon font draws.
const _fallback = IconData(0xe2a8, fontFamily: 'NoSuchIconFont');

void main() {
  test('the icon and text fonts are declared in the packaged FontManifest (device builds)', () async {
    final families = await manifestFontFamilies();
    expect(
      families,
      containsAll(<String>['Inter', 'Newsreader', 'packages/phosphor_flutter/PhosphorLight', 'packages/phosphor_flutter/PhosphorRegular']),
    );
  });

  testWidgets('without loading the manifest fonts, icons render as the fallback box (the golden bug)', (tester) async {
    final fallback = await _render(tester, _fallback);
    expect(await _render(tester, AppIcons.heart), equals(fallback));
  });

  testWidgets('with the app fonts loaded, every AppIcons glyph renders (not the fallback) and the tip tiers differ', (tester) async {
    await tester.runAsync(loadAppFonts);
    final fallback = await _render(tester, _fallback);
    final images = <String, Uint8List>{};
    for (final MapEntry(key: name, value: icon) in AppIcons.all.entries) {
      final img = await _render(tester, icon);
      expect(img, isNot(equals(fallback)), reason: '$name renders the fallback glyph');
      expect(img.any((b) => b != 0), isTrue, reason: '$name renders nothing');
      images[name] = img;
    }
    final tips = ['tipTea', 'tipCushion', 'tipIncense', 'tipRetreat'];
    for (var i = 0; i < tips.length; i++) {
      for (var j = i + 1; j < tips.length; j++) {
        expect(images[tips[i]], isNot(equals(images[tips[j]])), reason: '${tips[i]} vs ${tips[j]}');
      }
    }
  });
}
