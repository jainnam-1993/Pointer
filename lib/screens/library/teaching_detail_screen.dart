/**
 * Unified teaching detail screen used by all browse-by detail views
 * (teacher, lineage, mood, topic).
 *
 * Displays a back-button app bar, optional description widget, articles
 * section ([ArticleListItem]), and quotes section ([TeachingCard]).
 * Quotes are sorted with unviewed items first via [TeachingListSorting].
 * Respects [ContentFilter] to show only articles, only quotes, or both.
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/teaching.dart';
import '../../models/article.dart';
import '../../providers/core_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_gradient.dart';
import '../../widgets/animated_transitions.dart';
import 'package:go_router/go_router.dart';
import 'library_models.dart';
import 'library_widgets.dart';

/**
 * A parameterized screen that renders articles and quotes for any
 * browse-by dimension (teacher, lineage, mood, topic).
 *
 * Each concrete screen (e.g. [TeacherTeachingsScreen]) is a thin wrapper
 * that resolves its data and delegates to this widget.
 */
class TeachingDetailScreen extends ConsumerStatefulWidget {
  /** Primary title shown in the app bar. */
  final String title;

  /** Optional subtitle below the title (e.g. "5 articles, 12 quotes"). */
  final String? subtitle;

  /** Optional description widget rendered between the app bar and content. */
  final Widget? descriptionWidget;

  /** Articles to display in the articles section. */
  final List<Article> articles;

  /** Teachings (quotes) to display in the quotes section. */
  final List<Teaching> teachings;

  /** Content type filter (all, articles only, or quotes only). */
  final ContentFilter filter;

  /** Whether to show an empty state when both articles and teachings are empty. */
  final bool showEmptyState;

  const TeachingDetailScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.descriptionWidget,
    required this.articles,
    required this.teachings,
    required this.filter,
    this.showEmptyState = false,
  });

  @override
  ConsumerState<TeachingDetailScreen> createState() => _TeachingDetailScreenState();
}

class _TeachingDetailScreenState extends ConsumerState<TeachingDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final storage = ref.watch(storageServiceProvider);
    final viewedIds = storage.viewedTeachingIds;

    // Apply filter and sort by viewed status (unviewed first)
    final filteredTeachings = widget.filter == ContentFilter.articles ? <Teaching>[] : widget.teachings;
    final teachings = filteredTeachings.sortedByViewedStatus(viewedIds);
    final articles = widget.filter == ContentFilter.quotes ? <Article>[] : widget.articles;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colors.textPrimary),
                              ),
                              if (widget.subtitle != null)
                                Text(
                                  widget.subtitle!,
                                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Optional description
                if (widget.descriptionWidget != null) widget.descriptionWidget!,

                // Articles section (if any)
                if (articles.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SectionHeader(title: 'Articles', count: articles.length),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final article = articles[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ArticleListItem(
                              article: article,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                context.push('/article/${article.id}');
                              },
                            ),
                          ),
                        );
                      }, childCount: articles.length),
                    ),
                  ),
                ],

                // Quotes section
                if (teachings.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, articles.isNotEmpty ? 24 : 0, 24, 0),
                      child: SectionHeader(title: 'Quotes', count: teachings.length),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(left: 24, right: 24, bottom: 32 + bottomPadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final teaching = teachings[index];
                        final isViewed = viewedIds.contains(teaching.id);
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TeachingCard(
                              teaching: teaching,
                              isViewed: isViewed,
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                await storage.markTeachingAsViewed(teaching.id);
                                if (context.mounted) setState(() {});
                              },
                              onShare: () => showLibraryShareSheet(context, teaching),
                            ),
                          ),
                        );
                      }, childCount: teachings.length),
                    ),
                  ),
                ],

                // Empty state
                if (widget.showEmptyState && articles.isEmpty && teachings.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text('No content found', style: TextStyle(color: colors.textMuted)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
