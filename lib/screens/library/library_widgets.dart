/**
 * Shared widgets for library screens: SectionHeader, ArticleListItem, TeachingCard,
 * FilterSheet, and FilterOption.
 *
 * Also provides showLibraryShareSheet for sharing teachings via SharePreviewScreen.
 */
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/pointings.dart';
import '../../data/teaching.dart';
import '../../models/article.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../share_preview_screen.dart';

/// Section header for separated content sections
class SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const SectionHeader({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: colors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Text(
              count.toString(),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card for displaying an article in a list
class ArticleListItem extends StatelessWidget {
  final Article article;
  final bool isLocked;
  final VoidCallback onTap;

  const ArticleListItem({super.key, required this.article, required this.isLocked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: '${article.title}. ${article.subtitle ?? ""}. ${article.readingTimeMinutes} minute read${isLocked ? ". Premium content, locked" : ""}',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Opacity(
          opacity: isLocked ? 0.6 : 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    ),
                    if (article.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: colors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('${article.readingTimeMinutes} min', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                        if (article.teacher != null) ...[
                          Text(' · ', style: TextStyle(fontSize: 12, color: colors.textMuted)),
                          Flexible(
                            child: Text(
                              article.teacher!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: colors.textMuted),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(Icons.arrow_forward_ios, size: 14, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card for displaying a teaching/quote
class TeachingCard extends StatelessWidget {
  final Teaching teaching;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final bool isViewed;

  const TeachingCard({super.key, required this.teaching, this.onTap, this.onShare, this.isViewed = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final traditionInfo = traditions[teaching.lineage]!;

    return Semantics(
      label: '${teaching.content}. By ${teaching.teacher}. ${traditionInfo.name} tradition.${isViewed ? " Previously read." : ""}',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Opacity(
          opacity: isViewed ? 0.7 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content
              Text(teaching.content, style: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.5)),
              const SizedBox(height: 12),

              // Footer: Teacher, share, and lineage
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '— ${teaching.teacher}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textMuted, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                  if (onShare != null) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onShare,
                      child: Icon(Icons.share_outlined, size: 18, color: colors.textMuted),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: colors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(traditionInfo.icon, style: const TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(traditionInfo.name, style: TextStyle(color: colors.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),

              // Topic tags
              if (teaching.topicTags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: teaching.topicTags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.glassBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.glassBorder),
                      ),
                      child: Text(TopicTags.displayName(tag), style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ), // Opacity
      ), // GlassCard
    );
  }
}

/// Show share sheet for a teaching
void showLibraryShareSheet(BuildContext context, Teaching teaching) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.9,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SharePreviewScreen(pointing: teaching.toPointing()),
      ),
    ),
  );
}

/// Shared glassmorphism bottom sheet for filter options
class FilterSheet<T> extends StatelessWidget {
  final String title;
  final List<FilterOption<T>> options;
  final T currentValue;
  final ValueChanged<T> onSelected;

  const FilterSheet({super.key, required this.title, required this.options, required this.currentValue, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;
    // Navbar clearance: navbar height (~65) + small gap (8)
    const navbarClearance = 73.0;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            decoration: BoxDecoration(
              // Dark frosted glass: semi-opaque dark base + subtle light gradient overlay
              color: isDark
                  ? const Color(0xFF1C1C1E).withValues(alpha: 0.85) // iOS system gray6 dark
                  : Colors.white.withValues(alpha: 0.92),
              gradient: isDark
                  ? LinearGradient(
                      colors: [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.02)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 16),
                ...options.map((option) {
                  final isSelected = option.value == currentValue;
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(option.icon, color: isSelected ? colors.accent : colors.textMuted),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        color: isSelected ? colors.accent : colors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check, color: colors.accent) : null,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSelected(option.value);
                    },
                  );
                }),
                // Navbar clearance
                SizedBox(height: navbarClearance + MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Option for filter sheet
class FilterOption<T> {
  final T value;
  final String label;
  final IconData icon;

  const FilterOption({required this.value, required this.label, required this.icon});
}

