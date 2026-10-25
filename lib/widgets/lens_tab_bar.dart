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

import 'dart:async';
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

  /** Dark glass bar: translucent violet-grey over a backdrop blur, and its light rim. */
  static const Color capsuleDarkGlass = Color(0x4D3A3560);
  static const Color rimDarkGlass = Color(0x24FFFFFF);

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

  /** Tab labels grow with the text scale up to this factor; above it a long press shows the label large instead. */
  static const double labelScaleCap = 1.6;

  /** The tab label's own style at [size]; measured and painted merged into the ambient [DefaultTextStyle]. */
  static TextStyle label(double size, FontWeight weight) => TextStyle(fontFamily: AppFonts.sans, fontSize: size, fontWeight: weight);

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

  /** Main-axis padding inside the rail: with the rail pill [LiquidGlass.railCellHeight] - 4 tall, the pill is 6 from the rim
   * on every side, like its 6 side inset. */
  static const double railPad = 4;

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
    _hideLarge();
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

  /** Main-axis padding: on the rail it is [LensTabBar.railPad], so the selected pill sits 6 from the rim on all four sides. */
  double get _pad => widget.axis == Axis.horizontal ? LensTabBar.pad : LensTabBar.railPad;

  double _cellAt(double mainOffset) => ((mainOffset - _pad) / _cell - 0.5).clamp(0.0, widget.tabs.length - 1.0);

  /**
   * Large label (the equivalent of iOS's Large Content Viewer): tab labels stop growing past [LensTabStyle.labelScaleCap]
   * so the bar and rail keep their height; above that text scale, a long press shows the tab's icon and label large.
   */
  Timer? _largeTimer;
  OverlayEntry? _large;

  void _scheduleLarge(int i) {
    _hideLarge();
    if (MediaQuery.textScalerOf(context).scale(10) / 10 <= LensTabStyle.labelScaleCap) return;
    _largeTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final tab = widget.tabs[i];
      final colors = context.colors;
      _large = OverlayEntry(
        builder: (context) => IgnorePointer(
          child: Center(
            child: Container(
              key: const ValueKey('tab-large-label'),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tab.$1, size: 56, color: colors.textPrimary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    tab.$2,
                    style: TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.title, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_large!);
    });
  }

  void _hideLarge() {
    _largeTimer?.cancel();
    _largeTimer = null;
    _large?.remove();
    _large = null;
  }

  /** The tab under the finger at touch-down: what a tap without a drag selects. */
  int _touched = 0;

  void _down(Offset local) {
    phase = LensPhase.pressed;
    final at = _cellAt(widget.axis == Axis.horizontal ? local.dx : local.dy);
    _touched = at.round();
    _scheduleLarge(_touched);
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
    _hideLarge();
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

  /**
   * One label size for every tab on this bar or rail, selected or not: the caption at the user's text scale, capped at
   * [LensTabStyle.labelScaleCap], then shrunk once so the widest label (at the selected weight) and the icon fit the
   * pill. So all labels match at any text scale and none overhangs its pill.
   *
   * The widths are measured at the style the label is painted with: the ambient [DefaultTextStyle] merged with the
   * label's own, as [Text] does. Measuring the bare style missed the inherited letter spacing (0.25 under a Material
   * ancestor), so "Library" painted about 1 px wider than the rail pill's inner width, wrapped its last letter onto a
   * hidden second line and showed as "Librar" at text scale 1.3 and above (merge review of r12).
   */
  double _sharedLabelSize(BuildContext context, Size box) {
    const iconAndGap = 24.0 + 3.0, vertical = 4.0, inset = 6.0;
    final ambient = DefaultTextStyle.of(context).style;
    double widestAt(double size) {
      var widest = 0.0;
      for (final t in widget.tabs) {
        final tp = TextPainter(
          text: TextSpan(text: t.$2, style: ambient.merge(LensTabStyle.label(size, FontWeight.w600))),
          textDirection: TextDirection.ltr,
          textScaler: TextScaler.noScaling,
          maxLines: 1,
        )..layout();
        widest = math.max(widest, tp.width);
        tp.dispose();
      }
      return widest;
    }

    final heightRoom = (box.height - vertical - iconAndGap) / 1.3;
    var size = math.min(
      MediaQuery.textScalerOf(context).scale(AppType.caption).clamp(AppType.caption, AppType.caption * LensTabStyle.labelScaleCap),
      heightRoom,
    );
    final room = box.width - 2 * inset;
    // Letter spacing is fixed in pixels and glyph advances round, so width is not exactly proportional to size: rescale
    // from the measured width until the widest label fits.
    for (var i = 0; i < 4; i++) {
      final widest = widestAt(size);
      if (widest <= room || widest == 0) break;
      size *= room / widest * 0.995;
    }
    return math.max(1.0, size);
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
        final extent = horizontal ? (widget.minimized ? LensTabBar.minimizedWidth(n) : c.maxWidth) : n * LiquidGlass.railCellHeight + 2 * _pad;
        final cell = (extent - 2 * _pad) / n;
        _cell = cell;
        final showLabel = !(horizontal && widget.minimized);
        final dark = Theme.of(context).brightness == Brightness.dark;
        final highContrast = GlassMaterial.of(context).opaque;
        final style = LensBarLook.of(dark: dark, highContrast: highContrast);

        // Rest pill: flat and tinted, inset from the capsule.
        // On the rail the pill keeps the same inset from the rim on all four sides; on the bar it spans the cell less a gap.
        final pillMain = cell - (horizontal ? LiquidGlass.pillCellGap : 2 * (LiquidGlass.pillInset - LensTabBar.railPad));
        final pillCross = thickness - 2 * LiquidGlass.pillInset;
        // Every tab's icon and label are laid out in the rest pill's box, so the label always fits inside the pill.
        final pillBox = horizontal ? Size(pillMain, pillCross) : Size(pillCross, pillMain);
        final labelSize = _sharedLabelSize(context, pillBox);
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
            ? Positioned(left: _pad + i * cell, top: 0, width: cell, height: thickness, child: child)
            : Positioned(top: _pad + i * cell, left: 0, width: thickness, height: cell, child: child);

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
                        // The tab under the pill or lens is drawn by it, once. Its cell icon is hidden, so it is not in
                        // the backdrop the lens refracts (a visible cell icon there showed as a displaced second
                        // copy under the lens's own label: the "image up and down" the user saw on the rail).
                        child: Center(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_pos, _lift]),
                            builder: (context, child) {
                              final underLens = (i - _pos.value).abs() < 0.5;
                              final hidden = underLens || (i == widget.currentIndex && _lift.value <= 0.001);
                              return Opacity(opacity: hidden ? 0 : 1, child: child);
                            },
                            // Every tab shows its label (HIG tab bars); the selected one is drawn by the pill or lens.
                            child: _ActiveLabel(
                              tab: widget.tabs[i],
                              showLabel: showLabel,
                              color: style.inactive,
                              weight: FontWeight.w500,
                              box: pillBox,
                              labelSize: labelSize,
                            ),
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
                      final inset =
                          thickness * 0.06 * lift; // only the lifted lens needs keeping inside the rounded ends; the rest pill is centred on its cell
                      final centreMain = (_pad + cell * (_pos.value + 0.5)).clamp(main / 2 + inset, extent - main / 2 - inset);
                      final rect = horizontal
                          ? Rect.fromCenter(center: Offset(centreMain, thickness / 2), width: main, height: cross)
                          : Rect.fromCenter(center: Offset(thickness / 2, centreMain), width: cross, height: main);
                      final i = _pos.value.round().clamp(0, n - 1);
                      final label = Transform.scale(
                        scale: 1 + (Motion.lensMagnify - 1) * lift,
                        child: _ActiveLabel(tab: widget.tabs[i], showLabel: showLabel, color: style.active, box: pillBox, labelSize: labelSize),
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
                                // The rest pill is the same glass as the lens, at rest: a frosted tint, a thin bright rim, a
                                // soft top highlight and a little depth; no refraction or motion. Its size comes from the cell,
                                // so it is identical for every tab.
                                child: DecoratedBox(
                                  key: const ValueKey('tab-pill'),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(math.min(main, cross) / 2),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color.alphaBlend(style.pillHighlight, style.pill), style.pill],
                                    ),
                                    border: Border.all(color: style.pillRim, width: 1),
                                    boxShadow: [BoxShadow(color: style.pillShadow, blurRadius: 6, offset: const Offset(0, 1.5))],
                                  ),
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
  final Color pillRim;
  final Color pillHighlight;
  final Color pillShadow;
  final Color inactive;
  final Color active;

  const LensBarLook({
    required this.capsule,
    required this.border,
    required this.shadow,
    required this.frosted,
    required this.pill,
    this.pillRim = const Color(0x66FFFFFF),
    this.pillHighlight = const Color(0x33FFFFFF),
    this.pillShadow = const Color(0x14000000),
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
        // Dark glass (store panel 1.3.0, item 1): a translucent violet-grey body over a backdrop blur, so the ambient
        // sky shows through as it does under the light bar, with a thin light rim and the same soft shadow. Not an
        // opaque slab.
        capsule: LensTabStyle.capsuleDarkGlass,
        border: Border.all(color: LensTabStyle.rimDarkGlass, width: 1),
        // A light diffuse shadow: the wide 22% shadow drew a dark halo ring around the glass on the dark sky.
        shadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 20, offset: Offset(0, 6))],
        frosted: true,
        // Selected: lavender-tinted glass (the dark accent), with a lavender rim at 3:1 or more against the bar.
        pill: const Color(0x4DA597E0),
        pillRim: const Color(0x8CB9ADF0),
        pillHighlight: const Color(0x1FFFFFFF),
        pillShadow: const Color(0x33000000),
        inactive: const Color(0xFFB4B1C0),
        active: LensTabStyle.active,
      );
    }
    return LensBarLook(
      // Light glass that reads as glass on a pale field: a translucent body (not a solid fill), a 1 px warm-grey
      // hairline for the edge, and a soft two-step shadow for depth.
      // Neutral white glass that the field tints through the blur (design panel: grey read as a tray, cream as a
      // yellow slab), a white rim, and one diffuse shadow with no hard lip.
      capsule: const Color(0x9EFFFCF5),
      border: Border.all(color: const Color(0x99FFFFFF), width: 1),
      shadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 3))],
      frosted: true,
      // Selected (store panel 1.3.0, item 2: white on cream barely showed): sage-tinted glass with a sage rim at 3:1 or
      // more against the bar, and the label and icon in deep sage ink. Separation comes from the accent tint, not a
      // heavier shadow.
      pill: const Color(0x333F6B52),
      pillRim: const Color(0xD93F6B52),
      pillHighlight: const Color(0x40FFFFFF), // the same glass top highlight as the dark pill
      pillShadow: const Color(0x1A1E2A1F),
      inactive: const Color(0xFF5A5F58),
      active: const Color(0xFF24402F),
    );
  }
}

