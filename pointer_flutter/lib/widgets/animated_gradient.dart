import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Time period for 24h gradient cycle
enum TimeOfDayPeriod {
  dawn,    // 5-7am - soft warm colors
  morning, // 7-12pm - bright, energizing
  midday,  // 12-2pm - warm, golden
  afternoon, // 2-5pm - calming transition
  dusk,    // 5-8pm - warm oranges and purples
  evening, // 8-10pm - deep purples and blues
  night,   // 10pm-5am - deep, restful
}

/// Get current time period for gradient selection
TimeOfDayPeriod _getCurrentTimePeriod() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 7) return TimeOfDayPeriod.dawn;
  if (hour >= 7 && hour < 12) return TimeOfDayPeriod.morning;
  if (hour >= 12 && hour < 14) return TimeOfDayPeriod.midday;
  if (hour >= 14 && hour < 17) return TimeOfDayPeriod.afternoon;
  if (hour >= 17 && hour < 20) return TimeOfDayPeriod.dusk;
  if (hour >= 20 && hour < 22) return TimeOfDayPeriod.evening;
  return TimeOfDayPeriod.night;
}

/// Get gradient colors for time period (dark mode)
LinearGradient _getTimeBasedGradient(TimeOfDayPeriod period) {
  switch (period) {
    case TimeOfDayPeriod.dawn:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
      );
    case TimeOfDayPeriod.morning:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D0D0D), Color(0xFF1a1a2e), Color(0xFF0f0f1a)],
      );
    case TimeOfDayPeriod.midday:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D0D0D), Color(0xFF050505), Color(0xFF0a0a0a)],
      );
    case TimeOfDayPeriod.afternoon:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D0D0D), Color(0xFF1a0a2e), Color(0xFF0f0a1a)],
      );
    case TimeOfDayPeriod.dusk:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1a0a1e), Color(0xFF2d0a3e), Color(0xFF0f0a2a)],
      );
    case TimeOfDayPeriod.evening:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0524), Color(0xFF1A0A3A), Color(0xFF0a0a1a)],
      );
    case TimeOfDayPeriod.night:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.3, 0.7, 1.0],
        colors: [
          Color(0xFF0D0D0D),
          Color(0xFF050505),
          Color(0xFF000000),
          Color(0xFF0A0A0A),
        ],
      );
  }
}

/// Animated gradient background using flutter_animate
///
/// Features:
/// - 24h gradient cycle - colors shift based on time of day
/// - Respects accessibility settings (reduce motion)
/// - OLED mode support (pure black)
///
/// Excluded from accessibility tree as it's purely decorative.
/// Set [disableAnimations] to true in tests to prevent timer issues.
class AnimatedGradient extends ConsumerWidget {
  const AnimatedGradient({super.key});

  /// Disable animations globally (for testing)
  static bool disableAnimations = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Exclude decorative background from accessibility tree
    return ExcludeSemantics(
      child: _buildGradient(context, ref),
    );
  }

  Widget _buildGradient(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Check OLED mode - pure black background, no gradient animation
    final isOledMode = ref.watch(oledModeProvider);
    if (isOledMode) {
      return Container(color: Colors.black);
    }

    // Check reduce motion preference
    final appOverride = ref.watch(reduceMotionOverrideProvider);
    final reduceMotion = shouldReduceMotion(context, appOverride);

    // Time-based gradient for 24h cycle (dark mode) or light theme gradient
    final gradient = isDark
        ? _getTimeBasedGradient(_getCurrentTimePeriod())
        : AppGradients.backgroundLight;

    // Enhanced shimmer for dark mode - subtle glow effect on black background
    final shimmerColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColorsLight.primary.withValues(alpha: 0.08);

    final container = Container(
      decoration: BoxDecoration(gradient: gradient),
    );

    // Skip animations when:
    // 1. Static flag is set (for testing)
    // 2. In test environment
    // 3. Reduce motion is enabled (accessibility)
    if (disableAnimations ||
        reduceMotion ||
        kDebugMode && !kIsWeb && _isTestEnvironment()) {
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
/// Respects accessibility settings:
/// - System reduce motion (MediaQuery.disableAnimations)
/// - App-level override (reduceMotionOverrideProvider)
/// - [AnimatedGradient.disableAnimations] for test compatibility
///
/// Excluded from accessibility tree as it's purely decorative.
class FloatingParticles extends ConsumerWidget {
  const FloatingParticles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check reduce motion preference
    final appOverride = ref.watch(reduceMotionOverrideProvider);
    final reduceMotion = shouldReduceMotion(context, appOverride);

    // Skip animations when:
    // 1. Static flag is set (for testing)
    // 2. In test environment
    // 3. Reduce motion is enabled (accessibility)
    if (AnimatedGradient.disableAnimations ||
        reduceMotion ||
        kDebugMode && !kIsWeb && AnimatedGradient._isTestEnvironment()) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Enhanced particle visibility for dark mode
    final particleColor = isDark ? Colors.white : Colors.black;
    final baseAlpha = isDark ? 0.15 : 0.1;

    // Exclude decorative particles from accessibility tree
    return ExcludeSemantics(
      child: IgnorePointer(
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
      ),
    );
  }
}
