import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Animated gradient background using flutter_animate
///
/// Set [disableAnimations] to true in tests to prevent timer issues.
class AnimatedGradient extends StatelessWidget {
  const AnimatedGradient({super.key});

  /// Disable animations globally (for testing)
  static bool disableAnimations = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Enhanced dark mode gradient with more color depth and variation
    // Matches the visual richness of light mode
    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.6, 1.0],
            colors: [
              Color(0xFF2D1B4E), // Rich purple at top
              Color(0xFF1A0A3A), // Deep violet
              Color(0xFF0F0524), // Dark base
              Color(0xFF1E1145), // Subtle purple glow at bottom
            ],
          )
        : AppGradients.backgroundLight;

    // Enhanced shimmer for dark mode - more visible glow effect
    final shimmerColor = isDark
        ? AppColors.primary.withValues(alpha: 0.15)
        : AppColorsLight.primary.withValues(alpha: 0.08);

    final container = Container(
      decoration: BoxDecoration(gradient: gradient),
    );

    // Skip animations in test mode to prevent timer issues
    if (disableAnimations || kDebugMode && !kIsWeb && _isTestEnvironment()) {
      return container;
    }

    return container
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .shimmer(
          duration: 4000.ms, // Slightly slower for smoother feel
          color: shimmerColor,
        );
  }

  /// Check if running in test environment
  static bool _isTestEnvironment() {
    // AutomatedTestWidgetsFlutterBinding sets this
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }
}

/// Floating particles effect
///
/// Respects [AnimatedGradient.disableAnimations] for test compatibility.
class FloatingParticles extends StatelessWidget {
  const FloatingParticles({super.key});

  @override
  Widget build(BuildContext context) {
    // Skip animations in test mode
    if (AnimatedGradient.disableAnimations ||
        kDebugMode && !kIsWeb && AnimatedGradient._isTestEnvironment()) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Enhanced particle visibility for dark mode
    final particleColor = isDark ? Colors.white : Colors.black;
    final baseAlpha = isDark ? 0.15 : 0.1;

    return IgnorePointer(
      child: Stack(
        children: List.generate(6, (index) {
          return Positioned(
            left: (index * 60.0) + 20,
            top: (index * 80.0) + 50,
            child: Container(
              width: 4 + (index % 3) * 2.0,
              height: 4 + (index % 3) * 2.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: particleColor.withValues(alpha: baseAlpha + (index % 3) * 0.05),
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: 0,
                  end: -20 - index * 5.0,
                  duration: (3000 + index * 500).ms,
                  curve: Curves.easeInOut,
                )
                .fadeIn(
                  duration: 1000.ms,
                ),
          );
        }),
      ),
    );
  }
}
