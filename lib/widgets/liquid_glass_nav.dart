/**
 * Liquid Glass navigation: the floating tab bar (compact windows) and side rail (medium and expanded windows).
 *
 * One clear capsule of glass on the shell's single grouped backdrop blur, a light tint, a specular rim lit from the upper
 * left, a selection pill that travels on [Motion.liquid] and stretches with its speed, and a press glow that lights the
 * glass from under the finger. The edge lensing, fresnel and drifting rim light come later from the ambient shader; this
 * file paints only static layers, so it adds no per-frame work at rest.
 *
 * Spec: AgentResearch/PointerOptimize/design/CalmGlassBrief.md sections 3.2, 3.3, 3.5 and 3.6.
 */
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../services/reduce_transparency.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../utils/motion.dart';
import 'glass_card.dart' show GradientBoxBorder;
import 'liquid_glass_shader.dart';

/** One tab: inactive icon, active icon (Regular weight) and label. */
typedef LiquidTab = (IconData icon, IconData activeIcon, String label);

/** Resolved optical values for the current theme (CalmGlassBrief 3.3). */
class LiquidGlassLook {
  final List<Color> tint;
  final List<Color> rim;
  final Color? shadow;
  final double shadowBlur;
  final double shadowY;
  final double sigma;
  final Color pillFill;
  final Color pillRim;
  final Color? pillShadow;
  final Color glow;

  /** High contrast or Reduce Transparency: no blur, a solid fill. */
  final bool opaque;

  final double rimWidth;

  const LiquidGlassLook({
    required this.tint,
    required this.rim,
    required this.shadow,
    required this.shadowBlur,
    required this.shadowY,
    required this.sigma,
    required this.pillFill,
    required this.pillRim,
    required this.pillShadow,
    required this.glow,
    required this.opaque,
    this.rimWidth = LiquidGlass.rimWidth,
  });

  factory LiquidGlassLook.of(BuildContext context) {
    final colors = context.colors;
    final glass = GlassMaterial.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOled = isDark && colors.surface == const Color(0xFF000000);
    const warmWhite = Color(0xFFFFF8F0);
    if (glass.opaque) {
      return LiquidGlassLook(
        tint: [colors.surface, colors.surface],
        rim: [Colors.white.withValues(alpha: 0.7), Colors.white.withValues(alpha: 0.7)],
        shadow: null,
        shadowBlur: 0,
        shadowY: 0,
        sigma: 0,
        pillFill: Colors.white.withValues(alpha: 0.16),
        pillRim: Colors.white.withValues(alpha: 0.9),
        pillShadow: null,
        glow: Colors.transparent,
        opaque: true,
        rimWidth: 1.5,
      );
    }
    if (ReduceTransparency.of(context)) {
      // Reduce Transparency (CalmGlassBrief 3.3): no blur, no lens; a frosted, nearly opaque surface and a quiet rim.
      return LiquidGlassLook(
        tint: [colors.surface.withValues(alpha: 0.94), colors.surface.withValues(alpha: 0.94)],
        rim: [colors.textPrimary.withValues(alpha: 0.20), colors.textPrimary.withValues(alpha: 0.20)],
        shadow: isDark ? null : InkPalette.ink.withValues(alpha: 0.08),
        shadowBlur: 24,
        shadowY: 6,
        sigma: 0,
        pillFill: colors.textPrimary.withValues(alpha: isDark ? 0.12 : 0.08),
        pillRim: colors.textPrimary.withValues(alpha: 0.20),
        pillShadow: null,
        glow: Colors.transparent,
        opaque: true,
        rimWidth: 1,
      );
    }
    if (isOled) {
      return LiquidGlassLook(
        tint: [colors.surface.withValues(alpha: 0.58), colors.surface.withValues(alpha: 0.55)],
        rim: [warmWhite.withValues(alpha: 0.40), Colors.white.withValues(alpha: 0.12)],
        shadow: null,
        shadowBlur: 0,
        shadowY: 0,
        sigma: LiquidGlass.blurSigmaOled,
        pillFill: Colors.white.withValues(alpha: 0.10),
        pillRim: Colors.white.withValues(alpha: 0.30),
        pillShadow: null,
        glow: Colors.white.withValues(alpha: 0.10),
        opaque: false,
      );
    }
    if (isDark) {
      return LiquidGlassLook(
        tint: [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.07)],
        rim: [warmWhite.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0.22)],
        shadow: Colors.black.withValues(alpha: 0.22),
        shadowBlur: 28,
        shadowY: 8,
        sigma: LiquidGlass.blurSigma,
        pillFill: Colors.white.withValues(alpha: 0.12),
        pillRim: Colors.white.withValues(alpha: 0.35),
        pillShadow: null,
        glow: Colors.white.withValues(alpha: 0.10),
        opaque: false,
      );
    }
    return LiquidGlassLook(
      // Mostly clear so the field shows through; the lens, rim and shadow carry the glass (fill 0.08 to 0.18).
      // With the lens drawing the edge, the fill stays very light: a white wash above the shader would lift the darker
      // edge cues straight back to the background (measured: hairline 210 washed to 218).
      tint: LiquidGlassShader.active
          ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.05)]
          : [Colors.white.withValues(alpha: 0.18), Colors.white.withValues(alpha: 0.12)],
      rim: [Colors.white.withValues(alpha: 0.85), InkPalette.ink.withValues(alpha: 0.10)],
      shadow: Colors.black.withValues(alpha: 0.10),
      shadowBlur: 8,
      shadowY: 3,
      sigma: LiquidGlass.blurSigma,
      pillFill: Colors.white.withValues(alpha: 0.45),
      pillRim: Colors.white.withValues(alpha: 0.90),
      pillShadow: InkPalette.ink.withValues(alpha: 0.06),
      glow: Colors.white.withValues(alpha: 0.18),
      opaque: false,
    );
  }
}

