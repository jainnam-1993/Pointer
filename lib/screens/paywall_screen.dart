import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../providers/providers.dart';
import '../services/revenue_cat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
    final textColorSecondary = isDark ? Colors.white.withValues(alpha: 0.7) : AppColorsLight.textSecondary;
    final textColorMuted = isDark ? Colors.white.withValues(alpha: 0.5) : AppColorsLight.textMuted;
    final goldColor = isDark ? AppColors.gold : AppColorsLight.gold;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: bottomPadding + 20,
              ),
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: Semantics(
                      button: true,
                      label: 'Close premium subscription screen',
                      child: IconButton(
                        icon: Icon(Icons.close, color: textColor),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Premium icon with animation
                  StaggeredFadeIn(
                    index: 0,
                    child: Container(
                      width: 80,
                      height: 80,
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
                        size: 40,
                        color: goldColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  StaggeredFadeIn(
                    index: 1,
                    child: Text(
                      'Unlock Everything',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 8),

                  StaggeredFadeIn(
                    index: 2,
                    child: Text(
                      'Access all traditions and guided sessions',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColorSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Features
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _FeatureRow(
                          icon: Icons.self_improvement,
                          title: 'All Traditions',
                          description: 'Access pointings from all 5 lineages',
                        ),
                        const SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.spa,
                          title: 'Guided Sessions',
                          description: 'Unlock all self-inquiry sessions',
                        ),
                        const SizedBox(height: 16),
                        _FeatureRow(
                          icon: Icons.notifications_active,
                          title: 'Custom Notifications',
                          description: 'Set your preferred reminder times',
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Dynamic pricing from RevenueCat products
                  if (subscription.products.isNotEmpty) ...[
                    // Show monthly product
                    _ProductButton(
                      product: subscription.products.firstWhere(
                        (p) => p.isMonthly,
                        orElse: () => subscription.products.first,
                      ),
                      isLoading: subscription.isLoading,
                      goldColor: goldColor,
                      textColorMuted: textColorMuted,
                      onPurchase: (product) async {
                        final hasVibrator = await Vibration.hasVibrator();
                        if (hasVibrator == true) {
                          Vibration.vibrate(duration: 100, amplitude: 200);
                        }
                        final result = await ref
                            .read(subscriptionProvider.notifier)
                            .purchasePackage(product);
                        if (result.success && context.mounted) {
                          context.pop();
                        }
                      },
                    ),
                    // Show yearly product if available
                    if (subscription.products.any((p) => p.isYearly)) ...[
                      const SizedBox(height: 12),
                      _ProductButton(
                        product: subscription.products.firstWhere((p) => p.isYearly),
                        isLoading: subscription.isLoading,
                        goldColor: goldColor,
                        textColorMuted: textColorMuted,
                        isSecondary: true,
                        onPurchase: (product) async {
                          final hasVibrator = await Vibration.hasVibrator();
                          if (hasVibrator == true) {
                            Vibration.vibrate(duration: 100, amplitude: 200);
                          }
                          final result = await ref
                              .read(subscriptionProvider.notifier)
                              .purchasePackage(product);
                          if (result.success && context.mounted) {
                            context.pop();
                          }
                        },
                      ),
                    ],
                  ] else ...[
                    // Fallback when products not loaded
                    Text(
                      'Loading subscription options...',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColorMuted,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Restore purchases
                  Semantics(
                    button: true,
                    label: 'Restore previous purchases',
                    child: TextButton(
                      onPressed: () async {
                        await ref
                            .read(subscriptionProvider.notifier)
                            .restorePurchases();
                      },
                      child: Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: textColorMuted,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textColor = isDark ? Colors.white : AppColorsLight.textPrimary;
    final textColorSecondary = isDark ? Colors.white.withValues(alpha: 0.6) : AppColorsLight.textSecondary;
    final goldColor = isDark ? AppColors.gold : AppColorsLight.gold;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: goldColor.withValues(alpha: 0.1),
          ),
          child: Icon(
            icon,
            color: goldColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: textColorSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Product purchase button with dynamic pricing
class _ProductButton extends StatelessWidget {
  final SubscriptionProduct product;
  final bool isLoading;
  final Color goldColor;
  final Color textColorMuted;
  final bool isSecondary;
  final Future<void> Function(SubscriptionProduct) onPurchase;

  const _ProductButton({
    required this.product,
    required this.isLoading,
    required this.goldColor,
    required this.textColorMuted,
    required this.onPurchase,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final periodText = product.isYearly ? '/year' : '/month';
    final savingsText = product.isYearly ? ' (Save 40%)' : '';

    return Column(
      children: [
        Text(
          '${product.price}$periodText$savingsText',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: goldColor,
                fontSize: isSecondary ? 18 : 24,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cancel anytime',
          style: TextStyle(
            fontSize: 14,
            color: textColorMuted,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          label: isLoading
              ? 'Processing subscription'
              : 'Subscribe now for ${product.price} per ${product.isYearly ? "year" : "month"}',
          child: SizedBox(
            width: double.infinity,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderColor: goldColor.withValues(alpha: isSecondary ? 0.3 : 0.5),
              onTap: isLoading ? null : () => onPurchase(product),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: goldColor,
                        ),
                      )
                    : Text(
                        isSecondary ? 'Subscribe Yearly' : 'Subscribe Now',
                        style: TextStyle(
                          color: goldColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
