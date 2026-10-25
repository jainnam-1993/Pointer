/**
 * The tab bar and rail as a solid dark capsule with a raised glass lens over the selected tab, after the reference at
 * liquidglassdesign.com/gallery/liquid-glass-ui-tab-navigation (design/target-tabnav/target.png).
 *
 * - The capsule is opaque near-black with a wide soft shadow, so it needs no backdrop read.
 * - The lens is a rounded square about 1.3x the bar's thickness that overflows it on both sides. It refracts what is
 *   behind it through liquid_glass.frag: the bar's edge bends into crescents and the background shows through,
 *   magnified, where the lens passes the bar. A thin bright rim with a little colour split closes it.
 * - Inactive tabs are filled grey icons without labels; the active tab is a white glowing icon with its label, carried
 *   by the lens.
 * - The lens travels on Motion.lensMove and stretches along its motion; under Reduce Motion it moves without travel.
 */
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../services/reduce_transparency.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';
import 'liquid_glass_nav.dart' show liquidStretch;
import 'liquid_glass_shader.dart';

/** One tab: its filled icon and label. */
typedef LensTab = (IconData icon, String label);

/** Colours and sizes of the lens tab bar (one place, so the design can be tuned against the reference). */
abstract final class LensTabStyle {
  static const Color capsule = Color(0xFF0B0B0C);

  /** Dark theme: a slightly lifted capsule and a light hairline, so the bar reads as an object on a dark field. */
  static const Color capsuleDark = Color(0xFF161618);
  static const Color hairlineDark = Color(0x29FFFFFF);

  /** High contrast: no glass; a solid bar and pill with clear borders. */
  static const Color hcBorder = Color(0xB3FFFFFF);
  static const Color hcPill = Color(0xFF2C2C30);

  /** The lens body where the shader is unavailable (and its tint everywhere): a faint clear white. */
  static const Color lensFallbackFill = Color(0x1FFFFFFF);
  static const Color inactive = Color(0xFF6E6E73);
  static const Color active = Color(0xFFFFFFFF);

  /** The lens is this much thicker than the bar (it overflows on both sides). */
  static const double lensThickness = 1.4;

  /** Lens width as a share of a cell, capped by [lensAspect] times its thickness. */
  static const double lensCellShare = 1.15;
  static const double lensAspect = 1.25;

  /** Corner radius of the lens as a share of its shorter side (a soft rounded square). */
  static const double lensRadius = 0.42;

  /** One soft, wide drop shadow (about 22% black, 32 px blur, 8 px down), never a hard band. */
  static const List<BoxShadow> capsuleShadow = [BoxShadow(color: Color(0x38000000), blurRadius: 32, offset: Offset(0, 8))];

  /** Lens bevel and refraction as shares of its shorter side. The rim samples inward by about the overhang, so the edge shows a dark rim and
   * the overhang shows the background as bright crescents. */
  static const double lensBand = 0.16;
  static const double lensRefraction = 0.03;

  static const List<Shadow> activeGlow = [Shadow(color: Color(0x99FFFFFF), blurRadius: 12)];
}

class LensTabBar extends StatefulWidget {
  final List<LensTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Axis axis;
  final bool minimized;

  const LensTabBar({super.key, required this.tabs, required this.currentIndex, required this.onTap, required this.axis, this.minimized = false});

  /** Main-axis padding inside the capsule. */
  static const double pad = 8;

  /** Width of the minimized bar for [count] tabs. */
  static double minimizedWidth(int count) => count * LiquidGlass.minimizedCell + 2 * pad;

  @override
  State<LensTabBar> createState() => _LensTabBarState();
}

/**
 * Tab lens state machine, after the native iOS 27 tab bar (findings/joy-motion-spec.md, "Tab lens state machine",
 * recorded on the Studio simulator: visual/liquid-glass/state-machine/).
 *
 * - rest: the selected tab sits on a flat, tinted pill. No lens, no refraction, no magnification.
 * - pressed: on touch-down the pill lifts into the liquid lens (scale [Motion.lensLiftX] x [Motion.lensLiftY], refraction,
 *   content magnified [Motion.lensMagnify]) at the touched tab on the raw pointer-down, reaching full scale in about 100 ms ([Motion.lensFlatten]).
 * - dragging: the lens follows the finger 1:1 across the tabs.
 * - settling: on release the tab under the finger is selected; the lens springs to it on [Motion.lensMove] while it
 *   flattens back to the rest pill on [Motion.lensFlatten] (about 110 ms, no overshoot), as native does.
 * Reduce Motion: no lift or lens; the pill moves to the new tab without travel.
 */
enum LensPhase { rest, pressed, dragging, settling }