/** Stretch factor for the pill at [velocityPx] px/s along its travel (CalmGlassBrief 3.5). */
double liquidStretch(double velocityPx) => math.min(LiquidGlass.stretchMax, velocityPx.abs() / LiquidGlass.stretchVelocity);

/**
 * The glass capsule shared by the bar and the rail: shadow, the shell's grouped blur, tint, specular rim, the travelling
 * pill, the press glow and the items.
 */
class LiquidGlassNav extends StatefulWidget {
  final List<LiquidTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /** Horizontal for the tab bar, vertical for the rail. */
  final Axis axis;

  /** Bar only: icons only at [LiquidGlass.barMinimizedHeight]. */
  final bool minimized;

  /** Padding along the main axis, so the end pills keep [LiquidGlass.pillInset] from the edge. */
  static const double padMain = LiquidGlass.pillInset - LiquidGlass.pillCellGap / 2 + 2;

  /** Width of the minimized bar for [count] tabs: it hugs its icons. */
  static double minimizedWidth(int count) => count * LiquidGlass.minimizedCell + 2 * padMain;

  const LiquidGlassNav({super.key, required this.tabs, required this.currentIndex, required this.onTap, required this.axis, this.minimized = false});

  @override
  State<LiquidGlassNav> createState() => _LiquidGlassNavState();
}

class _LiquidGlassNavState extends State<LiquidGlassNav> with TickerProviderStateMixin {
  /** Pill position in cell units (0 = first tab), driven by [Motion.liquid]. */
  late final AnimationController _pill = AnimationController.unbounded(vsync: this, value: widget.currentIndex.toDouble());

  /** Press glow, 0 to 1 over grow plus fade. */
  late final AnimationController _glow = AnimationController(vsync: this, duration: LiquidGlass.glowGrow + LiquidGlass.glowFade);

  Offset _glowAt = Offset.zero;
  int _fadeKey = 0;

  @override
  void didUpdateWidget(LiquidGlassNav old) {
    super.didUpdateWidget(old);
    if (old.currentIndex == widget.currentIndex) return;
    final target = widget.currentIndex.toDouble();
    if (Motion.reduce(context)) {
      // Reduce Motion: no travel and no stretch; the pill crossfades in place.
      _pill.value = target;
      _fadeKey++;
    } else {
      _pill.animateWith(SpringSimulation(Motion.liquid, _pill.value, target, _pill.velocity));
    }
  }

  @override
  void dispose() {
    ReduceTransparency.instance.removeListener(_onReduceTransparency);
    _pill.dispose();
    _glow.dispose();
    super.dispose();
  }

  void _press(Offset local) {
    _glowAt = local;
    if (Motion.reduce(context)) {
      // Full size at once, then a short fade.
      _glow.value = LiquidGlass.glowGrow.inMicroseconds / _glow.duration!.inMicroseconds;
      _glow.animateTo(1, duration: Motion.quick, curve: Curves.easeOut);
    } else {
      _glow.forward(from: 0);
    }
  }

  void _select(int index) {
    if (index != widget.currentIndex) Haptics.selection();
    widget.onTap(index);
  }

  @override
  void initState() {
    super.initState();
    ReduceTransparency.instance.addListener(_onReduceTransparency);
    LiquidGlassShader.ensureLoaded();
    LiquidGlassShader.loaded.then((_) {
      if (mounted) setState(() {});
    });
  }

