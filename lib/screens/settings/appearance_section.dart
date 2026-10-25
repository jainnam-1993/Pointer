/** Appearance settings section: theme selector, zen mode toggle, and animation toggle. */
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/motion.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pointer_switch.dart';
import '../../utils/haptics.dart';

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
          // One segmented control: a quiet track, the selected segment a filled pill on it.
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: context.colors.textPrimary.withValues(alpha: SelectionTint.resting),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd + AppSpacing.xs),
            ),
            child: Row(
              children: [
                ThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode_outlined,
                  isSelected: currentMode == AppThemeMode.light,
                  onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.light),
                ),
                const SizedBox(width: AppSpacing.xs),
                ThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  isSelected: currentMode == AppThemeMode.dark,
                  onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.dark),
                ),
                const SizedBox(width: AppSpacing.xs),
                ThemeOption(
                  label: 'System',
                  icon: Icons.settings_brightness_outlined,
                  isSelected: currentMode == AppThemeMode.system,
                  onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.system),
                ),
              ],
            ),
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
    final unselectedColor = colors.textSecondary;

    // Enhanced selection visibility:
    // - Thicker border (2px selected vs 1px unselected)
    // - Stronger background fill
    // - High contrast border color
    // One level inside the Appearance card: only the selected segment has a fill, like a segmented control.
    final bgColor = isSelected ? SelectionTint.fill(colors, selected: true, isDark: isDark) : Colors.transparent;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: '$label theme${isSelected ? ', selected' : ''}',
        child: GestureDetector(
          onTap: () async {
            Haptics.selection();
            onTap();
          },
          child: AnimatedContainer(
            duration: Motion.reduce(context) ? Duration.zero : Motion.quick,
            curve: Motion.inOut,
            constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            child: Column(
              children: [
                // Selection shows through the segment fill and label weight; no badge over the glyph.
                Icon(icon, size: 24, color: isSelected ? colors.textPrimary : unselectedColor),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? colors.textPrimary : unselectedColor,
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
