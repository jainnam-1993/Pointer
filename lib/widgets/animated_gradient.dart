import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'ambient.dart';
import '../utils/motion.dart';

/**
 * Time-of-day period for the 24-hour gradient cycle.
 *
 * Each period maps to a distinct dark-mode background gradient palette
 * in [AnimatedGradient], creating a subtle ambient awareness of real-world time.
 */
enum TimeOfDayPeriod {
  /** 5-7 AM: soft warm tones for early morning. */
  dawn,

  /** 7 AM-12 PM: bright, energizing tones. */
  morning,

  /** 12-2 PM: warm, golden mid-day tones. */
  midday,

  /** 2-5 PM: calming transitional tones. */
  afternoon,

  /** 5-8 PM: warm oranges and purples for sunset. */
  dusk,

  /** 8-10 PM: deep purples and blues for the evening. */
  evening,

  /** 10 PM-5 AM: deep, restful near-black tones. */
  night,
}

/** Get current time period for gradient selection */
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

/** Get gradient colors for time period (dark mode) */
/** Period the ambient background shows now (honours [AnimatedGradient.debugPeriodOverride]). */
TimeOfDayPeriod currentAmbientPeriod() => AnimatedGradient.debugPeriodOverride ?? _getCurrentTimePeriod();

/** Whether ambient motion should run in this context (reduce motion, tests, flags). */
bool ambientMotionEnabled(BuildContext context, WidgetRef ref) {
  final reduceMotion = Motion.reduce(context);
  if (reduceMotion || AnimatedGradient.disableAnimations) return false;
  return AnimatedGradient.forceMotionInTests || !AnimatedGradient.isTestEnvironment();
}

/**
 * Ambient palette resolved from the inherited Theme alone (no providers), for
 * frost surfaces that may build outside the app's provider overrides.
 */
AmbientPalette ambientPaletteForTheme(BuildContext context) {
  final colors = context.colors;
  if (identical(colors, PointerColors.highContrastLight)) return AmbientPalette.light.subdued();
  if (identical(colors, PointerColors.highContrast)) return AmbientPalette.dark[currentAmbientPeriod().index].subdued();
  if (!context.isDarkMode) return AmbientPalette.light;
  if (identical(context.colors, PointerColors.oled)) return AmbientPalette.oled;
  return AmbientPalette.dark[currentAmbientPeriod().index];
}

/**
 * Ambient palette for the current theme, OLED setting and [period].
 * Glass cards call this so their analytic frost matches the background.
 */
AmbientPalette ambientPaletteFor(BuildContext context, WidgetRef ref, {TimeOfDayPeriod? period}) {
  final themeMode = ref.watch(themeModeProvider);
  final isDark = themeMode == AppThemeMode.dark || (themeMode == AppThemeMode.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);
  // OLED wins regardless of theme, as before the shader.
  if (ref.watch(oledModeProvider)) return AmbientPalette.oled;
  final base = isDark ? AmbientPalette.dark[(period ?? currentAmbientPeriod()).index] : AmbientPalette.light;
  // High contrast keeps the ambient but tones it down behind the opaque cards.
  return GlassMaterial.of(context).opaque ? base.subdued() : base;
}

/**
 * Ambient background: time-of-day gradient, aurora flow and dust motes from shaders/ambient.frag
 *
 * Features:
 * - 24h gradient cycle - colors shift based on time of day with auto-refresh
 * - Smooth 5-minute polling to detect time period changes
 * - Respects accessibility settings (reduce motion)
 * - OLED mode support (pure black)
 *
 * Excluded from accessibility tree as it's purely decorative.
 * Set [disableAnimations] to true in tests to prevent timer issues.
 */
class AnimatedGradient extends ConsumerStatefulWidget {
  const AnimatedGradient({super.key, this.periodOverride});

  /** Disable animations globally (for testing) */
  static bool disableAnimations = false;

  /**
   * Global fixed period used when [periodOverride] is null (for golden tests).
   *
   * Screens build `const AnimatedGradient()`, so tests cannot pass [periodOverride]
   * through them; setting this freezes the wall-clock-dependent gradient instead.
   */
  static TimeOfDayPeriod? debugPeriodOverride;

  /** Lets integration tests (idle_frames_test) run the real ambient clock under a test binding. */
  static bool forceMotionInTests = false;

  /** Optional fixed period for deterministic rendering in tests/previews. */
  final TimeOfDayPeriod? periodOverride;

  /** Check if running in test environment */
  static bool isTestEnvironment() {
    // AutomatedTestWidgetsFlutterBinding sets this
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  @override
  ConsumerState<AnimatedGradient> createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends ConsumerState<AnimatedGradient> {
  Timer? _timeCheckTimer;
  late TimeOfDayPeriod _currentPeriod;

  @override
  void initState() {
    super.initState();
    _currentPeriod = widget.periodOverride ?? AnimatedGradient.debugPeriodOverride ?? _getCurrentTimePeriod();
    _configureTimeCheckTimer();
  }

  @override
  void dispose() {
    _timeCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedGradient oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodOverride != widget.periodOverride) {
      _currentPeriod = widget.periodOverride ?? AnimatedGradient.debugPeriodOverride ?? _getCurrentTimePeriod();
      _configureTimeCheckTimer();
    }
  }

  void _configureTimeCheckTimer() {
    _timeCheckTimer?.cancel();
    // Check time period every 5 minutes for 24h gradient cycle.
    // Skip timer when a fixed period is requested or tests disable animation.
    if (widget.periodOverride != null ||
        AnimatedGradient.debugPeriodOverride != null ||
        AnimatedGradient.disableAnimations ||
        AnimatedGradient.isTestEnvironment()) {
      return;
    }

    _timeCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _checkTimePeriodChange();
    });
  }

  void _checkTimePeriodChange() {
    if (widget.periodOverride != null) return;
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
    // One shader pass: time-of-day gradient, aurora flow, dust motes, dither.
    // Falls back to a gradient painter if the FragmentProgram cannot load.
    final reduceMotion = Motion.reduce(context);
    AmbientClock.instance.setReduceMotion(reduceMotion);
    final palette = ambientPaletteFor(context, ref, period: _currentPeriod);
    return AmbientBackground(palette: palette, animate: ambientMotionEnabled(context, ref));
  }
}
