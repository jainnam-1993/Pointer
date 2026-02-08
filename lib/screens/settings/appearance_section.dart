// Appearance section - theme selector, zen mode, animation toggle
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

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

class ZenModeToggle extends ConsumerWidget {
  const ZenModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isZenMode = ref.watch(zenModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final switchThumbColor = isDark ? Colors.white : colors.primary;
    final switchActiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.4) : colors.primary.withValues(alpha: 0.3);
    final switchInactiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3);

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
        Switch(
          value: isZenMode,
          onChanged: (value) {
            ref.read(zenModeProvider.notifier).state = value;
          },
          activeThumbColor: switchThumbColor,
          activeTrackColor: switchActiveTrackColor,
          inactiveThumbColor: isDark ? Colors.white : Colors.grey,
          inactiveTrackColor: switchInactiveTrackColor,
        ),
      ],
    );
  }
}

class AnimationToggle extends ConsumerWidget {
  const AnimationToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = context.colors;
    final switchThumbColor = isDark ? Colors.white : colors.primary;
    final switchActiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.4) : colors.primary.withValues(alpha: 0.3);
    final switchInactiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3);

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
        Switch(
          value: settings.animationsEnabled,
          onChanged: (value) {
            ref.read(settingsProvider.notifier).setAnimationsEnabled(value);
          },
          activeThumbColor: switchThumbColor,
          activeTrackColor: switchActiveTrackColor,
          inactiveThumbColor: isDark ? Colors.white : Colors.grey,
          inactiveTrackColor: switchInactiveTrackColor,
        ),
      ],
    );
  }
}

// _OledModeToggle removed (Phase 5.5) - caused light mode to turn black
// Provider and storage keys retained for backwards compatibility

class ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeOption({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
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
