/**
 * Immutable model of all user-configurable app settings.
 *
 * Persisted as JSON via [StorageService.updateSettings] and
 * loaded via [StorageService.settings]. Defaults are chosen for
 * a mindful, non-intrusive experience (auto-advance on, haptics on).
 */
library;

import 'package:flutter/foundation.dart';

class AppSettings {
  /** Whether haptic feedback is enabled for interactions. */
  final bool hapticFeedback;

  /** Whether pointings auto-advance to the next after [autoAdvanceDelay] seconds. */
  final bool autoAdvance;

  /** Seconds to wait before auto-advancing to the next pointing. */
  final int autoAdvanceDelay;

  /** Theme mode string: `'system'`, `'light'`, or `'dark'`. */
  final String theme;

  /** Whether high-contrast colour palette is active for accessibility. */
  final bool highContrast;

  /** Whether OLED-optimized true-black background is enabled. */
  final bool oledMode;

  /** Whether zen mode is active (hides UI chrome for distraction-free reading). */
  final bool zenMode;

  /** Whether animations and transitions are enabled (false forces reduced motion). */
  final bool animationsEnabled;

  const AppSettings({
    this.hapticFeedback = true,
    this.autoAdvance = true, // Default ON (opt-out)
    this.autoAdvanceDelay = 60, // 1 minute default
    this.theme = 'system',
    this.highContrast = false,
    this.oledMode = false,
    this.zenMode = false,
    this.animationsEnabled = true,
  });

  AppSettings copyWith({
    bool? hapticFeedback,
    bool? autoAdvance,
    int? autoAdvanceDelay,
    String? theme,
    bool? highContrast,
    bool? oledMode,
    bool? zenMode,
    bool? animationsEnabled,
  }) {
    return AppSettings(
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      autoAdvanceDelay: autoAdvanceDelay ?? this.autoAdvanceDelay,
      theme: theme ?? this.theme,
      highContrast: highContrast ?? this.highContrast,
      oledMode: oledMode ?? this.oledMode,
      zenMode: zenMode ?? this.zenMode,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'hapticFeedback': hapticFeedback,
    'autoAdvance': autoAdvance,
    'autoAdvanceDelay': autoAdvanceDelay,
    'theme': theme,
    'highContrast': highContrast,
    'oledMode': oledMode,
    'zenMode': zenMode,
    'animationsEnabled': animationsEnabled,
  };

  /**
   * Builds settings from persisted JSON, field by field.
   *
   * A missing field takes its default. A field of the wrong type (left by an
   * older schema or a manual edit) also takes its default, while the valid
   * fields are kept; the rejected fields are logged once per call.
   */
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const defaults = AppSettings();
    final rejected = <String>[];

    T read<T>(String key, T fallback) {
      final value = json[key];
      if (value == null) return fallback;
      if (value is T) return value;
      rejected.add(key);
      return fallback;
    }

    int readInt(String key, int fallback) {
      final value = json[key];
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num && value.isFinite && value == value.roundToDouble()) return value.toInt();
      rejected.add(key);
      return fallback;
    }

    final settings = AppSettings(
      hapticFeedback: read<bool>('hapticFeedback', defaults.hapticFeedback),
      autoAdvance: read<bool>('autoAdvance', defaults.autoAdvance),
      autoAdvanceDelay: readInt('autoAdvanceDelay', defaults.autoAdvanceDelay),
      theme: read<String>('theme', defaults.theme),
      highContrast: read<bool>('highContrast', defaults.highContrast),
      oledMode: read<bool>('oledMode', defaults.oledMode),
      zenMode: read<bool>('zenMode', defaults.zenMode),
      animationsEnabled: read<bool>('animationsEnabled', defaults.animationsEnabled),
    );
    if (rejected.isNotEmpty) {
      debugPrint('AppSettings: ignoring wrong-typed saved fields ${rejected.join(', ')}; using defaults for them');
    }
    return settings;
  }
}
