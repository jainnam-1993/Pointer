/**
 * Expandable tip jar donation widget for the settings screen.
 *
 * Provides a collapsible [GlassCard] that expands to reveal a 2x2 grid of
 * consumable in-app purchase options (Tea, Cushion, Incense, Retreat).
 * Integrates with [DonationNotifier] for IAP lifecycle management.
 *
 * See also: [DonationState] for the underlying state model.
 */
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../layout/adaptive.dart';
import '../providers/donation_providers.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';
import '../utils/haptics.dart';
import '../theme/app_icons.dart';
import '../utils/motion.dart';
import 'press_scale.dart';

/** Product display configuration pairing a product ID with its label and icon. */
class _TipProduct {
  final String label;
  final IconData icon;

  const _TipProduct(this.label, this.icon);
}

/** Map product IDs to display labels and icons */
const _tipProducts = <String, _TipProduct>{
  // Phosphor Light line icons, distinct from the tab icons.
  'tip_small': _TipProduct('Tea', AppIcons.tipTea),
  'tip_medium': _TipProduct('Cushion', AppIcons.tipCushion),
  'tip_large': _TipProduct('Incense', AppIcons.tipIncense),
  'tip_generous': _TipProduct('Retreat', AppIcons.tipRetreat),
};

/**
 * Resolves a product config from either a short ID (tip_small) or
 * a fully-qualified store ID (com.dailypointer.tip_small).
 */
_TipProduct? _resolveTipProduct(String productId) {
  final direct = _tipProducts[productId];
  if (direct != null) return direct;
  final suffix = productId.split('.').last;
  return _tipProducts[suffix];
}

/** Widest the tip card grows: about a large phone, so tier tiles keep their phone proportions. */
const double kTipCardMaxWidth = 440;

/**
 * Floating donation button with expandable tip options
 *
 * Displays as a collapsed button that expands to show:
 * - Description text
 * - 2x2 grid of tip options
 *
 * Integrates with [donationProvider] for IAP state management.
 */
class DonationButton extends ConsumerStatefulWidget {
  const DonationButton({super.key});

  @override
  ConsumerState<DonationButton> createState() => _DonationButtonState();
}

