import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/screens/home_screen.dart' show BalancedText;

import '../helpers/app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  // The store panel's case: a quote whose natural wrap leaves "you." alone.
  const quote = 'What you are looking for is what is looking. There is nothing to find, because it was never apart from you.';

  for (final width in [240.0, 280.0, 320.0, 360.0, 420.0, 520.0]) {
    testWidgets('no lone word on the last line at $width dp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              child: const BalancedText(quote, style: TextStyle(fontFamily: 'Newsreader', fontSize: 28)),
            ),
          ),
        ),
      );
      final paragraph = tester.renderObject<RenderParagraph>(find.descendant(of: find.byType(BalancedText), matching: find.byType(RichText)));
      final boxes = paragraph.getBoxesForSelection(const TextSelection(baseOffset: 0, extentOffset: quote.length));
      final lastTop = boxes.map((b) => b.top).reduce((a, b) => a > b ? a : b);
      final lastLine = boxes.where((b) => b.top == lastTop).toList();
      final lastStart = paragraph.getPositionForOffset(Offset(lastLine.first.left + 1, lastTop + 1)).offset;
      expect(quote.substring(lastStart).trim().contains(' '), isTrue, reason: 'last line "${quote.substring(lastStart)}" at $width dp');
    });
  }
}