  void _onReduceTransparency() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final look = LiquidGlassLook.of(context);
    final horizontal = widget.axis == Axis.horizontal;
    final reduce = Motion.reduce(context);

    final height = horizontal ? (widget.minimized ? LiquidGlass.barMinimizedHeight : LiquidGlass.barHeight) : null;
    final radius = horizontal ? (height! / 2) : LiquidGlass.railWidth / 2;
    final cellMain = horizontal
        ? (widget.minimized ? LiquidGlass.minimizedCell : null) // null: equal shares of the bar width
        : LiquidGlass.railCellHeight;

    final shape = BorderRadius.circular(radius);
    Widget body = LayoutBuilder(
      builder: (context, constraints) {
        final count = widget.tabs.length;
        const padMain = LiquidGlassNav.padMain;
        final extent = horizontal && cellMain == null ? constraints.maxWidth : count * cellMain! + 2 * padMain;
        final cell = horizontal ? (cellMain ?? (extent - 2 * padMain) / count) : cellMain!;
        final cross = horizontal ? height! : LiquidGlass.railWidth;

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (d) => _press(d.localPosition),
          child: SizedBox(
            width: horizontal ? extent : cross,
            height: horizontal ? cross : extent,
            child: Stack(
              children: [
                // Selection pill (layer 9): travels on the liquid spring, stretched along its travel by its speed.
                AnimatedBuilder(
                  animation: _pill,
                  builder: (context, _) {
                    final stretch = reduce ? 0.0 : liquidStretch(_pill.velocity * cell);
                    final mini = horizontal && widget.minimized;
                    final baseMain = mini ? 36.0 : (horizontal ? cell - LiquidGlass.pillCellGap : LiquidGlass.railWidth - 12);
                    final baseCross = mini ? 36.0 : (horizontal ? cross - 2 * LiquidGlass.pillInset : cell - LiquidGlass.pillCellGap);
                    final main = baseMain * (1 + stretch);
                    final crossSize = baseCross * (1 - LiquidGlass.squash * stretch / LiquidGlass.stretchMax);
                    final centreMain = padMain + cell * (_pill.value + 0.5);
                    final pr = math.min(main, crossSize) / 2;
                    final rect = horizontal
                        ? Rect.fromCenter(center: Offset(centreMain, cross / 2), width: main, height: crossSize)
                        : Rect.fromCenter(center: Offset(cross / 2, centreMain), width: crossSize, height: main);
                    return Positioned.fromRect(
                      rect: rect,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_fadeKey),
                        tween: Tween(begin: _fadeKey == 0 ? 1 : 0, end: 1),
                        duration: Motion.quick,
                        builder: (context, o, child) => Opacity(opacity: o, child: child),
                        child: DecoratedBox(
                          key: const ValueKey('liquid-pill'),
                          decoration: BoxDecoration(
                            color: look.pillFill,
                            borderRadius: BorderRadius.circular(pr),
                            // Its own specular rim, lit from the upper left like the capsule, so the pill reads as a lens.
                            border: GradientBoxBorder(
                              gradient: LinearGradient(
                                colors: [
                                  look.pillRim,
                                  look.pillRim.withValues(alpha: look.pillRim.a * 0.25),
                                  look.pillRim.withValues(alpha: look.pillRim.a * 0.6),
                                ],
                                stops: const [0, 0.6, 1],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: 1,
                            ),
                            boxShadow: look.pillShadow == null
                                ? null
                                : [BoxShadow(color: look.pillShadow!, blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Press glow (layer 10): the glass lights up from under the finger.
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _glow,
                    builder: (context, _) => CustomPaint(size: Size.infinite, painter: _GlowPainter(_glow.value, _glowAt, look.glow)),
                  ),
                ),
                // Items (layer 11).
                Positioned.fill(
                  child: Padding(
                    padding: horizontal ? EdgeInsets.symmetric(horizontal: padMain) : EdgeInsets.symmetric(vertical: padMain),
                    child: Flex(
                      direction: widget.axis,
                      children: [
                        for (var i = 0; i < count; i++)
                          SizedBox(
                            width: horizontal ? cell : null,
                            height: horizontal ? null : cell,
                            child: _LiquidItem(
                              tab: widget.tabs[i],
                              isActive: widget.currentIndex == i,
                              showLabel: !(horizontal && widget.minimized),
                              onTap: () => _select(i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Layers 2 to 8: the one grouped backdrop blur, the tint and the specular rim.
    final tint = BoxDecoration(
      borderRadius: shape,
      gradient: LinearGradient(colors: look.tint, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      border: GradientBoxBorder(
        gradient: LinearGradient(
          colors: LiquidGlassShader.active && !look.opaque ? const [Color(0x00000000), Color(0x00000000)] : look.rim,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        width: look.rimWidth,
      ),
    );
    Widget glass = DecoratedBox(decoration: tint, child: body);
    if (!look.opaque) {
      final inner = glass;
      glass = LayoutBuilder(
        builder: (context, c) {
          final box = horizontal
              ? Size(c.maxWidth, c.maxHeight)
              : Size(LiquidGlass.railWidth, widget.tabs.length * LiquidGlass.railCellHeight + 2 * LiquidGlassNav.padMain);
          final dark = Theme.of(context).brightness == Brightness.dark;
          final lens = LiquidLens(
            radius: radius,
            band: widget.minimized ? 4 : 5,
            refraction: widget.minimized ? 3 : 4,
            rimLit: dark ? 0.75 : 0.95,
            rimFar: dark ? 0.28 : 0.45,
            bevelDarken: dark ? 0.04 : 0.14,
            bevelSaturation: dark ? 0.25 : 0.45,
            lightTheme: !dark,
            hairline: 0.14,
            hairlineWidth: 1,
            topInnerShadow: dark ? 0.10 : 0.06,
          );
          final filter = LiquidGlassShader.filter(box: box, lens: lens, blurSigma: look.sigma);
          // The lens needs its own backdrop read. A grouped backdrop hands the shader the shared full-screen texture
          // while FlutterFragCoord stays local to the glass, so on the phone the lens sampled the screen's top-left
          // corner. The bar and the rail are never on screen together, so this is still one backdrop read per frame.
          return LiquidGlassShader.active ? BackdropFilter(filter: filter, child: inner) : BackdropFilter.grouped(filter: filter, child: inner);
        },
      );
    }
    // The shadow is painted only outside the capsule: a BoxShadow under translucent glass shows through and greys the
    // body (the emulator showed the light body 13 levels darker than the background).
    return CustomPaint(
      painter: look.shadow == null ? null : _OuterShadowPainter(radius: radius, color: look.shadow!, blur: look.shadowBlur, dy: look.shadowY),
      child: ClipRRect(borderRadius: shape, child: glass),
    );
  }
}

class _OuterShadowPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double blur;
  final double dy;

  _OuterShadowPainter({required this.radius, required this.color, required this.blur, required this.dy});

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(blur * 2 + dy.abs()))
      ..addRRect(body);
    canvas.save();
    canvas.clipPath(outside);
    canvas.drawRRect(
      body.shift(Offset(0, dy)),
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter old) => old.radius != radius || old.color != color || old.blur != blur || old.dy != dy;
}

class _GlowPainter extends CustomPainter {
  final double t;
  final Offset at;
  final Color color;

  _GlowPainter(this.t, this.at, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1 || color.a == 0) return;
    final total = (LiquidGlass.glowGrow + LiquidGlass.glowFade).inMicroseconds;
    final grow = LiquidGlass.glowGrow.inMicroseconds / total;
    final r = LiquidGlass.glowRadius * Curves.easeOutCubic.transform(math.min(1, t / grow));
    final fade = t <= grow ? 1.0 : 1 - Curves.easeOut.transform((t - grow) / (1 - grow));
    if (r <= 0) return;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: color.a * fade),
          color.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: at, radius: r));
    canvas.drawCircle(at, r, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.t != t || old.at != at || old.color != color;
}

class _LiquidItem extends StatelessWidget {
  final LiquidTab tab;
  final bool isActive;
  final bool showLabel;
  final VoidCallback onTap;

  const _LiquidItem({required this.tab, required this.isActive, required this.showLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isActive ? colors.textPrimary : colors.textMuted;
    final reduce = Motion.reduce(context);
    return Semantics(
      button: true,
      selected: isActive,
      label: '${tab.$3} tab${isActive ? ', selected' : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: AppSpacing.minTouchTarget, minHeight: AppSpacing.minTouchTarget),
          child: AnimatedScale(
            // The pill magnifies what sits under it, like a lens.
            scale: isActive ? LiquidGlass.pillMagnify : 1.0,
            duration: reduce ? Duration.zero : Motion.quick,
            curve: Motion.inOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isActive ? tab.$2 : tab.$1, color: color, size: 24),
                AnimatedSize(
                  duration: reduce ? Duration.zero : Motion.quick,
                  curve: Motion.inOut,
                  child: showLabel
                      ? Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            tab.$3,
                            maxLines: 1,
                            style: TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.caption, fontWeight: FontWeight.w500, color: color),
                          ),
                        )
                      : const SizedBox(width: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
