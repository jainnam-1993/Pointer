import 'dart:io';

import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/widgets/ambient.dart';

/**
 * Regression for the black background on the vivo V2330 (Adreno 750, Impeller
 * on Vulkan). The GPU ran shaders/ambient.frag at half precision, hash() scaled
 * raw fragment coordinates past fp16's largest finite value, and every pixel
 * beyond 531 x 144 logical px painted black. The emulator runs in fp32, so only
 * a source check catches it on the devdesk: every hash() intermediate must stay
 * finite in fp16 for any input.
 */
void main() {
  const fp16Max = 65504.0;
  final source = File('shaders/ambient.frag').readAsStringSync();
  final code = source.split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

  final scale = RegExp(r'p\s*=\s*fract\(p\s*\*\s*vec2\(([\d.]+),\s*([\d.]+)\)\)').firstMatch(code);
  final wrap = RegExp(r'const float kHashWrap\s*=\s*([\d.]+);').firstMatch(code);
  final mix = RegExp(r'p\s*\+=\s*dot\(p,\s*p\s*\+\s*([\d.]+)\)').firstMatch(code);

  test('hash() wraps its input before scaling', () {
    expect(scale, isNotNull, reason: 'hash() scale factors changed; recheck the fp16 range argument');
    expect(wrap, isNotNull);
    expect(mix, isNotNull);
    final body = code.substring(code.indexOf('float hash(vec2 p)'), code.indexOf('float noise('));
    expect(body.indexOf('p = mod(p, kHashWrap);'), lessThan(body.indexOf('fract(p *')), reason: 'the wrap must come before the scale');
    expect(double.parse(wrap!.group(1)!), AmbientShader.hashWrap, reason: 'Dart wraps lattice offsets with the same period');
  });

  test('every hash() intermediate is finite in fp16', () {
    final kx = double.parse(scale!.group(1)!);
    final ky = double.parse(scale.group(2)!);
    final w = double.parse(wrap!.group(1)!);
    final c = double.parse(mix!.group(1)!);
    expect(w * kx, lessThan(fp16Max));
    expect(w * ky, lessThan(fp16Max));
    // After fract, p is in [0, 1): p += dot(p, p + c) <= 1 + 2 * (1 + c), then p.x * p.y.
    final afterMix = 1 + 2 * (1 + c);
    expect(afterMix * afterMix, lessThan(fp16Max));
  });

  test('the old unwrapped hash overflowed exactly where the phone went black', () {
    final kx = double.parse(scale!.group(1)!);
    // The light patch in the user's screenshot ended at physical x = 1433 on a DPR 2.7 display.
    expect((fp16Max / kx * 2.7).floor(), 1433);
  });

  test('the shader takes no raw time uniform', () {
    expect(RegExp(r'uniform float uTime').hasMatch(code), isFalse);
  });

  group('time uniforms', () {
    // Values that a fp16 GPU resolves to at least 1/64: magnitudes below 32.
    for (final t in [37.0, 300.0, 3600.0, 86400.0, 7 * 86400.0]) {
      test('stay small at t = $t s', () {
        final u = AmbientShader.timeUniforms(t);
        expect(u, hasLength(22));
        for (final v in u) {
          expect(v.abs(), lessThan(AmbientShader.hashWrap));
        }
      });
    }

    test('advance every frame and wrap only by whole periods, even after a week', () {
      const t = 7 * 86400.0 + 0.5;
      final a = AmbientShader.timeUniforms(t);
      final b = AmbientShader.timeUniforms(t + 1 / 30);
      var moved = 0;
      for (var i = 0; i < a.length; i++) {
        final d = b[i] - a[i];
        if (d.abs() > 1e-9) moved++;
        final period = i == a.length - 1 ? 2 * math.pi : AmbientShader.hashWrap;
        // Lattice ids (floor parts) step by whole cells; everything else moves a little or wraps by a whole period.
        final rem = (d.abs() % period);
        expect(rem < 0.05 || period - rem < 0.05 || (d - d.roundToDouble()).abs() < 1e-9, isTrue, reason: 'uniform $i jumped by $d');
      }
      expect(moved, greaterThanOrEqualTo(15), reason: 'the field should be moving');
    });
  });
}
