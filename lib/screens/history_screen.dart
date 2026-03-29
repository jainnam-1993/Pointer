import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/pointings.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/pointer_scaffold.dart';

/**
 * Screen showing chronological history of previously viewed pointings.
 *
 * Displays [_HistoryCard] items with tradition badge, content preview, teacher
 * attribution, and relative timestamp. Tapping a card sets it as the current
 * pointing and navigates back to the home screen. Shows an empty state
 * when no pointings have been viewed yet.
 */
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final viewedPointings = storage.viewedPointings;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;
    final titleFontSize = MediaQuery.of(context).size.width < 360 ? 24.0 : 28.0;

    return PointerScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.pop();
                  },
                  icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      'Past Pointings',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: titleFontSize),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Empty state or list
          Expanded(
            child: viewedPointings.isEmpty
                ? _buildEmptyState(context, colors)
                : _buildPointingsList(context, ref, viewedPointings, bottomPadding, colors),
          ),
        ],
      ),
    );
  }

  /** Builds the empty state shown when no pointings have been viewed yet. */
  Widget _buildEmptyState(BuildContext context, PointerColors colors) {
    return const EmptyStateWidget(
      icon: Icons.history,
      title: 'No pointings yet',
      subtitle: 'Your viewed pointings will appear here',
    );
  }

  /** Builds the scrollable list of viewed pointings with [StaggeredFadeIn] animations. */
  Widget _buildPointingsList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> viewedPointings,
    double bottomPadding,
    PointerColors colors,
  ) {
    return ListView.builder(
      padding: EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, top: AppSpacing.sm, bottom: 100 + bottomPadding),
      itemCount: viewedPointings.length,
      itemBuilder: (context, index) {
        final viewed = viewedPointings[index];
        final pointingId = viewed['id'] as String;
        final viewedAt = DateTime.fromMillisecondsSinceEpoch(viewed['viewedAt'] as int);

        // Find the actual pointing data
        final pointing = pointings.cast<Pointing?>().firstWhere((p) => p?.id == pointingId, orElse: () => null);

        if (pointing == null) return const SizedBox.shrink();

        return StaggeredFadeIn(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _HistoryCard(
              pointing: pointing,
              viewedAt: viewedAt,
              onTap: () {
                HapticFeedback.mediumImpact();
                // Set this pointing as current and go back to home
                ref.read(currentPointingProvider.notifier).setPointing(pointing);
                context.go('/');
              },
            ),
          ),
        );
      },
    );
  }
}

/** Card displaying a previously viewed [Pointing] with tradition badge and relative timestamp. */
class _HistoryCard extends StatelessWidget {
  /** The pointing to display. */
  final Pointing pointing;

  /** When this pointing was last viewed. */
  final DateTime viewedAt;

  /** Callback when the card is tapped (sets as current pointing and navigates home). */
  final VoidCallback onTap;

  const _HistoryCard({required this.pointing, required this.viewedAt, required this.onTap});

  /** Formats a [DateTime] as a relative time string (e.g., "5m ago", "Yesterday", "3/15"). */
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}m ago';
      }
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final traditionInfo = traditions[pointing.tradition]!;

    return Semantics(
      button: true,
      label: 'Pointing by ${pointing.teacher ?? "unknown"}: ${pointing.content.length > 80 ? pointing.content.substring(0, 80) : pointing.content}',
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with tradition and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Semantics(excludeSemantics: true, label: traditionInfo.name, child: Text(traditionInfo.icon, style: const TextStyle(fontSize: 16))),
                      const SizedBox(width: 8),
                    Text(
                      traditionInfo.name,
                      style: TextStyle(color: colors.accent, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(_formatDate(viewedAt), style: TextStyle(color: colors.textSecondary.withValues(alpha: 0.7), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            // Pointing content (truncated)
            Text(
              pointing.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.4),
            ),

            // Teacher attribution
            if (pointing.teacher != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '— ${pointing.teacher}',
                style: TextStyle(color: colors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }
}
