import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/widgets/liquid_glass_shader.dart';

/**
 * Pins the Dart uniform layout to shaders/liquid_glass.frag, the frosted fallback, and the fp16 range.
 *
 * The phone (Adreno 750, Impeller Vulkan) runs shaders at half precision even when highp is declared, and emulators
 * run fp32, so precision bugs only show here: every uniform and every geometric intermediate must stay small.
 */
void main() {
  final code = File('shaders/liquid_glass.frag').readAsStringSync().split('\n').where((l) => !l.trimLeft().startsWith('//')).join('\n');

  test('uniforms follow the shader order after the engine size, in units of the shorter side', () {
    const lens = LiquidLens(radius: 32, band: 5, refraction: 4, rimWidth: 1.25);
    final u = liquidGlassUniforms(const Size(358, 64), lens);
    expect(kLiquidGlassFirstUniform, 2);
    expect(u, hasLength(26));
    expect(u[0], closeTo(358 / 2 / 64, 1e-9)); // uHalf.x
    expect(u[1], closeTo(0.5, 1e-9)); // uHalf.y
    expect(u.sublist(2, 6), [32 / 64, 5 / 64, 4 / 64, 1.25 / 64]); // uShape
  });

  test('light theme switches on the darker edge cues; dark leaves them off', () {
    final dark = liquidGlassUniforms(const Size(72, 268), const LiquidLens(radius: 36));
    final light = liquidGlassUniforms(const Size(72, 268), const LiquidLens(radius: 36, lightTheme: true));
    expect(dark.sublist(18, 22), [0, 0.75 / 72, 0, 0]);
    expect(light.sublist(18, 22), [0.10, 0.75 / 72, 0.85, 1]);
  });

  test('uniforms are independent of devicePixelRatio and resolution: the same shape gives the same numbers', () {
    final a = liquidGlassUniforms(const Size(358, 64), const LiquidLens(radius: 32));
    final b = liquidGlassUniforms(const Size(716, 128), const LiquidLens(radius: 64, band: 10, refraction: 8, rimWidth: 2.5));
    for (var i = 0; i < 6; i++) {
      expect(a[i], closeTo(b[i], 1e-9));
    }
  });

  group('fp16 range', () {
    const fp16Precise = 32.0; // below this, fp16 resolves at least 1/64
    for (final box in const [Size(358, 64), Size(440, 64), Size(204, 48), Size(72, 268), Size(1200, 64)]) {
      test('all uniforms stay small for a ${box.width.toInt()} x ${box.height.toInt()} glass', () {
        final u = liquidGlassUniforms(box, LiquidLens(radius: box.shortestSide / 2));
        for (final v in u) {
          expect(v.abs(), lessThan(fp16Precise));
        }
        // The largest geometric intermediate is length(p) at a corner: |uHalf| plus the refraction offset.
        final corner = math.sqrt(u[0] * u[0] + u[1] * u[1]) + u[4];
        expect(corner, lessThan(fp16Precise));
      });
    }

    test('FlutterFragCoord is only ever divided by uSize, never scaled', () {
      final uses = RegExp(r'FlutterFragCoord\(\)[^;]*;').allMatches(code).map((m) => m.group(0)!).toList();
      expect(uses, hasLength(1));
      expect(uses.single.replaceAll(' ', ''), 'FlutterFragCoord().xy/uSize;');
    });

    test('no raw time or pixel-sized uniform', () {
      expect(code, isNot(contains('uTime')));
      expect(code, isNot(contains('uBox')));
    });
  });

  test('the shader declares the uniform blocks in Dart order, highp, and is registered', () {
    expect(code, contains('precision highp float;'));
    final order = [
      'uniform vec2 uSize',
      'uniform vec2 uHalf',
      'uniform vec4 uShape',
      'uniform vec4 uLight',
      'uniform vec4 uRimColor',
      'uniform vec4 uBody',
      'uniform vec4 uEdge',
      'uniform vec4 uFrost',
      'uniform sampler2D uTexture',
    ];
    var at = -1;
    for (final decl in order) {
      final i = code.indexOf(decl);
      expect(i, greaterThan(at), reason: decl);
      at = i;
    }
    expect(File('pubspec.yaml').readAsStringSync(), contains('shaders/liquid_glass.frag'));
  });

  test('without shader filter support the filter is the plain frosted blur', () {
    final f = LiquidGlassShader.filter(box: const Size(358, 64), lens: const LiquidLens(radius: 32), blurSigma: 14);
    expect(f, ImageFilter.blur(sigmaX: 14, sigmaY: 14));
  });
}
