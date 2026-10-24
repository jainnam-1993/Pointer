import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../utils/motion.dart';
import 'animated_gradient.dart';
import 'press_scale.dart';

/**
 * Glass effect intensity levels matching iOS Control Center aesthetic.
 *
 * Controls the blur radius and opacity of frosted glass effects
 * in [GlassCard] and [GlassButton].
 */
enum GlassIntensity {
  /** Subtle frosted effect with low blur and opacity. */
  light,

  /** Default iOS Control Center-style frosted glass. */
  standard,

  /** Strong frosted effect with maximum blur and opacity. */
  heavy,
}

/**
 * Glassmorphic card widget with iOS Control Center-style frosted glass effect.
 *
 * Supports multiple [GlassIntensity] levels, optional breathing shimmer animation,
 * and high-contrast mode fallback. Uses [PointerColors] from the current theme
 * via `context.colors`.
 *
 * The shimmer animation respects reduce-motion accessibility settings and the
 * [backgroundShimmerActiveProvider] to avoid visual competition with the
 * background [AnimatedGradient].
 *
 * See also:
 * - [GlassButton] for the interactive button variant
 */
class GlassCard extends ConsumerWidget {
  /** The widget displayed inside the glass card. */
  final Widget child;

  /** Inner padding of the card content. */
  final EdgeInsetsGeometry padding;

  /** Corner radius of the glass card. */
  final double borderRadius;

  /** Custom border color override; defaults to [PointerColors.glassBorder]. */
  final Color? borderColor;

  /** Optional tap handler that wraps the card in a [GestureDetector]. */
  final VoidCallback? onTap;

  /** Controls the blur and opacity intensity of the frosted glass effect. */
  final GlassIntensity intensity;

  /** Minimum height constraint for the card content. */
  final double? minHeight;

  /** Maximum height constraint; enables scrolling when [enableScrolling] is true. */
  final double? maxHeight;

  /** Whether to wrap content in a [SingleChildScrollView] when [maxHeight] is set. */
  final bool enableScrolling;

  /**
   * Enable subtle breathing gradient animation
   * When true, adds a slow shimmer effect that "breathes" with the background
   * Respects reduceMotion accessibility setting
   */
  final bool enableBreathingAnimation;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardAll,
    this.borderRadius = AppSpacing.radiusCard,
    this.borderColor,
    this.onTap,
    this.intensity = GlassIntensity.standard,
    this.minHeight,
    this.maxHeight,
    this.enableScrolling = true,
    this.enableBreathingAnimation = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final isHighContrast = isHighContrastEnabled(context, ref);

    if (isHighContrast) {
      return _buildHighContrastCard(context);
    }

    return _buildGlassCard(context, ref, colors, isDark);
  }

  Widget _wrapTap(Widget card) => onTap == null ? card : PressScale(onTap: onTap, child: card);

  Widget _buildHighContrastCard(BuildContext context) {
    const glass = GlassMaterial.highContrast;
    return _wrapTap(
      Container(
        padding: padding,
        decoration: BoxDecoration(
          color: glass.fill,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: glass.rimTop, width: glass.rimWidth),
        ),
        child: child,
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, WidgetRef ref, PointerColors colors, bool isDark) {
    final glass = GlassMaterial.of(context);
    final (double blurFactor, double fillFactor) = switch (intensity) {
      GlassIntensity.light => (0.75, GlassMaterial.lightFactor),
      GlassIntensity.standard => (1.0, 1.0),
      GlassIntensity.heavy => (1.3, GlassMaterial.heavyFactor),
    };
    final blur = glass.blurSigma * blurFactor;
    final rim = borderColor == null
        ? glass.rim
        : LinearGradient(colors: [borderColor!, borderColor!.withValues(alpha: 0.3)], begin: Alignment.topLeft, end: Alignment.bottomRight);

    Widget innerContent = child;
    if (maxHeight != null && enableScrolling) {
      innerContent = SingleChildScrollView(physics: const BouncingScrollPhysics(), child: child);
    }

    Widget constrainedContent = innerContent;
    if (minHeight != null || maxHeight != null) {
      constrainedContent = ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight ?? 0, maxHeight: maxHeight ?? double.infinity),
        child: innerContent,
      );
    }

    // Breathing shimmer: off under reduce motion, in tests, or when the background already shimmers.
    var shouldAnimate =
        enableBreathingAnimation && !Motion.reduce(context) && !AnimatedGradient.disableAnimations && !AnimatedGradient.isTestEnvironment();
    if (shouldAnimate) {
      shouldAnimate = !ref.watch(backgroundShimmerActiveProvider);
    }

    Widget glassContainer = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: glass.fillFor(fillFactor),
        borderRadius: BorderRadius.circular(borderRadius),
        border: GradientBoxBorder(gradient: rim, width: glass.rimWidth),
      ),
      child: constrainedContent,
    );

    if (shouldAnimate) {
      final shimmerColor = colors.shimmerColor.withValues(alpha: isDark ? 0.12 : 0.08);
      glassContainer = Stack(
        children: [
          glassContainer,
          Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius)))
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: Motion.breath * 2, color: shimmerColor, angle: 0.5),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final card = DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), boxShadow: glass.shadows),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: glassContainer,
        ),
      ),
    );

    return _wrapTap(card);
  }
}

