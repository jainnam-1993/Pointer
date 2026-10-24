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

import '../utils/frame_log.dart';

/** Build with `--dart-define=POINTER_LIQUID_LENS=false` to measure the glass without the lens (blur only). */
const bool kLiquidLens = bool.fromEnvironment('POINTER_LIQUID_LENS', defaultValue: true);

/**
 * Optical values for one glass shape, in logical px where a length is meant (CalmGlassBrief 3.3 and the main review of
 * 2026-10-24): a 1.25 px specular rim lit from the upper left, a 5 px bevel that bends and slightly darkens the
 * backdrop, a faint far-edge rim, a top inner shadow, and a saturation lift (vibrancy).
 */
@immutable
class LiquidLens {
  final double radius;
  final double band;
  final double refraction;
  final double rimWidth;
  final double rimLit;
  final double rimFar;
  final double fresnel;
  final double topInnerShadow;
  final Color rimColor;
  final double bevelDarken;
  final double saturation;
  final double bevelSaturation;

  /** Direction toward the light in screen space (y down): the upper left. */
  final Offset lightDir;

  /**
   * Light theme: the edge is drawn with darker cues (main review of 2026-10-24), a [hairline] of black at this alpha and
   * [hairlineWidth] px, the bevel multiply ([bevelDarken]), and a 1 px inner top [innerHighlight]. Dark keeps the
   * additive rim.
   */
  final bool lightTheme;

  final double hairline;

  final double hairlineWidth;

  final double innerHighlight;

  const LiquidLens({
    required this.radius,
    this.band = 5,
    this.refraction = 4,
    this.rimWidth = 1.25,
    this.rimLit = 0.9,
    this.rimFar = 0.35,
    this.fresnel = 0.10,
    this.topInnerShadow = 0.06,
    this.rimColor = const Color(0xFFFFFFFF),
    this.bevelDarken = 0.08,
    this.saturation = 1.18,
    this.bevelSaturation = 0.25,
    this.lightDir = const Offset(-0.6, -0.8),
    this.lightTheme = false,
    this.hairline = 0.10,
    this.hairlineWidth = 0.75,
    this.innerHighlight = 0.85,
  });
}

/**
 * The float uniforms after the engine's `uSize` (indices 0 and 1), in shader order: uHalf, uShape, uLight, uRimColor,
 * uBody, uEdge. Every length is divided by the box's shorter side, so the shader only sees values of a few units (fp16-safe on
 * the phone). Kept pure so tests can pin the layout and the range.
 */
List<double> liquidGlassUniforms(Size box, LiquidLens lens) {
  final unit = box.shortestSide <= 0 ? 1.0 : box.shortestSide;
  return [
    box.width / 2 / unit,
    box.height / 2 / unit,
    lens.radius / unit,
    lens.band / unit,
    lens.refraction / unit,
    lens.rimWidth / unit,
    lens.rimLit,
    lens.rimFar,
    lens.fresnel,
    lens.topInnerShadow,
    lens.rimColor.r,
    lens.rimColor.g,
    lens.rimColor.b,
    lens.bevelDarken,
    lens.saturation,
    lens.bevelSaturation,
    lens.lightDir.dx,
    lens.lightDir.dy,
    lens.lightTheme ? lens.hairline : 0,
    lens.hairlineWidth / unit,
    lens.lightTheme ? lens.innerHighlight : 0,
    lens.lightTheme ? 1 : 0,
  ];
}

/** First float index the app sets; 0 and 1 belong to the engine. */
const int kLiquidGlassFirstUniform = 2;

class LiquidGlassShader {
  static ui.FragmentProgram? _program;
  static Future<void>? _loading;

  /** Starts loading once; safe to call from every build. */
  static void ensureLoaded() {
    if (_program != null || _loading != null) return;
    FrameLog.ensureStarted();
    if (!kLiquidLens) {
      _loading = Future<void>.value();
      debugPrint('[LiquidGlass] path=fallback-blur reason=POINTER_LIQUID_LENS=false');
      return;
    }
    if (!ui.ImageFilter.isShaderFilterSupported) {
      _loading = Future<void>.value();
      debugPrint('[LiquidGlass] path=fallback-blur reason=shader filters unsupported (not Impeller)');
      return;
    }
    _loading = () async {
      try {
        _program = await ui.FragmentProgram.fromAsset('shaders/liquid_glass.frag');
        debugPrint('[LiquidGlass] path=lens (program loaded, ungrouped backdrop)');
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
  static ui.ImageFilter filter({required Size box, required LiquidLens lens, required double blurSigma}) =>
      ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);

  /**
   * The lens alone, for a second BackdropFilter inside the blurred one; null on the fallback path.
   *
   * Not composed with the blur: a blur's output is larger than its input by its kernel (and clipped at the screen
   * edge), so a shader composed after it gets a texture whose bounds are not the glass's, and on the emulator the rim
   * landed off the rail's top edge. Nested, the lens reads the already blurred backdrop at exactly its own bounds.
   * Each call makes its own FragmentShader, so no instance is shared across draws.
   */
  static ui.ImageFilter? lens({required Size box, required LiquidLens lens}) {
    final program = _program;
    if (program == null || !ui.ImageFilter.isShaderFilterSupported || box.isEmpty) return null;
    final shader = program.fragmentShader();
    final values = liquidGlassUniforms(box, lens);
    for (var i = 0; i < values.length; i++) {
      shader.setFloat(kLiquidGlassFirstUniform + i, values[i]);
    }
    return ui.ImageFilter.shader(shader);
  }
}
