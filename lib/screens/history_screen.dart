import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/pointings.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';

/// Screen showing history of viewed pointings
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final viewedPointings = storage.viewedPointings;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.colors;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.pop();
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: colors.textPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Past Pointings',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Empty state or list
                Expanded(
                  child: viewedPointings.isEmpty
                      ? _buildEmptyState(context, colors)
                      : _buildPointingsList(
                          context, ref, viewedPointings, bottomPadding, colors),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, PointerColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: colors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No pointings yet',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your viewed pointings will appear here',
            style: TextStyle(
              color: colors.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointingsList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> viewedPointings,
    double bottomPadding,
    PointerColors colors,
  ) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 100 + bottomPadding,
      ),
      itemCount: viewedPointings.length,
      itemBuilder: (context, index) {
        final viewed = viewedPointings[index];
        final pointingId = viewed['id'] as String;
        final viewedAt = DateTime.fromMillisecondsSinceEpoch(viewed['viewedAt'] as int);

        // Find the actual pointing data
        final pointing = pointings.cast<Pointing?>().firstWhere(
          (p) => p?.id == pointingId,
          orElse: () => null,
        );

        if (pointing == null) return const SizedBox.shrink();

        return StaggeredFadeIn(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
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

class _HistoryCard extends StatelessWidget {
  final Pointing pointing;
  final DateTime viewedAt;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.pointing,
    required this.viewedAt,
    required this.onTap,
  });

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

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with tradition and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      traditionInfo.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      traditionInfo.name,
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatDate(viewedAt),
                  style: TextStyle(
                    color: colors.textSecondary.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pointing content (truncated)
            Text(
              pointing.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                height: 1.4,
              ),
            ),

            // Teacher attribution
            if (pointing.teacher != null) ...[
              const SizedBox(height: 8),
              Text(
                '— ${pointing.teacher}',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
