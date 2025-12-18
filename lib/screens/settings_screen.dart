import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _permissionGranted = true;
  final int _frequency = 3;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check if notification permissions are granted
    // This is a simplified check - in production you'd use platform channels
    setState(() {
      _permissionGranted = true; // Default to true, will be false if denied
    });
  }

  Future<void> _showNotificationTimesSheet() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NotificationTimesSheet(),
    );
  }

  Future<void> _showAboutDialog() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        title: 'About Pointer',
        content: Text(
          'Pointer delivers daily non-dual awareness "pointings" from various spiritual traditions.\n\n'
          'Each pointing is a direct invitation to recognize what you already are.\n\n'
          'Version 1.0.0',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: context.colors.accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 50, amplitude: 128);
    }

    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showPermissionDeniedDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        title: 'Permission Required',
        content: Text(
          'Notification permission is required to receive daily pointings. '
          'Please enable notifications in your device settings.',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: context.colors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = context.isDarkMode;
    final textColorMuted = isDark ? Colors.white.withValues(alpha: 0.5) : AppColorsLight.textMuted;
    final textColorSubtle = isDark ? Colors.white.withValues(alpha: 0.4) : AppColorsLight.textMuted;
    final textColorVersion = isDark ? Colors.white.withValues(alpha: 0.3) : AppColorsLight.textMuted;
    final goldColor = isDark ? AppColors.gold : AppColorsLight.gold;
    final switchThumbColor = isDark ? Colors.white : AppColorsLight.primary;
    final switchActiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.4) : AppColorsLight.primary.withValues(alpha: 0.3);
    final switchInactiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 120 + bottomPadding,
              ),
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 24),

                // Notifications section
                _SectionHeader(title: 'NOTIFICATIONS'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        title: 'Daily Pointings',
                        subtitle: _permissionGranted
                            ? '$_frequency per day'
                            : 'Permission required',
                        trailing: Switch(
                          value: _notificationsEnabled && _permissionGranted,
                          onChanged: (value) async {
                            final hasVibrator = await Vibration.hasVibrator();
                            if (hasVibrator == true) {
                              Vibration.vibrate(duration: 50, amplitude: 128);
                            }

                            if (value && !_permissionGranted) {
                              final notificationService = ref.read(notificationServiceProvider);
                              final granted = await notificationService.requestPermissions();
                              if (!granted) {
                                _showPermissionDeniedDialog();
                                return;
                              }
                              setState(() => _permissionGranted = true);
                            }

                            setState(() => _notificationsEnabled = value);
                            await ref.read(notificationServiceProvider).setNotificationsEnabled(value);
                          },
                          activeThumbColor: switchThumbColor,
                          activeTrackColor: switchActiveTrackColor,
                          inactiveThumbColor: isDark ? Colors.white : Colors.grey,
                          inactiveTrackColor: switchInactiveTrackColor,
                        ),
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Notification Times',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '8am, 12pm, 9pm',
                              style: TextStyle(
                                color: textColorMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: textColorSubtle,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: _showNotificationTimesSheet,
                      ),
                    ],
                  ),
                ),

                // Appearance section
                const SizedBox(height: 24),
                _SectionHeader(title: 'APPEARANCE'),
                const SizedBox(height: 12),
                const _AppearanceSelector(),

                // Traditions section
                const SizedBox(height: 24),
                _SectionHeader(title: 'TRADITIONS'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: _SettingsRow(
                    title: 'Manage Lineages',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: textColorSubtle,
                      size: 20,
                    ),
                    onTap: () async {
                      final hasVibrator = await Vibration.hasVibrator();
                      if (hasVibrator == true) {
                        Vibration.vibrate(duration: 50, amplitude: 128);
                      }
                      // Navigate to lineages tab
                      if (context.mounted) {
                        context.go('/lineages');
                      }
                    },
                  ),
                ),

                // History section
                const SizedBox(height: 24),
                _SectionHeader(title: 'HISTORY'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: _SettingsRow(
                    title: 'Past Pointings',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: textColorSubtle,
                      size: 20,
                    ),
                    onTap: () async {
                      final hasVibrator = await Vibration.hasVibrator();
                      if (hasVibrator == true) {
                        Vibration.vibrate(duration: 50, amplitude: 128);
                      }
                      if (context.mounted) {
                        context.push('/history');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'No streaks. Just recognition.',
                    style: TextStyle(
                      color: textColorSubtle,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Account section
                const SizedBox(height: 24),
                _SectionHeader(title: 'ACCOUNT'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  borderColor: subscription.isPremium
                      ? goldColor.withValues(alpha: 0.3)
                      : null,
                  child: subscription.isPremium
                      ? _SettingsRow(
                          title: 'Premium Active',
                          subtitle: 'All features unlocked',
                          trailing: Icon(
                            Icons.auto_awesome,
                            color: goldColor,
                            size: 24,
                          ),
                        )
                      : _SettingsRow(
                          title: 'Upgrade to Premium',
                          subtitle: 'Unlock all traditions & sessions',
                          leading: Icon(
                            Icons.auto_awesome,
                            color: goldColor,
                            size: 18,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: textColorSubtle,
                            size: 20,
                          ),
                          onTap: () => context.push('/paywall'),
                        ),
                ),

                // About section
                const SizedBox(height: 24),
                _SectionHeader(title: 'ABOUT'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        title: 'About Pointer',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColorSubtle,
                          size: 20,
                        ),
                        onTap: _showAboutDialog,
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Privacy Policy',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColorSubtle,
                          size: 20,
                        ),
                        onTap: () => _launchUrl('https://pointer.app/privacy'),
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Terms of Service',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColorSubtle,
                          size: 20,
                        ),
                        onTap: () => _launchUrl('https://pointer.app/terms'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Pointer v1.0.0',
                    style: TextStyle(
                      color: textColorVersion,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const _SettingsRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
    final textColorSubtitle = isDark ? Colors.white.withValues(alpha: 0.5) : AppColorsLight.textMuted;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColorSubtitle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );

    final label = semanticLabel ?? '$title${subtitle != null ? ', $subtitle' : ''}';

    if (onTap != null) {
      return Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }
    return Semantics(
      label: label,
      child: content,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1),
    );
  }
}

