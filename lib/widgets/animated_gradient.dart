import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/**
 * Time-of-day period for the 24-hour gradient cycle.
 *
 * Each period maps to a distinct dark-mode background gradient palette
 * in [AnimatedGradient], creating a subtle ambient awareness of real-world time.
 */
enum TimeOfDayPeriod {
  /// 5-7 AM: soft warm tones for early morning.
  dawn,

  /// 7 AM-12 PM: bright, energizing tones.
  morning,

  /// 12-2 PM: warm, golden mid-day tones.
  midday,

  /// 2-5 PM: calming transitional tones.
  afternoon,

  /// 5-8 PM: warm oranges and purples for sunset.
  dusk,

  /// 8-10 PM: deep purples and blues for the evening.
  evening,

  /// 10 PM-5 AM: deep, restful near-black tones.
  night,
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
      // B.3: Shifted from blue-purple to warm dark (was 0xFF16213e, 0xFF0f3460)
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0C0A0A), Color(0xFF0E0C0A), Color(0xFF100E0C)],
      );
    case TimeOfDayPeriod.morning:
      // B.3: Shifted from blue-purple to neutral dark (was 0xFF1a1a2e, 0xFF0f0f1a)
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D0D0D), Color(0xFF0E0E10), Color(0xFF0A0A0C)],
      );
    case TimeOfDayPeriod.midday:
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D0D0D), Color(0xFF050505), Color(0xFF0a0a0a)],
      );
    case TimeOfDayPeriod.afternoon:
      // B.3: Shifted from purple to neutral dark (was 0xFF1a0a2e, 0xFF0f0a1a)
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D0D0D), Color(0xFF0A0A0E), Color(0xFF080810)],
      );
    case TimeOfDayPeriod.dusk:
      // B.3: Shifted from purple to warm dark (was 0xFF1a0a1e, 0xFF2d0a3e)
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0E0A0A), Color(0xFF100C0C), Color(0xFF0A0808)],
      );
    case TimeOfDayPeriod.evening:
      // B.3: Shifted from purple to cool dark (was 0xFF0F0524, 0xFF1A0A3A)
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF080810), Color(0xFF0A0A12), Color(0xFF060608)],
      );
    case TimeOfDayPeriod.night:
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.3, 0.7, 1.0],
        colors: [Color(0xFF0D0D0D), Color(0xFF050505), Color(0xFF000000), Color(0xFF0A0A0A)],
      );
  }
}

/// Device performance tier for adaptive animation complexity
enum _DeviceTier { high, mid, low }

/// Classify device by screen metrics for adaptive animation tuning
_DeviceTier _getDeviceTier(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final dpr = MediaQuery.of(context).devicePixelRatio;
  if (size.height >= 800 && dpr >= 3.0) return _DeviceTier.high;
  if (size.height < 700) return _DeviceTier.low;
  return _DeviceTier.mid;
}

/// Animated gradient background using flutter_animate
///
/// Features:
/// - 24h gradient cycle - colors shift based on time of day with auto-refresh
/// - Smooth 5-minute polling to detect time period changes
/// - Respects accessibility settings (reduce motion)
/// - OLED mode support (pure black)
///
/// Excluded from accessibility tree as it's purely decorative.
/// Set [disableAnimations] to true in tests to prevent timer issues.
class AnimatedGradient extends ConsumerStatefulWidget {
  const AnimatedGradient({super.key});

  /// Disable animations globally (for testing)
  static bool disableAnimations = false;

  /// Check if running in test environment
  static bool isTestEnvironment() {
    // AutomatedTestWidgetsFlutterBinding sets this
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  @override
  ConsumerState<AnimatedGradient> createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends ConsumerState<AnimatedGradient> {
  Timer? _timeCheckTimer;
  TimeOfDayPeriod _currentPeriod = _getCurrentTimePeriod();

  @override
  void initState() {
    super.initState();
    // Check time period every 5 minutes for 24h gradient cycle
    // Skip timer in test environment to avoid timer issues
    if (!AnimatedGradient.disableAnimations && !AnimatedGradient.isTestEnvironment()) {
      _timeCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        _checkTimePeriodChange();
      });
    }
  }

  @override
  void dispose() {
    _timeCheckTimer?.cancel();
    super.dispose();
  }

