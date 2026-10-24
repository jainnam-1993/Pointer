import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/layout/tab_crossfade.dart';
import 'package:pointer/utils/motion.dart';

/** Tab switches cross-fade without a flash or a layout jump, and only the current tab takes input. */
void main() {
  Future<void> pump(WidgetTester tester, int index, {bool reduce = false}) => tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduce),
        child: TabCrossFadeContainer(
          currentIndex: index,
          children: [for (var i = 0; i < 3; i++) Center(child: Text('tab $i'))],
        ),
      ),
    ),
  );

  double opacityOf(WidgetTester tester, String text) {
    final o = find.ancestor(of: find.text(text), matching: find.byType(Opacity));
    return o.evaluate().isEmpty ? 1 : tester.widget<Opacity>(o.first).opacity;
  }

  testWidgets('both tabs are on screen mid-switch, fading in opposite directions; then only the new one', (tester) async {
    await pump(tester, 0);
    expect(find.text('tab 0'), findsOneWidget);
    expect(find.text('tab 1'), findsNothing); // offstage
    await pump(tester, 1);
    await tester.pump(Motion.quick ~/ 2);
    final a = opacityOf(tester, 'tab 0');
    final b = opacityOf(tester, 'tab 1');
    expect(a, inExclusiveRange(0, 1));
    expect(b, inExclusiveRange(0, 1));
    expect(a + b, closeTo(1, 0.35), reason: 'a cross-fade, not a dip to the background');
    await tester.pumpAndSettle();
    expect(find.text('tab 0'), findsNothing);
    expect(find.text('tab 1'), findsOneWidget);
    expect(opacityOf(tester, 'tab 1'), 1);
  });

  testWidgets('no layout jump: the incoming tab keeps its position (scale is centred)', (tester) async {
    await pump(tester, 0);
    await pump(tester, 2);
    await tester.pump(Motion.quick ~/ 2);
    final mid = tester.getCenter(find.text('tab 2'));
    await tester.pumpAndSettle();
    expect(tester.getCenter(find.text('tab 2')), offsetMoreOrLessEquals(mid, epsilon: 0.5));
  });

  testWidgets('Reduce Motion keeps the fade but drops the scale', (tester) async {
    await pump(tester, 0, reduce: true);
    await pump(tester, 1, reduce: true);
    await tester.pump(Motion.quick ~/ 2);
    expect(find.ancestor(of: find.text('tab 1'), matching: find.byType(Transform)), findsNothing);
    expect(opacityOf(tester, 'tab 1'), inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
  });

  testWidgets('the outgoing tab ignores taps while it fades', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: TabCrossFadeContainer(
          currentIndex: 0,
          children: [
            GestureDetector(onTap: () => taps++, child: const SizedBox.expand()),
            const SizedBox.expand(),
          ],
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TabCrossFadeContainer(
          currentIndex: 1,
          children: [
            GestureDetector(onTap: () => taps++, child: const SizedBox.expand()),
            const SizedBox.expand(),
          ],
        ),
      ),
    );
    await tester.pump(Motion.quick ~/ 2);
    await tester.tapAt(const Offset(100, 100));
    await tester.pumpAndSettle();
    expect(taps, 0);
  });
}
