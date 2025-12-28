// Inquiry Visual - Breathing/pulse animation for inquiry pauses
// Respects accessibility settings (reduced motion)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// A breathing/pulsing visual element for inquiry pauses
///
/// Displays a subtle animated circle that expands and contracts
/// to encourage mindful breathing during contemplation.
///
/// Respects accessibility settings:
/// - System reduce motion (MediaQuery.disableAnimations)
/// - App-level override (reduceMotionOverrideProvider)
/// - [disableAnimations] flag for testing
class InquiryVisual extends ConsumerWidget {
  const InquiryVisual({
    super.key,
    this.size = 120,
    this.color,
  });

  /// Size of the visual element
  final double size;

  /// Optional custom color (defaults to theme accent)
  final Color? color;

  /// Disable animations globally (for testing)
  static bool disableAnimations = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    // Check reduce motion preference
    final appOverride = ref.watch(reduceMotionOverrideProvider);
    final reduceMotion = shouldReduceMotion(context, appOverride);

    final visualColor = color ?? colors.accent;
    final glowColor = visualColor.withValues(alpha: 0.3);

    // Static version for reduced motion or testing
    if (disableAnimations || reduceMotion) {
      return _buildStaticVisual(visualColor, glowColor, isDark);
    }

    // Animated breathing visual
    return _buildAnimatedVisual(visualColor, glowColor, isDark);
  }

  Widget _buildStaticVisual(Color visualColor, Color glowColor, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: visualColor.withValues(alpha: 0.15),
            border: Border.all(
              color: visualColor.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedVisual(Color visualColor, Color glowColor, bool isDark) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring - slow pulse
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: visualColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
                duration: 4000.ms,
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: 1000.ms),

          // Middle ring
          Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: visualColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 3500.ms,
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: 800.ms),

          // Inner breathing circle
          Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: visualColor.withValues(alpha: 0.12),
              border: Border.all(
                color: visualColor.withValues(alpha: 0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 25,
                  spreadRadius: 8,
                ),
              ],
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1.15, 1.15),
                duration: 3000.ms,
                curve: Curves.easeInOut,
              )
              .fadeIn(duration: 600.ms),

          // Center dot
          Container(
            width: size * 0.08,
            height: size * 0.08,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: visualColor.withValues(alpha: 0.6),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .fade(
                begin: 0.4,
                end: 0.8,
                duration: 2500.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }
}
