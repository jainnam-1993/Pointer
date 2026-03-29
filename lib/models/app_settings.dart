/**
 * Immutable model of all user-configurable app settings.
 *
 * Persisted as JSON via [StorageService.updateSettings] and
 * loaded via [StorageService.settings]. Defaults are chosen for
 * a mindful, non-intrusive experience (auto-advance on, haptics on).
 */
library;

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

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hapticFeedback: json['hapticFeedback'] ?? true,
      autoAdvance: json['autoAdvance'] ?? true, // Default ON
      autoAdvanceDelay: json['autoAdvanceDelay'] ?? 60, // 1 minute
      theme: json['theme'] ?? 'system',
      highContrast: json['highContrast'] ?? false,
      oledMode: json['oledMode'] ?? false,
      zenMode: json['zenMode'] ?? false,
      animationsEnabled: json['animationsEnabled'] ?? true,
    );
  }
}
