/** Notification schedule management bottom sheet with presets, time window, and frequency controls. */
library;

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../services/notification_service.dart';
import '../../layout/adaptive.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ambient.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/selectable_chip.dart';

/**
 * Bottom sheet for managing notification schedule with presets and custom time controls.
 *
 * Provides quick presets ([NotificationPreset]: Morning, All Day, Evening, Minimal),
 * a start/end time window with [CupertinoPicker] wheels, and frequency selection
 * (30m to 12h). Changes are saved immediately via [NotificationService.saveSchedule].
 */
class NotificationTimesSheet extends ConsumerStatefulWidget {
  const NotificationTimesSheet({super.key});

  @override
  ConsumerState<NotificationTimesSheet> createState() => _NotificationTimesSheetState();
}

class _NotificationTimesSheetState extends ConsumerState<NotificationTimesSheet> {
  /** The current notification schedule being edited. */
  late NotificationSchedule _schedule;

  /** Available frequency options in minutes (30m, 1h, 2h, 3h, 4h, 6h, 8h, 12h). */
  static const _frequencyOptions = [30, 60, 120, 180, 240, 360, 480, 720];

  @override
  void initState() {
    super.initState();
    _schedule = ref.read(notificationServiceProvider).getSchedule();
  }

  /** Persists the current schedule to the notification service. */
  Future<void> _saveSchedule() async {
    await ref.read(notificationServiceProvider).saveSchedule(_schedule);
  }

  /**
   * Opens a [CupertinoPicker] bottom sheet for selecting start or end time.
   *
   * Uses responsive height calculation based on orientation and safe area.
   */
  Future<void> _pickTime(bool isStart) async {
    final hour = isStart ? _schedule.startHour : _schedule.endHour;
    final minute = isStart ? _schedule.startMinute : _schedule.endMinute;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int selectedHour = hour;
    int selectedMinute = minute;

    await showAdaptiveSheet(
      context: context,
      anchorPoint: sheetAnchorPoint(context),
      isScrollControlled: true,
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
              // No blur: this picker opens over the already blurred schedule sheet.
              child: Container(
                height: pickerHeight,
                decoration: BoxDecoration(
                  color: GlassMaterial.sheetSurface(context.colors),
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
            );
          },
        );
      },
    );
  }

  /** Returns whether the current schedule matches the given [preset]'s configuration. */
  bool _matchesPreset(NotificationPreset preset) {
    final presetSchedule = preset.schedule;
    return _schedule.startHour == presetSchedule.startHour &&
        _schedule.endHour == presetSchedule.endHour &&
        _schedule.frequencyMinutes == presetSchedule.frequencyMinutes;
  }

  /** Applies a [NotificationPreset] and saves the resulting schedule. */
  void _applyPreset(NotificationPreset preset) {
    setState(() {
      _schedule = preset.schedule;
    });
    _saveSchedule();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;
    final glass = GlassMaterial.of(context);
    final textColor = colors.textPrimary;
    final mutedColor = colors.textSecondary;

    return Container(
      constraints: BoxConstraints(maxHeight: sheetMaxHeight(MediaQuery.sizeOf(context).height)),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            decoration: BoxDecoration(
              color: GlassMaterial.sheetSurface(colors),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: glass.rimTop, width: glass.rimWidth),
              ),
            ),
            child: FrostScope(
              surface: GlassMaterial.sheetSurface(colors),
              child: SafeArea(
                // The schedule scrolls; Done stays pinned below it so it is reachable in any window height.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: KeyedSubtree(
                        key: const ValueKey('notification-sheet-scroll'),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: AppSpacing.sm),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notification Schedule', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor)),
                                const SizedBox(height: 8),
                                Text(
                                  _schedule.summary,
                                  style: TextStyle(color: mutedColor, fontSize: AppType.callout),
                                ),
                                const SizedBox(height: 20),

                                // Quick Presets (Phase 5.3)
                                Text('QUICK PRESETS', style: AppTextStyles.sectionHeader(context)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: NotificationPreset.values.map((preset) {
                                    return SelectableChip(
                                      label: preset.label,
                                      selected: _matchesPreset(preset),
                                      onSelected: () => _applyPreset(preset),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),

                                // Time Window
                                Text('TIME WINDOW', style: AppTextStyles.sectionHeader(context)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassCard(
                                        padding: const EdgeInsets.all(16),
                                        onTap: () => _pickTime(true),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Start',
                                              style: TextStyle(color: mutedColor, fontSize: AppType.caption),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              NotificationSchedule.formatTime(_schedule.startHour, _schedule.startMinute),
                                              style: TextStyle(color: textColor, fontSize: AppType.headline, fontWeight: FontWeight.w600),
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
                                            Text(
                                              'End',
                                              style: TextStyle(color: mutedColor, fontSize: AppType.caption),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              NotificationSchedule.formatTime(_schedule.endHour, _schedule.endMinute),
                                              style: TextStyle(color: textColor, fontSize: AppType.headline, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Frequency
                                Text('FREQUENCY', style: AppTextStyles.sectionHeader(context)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: _frequencyOptions.map((minutes) {
                                    final short = minutes < 60 ? '${minutes}m' : '${minutes ~/ 60}h';
                                    final spoken = minutes < 60
                                        ? 'Every $minutes minutes'
                                        : (minutes == 60 ? 'Every hour' : 'Every ${minutes ~/ 60} hours');
                                    return SelectableChip(
                                      label: short,
                                      semanticLabel: spoken,
                                      selected: _schedule.frequencyMinutes == minutes,
                                      onSelected: () async {
                                        setState(() => _schedule = _schedule.copyWith(frequencyMinutes: minutes));
                                        await _saveSchedule();
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Close button, pinned below the scrolling schedule.
                    Padding(
                      // One spacing token between the schedule and Done, so Done never overlaps the last chip row.
                      padding: EdgeInsets.only(left: 24, right: 24, top: AppSpacing.lg, bottom: bottomPadding + AppSpacing.lg),
                      child: SizedBox(
                        key: const ValueKey('notification-sheet-done'),
                        width: double.infinity,
                        child: GlassButton(label: 'Done', onPressed: () => Navigator.of(context).pop()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
