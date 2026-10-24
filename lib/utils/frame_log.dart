/**
 * Opt-in frame timing log for device measurements: build with `--dart-define=POINTER_FRAME_LOG=true` and read logcat
 * for `[FrameLog]`. Every 5 s it prints the frame count and the mean and p90 raster (GPU thread) time. Off by default,
 * so release and normal profile builds pay nothing.
 */
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

const bool kFrameLog = bool.fromEnvironment('POINTER_FRAME_LOG');

class FrameLog {
  static bool _started = false;
  static final List<int> _raster = [];
  static DateTime _windowStart = DateTime.now();

  static void ensureStarted() {
    if (!kFrameLog || _started) return;
    _started = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
    _windowStart = DateTime.now();
    _tick();
  }

  static void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _raster.add(t.rasterDuration.inMicroseconds);
    }
  }

  static Future<void> _tick() async {
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 5));
      final secs = DateTime.now().difference(_windowStart).inMilliseconds / 1000;
      final xs = [..._raster]..sort();
      _raster.clear();
      _windowStart = DateTime.now();
      final mean = xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length / 1000;
      final p90 = xs.isEmpty ? 0 : xs[(xs.length * 0.9).floor().clamp(0, xs.length - 1)] / 1000;
      debugPrint(
        '[FrameLog] frames=${xs.length} seconds=${secs.toStringAsFixed(1)} rasterMeanMs=${mean.toStringAsFixed(2)} rasterP90Ms=${p90.toStringAsFixed(2)}',
      );
    }
  }
}
