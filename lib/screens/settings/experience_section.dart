// Experience section - auto-advance toggle, ambient sound picker
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/ambient_sound_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

/// Auto-advance toggle for automatic pointing rotation
class AutoAdvanceToggle extends ConsumerWidget {
  const AutoAdvanceToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final isEnabled = ref.watch(autoAdvanceProvider);
    final switchThumbColor = isDark ? Colors.white : colors.primary;
    final switchActiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.4) : colors.primary.withValues(alpha: 0.3);
    final switchInactiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_mode,
                color: colors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Advance',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'New pointing every minute',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  ref.read(settingsProvider.notifier).setAutoAdvance(value);
                },
                activeThumbColor: switchThumbColor,
                activeTrackColor: switchActiveTrackColor,
                inactiveThumbColor: isDark ? Colors.white : Colors.grey,
                inactiveTrackColor: switchInactiveTrackColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sound picker for ambient opening sound
class AmbientSoundPicker extends ConsumerWidget {
  const AmbientSoundPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final currentSound = ref.watch(ambientSoundProvider);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: colors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Opening Sound',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Play a contemplative sound when app opens',
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AmbientSound.values.map((sound) {
              final isSelected = currentSound == sound;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(ambientSoundProvider.notifier).setSound(sound);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primary.withValues(alpha: isDark ? 0.3 : 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.glassBorder,
                    ),
                  ),
                  child: Text(
                    sound.displayName,
                    style: TextStyle(
                      color: isSelected ? colors.textPrimary : colors.textMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
