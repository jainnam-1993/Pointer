// Idle-frame and scroll-jank probe for the ambient rendering engine.
//
// Counts frames the engine produces while Home sits idle for 10 s, and frames
// plus janky frames (build or raster over 16.7 ms) during a scripted Library
// scroll. Results go to the test driver's response data and stdout.
//
// Run on a device or emulator (not under `flutter test` on the host):
//   flutter test integration_test/idle_frames_test.dart -d <device>
// Pass criteria: idle Home <= 30 fps (<= 300 frames in 10 s, 15 fps budget in
// battery saver); Library scroll frame count and jank within noise of base 53b893d.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pointer/widgets/animated_gradient.dart';

import 'test_helpers.dart';

class _FrameCounter {
  final List<FrameTiming> timings = [];

  void _onTimings(List<FrameTiming> t) => timings.addAll(t);

  void start() {
    timings.clear();
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  Map<String, Object> stop(Duration window) {
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
    const budget = Duration(microseconds: 16667);
    final jank = timings.where((t) => t.buildDuration > budget || t.rasterDuration > budget).length;
    return {'frames': timings.length, 'fps': timings.length / (window.inMilliseconds / 1000), 'jank': jank};
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Let the app schedule its own frames; the test must not pump on its own.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;

  testWidgets('idle Home and Library scroll frame counts', (tester) async {
    // The ambient background is otherwise frozen under any test binding.
    AnimatedGradient.forceMotionInTests = true;
    addTearDown(() => AnimatedGradient.forceMotionInTests = false);
    await tester.pumpWidget(await createTestApp());
    await pumpAndSettle(tester, timeout: const Duration(seconds: 20));
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

    const idle = Duration(seconds: 10);
    final counter = _FrameCounter()..start();
    await Future<void>.delayed(idle);
    final home = counter.stop(idle);

    await tester.tap(find.text('Library').last);
    await Future<void>.delayed(const Duration(seconds: 2));

    final scrollable = find.byType(Scrollable).first;
    final sw = Stopwatch()..start();
    counter.start();
    for (var i = 0; i < 4; i++) {
      await tester.fling(scrollable, const Offset(0, -600), 2500);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      await tester.fling(scrollable, const Offset(0, 600), 2500);
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    final scroll = counter.stop(sw.elapsed);

    binding.reportData = {'idle_home': home, 'library_scroll': scroll};
    debugPrint('[idle-frames] idle_home=$home library_scroll=$scroll');
    expect(home['fps']! as double, lessThanOrEqualTo(31.0), reason: 'idle Home must stay at or below 30 fps');
  });
}
