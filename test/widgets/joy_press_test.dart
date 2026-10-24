import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/utils/motion.dart';
import 'package:pointer/widgets/joy_press.dart';

/** Joy-motion spec 4.1 acceptance: press 0.96 on Motion.press, release on Motion.settle with no overshoot, cancel slop,
 * hover lift, Reduce Motion fallback. */
void main() {
  Future<int Function()> pump(WidgetTester tester, {bool reduce = false}) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduce),
          child: Center(
            child: JoyPress(haptic: null, onTap: () => taps++, child: const SizedBox(width: 200, height: 56)),
          ),
        ),
      ),
    );
    return () => taps;
  }

  double scaleOf(WidgetTester tester) {
    final t = find.descendant(of: find.byType(JoyPress), matching: find.byType(Transform));
    return t.evaluate().isEmpty ? 1 : tester.widget<Transform>(t.first).transform.entry(0, 0);
  }

  testWidgets('press sinks to 0.96, about 85% of the way by 300 ms; release returns with no overshoot', (tester) async {
    final taps = await pump(tester);
    final g = await tester.startGesture(tester.getCenter(find.byType(JoyPress)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final at300 = scaleOf(tester);
    expect((1 - at300) / (1 - Motion.pressScale), inInclusiveRange(0.75, 0.95));
    await tester.pump(const Duration(milliseconds: 500));
    expect(scaleOf(tester), closeTo(Motion.pressScale, 0.002));
    await g.up();
    var maxScale = 0.0;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      maxScale = scaleOf(tester) > maxScale ? scaleOf(tester) : maxScale;
    }
    expect(maxScale, lessThanOrEqualTo(1.0 + 1e-6), reason: 'release never overshoots');
    expect(scaleOf(tester), closeTo(1, 0.002));
    expect(taps(), 1);
  });

  testWidgets('moving more than 10 pt after down cancels the tap', (tester) async {
    final taps = await pump(tester);
    final g = await tester.startGesture(tester.getCenter(find.byType(JoyPress)));
    await tester.pump(const Duration(milliseconds: 50));
    await g.moveBy(const Offset(0, 14));
    await g.up();
    await tester.pumpAndSettle();
    expect(taps(), 0);
  });

  testWidgets('hover lifts gently and never presses', (tester) async {
    await pump(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(JoyPress)));
    await tester.pumpAndSettle();
    expect(scaleOf(tester), closeTo(JoyPress.hoverScale, 0.002));
    await mouse.moveTo(const Offset(1, 1));
    await tester.pumpAndSettle();
    expect(scaleOf(tester), closeTo(1, 0.002));
    await mouse.removePointer();
  });

  testWidgets('Reduce Motion: no scale; press dims, release restores', (tester) async {
    final taps = await pump(tester, reduce: true);
    final g = await tester.startGesture(tester.getCenter(find.byType(JoyPress)));
    await tester.pump();
    expect(find.descendant(of: find.byType(JoyPress), matching: find.byType(Transform)), findsNothing);
    final o = tester.widget<Opacity>(find.descendant(of: find.byType(JoyPress), matching: find.byType(Opacity)).first);
    expect(o.opacity, closeTo(0.85, 0.001));
    await g.up();
    await tester.pump();
    expect(tester.widget<Opacity>(find.descendant(of: find.byType(JoyPress), matching: find.byType(Opacity)).first).opacity, 1);
    expect(taps(), 1);
  });
}