class _AppearanceSelector extends ConsumerWidget {
  const _AppearanceSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white : AppColorsLight.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ThemeOption(
                label: 'Light',
                icon: Icons.light_mode_outlined,
                isSelected: currentMode == AppThemeMode.light,
                onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.light),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
                label: 'Dark',
                icon: Icons.dark_mode_outlined,
                isSelected: currentMode == AppThemeMode.dark,
                onTap: () => ref.read(settingsProvider.notifier).setTheme(AppThemeMode.dark),
              ),
              const SizedBox(width: 12),
              _ThemeOption(
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
          _ZenModeToggle(),
        ],
      ),
    );
  }
}

class _ZenModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isZenMode = ref.watch(zenModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final switchThumbColor = isDark ? Colors.white : AppColorsLight.primary;
    final switchActiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.4) : AppColorsLight.primary.withValues(alpha: 0.3);
    final switchInactiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Zen Mode',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Minimal UI, just the pointing',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColorsLight.textMuted,
                ),
              ),
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

// _OledModeToggle removed (Phase 5.5) - caused light mode to turn black
// Provider and storage keys retained for backwards compatibility

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = isDark ? AppColors.primary : AppColorsLight.primary;
    final borderColor = isSelected
        ? selectedColor
        : (isDark ? AppColors.glassBorder : AppColorsLight.glassBorder);
    final bgColor = isSelected
        ? selectedColor.withValues(alpha: 0.2)
        : Colors.transparent;

    return Expanded(
      child: Semantics(
        button: true,
        label: '$label theme${isSelected ? ', selected' : ''}',
        child: GestureDetector(
          onTap: () async {
            final hasVibrator = await Vibration.hasVibrator();
            if (hasVibrator == true) {
              Vibration.vibrate(duration: 50, amplitude: 128);
            }
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? selectedColor
                      : (isDark ? Colors.white.withValues(alpha: 0.7) : AppColorsLight.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? selectedColor
                        : (isDark ? Colors.white.withValues(alpha: 0.7) : AppColorsLight.textSecondary),
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

/// Bottom sheet for managing notification schedule (Phase 5.1)
class _NotificationTimesSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NotificationTimesSheet> createState() => _NotificationTimesSheetState();
}

class _NotificationTimesSheetState extends ConsumerState<_NotificationTimesSheet> {
  late NotificationSchedule _schedule;
  static const _frequencyOptions = [1, 2, 3, 4, 6, 8, 12];

  @override
  void initState() {
    super.initState();
    _schedule = ref.read(notificationServiceProvider).getSchedule();
  }

  Future<void> _saveSchedule() async {
    await ref.read(notificationServiceProvider).saveSchedule(_schedule);
  }

  Future<void> _pickTime(bool isStart) async {
    final hour = isStart ? _schedule.startHour : _schedule.endHour;
    final minute = isStart ? _schedule.startMinute : _schedule.endMinute;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
    );

    if (picked != null) {
      setState(() {
        _schedule = isStart
            ? _schedule.copyWith(startHour: picked.hour, startMinute: picked.minute)
            : _schedule.copyWith(endHour: picked.hour, endMinute: picked.minute);
      });
      await _saveSchedule();
    }
  }

  bool _matchesPreset(NotificationPreset preset) {
    final presetSchedule = preset.schedule;
    return _schedule.startHour == presetSchedule.startHour &&
        _schedule.endHour == presetSchedule.endHour &&
        _schedule.frequencyHours == presetSchedule.frequencyHours;
  }

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
    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
    final mutedColor = isDark ? Colors.white.withValues(alpha: 0.6) : AppColorsLight.textSecondary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
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
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: bottomPadding + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                    'Notification Schedule',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _schedule.summary,
                    style: TextStyle(color: mutedColor, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Quick Presets (Phase 5.3)
                  Text('Quick Presets', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: NotificationPreset.values.map((preset) {
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
                        side: BorderSide(
                          color: isSelected ? context.colors.accent : context.colors.glassBorder,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Time Window
                  Text('Time Window', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
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
                  Text('Frequency', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _frequencyOptions.map((hours) {
                      final isSelected = _schedule.frequencyHours == hours;
                      return GestureDetector(
                        onTap: () async {
                          setState(() => _schedule = _schedule.copyWith(frequencyHours: hours));
                          await _saveSchedule();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white.withValues(alpha: 0.3) : AppColorsLight.primary.withValues(alpha: 0.2))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColorsLight.primary)
                                  : (isDark ? Colors.white.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3)),
                            ),
                          ),
                          child: Text(
                            '${hours}h',
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
