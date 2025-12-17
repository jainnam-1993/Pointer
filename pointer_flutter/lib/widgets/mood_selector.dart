import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Mood selector widget - horizontal scrolling mood chips.
///
/// User selects their current mood to personalize pointing selection.
/// Selection persists and affects the pointing matching algorithm.
class MoodSelector extends ConsumerWidget {
  const MoodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMood = ref.watch(currentMoodProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 12),
          child: Text(
            'How are you feeling?',
            style: AppTextStyles.footerText(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: Mood.values.length,
            itemBuilder: (context, index) {
              final mood = Mood.values[index];
              final info = moodInfo[mood]!;
              final isSelected = mood == currentMood;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _MoodChip(
                  mood: mood,
                  info: info,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(currentMoodProvider.notifier).state = mood;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final Mood mood;
  final MoodInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.2)
              : colors.glassBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? colors.accent : colors.glassBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(info.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              info.name,
              style: TextStyle(
                color: isSelected ? colors.accent : colors.textSecondary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal bottom sheet for detailed mood selection with descriptions.
void showMoodPicker(BuildContext context, WidgetRef ref) {
  final colors = context.colors;

  showModalBottomSheet(
    context: context,
    backgroundColor: colors.cardBackground,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        final currentMood = ref.watch(currentMoodProvider);

        return Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: colors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'How are you feeling?',
                style: AppTextStyles.heading(context),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: Mood.values.length,
                itemBuilder: (context, index) {
                  final mood = Mood.values[index];
                  final info = moodInfo[mood]!;
                  final isSelected = mood == currentMood;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MoodListTile(
                      mood: mood,
                      info: info,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ref.read(currentMoodProvider.notifier).state = mood;
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _MoodListTile extends StatelessWidget {
  final Mood mood;
  final MoodInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodListTile({
    required this.mood,
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accent.withValues(alpha: 0.1)
              : colors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.accent : colors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accent.withValues(alpha: 0.2)
                    : colors.glassBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(info.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: TextStyle(
                      color: isSelected ? colors.accent : colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.description,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.accent, size: 24),
          ],
        ),
      ),
    );
  }
}
