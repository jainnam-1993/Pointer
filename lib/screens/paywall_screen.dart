import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 12,
                bottom: bottomPadding + 20,
              ),
              child: Column(
                children: [
                  // Header: Back + Icon + Restore
                  _buildHeader(context, ref, colors),

                  const SizedBox(height: 32),

                  // Title
                  StaggeredFadeIn(
                    index: 0,
                    child: Text(
                      'Unlock Pointer',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: colors.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  StaggeredFadeIn(
                    index: 1,
                    child: Text(
                      'One-time purchase, yours forever',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Features list
                  _buildFeaturesList(colors),

                  const Spacer(),

                  // Price and CTA
                  _buildPurchaseSection(context, ref, subscription, colors),

                  const SizedBox(height: 16),

                  // Legal links
                  _buildLegalLinks(colors),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, PointerColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        Semantics(
          button: true,
          label: 'Go back',
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),

        // Center icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                colors.gold.withValues(alpha: 0.3),
                colors.gold.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: colors.gold.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 24,
            color: colors.gold,
          ),
        ),

        // Restore button
        Semantics(
          button: true,
          label: 'Restore previous purchases',
          child: TextButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              final result = await ref
                  .read(subscriptionProvider.notifier)
                  .restorePurchases();
              if (!context.mounted) return;
              if (result.hasPremium) {
                context.pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('No previous purchase found'),
                    backgroundColor: colors.surface,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              'Restore',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(PointerColors colors) {
    final features = [
      _FeatureItem(
        icon: Icons.all_inclusive,
        title: 'Unlimited Pointings',
        description: 'No daily limits, explore freely',
      ),
      _FeatureItem(
        icon: Icons.self_improvement,
        title: 'All Traditions',
        description: 'Access all 5 spiritual lineages',
      ),
      _FeatureItem(
        icon: Icons.headphones,
        title: 'Audio & TTS',
        description: 'Listen to guided readings',
      ),
      _FeatureItem(
        icon: Icons.spa,
        title: 'Guided Inquiries',
        description: 'Unlock all self-inquiry sessions',
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return StaggeredFadeIn(
            index: index + 2,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: index < features.length - 1 ? 16 : 0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.gold.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      feature.icon,
                      color: colors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          feature.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPurchaseSection(
    BuildContext context,
    WidgetRef ref,
    SubscriptionState subscription,
    PointerColors colors,
  ) {
    // Find lifetime product
    final lifetimeProduct = subscription.products.isNotEmpty
        ? subscription.products.firstWhere(
            (p) => p.isLifetime,
            orElse: () => subscription.products.first,
          )
        : null;

    return Column(
      children: [
        // Price display
        if (lifetimeProduct != null) ...[
          StaggeredFadeIn(
            index: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  lifetimeProduct.price,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: colors.gold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'lifetime',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          StaggeredFadeIn(
            index: 7,
            child: Text(
              'One-time purchase • No subscription',
              style: TextStyle(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ),
        ] else ...[
          Text(
            'Loading...',
            style: TextStyle(
              fontSize: 14,
              color: colors.textMuted,
            ),
          ),
        ],

        const SizedBox(height: 20),

        // Purchase button
        StaggeredFadeIn(
          index: 8,
          child: Semantics(
            button: true,
            label: subscription.isLoading
                ? 'Processing purchase'
                : lifetimeProduct != null
                    ? 'Purchase lifetime access for ${lifetimeProduct.price}'
                    : 'Loading purchase options',
            child: SizedBox(
              width: double.infinity,
              child: GlassButton(
                label: 'Unlock Pointer',
                onPressed: () async {
                  if (subscription.isLoading || lifetimeProduct == null) return;
                  HapticFeedback.heavyImpact();
                  final result = await ref
                      .read(subscriptionProvider.notifier)
                      .purchasePackage(lifetimeProduct);
                  if (!context.mounted) return;
                  if (result.success) {
                    context.pop();
                  } else if (result.error != null && !result.isCancelled) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.error!),
                        backgroundColor: Colors.red.shade700,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                isLoading: subscription.isLoading,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalLinks(PointerColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _launchUrl('https://pointer.app/privacy'),
          child: Text(
            'Privacy policy',
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
            ),
          ),
        ),
        Text(
          '•',
          style: TextStyle(color: colors.textMuted),
        ),
        TextButton(
          onPressed: () => _launchUrl('https://pointer.app/terms'),
          child: Text(
            'Terms of service',
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
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
