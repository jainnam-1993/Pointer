import 'dart:io';

import 'dart:ui' show ImageFilter;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/widgets/liquid_glass_shader.dart';

/** Pins the Dart uniform layout to shaders/liquid_glass.frag, and the frosted fallback. */
void main() {
  test('uniforms follow the shader order after the engine size, in logical px', () {
    const lens = LiquidLens(radius: 32, band: 9, refraction: 6, lightAngle: -2, rimFacing: 0.55, rimOpposite: 0.22, rimColor: Color(0xFFFFFFFF));
    final u = liquidGlassUniforms(const Size(358, 64), lens);
    expect(kLiquidGlassFirstUniform, 2);
    expect(u, hasLength(14));
    expect(u.sublist(0, 2), [358, 64]); // uBox
    expect(u.sublist(2, 6), [32, 9, 6, -2]); // uShape
    expect(u.sublist(6, 10), [0.55, 0.22, 0.14, 0.10]); // uLight
    expect(u.sublist(10, 14), [1, 1, 1, 1.25]); // uRimColor
  });

  test('uniforms do not scale with devicePixelRatio: the box is logical', () {
    final a = liquidGlassUniforms(const Size(358, 64), const LiquidLens(radius: 32));
    expect(a.first, 358);
  });

  test('the shader declares the same uniform blocks, highp, and is registered', () {
    final src = File('shaders/liquid_glass.frag').readAsStringSync();
    expect(src, contains('precision highp float;'));
    final order = [
      'uniform vec2 uSize',
      'uniform vec2 uBox',
      'uniform vec4 uShape',
      'uniform vec4 uLight',
      'uniform vec4 uRimColor',
      'uniform sampler2D uTexture',
    ];
    var at = -1;
    for (final decl in order) {
      final i = src.indexOf(decl);
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
