/// Expandable tip jar donation widget for the settings screen.
///
/// Provides a collapsible [GlassCard] that expands to reveal a 2x2 grid of
/// consumable in-app purchase options (Tea, Cushion, Incense, Retreat).
/// Integrates with [DonationNotifier] for IAP lifecycle management.
///
/// See also: [DonationState] for the underlying state model.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../providers/donation_providers.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// Product display configuration pairing a product ID with its label and icon.
class _TipProduct {
  final String label;
  final IconData icon;

  const _TipProduct(this.label, this.icon);
}

/// Map product IDs to display labels and icons
const _tipProducts = <String, _TipProduct>{
  'tip_small': _TipProduct('Tea', Icons.local_cafe_outlined),
  'tip_medium': _TipProduct('Cushion', Icons.self_improvement_outlined),
  'tip_large': _TipProduct('Incense', Icons.spa_outlined),
  'tip_generous': _TipProduct('Retreat', Icons.park_outlined),
};

/// Floating donation button with expandable tip options
///
/// Displays as a collapsed button that expands to show:
/// - Description text
/// - 2x2 grid of tip options
///
/// Integrates with [donationProvider] for IAP state management.
class DonationButton extends ConsumerStatefulWidget {
  const DonationButton({super.key});

  @override
  ConsumerState<DonationButton> createState() => _DonationButtonState();
}

class _DonationButtonState extends ConsumerState<DonationButton> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onTipSelected(ProductDetails product) {
    HapticFeedback.mediumImpact();
    ref.read(donationProvider.notifier).purchaseTip(product);
  }

  void _retry() {
    HapticFeedback.lightImpact();
    ref.read(donationProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(donationProvider);
    final colors = context.colors;

    // Hide when not available and not loading
    if (!state.isAvailable && !state.isLoading) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: GlassCard(padding: EdgeInsets.zero, intensity: GlassIntensity.standard, child: _buildContent(state, colors)),
    );
  }

  Widget _buildContent(DonationState state, PointerColors colors) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row - always visible
            _buildHeader(state, colors),

            // Expanded content
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isExpanded ? 1.0 : 0.0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isExpanded ? _buildExpandedContent(state, colors) : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DonationState state, PointerColors colors) {
    return GestureDetector(
      onTap: state.isLoading ? null : _toggleExpanded,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(Icons.favorite_outline, color: colors.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Support Development',
              style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          if (state.isLoading && !_isExpanded)
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent))
          else
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.keyboard_arrow_down, color: colors.textMuted, size: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(DonationState state, PointerColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Here Now is free forever. If you find value, consider supporting development.',
          style: TextStyle(color: colors.textSecondary, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),
        _buildProductGrid(state, colors),
      ],
    );
  }

  Widget _buildProductGrid(DonationState state, PointerColors colors) {
    // Loading state
    if (state.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(color: colors.accent),
        ),
      );
    }

    // Error state
    if (state.error != null) {
      return _buildErrorState(state, colors);
    }

    // No products available
    if (state.products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No donation options available', style: TextStyle(color: colors.textMuted, fontSize: 14)),
        ),
      );
    }

    // Products grid (2x2)
    return _buildProductsGrid(state.products, colors);
  }

  Widget _buildErrorState(DonationState state, PointerColors colors) {
    return Column(
      children: [
        Text(
          state.error ?? 'An error occurred',
          style: TextStyle(color: Colors.red.shade300, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _retry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.glassBorder),
            ),
            child: Text(
              'Retry',
              style: TextStyle(color: colors.accent, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(List<ProductDetails> products, PointerColors colors) {
    final state = ref.watch(donationProvider);
    final isPurchasing = state.isLoading;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: products.map((product) {
        final config = _tipProducts[product.id];
        return _TipOptionCard(
          product: product,
          label: config?.label ?? product.title,
          icon: config?.icon ?? Icons.card_giftcard_outlined,
          colors: colors,
          onTap: isPurchasing ? null : () => _onTipSelected(product),
          isDisabled: isPurchasing,
        );
      }).toList(),
    );
  }
}

/// Individual tip option card
class _TipOptionCard extends StatelessWidget {
  final ProductDetails product;
  final String label;
  final IconData icon;
  final PointerColors colors;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _TipOptionCard({required this.product, required this.label, required this.icon, required this.colors, this.onTap, this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.glassBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.accent, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: colors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(product.price, style: TextStyle(color: colors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
