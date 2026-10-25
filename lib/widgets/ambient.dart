import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/**
 * Ambient rendering engine: one shared clock, one fragment shader, and the
 * analytic frost that glass cards draw from the same shader.
 *
 * Battery model: the background animates at 30 fps (15 fps in Low Power Mode or
 * battery saver) from a Timer, never from a vsync Ticker, so 120 Hz scrolling
 * stays available while idle screens produce at most 30 frames per second.
 * Painters listen to [AmbientClock.instance] and repaint inside their own
 * RepaintBoundary; no widget rebuilds happen per frame.
 */

/** Seconds shown when motion is reduced or the clock is frozen for tests. */
const double kAmbientStillTime = 37.0;

/**
 * Shared ambient time source.
 *
 * Runs only while: someone listens, the app is resumed, no modal sheet covers
 * the shell ([cover]/[uncover]), and motion is not reduced ([setReduceMotion]).
 * Covered routes stop listening themselves through TickerMode, see
 * [AmbientBackground].
 */
class AmbientClock extends ChangeNotifier with WidgetsBindingObserver implements ValueListenable<double> {
  AmbientClock._();

  /** Process-wide clock shared by every ambient painter. */
  static final AmbientClock instance = AmbientClock._();

  /** Channel shared with the existing settings handler on Android and iOS. */
  static const MethodChannel powerChannel = MethodChannel('com.dailypointer/settings');

  /** When true the clock never starts (golden and widget tests). */
  static bool frozen = false;

  static const Duration _normalInterval = Duration(microseconds: 33333); // 30 fps
  static const Duration _lowPowerInterval = Duration(microseconds: 66667); // 15 fps

  final Stopwatch _stopwatch = Stopwatch();
  double _offset = kAmbientStillTime;
  Timer? _timer;
  int _listeners = 0;
  int _covers = 0;
  bool _resumed = true;
  bool _reduceMotion = false;
  bool _lowPower = false;
  bool _observing = false;

  @override
  double get value => _stopwatch.elapsedMicroseconds / 1e6 + _offset;

  /** Whether the clock is ticking now (exposed for tests and diagnostics). */
  bool get isRunning => _timer != null;

  /** Current frame interval: 30 fps normally, 15 fps in a power-saving mode. */
  Duration get interval => _lowPower ? _lowPowerInterval : _normalInterval;

