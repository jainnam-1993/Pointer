/**
 * Glyph atlas warm-up for the screens a user opens first from Today (Settings, Library).
 *
 * Impeller draws text from a glyph atlas that holds each glyph at each (typeface, size, scale) once rasterised. The
 * first Settings open introduced dozens of new glyph runs over the ~330 ms sheet transition, so the atlas was rebuilt
 * and re-uploaded on 9 frames (CreateGlyphAtlas, UpdateAtlasBitmap, BlitPass encode), which backed up the GPU and
 * showed as 10 to 15 janky frames; later opens drew from the filled atlas with 0 janky frames (Perfetto, Pointer_UserFold,
 * a5ac8db). This paints the text styles those screens use, at the current text scale and pixel ratio, into an
 * offscreen image the size of the line after Today's first frame, one style per scheduler task between frames, so the atlas already holds them.
 */
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_theme.dart';

/** The glyphs Settings and Library draw (Latin copy, digits, the punctuation their rows use). */
const String _sample = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,:;·–—\'’"“”!?()/&%+-…';

/** Sans sizes and weights used by Settings rows, section headers, chips and Library cards and metadata. */
const List<double> _sansSizes = [11, AppType.caption, 13, AppType.callout, 15, AppType.body, AppType.headline, 20];
const List<FontWeight> _sansWeights = [FontWeight.w400, FontWeight.w500, FontWeight.w600];

/** The text styles to warm for [theme]: every style of its text theme plus the sans grid above. */
@visibleForTesting
List<TextStyle> glyphWarmupStyles(ThemeData theme) {
  final t = theme.textTheme;
  return [
    for (final s in [t.displayLarge, t.headlineMedium, t.titleLarge, t.titleMedium, t.bodyLarge, t.bodyMedium, t.labelSmall])
      if (s != null) s,
    for (final w in _sansWeights)
      for (final size in _sansSizes) TextStyle(fontFamily: AppFonts.sans, fontSize: size, fontWeight: w),
    const TextStyle(fontFamily: AppFonts.serif, fontSize: AppType.body),
    const TextStyle(fontFamily: AppFonts.serif, fontSize: AppType.headline),
  ];
}

/** Runs the warm-up once per (text scale, pixel ratio, brightness) after the first frame below it. */
class GlyphWarmup extends StatefulWidget {
  final Widget child;

  const GlyphWarmup({super.key, required this.child});

  /** Number of styles painted so far (tests). */
  @visibleForTesting
  static int painted = 0;

  @override
  State<GlyphWarmup> createState() => _GlyphWarmupState();
}

class _GlyphWarmupState extends State<GlyphWarmup> {
  Object? _done;
  int _generation = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scaler = MediaQuery.textScalerOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final theme = Theme.of(context);
    final key = (scaler.scale(100), dpr, theme.brightness);
    if (key == _done) return;
    _done = key;
    final generation = ++_generation;
    final styles = [for (final s in glyphWarmupStyles(theme)) s.copyWith(fontSize: scaler.scale(s.fontSize ?? AppType.body))];
    // Never before the first frame: cold start must not pay for it.
    SchedulerBinding.instance.addPostFrameCallback((_) => _paintNext(styles, 0, dpr, generation));
  }

  void _paintNext(List<TextStyle> styles, int i, double dpr, int generation) {
    if (!mounted || generation != _generation || i >= styles.length) return;
    SchedulerBinding.instance.scheduleTask<Future<void>>(
      () => _paint(styles[i], dpr).then<void>((_) => _paintNext(styles, i + 1, dpr, generation)),
      // Not Priority.idle: the default scheduling strategy runs only animation-priority tasks while any animation ticks,
      // and Today's ambient background always does, so idle tasks would never run.
      Priority.animation,
    );
  }

  /** One style per raster task, so no single frame pays for more than one atlas update. */
  static Future<void> _paint(TextStyle style, double dpr) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(dpr);
    final tp = TextPainter(
      text: TextSpan(text: _sample, style: style),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();
    // The image covers the whole line. With a 2x2 image (53f71de) Impeller culled the text run, whose glyph bounds start
    // a few pixels below the top, so the 33 snapshots rasterised no glyph at all (no CreateGlyphAtlas inside them).
    tp.paint(canvas, Offset.zero);
    final width = (tp.width * dpr).ceil().clamp(1, 4096), height = (tp.height * dpr).ceil().clamp(1, 512);
    tp.dispose();
    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(width, height);
      image.dispose();
    } finally {
      picture.dispose();
    }
    GlyphWarmup.painted++;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
