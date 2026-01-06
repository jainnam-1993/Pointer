import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import 'animated_gradient.dart';

/// Glass effect intensity levels - matches iOS Control Center aesthetic
enum GlassIntensity {
  light,
  standard,
  heavy,
}

/// Glassmorphic card widget with iOS-style frosted glass effects
class GlassCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;
  final GlassIntensity intensity;
  final double? minHeight;
  final double? maxHeight;
  final bool enableScrolling;

  /// Enable subtle breathing gradient animation
  /// When true, adds a slow shimmer effect that "breathes" with the background
  /// Respects reduceMotion accessibility setting
  final bool enableBreathingAnimation;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
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
    final highContrastColors = PointerColors.highContrast;

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: highContrastColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: highContrastColors.glassBorder,
          width: 2,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }

  Widget _buildGlassCard(BuildContext context, WidgetRef ref, PointerColors colors, bool isDark) {
    // Get blur and opacity values based on intensity - iOS Control Center style
    final (double blur, double topAlpha, double bottomAlpha) = switch (intensity) {
      GlassIntensity.light => isDark ? (25.0, 0.15, 0.08) : (20.0, 0.7, 0.45),
      GlassIntensity.standard => isDark ? (35.0, 0.25, 0.12) : (30.0, 0.85, 0.6),
      GlassIntensity.heavy => isDark ? (45.0, 0.38, 0.20) : (40.0, 0.95, 0.75),
    };

    // iOS-style glass gradient
    final glassGradient = LinearGradient(
      colors: [
        Colors.white.withValues(alpha: topAlpha),
        Colors.white.withValues(alpha: bottomAlpha),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final effectiveBorderColor = borderColor ?? colors.glassBorder;
    final borderGradient = isDark
        ? LinearGradient(
            colors: [
              effectiveBorderColor,
              effectiveBorderColor.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.08),
              Colors.black.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    Widget innerContent = child;
    if (maxHeight != null && enableScrolling) {
      innerContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: child,
      );
    }

    Widget constrainedContent = innerContent;
    if (minHeight != null || maxHeight != null) {
      constrainedContent = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight ?? 0,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: innerContent,
      );
    }

    // Check if breathing animation should be enabled
    // Respects: reduceMotion accessibility, test environment, and flag
    final appOverride = ref.watch(reduceMotionOverrideProvider);
    final reduceMotion = shouldReduceMotion(context, appOverride);
    final shouldAnimate = enableBreathingAnimation &&
        !reduceMotion &&
        !AnimatedGradient.disableAnimations &&
        !AnimatedGradient.isTestEnvironment();

    // Build the inner container with optional breathing animation overlay
    Widget glassContainer = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: glassGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: GradientBoxBorder(
          gradient: borderGradient,
          width: isDark ? 1.5 : 1,
        ),
      ),
      child: constrainedContent,
    );

    // Add breathing shimmer overlay when enabled
    if (shouldAnimate) {
      // Subtle shimmer that "breathes" - slower than background for layered effect
      // Uses theme's shimmerColor for consistency
      final shimmerColor = colors.shimmerColor.withValues(
        alpha: isDark ? 0.12 : 0.08, // Very subtle - not distracting
      );

      glassContainer = Stack(
        children: [
          glassContainer,
          // Animated shimmer overlay - positioned to match container bounds
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .shimmer(
                      duration: 8000.ms, // Slower than 4s background for layered feel
                      color: shimmerColor,
                      angle: 0.5, // Slight diagonal for organic feel
                    ),
              ),
            ),
          ),
        ],
      );
    }

    final card = Container(
      decoration: isDark
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: glassContainer,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Glassmorphic button widget with iOS-style effects
class GlassButton extends ConsumerWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Widget? icon;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
  });

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

  Widget _buildHighContrastButton(BuildContext context) {
    final highContrastColors = PointerColors.highContrast;

    // Wrap with ConstrainedBox to ensure 48px touch target (WCAG 2.5.8)
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: highContrastColors.cardBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: highContrastColors.glassBorder,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: highContrastColors.textPrimary,
                    ),
                  )
                else ...[
                  Text(
                    label,
                    style: TextStyle(
                      color: highContrastColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    icon!,
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton(BuildContext context, PointerColors colors, bool isDark) {
    final spinnerColor = colors.primary;

    final glassGradient = isDark
        ? LinearGradient(
            colors: isPrimary
                ? [Colors.white.withValues(alpha: 0.30), Colors.white.withValues(alpha: 0.15)]
                : [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.10)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: isPrimary
                ? [Colors.white.withValues(alpha: 0.92), Colors.white.withValues(alpha: 0.65)]
                : [Colors.white.withValues(alpha: 0.85), Colors.white.withValues(alpha: 0.55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final borderColor = isPrimary ? colors.glassBorderActive : colors.glassBorder;
    final borderGradient = LinearGradient(
      colors: [borderColor, borderColor.withValues(alpha: 0.3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Wrap with ConstrainedBox to ensure 48px touch target (WCAG 2.5.8)
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: glassGradient,
                borderRadius: BorderRadius.circular(32),
                border: GradientBoxBorder(gradient: borderGradient, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
                    )
                  else ...[
                    Text(
                      label,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (icon != null) ...[const SizedBox(width: 8), icon!],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/// Simple glass container for backgrounds and overlays
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 40,
    this.opacity = 0.25,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final effectiveRadius = borderRadius ?? BorderRadius.zero;
    final bgOpacity = isDark ? opacity : opacity + 0.5;

    return ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: bgOpacity),
            borderRadius: effectiveRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glass-styled bottom sheet with iOS Control Center aesthetic
class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showHandle;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.padding,
    this.showHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: padding ?? EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: bottomPadding + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showHandle) ...[
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colors.textMuted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                  Flexible(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-styled dialog with iOS aesthetic
class GlassDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;

  const GlassDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.28 : 0.92),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (content != null) content!,
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!
                        .map((action) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: action,
                            ))
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

/// Custom gradient border for BoxDecoration
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
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
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
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
