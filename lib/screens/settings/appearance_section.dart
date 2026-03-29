/** Appearance settings section: theme selector, zen mode toggle, and animation toggle. */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pointer_switch.dart';

/**
 * Appearance settings card containing theme selection, zen mode toggle, and animation toggle.
 *
 * Theme options: Light, Dark, System (via [AppThemeMode]). Contained within a [GlassCard]
 * with [ThemeOption] buttons, [ZenModeToggle], and [AnimationToggle].
 */
class AppearanceSelector extends ConsumerWidget {
  const AppearanceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: TextStyle(fontSize: 16, color: context.colors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              ThemeOption(
                label: 'Light',
                icon: Icons.light_mode_outlined,
                isSelected: currentMode == AppThemeMode.light,
                onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.light),
              ),
              const SizedBox(width: 12),
              ThemeOption(
                label: 'Dark',
                icon: Icons.dark_mode_outlined,
                isSelected: currentMode == AppThemeMode.dark,
                onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.dark),
              ),
              const SizedBox(width: 12),
              ThemeOption(
                label: 'System',
                icon: Icons.settings_brightness_outlined,
                isSelected: currentMode == AppThemeMode.system,
                onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.system),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // OLED Black Mode toggle removed (Phase 5.5) - caused light mode to turn black
          // Zen Mode toggle
          ZenModeToggle(),
          const SizedBox(height: 12),
          AnimationToggle(),
        ],
      ),
    );
  }
}

/** Toggle switch for zen mode (minimal UI with only the pointing text, no navigation bar). */
class ZenModeToggle extends ConsumerWidget {
  const ZenModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isZenMode = ref.watch(zenModeProvider);
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Zen Mode', style: TextStyle(fontSize: 14, color: colors.textPrimary)),
              const SizedBox(height: 2),
              Text('Minimal UI, just the pointing', style: TextStyle(fontSize: 12, color: colors.textMuted)),
            ],
          ),
        ),
        PointerSwitch(
          value: isZenMode,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setZenMode(value);
          },
        ),
      ],
    );
  }
}

/**
 * Toggle switch for background animations (gradient and floating particles).
 *
 * When disabled, bridges to [reduceMotionOverrideProvider] to suppress
 * all motion throughout the app.
 */
class AnimationToggle extends ConsumerWidget {
  const AnimationToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Background Animation', style: TextStyle(fontSize: 14, color: colors.textPrimary)),
              const SizedBox(height: 2),
              Text('Animated gradient and floating particles', style: TextStyle(fontSize: 12, color: colors.textMuted)),
            ],
          ),
        ),
        PointerSwitch(
          value: settings.animationsEnabled,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setAnimationsEnabled(value);
          },
        ),
      ],
    );
  }
}

// _OledModeToggle removed (Phase 5.5) - caused light mode to turn black
// Provider and storage keys retained for backwards compatibility

/**
 * Selectable theme option button with icon, label, and animated selection state.
 *
 * When selected, shows a thicker accent-colored border, tinted background, and a
 * small checkmark overlay on the icon. Designed for use in [AppearanceSelector].
 */
class ThemeOption extends StatelessWidget {
  /** Display label (e.g., "Light", "Dark", "System"). */
  final String label;

  /** Icon displayed above the label. */
  final IconData icon;

  /** Whether this option is currently selected. */
  final bool isSelected;

  /** Callback when this option is tapped. */
  final VoidCallback onTap;

  const ThemeOption({super.key, required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    // Use accent color for better visibility across themes
    final accentColor = colors.accent;
    final unselectedColor = colors.textSecondary;

    // Enhanced selection visibility:
    // - Thicker border (2px selected vs 1px unselected)
    // - Stronger background fill
    // - High contrast border color
    final borderColor = isSelected ? accentColor : colors.glassBorder;
    final borderWidth = isSelected ? 2.0 : 1.0;
    final bgColor = isSelected ? accentColor.withValues(alpha: isDark ? 0.25 : 0.15) : Colors.transparent;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label theme${isSelected ? ', selected' : ''}',
        child: GestureDetector(
          onTap: () async {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Column(
              children: [
                // Stack icon with checkmark overlay when selected
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, size: 24, color: isSelected ? accentColor : unselectedColor),
                    // Checkmark indicator in bottom-right corner
                    if (isSelected)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                          child: const Icon(Icons.check, size: 10, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? accentColor : unselectedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
