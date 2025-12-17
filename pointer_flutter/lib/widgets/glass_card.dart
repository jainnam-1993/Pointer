import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Glassmorphic card widget with enhanced glass effects
///
/// Supports Dynamic Type with flexible height and scrolling when content
/// exceeds the maximum height constraint.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? borderColor;
  final VoidCallback? onTap;

  /// Minimum height constraint for the card content (default: none)
  final double? minHeight;

  /// Maximum height constraint for the card content (default: none)
  /// When set, enables scrolling if content exceeds this height
  final double? maxHeight;

  /// Whether to enable scrolling when content exceeds maxHeight
  /// Only applies when maxHeight is set
  final bool enableScrolling;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.blur = 20,
    this.borderColor,
    this.onTap,
    this.minHeight,
    this.maxHeight,
    this.enableScrolling = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    // Enhanced liquid glass gradient - stronger opacity for dark mode
    final glassGradient = isDark
        ? LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.20),
              Colors.white.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final effectiveBorderColor = borderColor ?? colors.glassBorder;

    // Liquid glass border gradient - brighter at top-left, fading to bottom-right
    // For light mode, use subtle dark border for visibility
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
              Colors.black.withValues(alpha: 0.06),
              Colors.black.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    // Build the inner content, optionally wrapped in scroll view
    Widget innerContent = child;
    if (maxHeight != null && enableScrolling) {
      innerContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: child,
      );
    }

    // Apply constraints if specified
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

    final card = Container(
      decoration: isDark
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
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
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// Glassmorphic button widget with enhanced glass effects
class GlassButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final spinnerColor = isDark ? Colors.white : AppColorsLight.primary;

    // Enhanced liquid glass gradient for buttons - more visible on black background
    final glassGradient = isDark
        ? LinearGradient(
            colors: isPrimary
                ? [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.white.withValues(alpha: 0.12),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.08),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: isPrimary
                ? [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.6),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.5),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final borderColor = isPrimary ? colors.glassBorderActive : colors.glassBorder;
    final borderGradient = LinearGradient(
      colors: [
        borderColor,
        borderColor.withValues(alpha: 0.3),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: glassGradient,
                borderRadius: BorderRadius.circular(32),
                border: GradientBoxBorder(
                  gradient: borderGradient,
                  width: 1,
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
                        color: spinnerColor,
                      ),
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
      ),
    );
  }
}

/// Custom gradient border for BoxDecoration
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 1.0,
  });

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
      canvas.drawRRect(
        borderRadius.resolve(textDirection).toRRect(rect),
        paint,
      );
    } else if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) => GradientBoxBorder(
        gradient: gradient,
        width: width * t,
      );
}