  /** Number of modal surfaces (sheets, dialogs) currently covering the shell. */
  int get coverCount => _covers;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listeners++;
    _ensureObserving();
    _update();
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _listeners = math.max(0, _listeners - 1);
    _update();
  }

  /** Pauses the clock while a modal sheet or dialog is open. */
  void cover() {
    _covers++;
    _update();
  }

  /** Ends one [cover]. */
  void uncover() {
    _covers = math.max(0, _covers - 1);
    _update();
  }

  /** System or app-level reduce motion: hold a still frame. */
  void setReduceMotion(bool reduce) {
    if (_reduceMotion == reduce) return;
    _reduceMotion = reduce;
    if (reduce) {
      _stopwatch
        ..stop()
        ..reset();
      _offset = kAmbientStillTime;
      notifyListeners();
    }
    _update();
  }

  /** Test hook: forces the low-power frame rate without the platform channel. */
  @visibleForTesting
  void debugSetLowPower(bool lowPower) {
    _lowPower = lowPower;
    _restartTimer();
  }

  /** Test hook: resets all counters. */
  @visibleForTesting
  void debugReset() {
    _timer?.cancel();
    _timer = null;
    _covers = 0;
    _resumed = true;
    _reduceMotion = false;
    _lowPower = false;
    _stopwatch
      ..stop()
      ..reset();
    _offset = kAmbientStillTime;
  }

  void _ensureObserving() {
    if (_observing) return;
    _observing = true;
    WidgetsBinding.instance.addObserver(this);
    // The platforms push "lowPowerModeChanged" when battery saver or Low Power Mode
    // changes while the app stays resumed (quick settings, Control Center).
    powerChannel.setMethodCallHandler(_handlePowerCall);
    unawaited(_refreshPowerMode());
  }

  Future<void> _handlePowerCall(MethodCall call) async {
    if (call.method == 'lowPowerModeChanged' && call.arguments is bool) _setLowPower(call.arguments as bool);
  }

  void _setLowPower(bool lowPower) {
    if (frozen || lowPower == _lowPower) return;
    _lowPower = lowPower;
    _restartTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    if (_resumed) unawaited(_refreshPowerMode());
    _update();
  }

  // Native handlers in MainActivity.kt and AppDelegate.swift answer "isLowPowerMode";
  // missing handlers leave the 30 fps default.
  Future<void> _refreshPowerMode() async {
    if (frozen) return;
    try {
      _setLowPower(await powerChannel.invokeMethod<bool>('isLowPowerMode') ?? false);
    } on MissingPluginException {
      // Platform without the handler (tests, desktop): keep 30 fps.
    } on PlatformException {
      // Keep 30 fps.
    }
  }

  bool get _shouldRun => !frozen && _listeners > 0 && _covers == 0 && _resumed && !_reduceMotion;

  void _update() {
    if (_shouldRun) {
      if (_timer == null) {
        _stopwatch.start();
        _timer = Timer.periodic(interval, (_) => notifyListeners());
      }
    } else if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      _stopwatch.stop();
    }
  }

  void _restartTimer() {
    if (_timer == null) return;
    _timer!.cancel();
    _timer = Timer.periodic(interval, (_) => notifyListeners());
  }
}

/**
 * Pauses [AmbientClock] while a popup route (modal sheet, dialog) is on top.
 * Opaque page routes need no handling: the Navigator turns TickerMode off for
 * covered routes and [AmbientBackground] stops listening.
 */
class AmbientRouteObserver extends NavigatorObserver {
  final Set<Route<dynamic>> _covering = {};

  void _add(Route<dynamic>? route) {
    if (route is PopupRoute && _covering.add(route)) AmbientClock.instance.cover();
  }

  void _remove(Route<dynamic>? route) {
    if (route != null && _covering.remove(route)) AmbientClock.instance.uncover();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _remove(oldRoute);
    _add(newRoute);
  }
}

/** Colors for one time-of-day period and theme. */
@immutable
class AmbientPalette {
  final Color top;
  final Color mid;
  final Color bottom;
  final Color fieldA;
  final Color fieldB;
  final Color fieldC;

  /** Aurora field strength, 0 to 1. */
  final double aurora;

  /** Dust mote strength, 0 to 1. */
  final double motes;
  final bool isDark;

  const AmbientPalette({
    required this.top,
    required this.mid,
    required this.bottom,
    required this.fieldA,
    required this.fieldB,
    required this.fieldC,
    required this.aurora,
    required this.motes,
    required this.isDark,
  });

  /** This palette toned down for high contrast: a quieter aurora and fewer motes behind opaque cards. */
  AmbientPalette subdued() => AmbientPalette(
    top: top,
    mid: mid,
    bottom: bottom,
    fieldA: fieldA,
    fieldB: fieldB,
    fieldC: fieldC,
    aurora: aurora * 0.35,
    motes: motes * 0.35,
    isDark: isDark,
  );

  /** OLED: pure black, no aurora, no motes. */
  static const oled = AmbientPalette(
    top: Color(0xFF000000),
    mid: Color(0xFF000000),
    bottom: Color(0xFF000000),
    fieldA: Color(0xFF000000),
    fieldB: Color(0xFF000000),
    fieldC: Color(0xFF000000),
    aurora: 0,
    motes: 0,
    isDark: true,
  );

