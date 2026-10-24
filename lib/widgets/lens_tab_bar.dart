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
 * - The lens travels on Motion.liquid and stretches along its motion; under Reduce Motion it moves without travel.
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
  static const Color inactive = Color(0xFF6E6E73);
  static const Color active = Color(0xFFFFFFFF);

  /** The lens is this much thicker than the bar (it overflows on both sides). */
  static const double lensThickness = 1.3;

  /** Lens width as a share of a cell, capped by [lensAspect] times its thickness. */
  static const double lensCellShare = 1.15;
  static const double lensAspect = 1.25;

  /** Corner radius of the lens as a share of its shorter side (a soft rounded square). */
  static const double lensRadius = 0.42;

  /** One soft, wide drop shadow (about 22% black, 32 px blur, 8 px down), never a hard band. */
  static const List<BoxShadow> capsuleShadow = [BoxShadow(color: Color(0x38000000), blurRadius: 32, offset: Offset(0, 8))];

  /** Lens bevel and refraction as shares of its shorter side. The rim samples inward by about the overhang, so the edge shows a dark rim and
   * the overhang shows the background as bright crescents. */
  static const double lensBand = 0.14;
  static const double lensRefraction = 0.10;

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

class _LensTabBarState extends State<LensTabBar> with SingleTickerProviderStateMixin {
  late final AnimationController _pos = AnimationController.unbounded(vsync: this, value: widget.currentIndex.toDouble());

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
    if (old.currentIndex == widget.currentIndex) return;
    final target = widget.currentIndex.toDouble();
    if (Motion.reduce(context)) {
      _pos.value = target;
    } else {
      _pos.animateWith(SpringSimulation(Motion.liquid, _pos.value, target, _pos.velocity));
    }
  }

  @override
  void dispose() {
    _pos.dispose();
    super.dispose();
  }

  void _select(int i) {
    if (i != widget.currentIndex) Haptics.selection();
    widget.onTap(i);
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = widget.axis == Axis.horizontal;
    final plain = ReduceTransparency.of(context);
    final reduce = Motion.reduce(context);
    return LayoutBuilder(
      builder: (context, c) {
        final n = widget.tabs.length;
        final thickness = horizontal ? (widget.minimized ? LiquidGlass.barMinimizedHeight : LiquidGlass.barHeight) : LiquidGlass.railWidth;
        final extent = horizontal
            ? (widget.minimized ? LensTabBar.minimizedWidth(n) : c.maxWidth)
            : n * LiquidGlass.railCellHeight + 2 * LensTabBar.pad;
        final cell = (extent - 2 * LensTabBar.pad) / n;
        final lensCross = thickness * LensTabStyle.lensThickness;
        final lensMain = math.min(cell * LensTabStyle.lensCellShare, lensCross * LensTabStyle.lensAspect);
        final showLabel = !(horizontal && widget.minimized);

        final capsule = DecoratedBox(
          decoration: BoxDecoration(
            color: LensTabStyle.capsule,
            borderRadius: BorderRadius.circular(thickness / 2),
            boxShadow: LensTabStyle.capsuleShadow,
          ),
        );

        Widget cellAt(int i, Widget child) => horizontal
            ? Positioned(left: LensTabBar.pad + i * cell, top: 0, width: cell, height: thickness, child: child)
            : Positioned(top: LensTabBar.pad + i * cell, left: 0, width: thickness, height: cell, child: child);

        return SizedBox(
          width: horizontal ? extent : thickness,
          height: horizontal ? thickness : extent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: capsule),
              // Inactive tabs: filled grey icons, no labels. The active one is drawn by the lens instead.
              for (var i = 0; i < n; i++)
                cellAt(
                  i,
                  Semantics(
                    button: true,
                    selected: i == widget.currentIndex,
                    label: '${widget.tabs[i].$2} tab${i == widget.currentIndex ? ', selected' : ''}',
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(i),
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: i == widget.currentIndex ? 0 : 1,
                          duration: reduce ? Duration.zero : Motion.quick,
                          child: Icon(widget.tabs[i].$1, size: 24, color: LensTabStyle.inactive),
                        ),
                      ),
                    ),
                  ),
                ),
              // The lens, carrying the active icon and label; it ignores pointers so taps reach the cells below.
              AnimatedBuilder(
                animation: _pos,
                builder: (context, _) {
                  final stretch = reduce ? 0.0 : liquidStretch(_pos.velocity * cell);
                  final main = lensMain * (1 + stretch);
                  final cross = lensCross * (1 - LiquidGlass.squash * stretch / LiquidGlass.stretchMax);
                  // Clamp inside the capsule's rounded ends so the first and last lens never hang past them.
                  final inset = thickness * 0.1;
                  final centreMain = (LensTabBar.pad + cell * (_pos.value + 0.5)).clamp(main / 2 + inset, extent - main / 2 - inset);
                  final rect = horizontal
                      ? Rect.fromCenter(center: Offset(centreMain, thickness / 2), width: main, height: cross)
                      : Rect.fromCenter(center: Offset(thickness / 2, centreMain), width: cross, height: main);
                  final i = _pos.value.round().clamp(0, n - 1);
                  return Positioned.fromRect(
                    rect: rect,
                    child: IgnorePointer(
                      child: _Lens(
                        size: rect.size,
                        plain: plain,
                        child: _ActiveLabel(tab: widget.tabs[i], showLabel: showLabel),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveLabel extends StatelessWidget {
  final LensTab tab;
  final bool showLabel;

  const _ActiveLabel({required this.tab, required this.showLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tab.$1, size: 24, color: LensTabStyle.active, shadows: LensTabStyle.activeGlow),
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                tab.$2,
                maxLines: 1,
                style: const TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: AppType.caption,
                  fontWeight: FontWeight.w600,
                  color: LensTabStyle.active,
                  shadows: LensTabStyle.activeGlow,
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
      ),
    );
    Widget body = DecoratedBox(decoration: rim, child: child);
    if (plain || lens == null) {
      // Fallback (no shader, Reduce Transparency, tests): a faint clear lens with the same rim.
      body = DecoratedBox(
        decoration: ShapeDecoration(
          color: const Color(0x1FFFFFFF),
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
