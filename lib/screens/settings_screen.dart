import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../services/workmanager_service.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/donation_button.dart';
import '../widgets/glass_card.dart';
import 'settings/settings_widgets.dart';
import 'settings/settings_banners.dart';
import 'settings/appearance_section.dart';
import 'settings/experience_section.dart';
import 'settings/notification_times_sheet.dart';

// Re-export all settings subfiles for backward compatibility
export 'settings/settings_widgets.dart';
export 'settings/settings_banners.dart';
export 'settings/appearance_section.dart';
export 'settings/experience_section.dart';
export 'settings/notification_times_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with WidgetsBindingObserver {
  static const _settingsChannel = MethodChannel('com.dailypointer/settings');

  bool _notificationsEnabled = false; // Match service default, loaded in _checkPermissions
  bool _permissionGranted = true;

  // Developer options (hidden by default)
  int _versionTapCount = 0;
  bool _showDeveloperOptions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions when app resumes (user returns from system settings)
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      // Check if notification permissions are currently granted
      final notificationService = ref.read(notificationServiceProvider);
      final granted = await notificationService.checkPermissions();
      // Load the actual notification enabled state from service
      final enabled = notificationService.isNotificationsEnabled;
      if (mounted) {
        setState(() {
          _permissionGranted = granted;
          _notificationsEnabled = enabled;
        });
      }
    } catch (_) {
      // In test environment, assume granted
      if (mounted) {
        setState(() {
          _permissionGranted = true;
        });
      }
    }
  }

  Future<void> _showNotificationTimesSheet() async {
    HapticFeedback.mediumImpact();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => NotificationTimesSheet(showTestPreset: _showDeveloperOptions),
    );
  }

  Future<void> _showAboutDialog() async {
    HapticFeedback.mediumImpact();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => GlassDialog(
        title: 'About Here Now',
        content: Text(
          'Here Now delivers daily non-dual awareness "pointings" from various spiritual traditions.\n\n'
          'Each pointing is a direct invitation to recognize what you already are.\n\n'
          'Version 1.0.0',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 14, height: 1.5),
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
    HapticFeedback.mediumImpact();

    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open link'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Opens the app-specific notification settings via platform channel.
  /// Android: Settings.ACTION_APP_NOTIFICATION_SETTINGS (API 26+)
  /// iOS 16+: UIApplication.openNotificationSettingsURLString (direct to notifications)
  /// iOS <16: UIApplication.openSettingsURLString (general app settings)
  Future<void> _openAppNotificationSettings() async {
    try {
      await _settingsChannel.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint('Failed to open notification settings: $e');
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
          'Tap Open Settings, then enable Notifications.',
          style: TextStyle(color: context.colors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppNotificationSettings();
            },
            child: Text('Open Settings', style: TextStyle(color: context.colors.accent)),
          ),
        ],
      ),
    );
  }

  void _onVersionTap() {
    setState(() {
      _versionTapCount++;
      if (_versionTapCount >= 7 && !_showDeveloperOptions) {
        _showDeveloperOptions = true;
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Developer options enabled'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  /// Get notification count summary based on current schedule
  String _getNotificationCountSummary() {
    final schedule = ref.read(notificationServiceProvider).getSchedule();
    final count = schedule.getNotificationTimes(DateTime.now()).length;
    if (count == 0) return 'Disabled';
    return '$count per day';
  }

  /// Get schedule summary (e.g., "Every 3h, 8am - 9pm")
  String _getScheduleTimeSummary() {
    final schedule = ref.read(notificationServiceProvider).getSchedule();
    final freq = schedule.frequencyMinutes < 60
        ? '${schedule.frequencyMinutes}m'
        : '${schedule.frequencyMinutes ~/ 60}h';
    return 'Every $freq, ${_formatHourShort(schedule.startHour)} - ${_formatHourShort(schedule.endHour)}';
  }

  /// Format hour to short form (e.g., 8 -> "8am", 21 -> "9pm")
  String _formatHourShort(int hour) {
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour$period';
  }

  // TTS Configuration dialog disabled - feature temporarily removed
  // Future<void> _showTTSConfigDialog() async { ... }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final isDark = context.isDarkMode;
    final colors = context.colors;
    final textColorMuted = colors.textMuted;
    final textColorSubtle = isDark ? Colors.white.withValues(alpha: 0.4) : colors.textMuted;
    final textColorVersion = isDark ? Colors.white.withValues(alpha: 0.3) : colors.textMuted;
    final goldColor = colors.gold;
    final switchThumbColor = isDark ? Colors.white : colors.primary;
    final switchActiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.4) : colors.primary.withValues(alpha: 0.3);
    final switchInactiveTrackColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
              children: [
                StaggeredFadeIn(index: 0, child: Text('Settings', style: Theme.of(context).textTheme.displayLarge)),
                const SizedBox(height: 24),

                // Notifications section (Premium feature when IAP enabled)
                SettingsSectionHeader(title: 'NOTIFICATIONS'),
                const SizedBox(height: 12),
                // Premium badge for notifications - hidden when kFreeAccessEnabled
                if (!kFreeAccessEnabled && !subscription.isPremium)
                  PremiumFeatureBanner(feature: 'Notifications', onUpgrade: () => context.push('/paywall')),
                // Add permission banner when disabled (show if premium OR free access mode)
                if ((kFreeAccessEnabled || subscription.isPremium) && !_permissionGranted)
                  NotificationPermissionBanner(onOpenSettings: () => _openAppNotificationSettings()),
                GlassCard(
                  padding: EdgeInsets.zero,
                  borderColor: !kFreeAccessEnabled && !subscription.isPremium ? goldColor.withValues(alpha: 0.3) : null,
                  child: Column(
                    children: [
                      SettingsRow(
                        title: 'Daily Pointings',
                        // When kFreeAccessEnabled, show normal subtitle (not "Premium feature")
                        subtitle: !kFreeAccessEnabled && !subscription.isPremium
                            ? 'Premium feature'
                            : _permissionGranted
                            ? _getNotificationCountSummary()
                            : 'Permission required',
                        // Hide lock icon when kFreeAccessEnabled
                        leading: !kFreeAccessEnabled && !subscription.isPremium
                            ? Icon(Icons.lock_outline, color: goldColor, size: 18)
                            : null,
                        trailing: Switch(
                          // Allow toggle when kFreeAccessEnabled OR premium
                          value:
                              (kFreeAccessEnabled || subscription.isPremium) &&
                              _notificationsEnabled &&
                              _permissionGranted,
                          onChanged: (kFreeAccessEnabled || subscription.isPremium)
                              ? (value) async {
                                  HapticFeedback.mediumImpact();

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
                                }
                              : (_) {
                                  HapticFeedback.mediumImpact();
                                  context.push('/paywall');
                                },
                          activeThumbColor: switchThumbColor,
                          activeTrackColor: switchActiveTrackColor,
                          inactiveThumbColor: isDark ? Colors.white : Colors.grey,
                          inactiveTrackColor: switchInactiveTrackColor,
                        ),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        title: 'Notification Times',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hide lock icon when kFreeAccessEnabled
                            if (!kFreeAccessEnabled && !subscription.isPremium)
                              Icon(Icons.lock_outline, color: goldColor, size: 14)
                            else
                              Text(_getScheduleTimeSummary(), style: TextStyle(color: textColorMuted, fontSize: 14)),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, color: textColorSubtle, size: 20),
                          ],
                        ),
                        // Allow access when kFreeAccessEnabled OR premium
                        onTap: (kFreeAccessEnabled || subscription.isPremium)
                            ? _showNotificationTimesSheet
                            : () {
                                HapticFeedback.mediumImpact();
                                context.push('/paywall');
                              },
                      ),
                    ],
                  ),
                ),

                // Appearance section
                const SizedBox(height: 24),
                SettingsSectionHeader(title: 'APPEARANCE'),
                const SizedBox(height: 12),
                const AppearanceSelector(),

                // Traditions section
                const SizedBox(height: 24),
                SettingsSectionHeader(title: 'TRADITIONS'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: SettingsRow(
                    title: 'Manage Lineages',
                    trailing: Icon(Icons.chevron_right, color: textColorSubtle, size: 20),
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      // Navigate to lineages management screen
                      if (context.mounted) {
                        context.push('/lineages');
                      }
                    },
                  ),
                ),

                // History section
                const SizedBox(height: 24),
                SettingsSectionHeader(title: 'HISTORY'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: SettingsRow(
                    title: 'Past Pointings',
                    trailing: Icon(Icons.chevron_right, color: textColorSubtle, size: 20),
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      if (context.mounted) {
                        context.push('/history');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text('No streaks. Just recognition.', style: TextStyle(color: textColorSubtle, fontSize: 12)),
                ),

                // Experience section (ambient sounds, auto-advance)
                const SizedBox(height: 24),
                SettingsSectionHeader(title: 'EXPERIENCE'),
                const SizedBox(height: 12),
                AmbientSoundPicker(),
                const SizedBox(height: 12),
                AutoAdvanceToggle(),

                // About section
                const SizedBox(height: 24),
                SettingsSectionHeader(title: 'ABOUT'),
                const SizedBox(height: 12),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SettingsRow(
                        title: 'About Here Now',
                        trailing: Icon(Icons.chevron_right, color: textColorSubtle, size: 20),
                        onTap: _showAboutDialog,
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        title: 'Privacy Policy',
                        trailing: Icon(Icons.chevron_right, color: textColorSubtle, size: 20),
                        onTap: () => _launchUrl('https://jainnam-1993.github.io/Pointer/legal/privacy.html'),
                      ),
                      const SettingsDivider(),
                      SettingsRow(
                        title: 'Terms of Service',
                        trailing: Icon(Icons.chevron_right, color: textColorSubtle, size: 20),
                        onTap: () => _launchUrl('https://jainnam-1993.github.io/Pointer/legal/terms.html'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const DonationButton(),

                // Developer section (hidden until 7 taps on version)
                if (_showDeveloperOptions) ...[
                  const SizedBox(height: 24),
                  SettingsSectionHeader(title: 'DEVELOPER'),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SettingsRow(
                          title: 'Test Notification',
                          subtitle: 'Send a test pointing notification',
                          trailing: Icon(Icons.notifications_active, color: textColorSubtle, size: 20),
                          onTap: () async {
                            final notificationService = ref.read(notificationServiceProvider);
                            await notificationService.sendTestNotification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Test notification sent'), duration: Duration(seconds: 2)),
                              );
                            }
                          },
                        ),
                        const SettingsDivider(),
                        SettingsRow(
                          title: 'Test Background Notification',
                          subtitle: 'Schedule via WorkManager (1 min delay)',
                          trailing: Icon(Icons.schedule_send, color: textColorSubtle, size: 20),
                          onTap: () async {
                            await WorkManagerService.scheduleOneTimeNotification(
                              delay: const Duration(minutes: 1),
                              uniqueName: 'test_background_${DateTime.now().millisecondsSinceEpoch}',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Background notification scheduled in 1 minute. You can close the app.',
                                  ),
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                        ),
                        const SettingsDivider(),
                        SettingsRow(
                          title: 'Debug Pending Notifications',
                          subtitle: 'Check scheduled notifications (inexact mode)',
                          trailing: Icon(Icons.bug_report, color: textColorSubtle, size: 20),
                          onTap: () async {
                            final notificationService = ref.read(notificationServiceProvider);
                            await notificationService.debugPrintPendingNotifications();
                            final pending = await notificationService.getPendingNotifications();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pending notifications: ${pending.length}'),
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                        ),
                        // TTS Configuration disabled - feature temporarily removed
                        // const SettingsDivider(),
                        // SettingsRow(
                        //   title: 'TTS Configuration',
                        //   subtitle: 'Article audio access',
                        //   ...
                        // ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _onVersionTap,
                  child: Center(
                    child: Text('Here Now v1.0.0', style: TextStyle(color: textColorVersion, fontSize: 12)),
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
