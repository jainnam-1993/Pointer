import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/glass_card.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Premium icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withValues(alpha:0.3),
                          AppColors.gold.withValues(alpha:0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha:0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: AppColors.gold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Unlock Everything',
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Access all traditions and guided sessions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha:0.7),
                    ),
                    textAlign: TextAlign.center,
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

                  // Price
                  Text(
                    '\$4.99 / month',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.gold,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Cancel anytime',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha:0.5),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Purchase button
                  Semantics(
                    button: true,
                    label: subscription.isLoading
                        ? 'Processing subscription'
                        : 'Subscribe now for 4.99 dollars per month',
                    child: SizedBox(
                      width: double.infinity,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        borderColor: AppColors.gold.withValues(alpha:0.5),
                        onTap: subscription.isLoading
                            ? null
                            : () async {
                                final hasVibrator = await Vibration.hasVibrator();
                                if (hasVibrator == true) {
                                  Vibration.vibrate(duration: 100, amplitude: 200);
                                }
                                final success = await ref
                                    .read(subscriptionProvider.notifier)
                                    .purchasePremium();
                                if (success && context.mounted) {
                                  context.pop();
                                }
                              },
                        child: Center(
                          child: subscription.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.gold,
                                  ),
                                )
                              : const Text(
                                  'Subscribe Now',
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

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
                          color: Colors.white.withValues(alpha:0.5),
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
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha:0.1),
          ),
          child: Icon(
            icon,
            color: AppColors.gold,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha:0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