  /** Light mode: soft lavender and peach over a warm off-white. */
  // Light: "Sage and sand" (2026-10-24): warm off-white paper into pale sage, a faint warm-gold glow, no pink.
  static const light = AmbientPalette(
    top: Color(0xFFF6F1E6),
    mid: Color(0xFFF4EFE3),
    bottom: Color(0xFFE5ECE1),
    fieldA: Color(0xFFF3E2BF),
    fieldB: Color(0xFFF6EAD3),
    fieldC: Color(0xFFD2E1CE),
    aurora: 0.62,
    motes: 0.55,
    isDark: false,
  );

  /** Dark palettes keyed by period index (dawn..night), see TimeOfDayPeriod. */
  static const List<AmbientPalette> dark = [
    // dawn: amber and rose
    AmbientPalette(
      top: Color(0xFF15101A),
      mid: Color(0xFF130E14),
      bottom: Color(0xFF0B080B),
      fieldA: Color(0xFF6E3F5E),
      fieldB: Color(0xFF7A5030),
      fieldC: Color(0xFF41306E),
      aurora: 0.42,
      motes: 0.5,
      isDark: true,
    ),
    // morning: warm amber with teal
    AmbientPalette(
      top: Color(0xFF13110E),
      mid: Color(0xFF11100D),
      bottom: Color(0xFF0A0908),
      fieldA: Color(0xFF6A5230),
      fieldB: Color(0xFF24534F),
      fieldC: Color(0xFF5C3A48),
      aurora: 0.38,
      motes: 0.45,
      isDark: true,
    ),
    // midday: neutral with cool teal
    AmbientPalette(
      top: Color(0xFF101114),
      mid: Color(0xFF0D0E11),
      bottom: Color(0xFF08090B),
      fieldA: Color(0xFF235460),
      fieldB: Color(0xFF34407A),
      fieldC: Color(0xFF5E5034),
      aurora: 0.36,
      motes: 0.42,
      isDark: true,
    ),
    // afternoon: teal and indigo
    AmbientPalette(
      top: Color(0xFF0F1116),
      mid: Color(0xFF0D0F14),
      bottom: Color(0xFF08090C),
      fieldA: Color(0xFF245A66),
      fieldB: Color(0xFF353F86),
      fieldC: Color(0xFF66512E),
      aurora: 0.38,
      motes: 0.45,
      isDark: true,
    ),
    // dusk: rose, amber, violet
    AmbientPalette(
      top: Color(0xFF170E14),
      mid: Color(0xFF140C12),
      bottom: Color(0xFF0B0709),
      fieldA: Color(0xFF7A3550),
      fieldB: Color(0xFF7E4E28),
      fieldC: Color(0xFF46307A),
      aurora: 0.44,
      motes: 0.5,
      isDark: true,
    ),
    // evening: violet, indigo, rose
    AmbientPalette(
      top: Color(0xFF110E1E),
      mid: Color(0xFF0F0C1A),
      bottom: Color(0xFF09080F),
      fieldA: Color(0xFF4A3488),
      fieldB: Color(0xFF26467A),
      fieldC: Color(0xFF6A3658),
      aurora: 0.42,
      motes: 0.48,
      isDark: true,
    ),
    // night: indigo, teal, violet
    AmbientPalette(
      top: Color(0xFF0B0C1C),
      mid: Color(0xFF0A0B18),
      bottom: Color(0xFF06070D),
      fieldA: Color(0xFF34358A),
      fieldB: Color(0xFF1B5560),
      fieldC: Color(0xFF52327E),
      aurora: 0.40,
      motes: 0.45,
      isDark: true,
    ),
  ];
}

/** Loads and caches the ambient FragmentProgram; null means use the fallback. */
class AmbientShader {
  AmbientShader._();

  static const String assetKey = 'shaders/ambient.frag';
  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram?>? _loading;
  static bool _failed = false;

  /** Loaded program, or null while loading or after a load failure. */
  static ui.FragmentProgram? get program => _program;

  /** True after the program failed to load; painters use the gradient fallback. */
  static bool get failed => _failed;

