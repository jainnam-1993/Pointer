import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../providers/providers.dart';
import 'ambient.dart';
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

  Widget _buildHighContrastCard(BuildContext context) {
    final glass = GlassMaterial.of(context, highContrast: true);

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: glass.fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: glass.rimTop, width: glass.rimWidth),
      ),
      child: child,
    );

    return onTap == null ? card : PressScale(onTap: onTap, child: card);
  }

  Widget _buildGlassCard(BuildContext context, WidgetRef ref, PointerColors colors, bool isDark) {
    // All values come from the theme's GlassMaterial tokens (lib/theme/app_theme.dart).
    final glass = GlassMaterial.of(context);
    final level = intensity.index; // light, standard, heavy
    final frost = glass.levels[level].frost;
    var glassGradient = glass.fillAt(level);
    final borderGradient = borderColor == null ? glass.rim : glass.rimWith(borderColor!);

    Widget innerContent = child;
    if (maxHeight != null && enableScrolling) {
      innerContent = _ScrollingContent(child: child);
    }

    Widget constrainedContent = innerContent;
    if (minHeight != null || maxHeight != null) {
      constrainedContent = ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight ?? 0, maxHeight: maxHeight ?? double.infinity),
        child: innerContent,
      );
    }

    // Analytic frost: the ambient shader evaluated at this card's position with
    // frost settings stands in for a live BackdropFilter. [enableBreathingAnimation]
    // is kept for API compatibility; the frost already moves with the background.
    final palette = ambientPaletteForTheme(context);
    final animate = ambientMotionEnabled(context, ref);
    final radius = BorderRadius.circular(borderRadius);
    // On an opaque surface (sheet, dialog) the ambient is hidden: plain glass, no shader.
    final onSurface = FrostScope.suppressesFrost(context);
    if (onSurface) {
      // Plain glass for opaque sheets (white and raised in light).
      glassGradient = glass.onSurfaceAt(level);
    }

    // The old card drew its rim as a Container border, which also inset the child
    // by the rim width. The rim is now a foreground layer, so add that inset back
    // to keep every child exactly where it was.
    final rimWidth = glass.rimWidth;
    final material = Container(
      padding: padding,
      decoration: BoxDecoration(gradient: glassGradient, borderRadius: radius),
      // Top-edge highlight: a soft sheen across the upper third.
      foregroundDecoration: BoxDecoration(borderRadius: radius, gradient: glass.sheen),
      child: Padding(padding: EdgeInsets.all(rimWidth), child: constrainedContent),
    );

    final card = DecoratedBox(
      // Soft shadow in both themes, plus the hairline rim drawn outside the clip.
      decoration: BoxDecoration(borderRadius: radius, boxShadow: glass.shadows),
      position: DecorationPosition.background,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: GradientBoxBorder(gradient: borderGradient, width: rimWidth),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            // passthrough: the material gets the card's own constraints, exactly as the
            // old Container did; a loose Stack shrank it to the child's intrinsic size.
            fit: StackFit.passthrough,
            children: [
              if (!onSurface)
                Positioned.fill(
                  child: AmbientFrost(frost: frost, palette: palette, animate: animate),
                ),
              material,
            ],
          ),
        ),
      ),
    );

    // Press-scale feedback instead of an ink ripple.
    return onTap == null ? card : PressScale(onTap: onTap, child: card);
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

    return _buildGlassButton(context, ref, colors, isDark);
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
    final glass = GlassMaterial.of(context, highContrast: true);
    final hc = context.isDarkMode ? PointerColors.highContrast : PointerColors.highContrastLight;
    // 48x48 minimum touch target (WCAG 2.5.8); press-scale, no ripple.
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

  Widget _buildGlassButton(BuildContext context, WidgetRef ref, PointerColors colors, bool isDark) {
    final glass = GlassMaterial.of(context);
    final level = isPrimary ? glass.buttonPrimary : glass.buttonSecondary;
    final borderGradient = glass.rimWith(isPrimary ? colors.glassBorderActive : colors.glassBorder);
    final radius = BorderRadius.circular(AppSpacing.xxl);

    // 48x48 minimum touch target (WCAG 2.5.8); press-scale instead of an ink ripple.
    return PressScale(
      onTap: isLoading ? null : onPressed,
      semanticLabel: isLoading ? label : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: ClipRRect(
          borderRadius: radius,
          // Analytic frost instead of a live blur (see GlassCard).
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              if (!FrostScope.suppressesFrost(context))
                Positioned.fill(
                  child: AmbientFrost(frost: level.frost, palette: ambientPaletteForTheme(context), animate: ambientMotionEnabled(context, ref)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
                decoration: BoxDecoration(
                  gradient: glass.buttonFill(primary: isPrimary),
                  borderRadius: radius,
                  border: GradientBoxBorder(gradient: borderGradient, width: 1),
                ),
                child: _label(
                  context,
                  isPrimary ? (glass.onPrimary ?? colors.textPrimary) : colors.textPrimary,
                  isPrimary && glass.onPrimary != null ? glass.onPrimary! : colors.accent,
                ),
              ),
            ],
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

/**
 * Content taller than the card's [GlassCard.maxHeight]: it scrolls, and the
 * scrollbar stays visible whenever there is more to read, so a long quote
 * never looks cut off. With nothing to scroll the scrollbar draws nothing.
 */
class _ScrollingContent extends StatefulWidget {
  final Widget child;
  const _ScrollingContent({required this.child});

  @override
  State<_ScrollingContent> createState() => _ScrollingContentState();
}

class _ScrollingContentState extends State<_ScrollingContent> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      key: const ValueKey('glass-card-scrollbar'),
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(controller: _controller, physics: const BouncingScrollPhysics(), child: widget.child),
    );
  }
}
