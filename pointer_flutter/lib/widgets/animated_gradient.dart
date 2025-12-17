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

    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A0A3A),
              Color(0xFF0F0524),
              Color(0xFF150A2E),
            ],
          )
        : AppGradients.backgroundLight;

    final shimmerColor = isDark
        ? AppColors.primary.withValues(alpha: 0.1)
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
          duration: 3000.ms,
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
    final particleColor = isDark ? Colors.white : Colors.black;

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
                color: particleColor.withValues(alpha: 0.1 + (index % 3) * 0.05),
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
