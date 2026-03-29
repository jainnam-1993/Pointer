/** Screen showing articles and quotes filtered by topic tag. */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/articles.dart';
import '../../data/teaching.dart';
import '../../models/article.dart';
import '../../providers/core_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_gradient.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/animated_transitions.dart';
import 'library_models.dart';
import 'library_widgets.dart';

/**
 * Screen showing articles and quotes filtered by a [TopicTags] value.
 *
 * Displays the topic icon and display name in the header, with articles
 * (via [ArticleListItem]) and quotes (via [TeachingCard]) sections.
 * Quotes sorted with unviewed first. Shows an empty state when no content
 * matches the topic. Respects [ContentFilter] from parent.
 */
class TopicTeachingsScreen extends ConsumerStatefulWidget {
  /** The topic tag string (from [TopicTags] constants) to filter by. */
  final String topic;

  /** Content type filter propagated from the parent library screen. */
  final ContentFilter filter;

  const TopicTeachingsScreen({super.key, required this.topic, this.filter = ContentFilter.all});

  @override
  ConsumerState<TopicTeachingsScreen> createState() => _TopicTeachingsScreenState();
}

class _TopicTeachingsScreenState extends ConsumerState<TopicTeachingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final storage = ref.watch(storageServiceProvider);
    final viewedIds = storage.viewedTeachingIds;
    final allArticles = getArticlesByTopic(widget.topic);
    final allTeachings = TeachingRepository.byTopic(widget.topic);

    // Apply filter and sort by viewed status (unviewed first)
    final articles = widget.filter == ContentFilter.quotes ? <Article>[] : allArticles;
    final filteredTeachings = widget.filter == ContentFilter.articles ? <Teaching>[] : allTeachings;
    final teachings = filteredTeachings.sortedByViewedStatus(viewedIds);

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
                              Row(
                                children: [
                                  Text(TopicTags.icon(widget.topic), style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    TopicTags.displayName(widget.topic),
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                              Text(
                                '${articles.length} articles, ${teachings.length} quotes',
                                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Articles section
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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

                // Empty state if no content
                if (articles.isEmpty && teachings.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text('No content found for this topic', style: TextStyle(color: colors.textMuted)),
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