  /** Test hook: force the fallback path. */
  @visibleForTesting
  static bool debugForceFallback = false;

  /** Starts (or joins) the program load. Safe to call repeatedly. */
  static Future<ui.FragmentProgram?> ensureLoaded() {
    if (_program != null) return SynchronousFuture(_program);
    return _loading ??= ui.FragmentProgram.fromAsset(assetKey).then<ui.FragmentProgram?>(
      (p) => _program = p,
      onError: (Object e) {
        _failed = true;
        debugPrint('[ambient] shader load failed, using gradient fallback: $e');
        return null;
      },
    );
  }

  /** Sets every uniform in the order declared in shaders/ambient.frag. */
  static void setUniforms(
    ui.FragmentShader s, {
    required Size size,
    required Offset origin,
    required Size screen,
    required double time,
    required double frost,
    required AmbientPalette palette,
  }) {
    var i = 0;
    void f(double v) => s.setFloat(i++, v);
    void c(Color color) {
      f(color.r);
      f(color.g);
      f(color.b);
    }

    f(size.width);
    f(size.height);
    f(origin.dx);
    f(origin.dy);
    f(screen.width);
    f(screen.height);
    f(frost);
    f(palette.aurora);
    f(palette.motes);
    f(palette.isDark ? 1 : 0);
    c(palette.top);
    c(palette.mid);
    c(palette.bottom);
    c(palette.fieldA);
    c(palette.fieldB);
    c(palette.fieldC);
    timeUniforms(time).forEach(f);
  }

  /** Period of the shader's hash lattice (kHashWrap in shaders/ambient.frag). */
  static const double hashWrap = 32;

  /**
   * The time-driven uniforms (indices 28-49), computed in fp64 and kept small.
   * GPUs that run the shader at fp16 resolve a raw clock of 300 s only to 0.25 s,
   * so motion would stall into steps as a session ages. Every value here is a
   * sine, a phase below 2 pi, or a lattice offset below [hashWrap], at any time.
   */
  static List<double> timeUniforms(double t) {
    double wrap(double v, double period) => v % period;
    final out = <double>[
      math.sin(t * 0.031),
      math.cos(t * 0.023),
      math.cos(t * 0.027 + 1.3),
      math.sin(t * 0.019 + 0.7),
      math.sin(t * 0.017 + 2.1),
      math.cos(t * 0.029 + 0.4),
      wrap(t * 0.021, hashWrap),
      wrap(t * 0.018, hashWrap),
      wrap(t * 0.012, hashWrap),
    ];
    for (var l = 0; l < 3; l++) {
      final scale = 9 - l * 2.5;
      final k = (1 + l * 0.8) * t * scale;
      for (final d in [0.006 * k, -0.012 * k]) {
        out.add(d - d.floorToDouble());
      }
      for (final d in [0.006 * k, -0.012 * k]) {
        out.add(wrap(d.floorToDouble(), hashWrap));
      }
    }
    out.add(wrap(t * 0.5, 2 * math.pi));
    return out;
  }
}

/**
 * Paints the ambient field into [rect] as seen from [origin] on a [screen]-sized
 * background, with the shader when available and a gradient otherwise.
 */
void paintAmbient(
  Canvas canvas,
  Rect rect, {
  required Offset origin,
  required Size screen,
  required double time,
  required double frost,
  required AmbientPalette palette,
  ui.FragmentShader? shader,
}) {
  final program = AmbientShader.debugForceFallback ? null : AmbientShader.program;
  if (program != null && shader != null) {
    AmbientShader.setUniforms(shader, size: rect.size, origin: Offset.zero, screen: screen, time: time, frost: frost, palette: palette);
    // Draw in a global-aligned local space (origin uniform 0) so the shader's
    // fragment coordinates mean the same thing for cards and the background.
    canvas.save();
    canvas.translate(rect.left - origin.dx, rect.top - origin.dy);
    canvas.drawRect(origin & rect.size, Paint()..shader = shader);
    canvas.restore();
    return;
  }
  _paintFallback(canvas, rect, origin: origin, screen: screen, time: time, frost: frost, palette: palette);
}

