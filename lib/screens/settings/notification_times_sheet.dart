/** Notification schedule management bottom sheet with presets, time window, and frequency controls. */
library;

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';

/**
 * Bottom sheet for managing notification schedule with presets and custom time controls.
 *
 * Provides quick presets ([NotificationPreset]: Morning, All Day, Evening, Minimal),
 * a start/end time window with [CupertinoPicker] wheels, and frequency selection
 * (30m to 12h). Changes are saved immediately via [NotificationService.saveSchedule].
 */
class NotificationTimesSheet extends ConsumerStatefulWidget {
  /// Whether to show the test preset (visible only in developer mode).
  final bool showTestPreset;

  const NotificationTimesSheet({super.key, this.showTestPreset = false});

  @override
  ConsumerState<NotificationTimesSheet> createState() => _NotificationTimesSheetState();
}

class _NotificationTimesSheetState extends ConsumerState<NotificationTimesSheet> {
  /// The current notification schedule being edited.
  late NotificationSchedule _schedule;

  /// Available frequency options in minutes (30m, 1h, 2h, 3h, 4h, 6h, 8h, 12h).
  static const _frequencyOptions = [30, 60, 120, 180, 240, 360, 480, 720];

  @override
  void initState() {
    super.initState();
    _schedule = ref.read(notificationServiceProvider).getSchedule();
  }

  /// Persists the current schedule to the notification service.
  Future<void> _saveSchedule() async {
    await ref.read(notificationServiceProvider).saveSchedule(_schedule);
  }

  /// Opens a [CupertinoPicker] bottom sheet for selecting start or end time.
  ///
  /// Uses responsive height calculation based on orientation and safe area.
  Future<void> _pickTime(bool isStart) async {
    final hour = isStart ? _schedule.startHour : _schedule.endHour;
    final minute = isStart ? _schedule.startMinute : _schedule.endMinute;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int selectedHour = hour;
    int selectedMinute = minute;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Responsive height based on available space (accounts for safe areas/orientation)
            final mediaQuery = MediaQuery.of(context);
            final availableHeight = mediaQuery.size.height - mediaQuery.viewPadding.top - mediaQuery.viewPadding.bottom;
            final isLandscape = mediaQuery.orientation == Orientation.landscape;
            // In landscape: use 55% of available height, portrait: 40%
            // Clamp to reasonable bounds for each orientation
            final pickerHeight = isLandscape ? (availableHeight * 0.55).clamp(180.0, 280.0) : (availableHeight * 0.40).clamp(250.0, 350.0);

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
                child: Container(
                  height: pickerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
                            ),
                            Text(
                              isStart ? 'Start Time' : 'End Time',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                setState(() {
                                  _schedule = isStart
                                      ? _schedule.copyWith(startHour: selectedHour, startMinute: selectedMinute)
                                      : _schedule.copyWith(endHour: selectedHour, endMinute: selectedMinute);
                                });
                                await _saveSchedule();
                              },
                              child: Text(
                                'Done',
                                style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Time picker wheels
                      Expanded(
                        child: Row(
                          children: [
                            // Hour wheel
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(initialItem: selectedHour),
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setSheetState(() => selectedHour = index);
                                },
                                children: List.generate(24, (index) {
                                  final displayHour = index == 0 ? 12 : (index > 12 ? index - 12 : index);
                                  final period = index < 12 ? 'AM' : 'PM';
                                  return Center(
                                    child: Text('$displayHour $period', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20)),
                                  );
                                }),
                              ),
                            ),
                            // Minute wheel
                            Expanded(
                              child: CupertinoPicker(
                                scrollController: FixedExtentScrollController(initialItem: selectedMinute),
                                itemExtent: 40,
                                onSelectedItemChanged: (index) {
                                  setSheetState(() => selectedMinute = index);
                                },
                                children: List.generate(60, (index) {
                                  return Center(
                                    child: Text(
                                      index.toString().padLeft(2, '0'),
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Returns whether the current schedule matches the given [preset]'s configuration.
  bool _matchesPreset(NotificationPreset preset) {
    final presetSchedule = preset.schedule;
    return _schedule.startHour == presetSchedule.startHour &&
        _schedule.endHour == presetSchedule.endHour &&
        _schedule.frequencyMinutes == presetSchedule.frequencyMinutes;
  }

  /// Applies a [NotificationPreset] and saves the resulting schedule.
  void _applyPreset(NotificationPreset preset) {
    setState(() {
      _schedule = preset.schedule;
    });
    _saveSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;
    final textColor = colors.textPrimary;
    final mutedColor = colors.textSecondary;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomPadding + 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notification Schedule', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor)),
                      const SizedBox(height: 8),
                      Text(_schedule.summary, style: TextStyle(color: mutedColor, fontSize: 14)),
                      const SizedBox(height: 20),

                      // Quick Presets (Phase 5.3)
                      Text(
                        'Quick Presets',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: NotificationPreset.values
                            .where((preset) => widget.showTestPreset || preset != NotificationPreset.testEveryMinute)
                            .map((preset) {
                              final isSelected = _matchesPreset(preset);
                              return ChoiceChip(
                                label: Text(preset.label),
                                selected: isSelected,
                                onSelected: (_) => _applyPreset(preset),
                                selectedColor: context.colors.accent.withValues(alpha: 0.3),
                                labelStyle: TextStyle(
                                  color: isSelected ? context.colors.accent : textColor,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                side: BorderSide(color: isSelected ? context.colors.accent : context.colors.glassBorder),
                              );
                            })
                            .toList(),
                      ),
                      const SizedBox(height: 24),

                      // Time Window
                      Text(
                        'Time Window',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              onTap: () => _pickTime(true),
                              child: Column(
                                children: [
                                  Text('Start', style: TextStyle(color: mutedColor, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    NotificationSchedule.formatTime(_schedule.startHour, _schedule.startMinute),
                                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              onTap: () => _pickTime(false),
                              child: Column(
                                children: [
                                  Text('End', style: TextStyle(color: mutedColor, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text(
                                    NotificationSchedule.formatTime(_schedule.endHour, _schedule.endMinute),
                                    style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Frequency
                      Text(
                        'Frequency',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _frequencyOptions.map((minutes) {
                          final isSelected = _schedule.frequencyMinutes == minutes;
                          return GestureDetector(
                            onTap: () async {
                              setState(() => _schedule = _schedule.copyWith(frequencyMinutes: minutes));
                              await _saveSchedule();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? colors.primary.withValues(alpha: isDark ? 0.3 : 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? colors.primary : colors.glassBorder),
                              ),
                              child: Text(
                                minutes < 60 ? '${minutes}m' : '${minutes ~/ 60}h',
                                style: TextStyle(
                                  color: isSelected ? textColor : mutedColor,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          onTap: () => Navigator.of(context).pop(),
                          child: Center(
                            child: Text(
                              'Done',
                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