  void _checkTimePeriodChange() {
    final newPeriod = _getCurrentTimePeriod();
    if (newPeriod != _currentPeriod) {
      setState(() {
        _currentPeriod = newPeriod;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme mode provider to force rebuild on theme change
    final themeMode = ref.watch(themeModeProvider);

    // Exclude decorative background from accessibility tree
    return ExcludeSemantics(child: _buildGradient(context, themeMode));
  }

  Widget _buildGradient(BuildContext context, AppThemeMode themeMode) {
    // Derive isDark from provider value (not Theme.of) for proper rebuild
    final isDark =
        themeMode == AppThemeMode.dark || (themeMode == AppThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    // Check OLED mode - pure black background, no gradient animation
    final isOledMode = ref.watch(oledModeProvider);
    if (isOledMode) {
      return Container(color: Colors.black);
    }

    // Check reduce motion preference
    final appOverride = ref.watch(reduceMotionOverrideProvider);
    final reduceMotion = shouldReduceMotion(context, appOverride);

    // Time-based gradient for 24h cycle (dark mode) or light theme gradient
    final gradient = isDark ? _getTimeBasedGradient(_currentPeriod) : AppGradients.backgroundLight;

    // Enhanced shimmer with visible tints for both themes
    final shimmerColor = isDark
        ? const Color(0xFFFFE082).withValues(alpha: 0.18) // Warm amber shimmer
        : const Color(0xFFB794F4).withValues(alpha: 0.25); // Soft violet shimmer for light mode

    final container = Container(decoration: BoxDecoration(gradient: gradient));

    // Skip animations when:
    // 1. Static flag is set (for testing)
    // 2. In test environment
    // 3. Reduce motion is enabled (accessibility)
    if (AnimatedGradient.disableAnimations || reduceMotion || kDebugMode && !kIsWeb && AnimatedGradient.isTestEnvironment()) {
      return container;
    }

    // Adaptive shimmer duration based on device capability
    final tier = _getDeviceTier(context);
    final shimmerDuration = switch (tier) {
      _DeviceTier.high => 4000.ms,
      _DeviceTier.mid => 5333.ms, // ~45fps equivalent
      _DeviceTier.low => 8000.ms, // ~30fps equivalent
    };

    return RepaintBoundary(
      child: container.animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: shimmerDuration, color: shimmerColor),
    );
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
    if (AnimatedGradient.disableAnimations || reduceMotion || kDebugMode && !kIsWeb && AnimatedGradient.isTestEnvironment()) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Enhanced particle visibility for dark mode
    final particleColor = isDark ? Colors.white : Colors.black;
    final baseAlpha = isDark ? 0.15 : 0.1;

    // Adaptive particle count and duration based on device capability
    final tier = _getDeviceTier(context);
    final particleCount = switch (tier) {
      _DeviceTier.high => 6,
      _DeviceTier.mid => 3,
      _DeviceTier.low => 2,
    };
    final baseDuration = switch (tier) {
      _DeviceTier.high => 4000,
      _DeviceTier.mid => 5333,
      _DeviceTier.low => 8000,
    };

    // Exclude decorative particles from accessibility tree
    // Position particles around edges only (corners and margins)
    return ExcludeSemantics(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // Edge positions (corners and margins, avoiding center)
            final allPositions = [
              // Top corners
              Offset(20, 40),
              Offset(width - 30, 60),
              // Bottom corners
              Offset(30, height - 80),
              Offset(width - 40, height - 100),
              // Side margins (upper third and lower third only)
              Offset(15, height * 0.15),
              Offset(width - 20, height * 0.85),
            ];

            final positions = allPositions.take(particleCount).toList();

            return Stack(
              children: List.generate(positions.length, (index) {
                final pos = positions[index];
                return Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  // Single controller per particle (was 2: moveY + fade)
                  // Synced base duration replaces index*600 offset
                  child:
                      Container(
                            width: 3 + (index % 3) * 1.5,
                            height: 3 + (index % 3) * 1.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: particleColor.withValues(alpha: baseAlpha + (index % 3) * 0.03),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .custom(
                            duration: baseDuration.ms,
                            curve: Curves.easeInOut,
                            builder: (context, value, child) => Opacity(
                              opacity: value,
                              child: Transform.translate(offset: Offset(0, -15 * value), child: child),
                            ),
                          ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