/** Gradient equivalent of the shader layout: base gradient plus three soft fields. */
void _paintFallback(
  Canvas canvas,
  Rect rect, {
  required Offset origin,
  required Size screen,
  required double time,
  required double frost,
  required AmbientPalette palette,
}) {
  canvas.save();
  canvas.clipRect(rect);
  // Work in screen space so cards line up with the background.
  canvas.translate(rect.left - origin.dx, rect.top - origin.dy);
  final full = Offset.zero & screen;
  canvas.drawRect(
    full,
    Paint()..shader = ui.Gradient.linear(full.topCenter, full.bottomCenter, [palette.top, palette.mid, palette.bottom], const [0, 0.5, 1]),
  );
  if (palette.aurora > 0) {
    final t = time;
    final w = screen.width;
    final h = screen.height;
    final spread = 1 + 0.4 * frost;
    final fields = <(Offset, Color, double)>[
      (Offset(w * (0.22 + 0.10 * math.sin(t * 0.031)), h * (0.20 + 0.06 * math.cos(t * 0.023))), palette.fieldA, 0.45),
      (Offset(w * (0.82 + 0.08 * math.cos(t * 0.027 + 1.3)), h * (0.50 + 0.08 * math.sin(t * 0.019 + 0.7))), palette.fieldB, 0.42),
      (Offset(w * (0.42 + 0.12 * math.sin(t * 0.017 + 2.1)), h * (0.88 + 0.05 * math.cos(t * 0.029 + 0.4))), palette.fieldC, 0.48),
    ];
    for (final (center, color, radius) in fields) {
      final r = h * radius * spread;
      canvas.drawCircle(
        center,
        r,
        Paint()..shader = ui.Gradient.radial(center, r, [color.withValues(alpha: palette.aurora * 0.9), color.withValues(alpha: 0)]),
      );
    }
  }
  if (frost > 0) {
    canvas.drawRect(full, Paint()..color = Colors.white.withValues(alpha: frost * (palette.isDark ? 0.035 : 0.12)));
  }
  canvas.restore();
}

class _AmbientBackgroundPainter extends CustomPainter {
  final AmbientPalette palette;
  final ValueListenable<double>? clock;
  final ui.FragmentShader? shader;

  _AmbientBackgroundPainter({required this.palette, required this.clock, required this.shader}) : super(repaint: clock);

  @override
  void paint(Canvas canvas, Size size) {
    paintAmbient(
      canvas,
      Offset.zero & size,
      origin: Offset.zero,
      screen: size,
      time: clock?.value ?? kAmbientStillTime,
      frost: 0,
      palette: palette,
      shader: shader,
    );
  }

  @override
  bool shouldRepaint(_AmbientBackgroundPainter old) => old.palette != palette || old.clock != clock || old.shader != shader;
}

/**
 * Full-screen ambient background. Listens to [AmbientClock] only while its
 * route is visible (TickerMode) and [animate] is true.
 */
class AmbientBackground extends StatefulWidget {
  final AmbientPalette palette;
  final bool animate;

  const AmbientBackground({super.key, required this.palette, required this.animate});

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> {
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _attachShader();
  }