class _ActiveLabel extends StatelessWidget {
  final LensTab tab;
  final bool showLabel;

  final Color color;

  final FontWeight weight;

  /** The rest pill's size: icon and label are laid out inside it, so the label never overhangs the pill. */
  final Size box;

  /** The bar's shared label size (already scaled; drawn without further text scaling). */
  final double labelSize;

  const _ActiveLabel({
    required this.tab,
    required this.showLabel,
    required this.box,
    required this.labelSize,
    this.color = LensTabStyle.active,
    this.weight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    // Scale the icon and label down together when a large text scale would not fit the cell (rail width, bar cell),
    // so a label never clips or spills into its neighbour.
    // Fixed metrics for every tab: the icon is always 24 and sits at the same place; only the label scales down (never
    // clips) when a long label or a large text scale would not fit the cell width. So no tab's icon shrinks because
    // its label is longer ("Library"), and every tab looks the same size.
    const iconSize = 24.0, gap = 3.0, inset = 6.0;
    // The label slot grows with the text scale up to 1.6x, but never past what the pill holds on this axis (the rail's
    // pill is narrower and shorter than the bar's); beyond that the label scales down inside it, never clips.
    final slot = labelSize * 1.3;
    return Center(
      child: SizedBox.fromSize(
        size: box,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: inset, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.$1, size: iconSize, color: color, shadows: color == LensTabStyle.active ? LensTabStyle.activeGlow : null),
              if (showLabel)
                Padding(
                  padding: const EdgeInsets.only(top: gap),
                  // One label slot for every tab: the height follows the text scale (so labels grow for low vision)
                  // but not the label's length, so the icon sits at the same place in every pill.
                  child: SizedBox(
                    // Grows with the text scale up to 1.6x (the pill holds icon + label at that size); beyond it the label
                    // scales down inside the slot, never clips.
                    height: slot,
                    child: Text(
                      tab.$2,
                      maxLines: 1,
                      textScaler: TextScaler.noScaling,
                      style: LensTabStyle.label(
                        labelSize,
                        weight,
                      ).copyWith(color: color, shadows: color == LensTabStyle.active ? LensTabStyle.activeGlow : null),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
