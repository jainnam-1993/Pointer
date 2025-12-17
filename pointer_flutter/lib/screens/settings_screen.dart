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
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.white.withValues(alpha:0.4),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white.withValues(alpha:0.2),
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
                                color: Colors.white.withValues(alpha:0.5),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.white.withValues(alpha:0.4),
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

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
                      color: Colors.white.withValues(alpha:0.4),
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
                      color: Colors.white.withValues(alpha:0.4),
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
                      color: Colors.white.withValues(alpha:0.4),
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
                      ? AppColors.gold.withValues(alpha:0.3)
                      : null,
                  child: subscription.isPremium
                      ? _SettingsRow(
                          title: 'Premium Active',
                          subtitle: 'All features unlocked',
                          trailing: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.gold,
                            size: 24,
                          ),
                        )
                      : _SettingsRow(
                          title: 'Upgrade to Premium',
                          subtitle: 'Unlock all traditions & sessions',
                          leading: const Icon(
                            Icons.auto_awesome,
                            color: AppColors.gold,
                            size: 18,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.white.withValues(alpha:0.4),
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
                          color: Colors.white.withValues(alpha:0.4),
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Privacy Policy',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.white.withValues(alpha:0.4),
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                      const _Divider(),
                      _SettingsRow(
                        title: 'Terms of Service',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.white.withValues(alpha:0.4),
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
                      color: Colors.white.withValues(alpha:0.3),
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha:0.5),
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
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha:0.1),
    );
  }
}
