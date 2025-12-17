import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Expandable commentary section for premium users.
/// Shows extended context and guidance for pointings.
class CommentarySection extends ConsumerStatefulWidget {
  final String? commentary;
  final String pointingId;

  const CommentarySection({
    super.key,
    required this.commentary,
    required this.pointingId,
  });

  @override
  ConsumerState<CommentarySection> createState() => _CommentarySectionState();
}

class _CommentarySectionState extends ConsumerState<CommentarySection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _iconTurns = _controller.drive(
      Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    final subscription = ref.read(subscriptionProvider);

    if (!subscription.isPremium) {
      // Show paywall for non-premium users
      _showPremiumPrompt();
      return;
    }

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _showPremiumPrompt() {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              color: colors.gold,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Premium Feature',
              style: AppTextStyles.heading(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Extended commentary provides deeper context and practice suggestions for each pointing.',
              style: AppTextStyles.bodyText(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to paywall
                  // context.push('/paywall');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Upgrade to Premium'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.commentary == null) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final subscription = ref.watch(subscriptionProvider);
    final isPremium = subscription.isPremium;

    return Column(
      children: [
        // Header with expand/collapse
        GestureDetector(
          onTap: _toggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPremium)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: colors.gold,
                    ),
                  ),
                Text(
                  'Extended Commentary',
                  style: AppTextStyles.footerText(context).copyWith(
                    color: isPremium ? colors.textSecondary : colors.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: isPremium ? colors.textSecondary : colors.gold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expandable content
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _heightFactor.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              widget.commentary!,
              style: AppTextStyles.instructionText(context).copyWith(
                fontStyle: FontStyle.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