/**
 * Glassmorphic button widget with iOS Control Center-style frosted glass effect.
 *
 * Renders as a rounded pill button with backdrop blur and gradient border.
 * Supports primary/secondary variants, loading state with spinner, and optional
 * trailing icon. Ensures WCAG 2.5.8 minimum 48px touch target.
 *
 * Falls back to a solid high-contrast variant when [isHighContrastEnabled].
 *
 * See also:
 * - [GlassCard] for the non-interactive card variant
 */
class GlassButton extends ConsumerWidget {
  /** Button text label. */
  final String label;

  /** Callback invoked on tap (disabled while [isLoading] is true). */
  final VoidCallback onPressed;

  /** Whether to use primary (brighter) or secondary (subtler) glass styling. */
  final bool isPrimary;

  /** Optional trailing icon displayed after the label. */
  final Widget? icon;

  /** When true, replaces the label and icon with a [CircularProgressIndicator]. */
  final bool isLoading;

  const GlassButton({super.key, required this.label, required this.onPressed, this.isPrimary = true, this.icon, this.isLoading = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final isHighContrast = isHighContrastEnabled(context, ref);

    if (isHighContrast) {
      return _buildHighContrastButton(context);
    }

    return _buildGlassButton(context, colors, isDark);
  }

  Widget _label(BuildContext context, Color textColor, Color spinnerColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor))
        else ...[
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.buttonLabel(context).copyWith(color: textColor),
            ),
          ),
          if (icon != null) ...[const SizedBox(width: AppSpacing.sm), icon!],
        ],
      ],
    );
  }

  Widget _buildHighContrastButton(BuildContext context) {
    const glass = GlassMaterial.highContrast;
    final hc = PointerColors.highContrast;
    // 48x48 minimum touch target (WCAG 2.5.8).
    return PressScale(
      onTap: isLoading ? null : onPressed,
      semanticLabel: isLoading ? label : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
          decoration: BoxDecoration(
            color: glass.fill,
            borderRadius: BorderRadius.circular(AppSpacing.xxl),
            border: Border.all(color: glass.rimTop, width: glass.rimWidth),
          ),
          child: _label(context, hc.textPrimary, hc.textPrimary),
        ),
      ),
    );
  }

  Widget _buildGlassButton(BuildContext context, PointerColors colors, bool isDark) {
    final glass = GlassMaterial.of(context);
    final rim = isPrimary
        ? LinearGradient(colors: [colors.glassBorderActive, glass.rimBottom], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : glass.rim;
    // 48x48 minimum touch target (WCAG 2.5.8); press-scale instead of an ink ripple.
    return PressScale(
      onTap: isLoading ? null : onPressed,
      semanticLabel: isLoading ? label : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.xxl), boxShadow: glass.shadows),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xxl),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: glass.blurSigma * 0.8, sigmaY: glass.blurSigma * 0.8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
                decoration: BoxDecoration(
                  gradient: glass.fillFor(isPrimary ? GlassMaterial.heavyFactor : 1.0),
                  borderRadius: BorderRadius.circular(AppSpacing.xxl),
                  border: GradientBoxBorder(gradient: rim, width: glass.rimWidth),
                ),
                child: _label(context, colors.textPrimary, colors.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/**
 * Glass-styled dialog with iOS aesthetic.
 *
 * Renders a centered dialog with heavy backdrop blur, transparent background,
 * and rounded corners. Supports an optional title, content widget, and
 * action buttons aligned to the right.
 */
class GlassDialog extends StatelessWidget {
  /** Optional dialog title displayed at the top. */
  final String? title;

  /** Optional body content widget. */
  final Widget? content;

  /** Optional action buttons displayed in a right-aligned row at the bottom. */
  final List<Widget>? actions;

  const GlassDialog({super.key, this.title, this.content, this.actions});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glass = GlassMaterial.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glass.blurSigma * 1.6, sigmaY: glass.blurSigma * 1.6),
          child: Container(
            decoration: BoxDecoration(
              color: glass.opaque ? glass.fill : colors.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(20),
              border: GradientBoxBorder(gradient: glass.rim, width: glass.rimWidth),
            ),
            padding: AppSpacing.cardAll,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Text(
                      title!,
                      style: TextStyle(fontFamily: AppFonts.sans, fontSize: AppType.headline, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (content != null) content!,
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: action,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/**
 * Custom gradient border for [BoxDecoration].
 *
 * Paints a border using a [Gradient] shader instead of a solid color.
 * Supports rectangle (with optional [BorderRadius]) and circle shapes.
 * Used by [GlassCard] and [GlassButton] for their signature gradient borders.
 */
class GradientBoxBorder extends BoxBorder {
  /** The gradient used to paint the border stroke. */
  final Gradient gradient;

  /** Stroke width of the border in logical pixels. */
  final double width;

  const GradientBoxBorder({required this.gradient, this.width = 1.0});

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection, BoxShape shape = BoxShape.rectangle, BorderRadius? borderRadius}) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (borderRadius != null && shape == BoxShape.rectangle) {
      canvas.drawRRect(borderRadius.resolve(textDirection).toRRect(rect), paint);
    } else if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) => GradientBoxBorder(gradient: gradient, width: width * t);
}
