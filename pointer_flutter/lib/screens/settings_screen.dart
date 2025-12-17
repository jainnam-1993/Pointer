import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  final int _frequency = 3;

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
                        subtitle: '$_frequency per day',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) async {
                            final hasVibrator = await Vibration.hasVibrator();
                            if (hasVibrator == true) {
                              Vibration.vibrate(duration: 50, amplitude: 128);
                            }
                            setState(() => _notificationsEnabled = value);
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
                        onTap: () {},
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
                    onTap: () {},
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
                    onTap: () {},
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
                        onTap: () {},
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Privacy Policy',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColorSubtle,
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Terms of Service',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textColorSubtle,
                          size: 20,
                        ),
                        onTap: () {},
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
          // OLED Black Mode toggle
          _OledModeToggle(),
        ],
      ),
    );
  }
}

class _OledModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOledMode = ref.watch(oledModeProvider);
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
                'OLED Black Mode',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Pure black background for OLED displays',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColorsLight.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isOledMode,
          onChanged: (value) async {
            final settings = ref.read(settingsProvider);
            await ref.read(settingsProvider.notifier).update(
              settings.copyWith(oledMode: value),
            );
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