  void _attachShader() {
    final program = AmbientShader.program;
    if (program != null) {
      _shader = program.fragmentShader();
      return;
    }
    if (AmbientShader.failed) return;
    AmbientShader.ensureLoaded().then((p) {
      if (mounted && p != null) setState(() => _shader = p.fragmentShader());
    });
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = TickerMode.valuesOf(context).enabled;
    final live = widget.animate && visible && widget.palette.aurora + widget.palette.motes > 0;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AmbientBackgroundPainter(palette: widget.palette, clock: live ? AmbientClock.instance : null, shader: _shader),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/**
 * Analytic frost: paints the ambient shader at this box's global position with
 * frost settings, standing in for a BackdropFilter over the ambient background.
 * [palette] and [animate] must match the background (see ambientPaletteFor).
 */
class AmbientFrost extends LeafRenderObjectWidget {
  final double frost;
  final AmbientPalette palette;
  final bool animate;

  const AmbientFrost({super.key, this.frost = 1, required this.palette, required this.animate});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAmbientFrost(
      frost: frost,
      palette: palette,
      animate: animate && TickerMode.valuesOf(context).enabled,
      screen: MediaQuery.sizeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAmbientFrost renderObject) {
    renderObject
      ..frost = frost
      ..palette = palette
      ..animate = animate && TickerMode.valuesOf(context).enabled
      ..screen = MediaQuery.sizeOf(context)
      ..scroll = Scrollable.maybeOf(context)?.position;
  }
}

/** Render object behind [AmbientFrost]; repaints on clock ticks only. */
class RenderAmbientFrost extends RenderBox {
  RenderAmbientFrost({required double frost, required AmbientPalette palette, required bool animate, required Size screen})
    : _frost = frost,
      _palette = palette,
      _animate = animate,
      _screen = screen;

  double _frost;
  AmbientPalette _palette;
  bool _animate;
  Size _screen;
  ui.FragmentShader? _shader;

  set frost(double v) {
    if (v == _frost) return;
    _frost = v;
    markNeedsPaint();
  }

  set palette(AmbientPalette v) {
    if (v == _palette) return;
    _palette = v;
    markNeedsPaint();
  }

  set screen(Size v) {
    if (v == _screen) return;
    _screen = v;
    markNeedsPaint();
  }

  Listenable? _scroll;

  /** Scroll position of the enclosing Scrollable: frost must follow the card while the clock is still. */
  set scroll(Listenable? v) {
    if (identical(v, _scroll)) return;
    if (attached) _scroll?.removeListener(markNeedsPaint);
    _scroll = v;
    if (attached) _scroll?.addListener(markNeedsPaint);
  }

  set animate(bool v) {
    if (v == _animate) return;
    _animate = v;
    if (attached) {
      v ? AmbientClock.instance.addListener(markNeedsPaint) : AmbientClock.instance.removeListener(markNeedsPaint);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (_animate) AmbientClock.instance.addListener(markNeedsPaint);
    _scroll?.addListener(markNeedsPaint);
    final program = AmbientShader.program;
    if (program != null) {
      _shader ??= program.fragmentShader();
    } else if (!AmbientShader.failed) {
      AmbientShader.ensureLoaded().then((p) {
        if (attached && p != null) {
          _shader ??= p.fragmentShader();
          markNeedsPaint();
        }
      });
    }
  }

  @override
  void detach() {
    if (_animate) AmbientClock.instance.removeListener(markNeedsPaint);
    _scroll?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return;
    final global = localToGlobal(Offset.zero);
    paintAmbient(
      context.canvas,
      offset & size,
      origin: global,
      screen: _screen,
      time: _animate ? AmbientClock.instance.value : kAmbientStillTime,
      frost: _frost,
      palette: _palette,
      shader: _shader,
    );
  }
}

/**
 * Declares that the subtree sits on an opaque surface that hides the ambient
 * background (a sheet body, dialog, opaque panel). Glass inside it draws the
 * plain glass material tuned for [surface] instead of sampling the shader.
 * Modal routes (sheets, dialogs) imply it automatically, see [suppressesFrost].
 */
class FrostScope extends InheritedWidget {
  /** Color of the opaque surface, when known. */
  final Color? surface;

  const FrostScope({super.key, this.surface, required super.child});

  static FrostScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<FrostScope>();

  /** True when glass at [context] must not sample the ambient background. */
  static bool suppressesFrost(BuildContext context) => maybeOf(context) != null || ModalRoute.of(context) is PopupRoute;

  @override
  bool updateShouldNotify(FrostScope old) => old.surface != surface;
}
