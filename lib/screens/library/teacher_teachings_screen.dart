/** Screen showing articles and quotes by a specific teacher. */
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
import '../../widgets/animated_transitions.dart';
import '../article_reader_screen.dart';
import 'library_models.dart';
import 'library_widgets.dart';

/**
 * Screen showing articles and quotes by a specific teacher.
 *
 * Displays an articles section (using [ArticleListItem]) and a quotes section
 * (using [TeachingCard]). Quotes are sorted with unviewed items first via
 * [TeachingListSorting]. Respects [ContentFilter] to show only articles,
 * only quotes, or both.
 */
class TeacherTeachingsScreen extends ConsumerStatefulWidget {
  /** The teacher name to filter content by. */
  final String teacher;

  /** Content type filter propagated from the parent library screen. */
  final ContentFilter filter;

  const TeacherTeachingsScreen({super.key, required this.teacher, this.filter = ContentFilter.all});

  @override
  ConsumerState<TeacherTeachingsScreen> createState() => _TeacherTeachingsScreenState();
}

class _TeacherTeachingsScreenState extends ConsumerState<TeacherTeachingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final storage = ref.watch(storageServiceProvider);
    final viewedIds = storage.viewedTeachingIds;
    final allTeachings = TeachingRepository.byTeacher(widget.teacher);
    final allArticles = getArticlesByTeacher(widget.teacher);

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
                              Text(
                                widget.teacher,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colors.textPrimary),
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

                // Articles section (if any)
                if (articles.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: Text(
                        'ARTICLES (${articles.length})',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
                      ),
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
                                Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleReaderScreen(article: article)));
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
                    padding: EdgeInsets.fromLTRB(24, articles.isNotEmpty ? 24 : 16, 24, 12),
                    child: Text(
                      'QUOTES (${teachings.length})',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
                    ),
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