class _DonationButtonState extends ConsumerState<DonationButton> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    Haptics.selection();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onTipSelected(ProductDetails product) {
    Haptics.light();
    ref.read(donationProvider.notifier).purchaseTip(product);
  }

  void _retry() {
    Haptics.light();
    ref.read(donationProvider.notifier).initialize();
  }

  /** Light, 60 ms, light: the success pattern for a completed tip. */
  Future<void> _successHaptic() async {
    await Haptics.success();
  }

  void _dismissResult() {
    Haptics.light();
    ref.read(donationProvider.notifier).clearResult();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DonationResult?>(donationProvider.select((s) => s.lastResult), (previous, next) {
      if (next == null || next == previous) return;
      if (next == DonationResult.success) unawaited(_successHaptic());
      // Show the outcome even if the card was collapsed when it arrived.
      if (next != DonationResult.cancelled && !_isExpanded) setState(() => _isExpanded = true);
    });
    final state = ref.watch(donationProvider);
    if (!state.isAvailable && !state.isLoading) {
      return const SizedBox.shrink();
    }
    final colors = context.colors;

    // Capped at a phone-sized width so the two-column tier grid keeps its phone proportions on wide windows.
    return ContentWidth(
      maxWidth: kTipCardMaxWidth,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: GlassCard(padding: EdgeInsets.zero, intensity: GlassIntensity.standard, child: _buildContent(state, colors)),
      ),
    );
  }

  Widget _buildContent(DonationState state, PointerColors colors) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
      onTap: _toggleExpanded,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(AppIcons.heart, color: colors.accent, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Support Development',
              style: TextStyle(color: colors.textPrimary, fontFamily: AppFonts.sans, fontSize: AppType.body, fontWeight: FontWeight.w600),
            ),
          ),
          if (state.isLoading && !_isExpanded)
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent))
          else
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(AppIcons.chevronDown, color: colors.textMuted, size: 24),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(DonationState state, PointerColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Here Now is free forever. If you find value, consider supporting development.',
          style: TextStyle(color: colors.textSecondary, fontFamily: AppFonts.sans, fontSize: AppType.callout, height: 1.45),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Tips do not unlock features.',
          style: TextStyle(fontFamily: AppFonts.sans, color: colors.textMuted, fontSize: AppType.caption, height: 1.4),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildProductGrid(state, colors),
      ],
    );
  }

  Widget _buildProductGrid(DonationState state, PointerColors colors) {
    if (state.lastResult == DonationResult.success) {
      return _ThankYou(colors: colors, onDone: _dismissResult);
    }

    // Loading state
    if (state.isLoading) {
      return Center(
        child: Padding(
          padding: AppSpacing.cardAll,
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(
            'No donation options available',
            style: TextStyle(fontFamily: AppFonts.sans, color: colors.textMuted, fontSize: AppType.callout),
          ),
        ),
      );
    }

    // Products grid (2x2), with a calm note for the last attempt
    final note = _resultNote(state);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (note != null) ...[
          Semantics(
            liveRegion: true,
            child: Text(
              note,
              style: TextStyle(fontFamily: AppFonts.sans, color: colors.textSecondary, fontSize: AppType.callout, height: 1.45),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildProductsGrid(state.products, colors),
      ],
    );
  }

  /** User-facing copy for [DonationState.lastResult]; null when nothing to say. */
  static String? _resultNote(DonationState state) {
    return switch (state.lastResult) {
      DonationResult.pending => 'Your tip is waiting for approval. It will finish on its own, and you will not be charged twice.',
      DonationResult.cancelled => 'Purchase cancelled. You were not charged.',
      DonationResult.error => 'The tip did not go through, and you were not charged. Please try again.',
      DonationResult.success || null => null,
    };
  }

  Widget _buildErrorState(DonationState state, PointerColors colors) {
    return Column(
      children: [
        Text(
          state.error ?? 'An error occurred',
          style: TextStyle(fontFamily: AppFonts.sans, color: colors.textSecondary, fontSize: AppType.callout),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: _retry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: colors.glassBorder),
            ),
            child: Text(
              'Retry',
              style: TextStyle(color: colors.accent, fontFamily: AppFonts.sans, fontSize: AppType.callout, fontWeight: FontWeight.w500),
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
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.4,
      children: products.map((product) {
        final config = _resolveTipProduct(product.id);
        return _TipOptionCard(
          product: product,
          label: config?.label ?? product.title,
          icon: config?.icon ?? AppIcons.tipFallback,
          colors: colors,
          onTap: isPurchasing ? null : () => _onTipSelected(product),
          isDisabled: isPurchasing,
        );
      }).toList(),
    );
  }
}

/**
 * Thank-you moment shown in place of the tier grid after a completed tip.
 *
 * An ink enso draws itself once ([Motion.calm]), then the gratitude copy and a Done
 * control that returns to the tiers. No blur or repeating animation.
 */
class _ThankYou extends StatelessWidget {
  final PointerColors colors;
  final VoidCallback onDone;

  const _ThankYou({required this.colors, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      liveRegion: true,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
            duration: Motion.calm,
            curve: Curves.easeInOutCubic,
            builder: (context, progress, _) => CustomPaint(
              size: const Size.square(56),
              painter: _EnsoPainter(progress: progress, color: colors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Thank you. This keeps Here Now free.',
            style: AppTextStyles.quoteText(context).copyWith(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            button: true,
            child: GestureDetector(
              onTap: onDone,
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44, minWidth: 88),
                child: Center(
                  child: Text(
                    'Done',
                    style: TextStyle(fontFamily: AppFonts.sans, color: colors.accent, fontSize: AppType.callout, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/** Paints an open enso brush circle up to [progress] (0 to 1) of its sweep. */
class _EnsoPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _EnsoPainter({required this.progress, required this.color});

  static const _start = -1.9; // radians, upper left like a brush entry
  static const _sweep = 5.6; // leaves the traditional gap

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.07;
    canvas.drawArc(rect.deflate(paint.strokeWidth), _start, _sweep * progress, false, paint);
  }

  @override
  bool shouldRepaint(_EnsoPainter old) => old.progress != progress || old.color != color;
}

/** Individual tip option card */
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

    return PressScale(
      onTap: onTap,
      haptic: false,
      child: AnimatedOpacity(
        duration: Motion.instant,
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: colors.glassBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colors.accent, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(color: colors.textPrimary, fontFamily: AppFonts.sans, fontSize: AppType.callout, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                product.price,
                style: TextStyle(fontFamily: AppFonts.sans, color: colors.textMuted, fontSize: AppType.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