class _LensTabBarState extends State<LensTabBar> with TickerProviderStateMixin {
  /** Lens position in cell units (0 = first tab). */
  late final AnimationController _pos = AnimationController.unbounded(vsync: this, value: widget.currentIndex.toDouble());

  /** 0 = flat rest pill, 1 = lifted lens. */
  late final AnimationController _lift = AnimationController.unbounded(vsync: this);

  LensPhase phase = LensPhase.rest;
  double _cell = 1;

  @override
  void initState() {
    super.initState();
    LiquidGlassShader.ensureLoaded();
    LiquidGlassShader.loaded.then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(LensTabBar old) {
    super.didUpdateWidget(old);
    // Selection changed from outside (swipe between tabs, deep link): move the pill without lifting it.
    if (old.currentIndex != widget.currentIndex && phase == LensPhase.rest) _moveTo(widget.currentIndex.toDouble());
  }

  @override
  void dispose() {
    _pos.dispose();
    _lift.dispose();
    super.dispose();
  }

  bool get _reduce => Motion.reduce(context);

  void _moveTo(double target) {
    if (_reduce) {
      _pos.value = target;
      return;
    }
    _pos.animateWith(SpringSimulation(Motion.lensMove, _pos.value, target, _pos.velocity));
  }

  void _liftTo(double v, SpringDescription spring) {
    if (_reduce) {
      _lift.value = 0;
      return;
    }
    // Springs end within their tolerance of the target; snap so rest is exactly flat (scale 1.0, no lens).
    _lift.animateWith(SpringSimulation(spring, _lift.value, v, _lift.velocity)).whenComplete(() {
      if (mounted && !_lift.isAnimating && phase == LensPhase.rest && v == 0) _lift.value = 0;
    });
  }

  double _cellAt(double mainOffset) => ((mainOffset - LensTabBar.pad) / _cell - 0.5).clamp(0.0, widget.tabs.length - 1.0);

  /** The tab under the finger at touch-down: what a tap without a drag selects. */
  int _touched = 0;

  void _down(Offset local) {
    phase = LensPhase.pressed;
    final at = _cellAt(widget.axis == Axis.horizontal ? local.dx : local.dy);
    _touched = at.round();
    _liftTo(1, Motion.lensFlatten);
    _moveTo(at);
  }

  /** The finger's last position along the bar, in cell units: what a release selects. */
  double _finger = 0;

  void _drag(Offset local) {
    // A drag can win the gesture arena before the tap's touch-down fires (the finger moved past the slop within
    // 100 ms), so a drag from rest lifts the lens itself.
    if (phase == LensPhase.rest || phase == LensPhase.settling) _liftTo(1, Motion.lensFlatten);
    phase = LensPhase.dragging;
    _finger = _cellAt(widget.axis == Axis.horizontal ? local.dx : local.dy);
    _pos.stop();
    _pos.value = _finger; // follows the finger 1:1
  }

  /**
   * Release selects the tab under the finger where it lifted ([at], from the gesture's own end details), never the
   * lens's animated position, which can lag a fast flick. The lens then moves to the selection on [Motion.lensMove] while
   * it flattens in parallel on [Motion.lensFlatten] (about 110 ms, like native), with no overshoot.
   */
  void _release({Offset? at}) {
    if (phase == LensPhase.rest) return;
    if (at != null) _finger = _cellAt(widget.axis == Axis.horizontal ? at.dx : at.dy);
    final i = (phase == LensPhase.dragging ? _finger.round() : _touched).clamp(0, widget.tabs.length - 1);
    phase = LensPhase.rest;
    if (i != widget.currentIndex) Haptics.selection();
    widget.onTap(i);
    if (_reduce) {
      _pos.value = i.toDouble();
      _lift.value = 0;
      return;
    }
    _pos.animateWith(SpringSimulation(Motion.lensMove, _pos.value, i.toDouble(), _pos.velocity));
    _liftTo(0, Motion.lensFlatten);
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = widget.axis == Axis.horizontal;
    final plain = ReduceTransparency.of(context);
    final reduce = _reduce;
    return LayoutBuilder(
      builder: (context, c) {
        final n = widget.tabs.length;
        final thickness = horizontal ? (widget.minimized ? LiquidGlass.barMinimizedHeight : LiquidGlass.barHeight) : LiquidGlass.railWidth;
        final extent = horizontal
            ? (widget.minimized ? LensTabBar.minimizedWidth(n) : c.maxWidth)
            : n * LiquidGlass.railCellHeight + 2 * LensTabBar.pad;
        final cell = (extent - 2 * LensTabBar.pad) / n;
        _cell = cell;
        final showLabel = !(horizontal && widget.minimized);
        final dark = Theme.of(context).brightness == Brightness.dark;
        final highContrast = GlassMaterial.of(context).opaque;
        final style = LensBarLook.of(dark: dark, highContrast: highContrast);

        // Rest pill: flat and tinted, inset from the capsule.
        final pillMain = cell - LiquidGlass.pillCellGap;
        final pillCross = thickness - 2 * LiquidGlass.pillInset;
        // Lens: the pill lifted.
        final lensMain = pillMain * Motion.lensLiftX;
        final lensCross = pillCross * Motion.lensLiftY;

        Widget capsule = DecoratedBox(
          decoration: BoxDecoration(
            color: style.capsule,
            borderRadius: BorderRadius.circular(thickness / 2),
            border: style.border,
            boxShadow: style.shadow,
          ),
        );
        if (style.frosted && !plain) {
          capsule = ClipRRect(
            borderRadius: BorderRadius.circular(thickness / 2),
            child: BackdropFilter.grouped(
              filter: ui.ImageFilter.blur(sigmaX: LiquidGlass.blurSigma, sigmaY: LiquidGlass.blurSigma),
              child: capsule,
            ),
          );
          capsule = DecoratedBox(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(thickness / 2), boxShadow: style.shadow),
            child: capsule,
          );
        }

        Widget cellAt(int i, Widget child) => horizontal
            ? Positioned(left: LensTabBar.pad + i * cell, top: 0, width: cell, height: thickness, child: child)
            : Positioned(top: LensTabBar.pad + i * cell, left: 0, width: thickness, height: cell, child: child);

        Offset local(Offset global) => (context.findRenderObject()! as RenderBox).globalToLocal(global);

        return SizedBox(
          width: horizontal ? extent : thickness,
          height: horizontal ? thickness : extent,
          // Lift on the raw pointer-down in the same frame: no tap slop, arena or long-press wait. Recognizers only
          // track the drag; the pointer-up selects the tab under the finger.
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _down(e.localPosition),
            onPointerUp: (e) => _release(at: e.localPosition),
            onPointerCancel: (_) => _release(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: horizontal ? (d) => _drag(local(d.globalPosition)) : null,
              onHorizontalDragUpdate: horizontal ? (d) => _drag(local(d.globalPosition)) : null,
              onVerticalDragStart: horizontal ? null : (d) => _drag(local(d.globalPosition)),
              onVerticalDragUpdate: horizontal ? null : (d) => _drag(local(d.globalPosition)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: capsule),
                  for (var i = 0; i < n; i++)
                    cellAt(
                      i,
                      Semantics(
                        button: true,
                        selected: i == widget.currentIndex,
                        label: '${widget.tabs[i].$2} tab${i == widget.currentIndex ? ', selected' : ''}',
                        excludeSemantics: true,
                        onTap: () {
                          if (i != widget.currentIndex) Haptics.selection();
                          widget.onTap(i);
                        },
                        child: Center(
                          child: AnimatedOpacity(
                            opacity: i == widget.currentIndex ? 0 : 1,
                            duration: reduce ? Duration.zero : Motion.quick,
                            child: Icon(widget.tabs[i].$1, size: 24, color: style.inactive),
                          ),
                        ),
                      ),
                    ),
                  AnimatedBuilder(
                    animation: Listenable.merge([_pos, _lift]),
                    builder: (context, _) {
                      final lift = reduce ? 0.0 : _lift.value.clamp(0.0, 1.0);
                      final stretch = reduce || lift == 0 ? 0.0 : liquidStretch(_pos.velocity * cell);
                      final main = (pillMain + (lensMain - pillMain) * lift) * (1 + stretch);
                      final cross = (pillCross + (lensCross - pillCross) * lift) * (1 - LiquidGlass.squash * stretch / LiquidGlass.stretchMax);
                      final inset = thickness * 0.06 * (1 - lift);
                      final centreMain = (LensTabBar.pad + cell * (_pos.value + 0.5)).clamp(main / 2 + inset, extent - main / 2 - inset);
                      final rect = horizontal
                          ? Rect.fromCenter(center: Offset(centreMain, thickness / 2), width: main, height: cross)
                          : Rect.fromCenter(center: Offset(thickness / 2, centreMain), width: cross, height: main);
                      final i = _pos.value.round().clamp(0, n - 1);
                      final label = Transform.scale(
                        scale: 1 + (Motion.lensMagnify - 1) * lift,
                        child: _ActiveLabel(tab: widget.tabs[i], showLabel: showLabel, color: style.active),
                      );
                      return Positioned.fromRect(
                        rect: rect,
                        child: IgnorePointer(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Rest pill, fading out as the lens lifts.
                              Opacity(
                                opacity: 1 - lift,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: style.pill, borderRadius: BorderRadius.circular(math.min(main, cross) / 2)),
                                ),
                              ),
                              if (lift > 0.01)
                                Opacity(
                                  key: const ValueKey('tab-lens'),
                                  opacity: lift,
                                  child: _Lens(size: rect.size, plain: plain, child: const SizedBox.expand()),
                                ),
                              label,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/** Rest look of the bar per theme: light glass in light mode, a dark capsule in dark mode, solid in high contrast. */
class LensBarLook {
  final Color capsule;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;
  final bool frosted;
  final Color pill;
  final Color inactive;
  final Color active;

  const LensBarLook({
    required this.capsule,
    required this.border,
    required this.shadow,
    required this.frosted,
    required this.pill,
    required this.inactive,
    required this.active,
  });

  static LensBarLook of({required bool dark, required bool highContrast}) {
    if (highContrast) {
      return LensBarLook(
        capsule: LensTabStyle.capsuleDark,
        border: Border.all(color: LensTabStyle.hcBorder, width: 1.5),
        shadow: null,
        frosted: false,
        pill: LensTabStyle.hcPill,
        inactive: const Color(0xFFB0B0B5),
        active: LensTabStyle.active,
      );
    }
    if (dark) {
      return LensBarLook(
        capsule: LensTabStyle.capsuleDark,
        border: Border.all(color: LensTabStyle.hairlineDark, width: 1),
        shadow: LensTabStyle.capsuleShadow,
        frosted: false,
        pill: const Color(0x24FFFFFF),
        inactive: const Color(0xFF8E8E93),
        active: LensTabStyle.active,
      );
    }
    return LensBarLook(
      capsule: const Color(0x9EFFFFFF),
      border: Border.all(color: const Color(0xCCFFFFFF), width: 1),
      shadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 6))],
      frosted: true,
      pill: const Color(0x2E3F6B52), // sage at 18%
      inactive: const Color(0xFF6E6E73),
      active: const Color(0xFF1C1C1E),
    );
  }
}

class _ActiveLabel extends StatelessWidget {
  final LensTab tab;
  final bool showLabel;

  final Color color;

  const _ActiveLabel({required this.tab, required this.showLabel, this.color = LensTabStyle.active});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.$1, size: 24, color: color, shadows: color == LensTabStyle.active ? LensTabStyle.activeGlow : null),
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                tab.$2,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: AppType.caption,
                  fontWeight: FontWeight.w600,
                  color: color,
                  shadows: color == LensTabStyle.active ? LensTabStyle.activeGlow : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/** The raised lens: refracts what is behind it (bar and background) and draws a thin bright rim. */
class _Lens extends StatelessWidget {
  final Size size;
  final bool plain;
  final Widget child;

  const _Lens({required this.size, required this.plain, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final highContrast = GlassMaterial.of(context).opaque;
    final r = size.shortestSide * LensTabStyle.lensRadius;
    final radius = BorderRadius.circular(r);
    final rim = ShapeDecoration(
      shape: RoundedSuperellipseBorder(
        borderRadius: radius,
        side: const BorderSide(color: Color(0x8CFFFFFF), width: 1),
      ),
    );
    final lens = LiquidGlassShader.lens(
      box: size,
      lens: LiquidLens(
        radius: r,
        band: size.shortestSide * LensTabStyle.lensBand,
        refraction: size.shortestSide * LensTabStyle.lensRefraction,
        rimLit: 0.75,
        rimFar: 0.45,
        fresnel: 0.22,
        topInnerShadow: 0,
        bevelDarken: 0,
        saturation: 1.0,
        bevelSaturation: 0,
        dispersion: -0.10,
        bandLift: dark ? 0.60 : 0.55,
        bandLiftFrom: dark ? 0.04 : 0.15,
      ),
    );
    Widget body = DecoratedBox(decoration: rim, child: child);
    if (highContrast) {
      return DecoratedBox(
        decoration: ShapeDecoration(
          color: LensTabStyle.hcPill,
          shape: RoundedSuperellipseBorder(
            borderRadius: radius,
            side: const BorderSide(color: LensTabStyle.hcBorder, width: 1.5),
          ),
        ),
        child: child,
      );
    }
    if (plain || lens == null) {
      // Fallback (no shader, Reduce Transparency, tests): a faint clear lens with the same rim.
      body = DecoratedBox(
        decoration: ShapeDecoration(
          color: LensTabStyle.lensFallbackFill,
          shape: RoundedSuperellipseBorder(borderRadius: radius),
        ),
        child: body,
      );
      return body;
    }
    // Nested: the outer read hands the lens a texture of exactly its own bounds (see liquid-glass-spec.md).
    return ClipRSuperellipse(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 0.6, sigmaY: 0.6),
        child: BackdropFilter(filter: lens, child: body),
      ),
    );
  }
}
