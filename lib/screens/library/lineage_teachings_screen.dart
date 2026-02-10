/** Screen showing articles and quotes filtered by tradition/lineage. */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/articles.dart';
import '../../data/pointings.dart';
import '../../data/teaching.dart';
import '../../models/article.dart';
import '../../providers/core_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_gradient.dart';
import '../../widgets/animated_transitions.dart';
import '../article_reader_screen.dart';
import 'library_models.dart';
import 'library_widgets.dart';

/**
 * Screen showing articles and quotes filtered by spiritual tradition/lineage.
 *
 * Displays the tradition description, an articles section with [ArticleListItem],
 * and a quotes section with [TeachingCard]. Quotes sorted with unviewed first.
 * Respects [ContentFilter] from the parent library screen.
 */
class LineageTeachingsScreen extends ConsumerStatefulWidget {
  /** The tradition to filter content by. */
  final Tradition tradition;

  /** Display metadata (name, icon, description) for this tradition. */
  final TraditionInfo info;

  /** Content type filter propagated from the parent library screen. */
  final ContentFilter filter;

  const LineageTeachingsScreen({super.key, required this.tradition, required this.info, this.filter = ContentFilter.all});

  @override
  ConsumerState<LineageTeachingsScreen> createState() => _LineageTeachingsScreenState();
}

class _LineageTeachingsScreenState extends ConsumerState<LineageTeachingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final storage = ref.watch(storageServiceProvider);
    final viewedIds = storage.viewedTeachingIds;
    final allTeachings = TeachingRepository.byLineage(widget.tradition);
    final allArticles = getArticlesByTradition(widget.tradition);

    // Apply filter and sort by viewed status (unviewed first)
    final filteredTeachings = widget.filter == ContentFilter.articles ? <Teaching>[] : allTeachings;
    final teachings = filteredTeachings.sortedByViewedStatus(viewedIds);
    final articles = widget.filter == ContentFilter.quotes ? <Article>[] : allArticles;

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
                                  Text(widget.info.icon, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.info.name,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colors.textPrimary),
                                  ),
                                ],
                              ),
                              Text(
                                '${articles.length} articles · ${teachings.length} quotes',
                                style: TextStyle(fontSize: 14, color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Description
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text(widget.info.description, style: TextStyle(color: colors.textSecondary, fontSize: 15)),
                  ),
                ),

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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleReaderScreen(article: article)));
                              },
                            ),
                          ),
                        );
                      }, childCount: articles.length),
                    ),
                  ),
                ],

                // Quotes section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, articles.isNotEmpty ? 24 : 0, 24, 12),
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
            ),
          ),
        ],
      ),
    );
  }
}
