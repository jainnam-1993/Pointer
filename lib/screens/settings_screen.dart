import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:app_settings/app_settings.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../services/notification_service.dart';
import '../services/ambient_sound_service.dart';
// TTS disabled - feature temporarily removed
// import '../services/aws_credential_service.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';
import '../widgets/premium_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  bool _notificationsEnabled = false;  // Match service default, loaded in _checkPermissions
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
      builder: (context) => _NotificationTimesSheet(showTestPreset: _showDeveloperOptions),
    );
  }

  Future<void> _showAboutDialog() async {
    HapticFeedback.mediumImpact();

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
            child: Text('Cancel', style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppSettings.openAppSettings(type: AppSettingsType.notification);
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
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 8,
              ),
              children: [
                StaggeredFadeIn(
                  index: 0,
                  child: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications section (Premium feature)
                _SectionHeader(title: 'NOTIFICATIONS'),
                const SizedBox(height: 12),
                // Premium badge for notifications
                if (!subscription.isPremium)
                  _PremiumFeatureBanner(
                    feature: 'Notifications',
                    onUpgrade: () => context.push('/paywall'),
                  ),
                // Add permission banner when disabled (only show if premium)
                if (subscription.isPremium && !_permissionGranted)
                  _NotificationPermissionBanner(
                    onOpenSettings: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
                  ),
                GlassCard(
                  padding: EdgeInsets.zero,
                  borderColor: !subscription.isPremium ? goldColor.withValues(alpha: 0.3) : null,
                  child: Column(
                    children: [
                      _SettingsRow(
                        title: 'Daily Pointings',
                        subtitle: !subscription.isPremium
                            ? 'Premium feature'
                            : _permissionGranted
                                ? _getNotificationCountSummary()
                                : 'Permission required',
                        leading: !subscription.isPremium
                            ? Icon(Icons.lock_outline, color: goldColor, size: 18)
                            : null,
                        trailing: Switch(
                          value: subscription.isPremium && _notificationsEnabled && _permissionGranted,
                          onChanged: subscription.isPremium
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
                      const _Divider(),
                      _SettingsRow(
                        title: 'Notification Times',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!subscription.isPremium)
                              Icon(Icons.lock_outline, color: goldColor, size: 14)
                            else
                              Text(
                                _getScheduleTimeSummary(),
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
                        onTap: subscription.isPremium
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
                      HapticFeedback.mediumImpact();
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

                // Experience section (ambient sounds)
                const SizedBox(height: 24),
                _SectionHeader(title: 'EXPERIENCE'),
                const SizedBox(height: 12),
                _AmbientSoundPicker(),

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
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            showPremiumSheet(context);
                          },
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
                        onTap: () => _launchUrl('https://jainnam-1993.github.io/Pointer/legal/privacy.html'),
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Terms of Service',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColorSubtle,
                          size: 20,
                        ),
                        onTap: () => _launchUrl('https://jainnam-1993.github.io/Pointer/legal/terms.html'),
                      ),
                    ],
                  ),
                ),

                // Developer section (hidden until 7 taps on version)
                if (_showDeveloperOptions) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'DEVELOPER'),
                  const SizedBox(height: 12),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsRow(
                          title: 'Test Notification',
                          subtitle: 'Send a test pointing notification',
                          trailing: Icon(
                            Icons.notifications_active,
                            color: textColorSubtle,
                            size: 20,
                          ),
                          onTap: () async {
                            final notificationService = ref.read(notificationServiceProvider);
                            await notificationService.sendTestNotification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Test notification sent'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        const _Divider(),
                        _SettingsRow(
                          title: 'Grant Alarm Permission',
                          subtitle: 'Required for scheduled notifications (Android 12+)',
                          trailing: Icon(
                            Icons.alarm,
                            color: textColorSubtle,
                            size: 20,
                          ),
                          onTap: () async {
                            final notificationService = ref.read(notificationServiceProvider);
                            final granted = await notificationService.requestExactAlarmPermission();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(granted ? 'Permission granted!' : 'Please enable in Settings'),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        ),
                        const _Divider(),
                        _SettingsRow(
                          title: 'Start 1-Min Timer',
                          subtitle: 'Send notification every minute (foreground)',
                          trailing: Icon(
                            Icons.timer,
                            color: textColorSubtle,
                            size: 20,
                          ),
                          onTap: () {
                            final notificationService = ref.read(notificationServiceProvider);
                            notificationService.startTestNotifications();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Timer started - notifications every 1 min'),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                        ),
                        // TTS Configuration disabled - feature temporarily removed
                        // const _Divider(),
                        // _SettingsRow(
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
                    child: Text(
                      'Pointer v1.0.0',
                      style: TextStyle(
                        color: textColorVersion,
                        fontSize: 12,
                      ),
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
    final colors = context.colors;
    final textColor = colors.textPrimary;
    final textColorSubtitle = colors.textMuted;

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

class _NotificationPermissionBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _NotificationPermissionBanner({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications Disabled',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enable in system settings to receive daily pointings',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onOpenSettings,
            child: Text(
              'Open Settings',
              style: TextStyle(
                color: colors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner showing a premium feature is locked
class _PremiumFeatureBanner extends StatelessWidget {
  final String feature;
  final VoidCallback onUpgrade;

  const _PremiumFeatureBanner({
    required this.feature,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final goldColor = colors.gold;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: goldColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$feature is a Premium Feature',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Upgrade to unlock $feature and more',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onUpgrade,
            child: Text(
              'Upgrade',
              style: TextStyle(
                color: goldColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
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
              color: context.colors.textPrimary,
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
              Text(
                'Zen Mode',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Minimal UI, just the pointing',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMuted,
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
    final colors = context.colors;
    final selectedColor = colors.primary;
    final unselectedColor = colors.textSecondary;
    final borderColor = isSelected
        ? selectedColor
        : colors.glassBorder;
    final bgColor = isSelected
        ? selectedColor.withValues(alpha: 0.2)
        : Colors.transparent;

    return Expanded(
      child: Semantics(
        button: true,
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
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? selectedColor : unselectedColor,
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
  final bool showTestPreset;

  const _NotificationTimesSheet({this.showTestPreset = false});

  @override
  ConsumerState<_NotificationTimesSheet> createState() => _NotificationTimesSheetState();
}

class _NotificationTimesSheetState extends ConsumerState<_NotificationTimesSheet> {
  late NotificationSchedule _schedule;
  static const _frequencyOptions = [30, 60, 120, 180, 240, 360, 480, 720];

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
            final availableHeight = mediaQuery.size.height -
                mediaQuery.viewPadding.top -
                mediaQuery.viewPadding.bottom;
            final isLandscape = mediaQuery.orientation == Orientation.landscape;
            // In landscape: use 55% of available height, portrait: 40%
            // Clamp to reasonable bounds for each orientation
            final pickerHeight = isLandscape
                ? (availableHeight * 0.55).clamp(180.0, 280.0)
                : (availableHeight * 0.40).clamp(250.0, 350.0);

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
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
                              child: Text('Done', style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w600)),
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
                                    child: Text(
                                      '$displayHour $period',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
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
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 20,
                                      ),
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

  bool _matchesPreset(NotificationPreset preset) {
    final presetSchedule = preset.schedule;
    return _schedule.startHour == presetSchedule.startHour &&
        _schedule.endHour == presetSchedule.endHour &&
        _schedule.frequencyMinutes == presetSchedule.frequencyMinutes;
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
    final colors = context.colors;
    final textColor = colors.textPrimary;
    final mutedColor = colors.textSecondary;

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
                            color: isSelected
                                ? colors.primary.withValues(alpha: isDark ? 0.3 : 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.glassBorder,
                            ),
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

/// Sound picker for ambient opening sound
class _AmbientSoundPicker extends ConsumerWidget {
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
