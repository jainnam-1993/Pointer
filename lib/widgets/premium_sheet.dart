import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Shows a modal bottom sheet with premium subscription details
void showPremiumSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PremiumSheet(),
  );
}

/// Modal sheet showing premium features and account actions
class PremiumSheet extends ConsumerWidget {
  const PremiumSheet({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String get _manageSubscriptionUrl {
    // For lifetime purchases, link to the app page (subscriptions page may show "no active subscriptions")
    if (Platform.isIOS) {
      return 'itms-apps://apps.apple.com/app/pointer/id6714086922';
    } else {
      return 'https://play.google.com/store/apps/details?id=com.pointer.pointer';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    final goldColor = colors.gold;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.75,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header with gold star
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            goldColor.withValues(alpha: 0.3),
                            goldColor.withValues(alpha: 0.1),
                          ],
                        ),
                        border: Border.all(
                          color: goldColor.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 28,
                        color: goldColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    'Premium Active',
                    style: AppTextStyles.heading(context),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    'Lifetime access',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Features list
                  _buildFeaturesList(colors, goldColor),

                  const SizedBox(height: 24),

                  // Actions
                  _buildActions(context, ref, colors, goldColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesList(PointerColors colors, Color goldColor) {
    final features = [
      _FeatureItem(
        icon: Icons.all_inclusive,
        title: 'Unlimited Pointings',
        description: 'No daily limits',
      ),
      _FeatureItem(
        icon: Icons.self_improvement,
        title: 'All Traditions',
        description: 'All 5 spiritual lineages',
      ),
      _FeatureItem(
        icon: Icons.headphones,
        title: 'Audio & TTS',
        description: 'Guided readings',
      ),
      _FeatureItem(
        icon: Icons.spa,
        title: 'Guided Inquiries',
        description: 'All inquiry sessions',
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features Unlocked',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < features.length - 1 ? 12 : 0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goldColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      feature.icon,
                      color: goldColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          feature.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: goldColor,
                    size: 18,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    WidgetRef ref,
    PointerColors colors,
    Color goldColor,
  ) {
    return Column(
      children: [
        // Restore Purchases
        Semantics(
          button: true,
          label: 'Restore purchases',
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () async {
              HapticFeedback.mediumImpact();
              final result = await ref
                  .read(subscriptionProvider.notifier)
                  .restorePurchases();
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.hasPremium
                        ? 'Purchases restored successfully'
                        : 'No previous purchases found',
                  ),
                  backgroundColor: result.hasPremium ? Colors.green : colors.surface,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.refresh, color: colors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Restore Purchases',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textMuted, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Manage Subscription
        Semantics(
          button: true,
          label: 'View in ${Platform.isIOS ? 'App Store' : 'Play Store'}',
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () async {
              HapticFeedback.mediumImpact();
              await _launchUrl(_manageSubscriptionUrl);
            },
            child: Row(
              children: [
                Icon(
                  Platform.isIOS ? Icons.apple : Icons.shop,
                  color: colors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'View in ${Platform.isIOS ? 'App Store' : 'Play Store'}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textMuted, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Contact Support
        Semantics(
          button: true,
          label: 'Contact support',
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            onTap: () async {
              HapticFeedback.mediumImpact();
              await _launchUrl('mailto:support@pointer.app');
            },
            child: Row(
              children: [
                Icon(Icons.mail_outline, color: colors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Contact Support',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
