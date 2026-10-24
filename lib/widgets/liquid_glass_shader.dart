/**
 * Loads `shaders/liquid_glass.frag` and turns it into a backdrop filter: the lens, rim and fresnel of Liquid Glass over
 * the shell's one grouped blur.
 *
 * Falls back to the plain frosted blur when shader filters are unavailable (the Skia backend, widget tests) or before
 * the program has loaded. Uniforms are in logical pixels of the glass box, so they do not depend on devicePixelRatio.
 */
library;

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/** Optical values for one glass shape (CalmGlassBrief 3.3, layers 4, 6, 7 and 8). */
@immutable
class LiquidLens {
  final double radius;
  final double band;
  final double refraction;
  final double lightAngle;
  final double rimFacing;
  final double rimOpposite;
  final double fresnel;
  final double innerShadow;
  final Color rimColor;
  final double rimWidth;

  const LiquidLens({
    required this.radius,
    this.band = 9,
    this.refraction = 6,
    this.lightAngle = -2.0944, // -120 degrees: light from the upper left
    this.rimFacing = 0.55,
    this.rimOpposite = 0.22,
    this.fresnel = 0.14,
    this.innerShadow = 0.10,
    this.rimColor = const Color(0xFFFFF8F0),
    this.rimWidth = 1.25,
  });
}

/**
 * The float uniforms after the engine's `uSize` (indices 0 and 1), in shader order: uBox, uShape, uLight, uRimColor.
 * Kept pure so a unit test can pin the layout to the shader.
 */
List<double> liquidGlassUniforms(Size box, LiquidLens lens) => [
  box.width,
  box.height,
  lens.radius,
  lens.band,
  lens.refraction,
  lens.lightAngle,
  lens.rimFacing,
  lens.rimOpposite,
  lens.fresnel,
  lens.innerShadow,
  lens.rimColor.r,
  lens.rimColor.g,
  lens.rimColor.b,
  lens.rimWidth,
];

/** First float index the app sets; 0 and 1 belong to the engine. */
const int kLiquidGlassFirstUniform = 2;

class LiquidGlassShader {
  static ui.FragmentProgram? _program;
  static Future<void>? _loading;

  /** Starts loading once; safe to call from every build. */
  static void ensureLoaded() {
    if (_program != null || _loading != null || !ui.ImageFilter.isShaderFilterSupported) return;
    _loading = () async {
      try {
        _program = await ui.FragmentProgram.fromAsset('shaders/liquid_glass.frag');
      } catch (e) {
        debugPrint('[LiquidGlassShader] load failed, keeping the frosted fallback: $e');
      }
    }();
  }

  /** Whether the lens is drawing (and so draws the rim itself). */
  static bool get active => _program != null && ui.ImageFilter.isShaderFilterSupported;

  static Future<void> get loaded => _loading ?? Future<void>.value();

  /**
   * The backdrop filter for a glass box: lens over [blurSigma] when shaders are available, otherwise the blur alone.
   */
  static ui.ImageFilter filter({required Size box, required LiquidLens lens, required double blurSigma}) {
    final blur = ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);
    final program = _program;
    if (program == null || !ui.ImageFilter.isShaderFilterSupported || box.isEmpty) return blur;
    final shader = program.fragmentShader();
    final values = liquidGlassUniforms(box, lens);
    for (var i = 0; i < values.length; i++) {
      shader.setFloat(kLiquidGlassFirstUniform + i, values[i]);
    }
    return ui.ImageFilter.compose(outer: ui.ImageFilter.shader(shader), inner: blur);
  }
}
