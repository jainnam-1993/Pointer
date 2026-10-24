import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
    expect(body.indexOf('p -= kHashWrap * trunc(p / kHashWrap);'), lessThan(body.indexOf('fract(p *')), reason: 'the wrap must come before the scale');
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
}
