/**
 * Library screen for browsing articles and teachings from non-dual traditions.
 *
 * Provides multiple browse modes (topics, teachers, lineages, moods, saved) with
 * ContentFilter support (all/articles/quotes). Features a horizontal-scrolling
 * featured articles section with peek indicator, browse mode and content type
 * dropdowns.
 *
 * Re-exports all library/ subfiles for backward compatibility.
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// flutter_markdown_plus moved to article_reader_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/articles.dart';
import '../data/pointings.dart';
import '../data/teaching.dart';
import '../models/article.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/glass_card.dart';
import 'article_reader_screen.dart';
import 'share_preview_screen.dart';
import 'library/library_models.dart';
import 'library/library_widgets.dart';
import 'library/teacher_teachings_screen.dart';
import 'library/lineage_teachings_screen.dart';
import 'library/mood_teachings_screen.dart';
import 'library/topic_teachings_screen.dart';

// Re-export all library subfiles for backward compatibility
export 'library/library_models.dart';
export 'library/library_widgets.dart';
export 'library/category_articles_screen.dart';
export 'library/teacher_teachings_screen.dart';
export 'library/lineage_teachings_screen.dart';
export 'library/mood_teachings_screen.dart';
export 'library/topic_teachings_screen.dart';

/**
 * Main library screen with featured articles, browse-by navigation, and saved pointings.
 *
 * Browse modes include [LibraryBrowseMode.topics], [LibraryBrowseMode.teachers],
 * [LibraryBrowseMode.lineages], [LibraryBrowseMode.moods], and [LibraryBrowseMode.saved].
 */
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  /** Current browse mode controlling which category navigation is shown. */
  LibraryBrowseMode _browseMode = LibraryBrowseMode.topics;

  /** Current content type filter (all, articles only, or quotes only). */
  ContentFilter _contentFilter = ContentFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final featured = getFeaturedArticles(limit: 3);
    final favorites = ref.watch(favoritesProvider);
    final savedArticleIds = ref.watch(articleFavoritesProvider);

    final hasActiveFilter = _browseMode != LibraryBrowseMode.topics || _contentFilter != ContentFilter.all;

    return PopScope(
      canPop: !hasActiveFilter,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!mounted) return;
        setState(() {
          _browseMode = LibraryBrowseMode.topics;
          _contentFilter = ContentFilter.all;
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: AnimatedGradient()),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Header with filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Library', style: Theme.of(context).textTheme.displayLarge),
                          const SizedBox(height: 4),
                          Text(
                            _browseMode == LibraryBrowseMode.saved ? 'Your saved pointings' : 'Explore teachings and articles',
                            style: TextStyle(color: colors.textSecondary, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Show saved pointings if browsing saved
                  if (_browseMode == LibraryBrowseMode.saved) ...[
                    // Browse Mode dropdown (so user can switch back)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'BROWSE BY',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
                              ),
                              const SizedBox(width: 12),
                              _BrowseModeDropdown(currentMode: _browseMode, onChanged: (mode) => setState(() => _browseMode = mode)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (favorites.isEmpty && savedArticleIds.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bookmark_border, size: 64, color: colors.textMuted),
                                const SizedBox(height: 16),
                                Text('Nothing saved yet', style: TextStyle(color: colors.textMuted, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Long-press a pointing or bookmark an article', style: TextStyle(color: colors.textMuted, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Saved articles section
                    if (savedArticleIds.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Text(
                            'ARTICLES',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final articleId = savedArticleIds[index];
                            final article = articles.cast<Article?>().firstWhere((a) => a?.id == articleId, orElse: () => null);
                            if (article == null) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                onTap: () => _openArticle(context, article),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    if (article.subtitle != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        article.subtitle!,
                                        style: TextStyle(color: colors.textSecondary, fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text('${article.readingTimeMinutes} min read', style: TextStyle(color: colors.textMuted, fontSize: 12)),
                                        if (article.teacher != null) ...[
                                          Text('  ·  ', style: TextStyle(color: colors.textMuted, fontSize: 12)),
                                          Expanded(
                                            child: Text(
                                              article.teacher!,
                                              style: TextStyle(color: colors.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ] else
                                          const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            ref.read(articleFavoritesProvider.notifier).toggle(articleId);
                                          },
                                          child: Icon(Icons.bookmark, size: 22, color: colors.accent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: savedArticleIds.length),
                        ),
                      ),
                    ],

                    // Saved pointings section
                    if (favorites.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          child: Text(
                            'POINTINGS',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((context, index) {
                            final pointingId = favorites[index];
                            final pointing = pointings.firstWhere((p) => p.id == pointingId, orElse: () => pointings.first);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pointing.content,
                                      style: TextStyle(color: colors.textPrimary, fontSize: 15, height: 1.5),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if (pointing.teacher != null)
                                          Expanded(
                                            child: Text('— ${pointing.teacher}', style: TextStyle(color: colors.textMuted, fontSize: 13)),
                                          )
                                        else
                                          const Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              useRootNavigator: true,
                                              builder: (_) => FractionallySizedBox(
                                                heightFactor: 0.9,
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                                  child: SharePreviewScreen(pointing: pointing),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 16),
                                            child: Icon(Icons.share_outlined, size: 20, color: colors.textMuted),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            ref.read(favoritesProvider.notifier).toggle(pointingId);
                                          },
                                          child: Icon(Icons.favorite, size: 22, color: colors.accent),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: favorites.length),
                        ),
                      ),
                    ],
                  ] else ...[
                    // Featured Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                        child: Text(
                          'FEATURED',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
                        ),
                      ),
                    ),

                    // Featured articles horizontal scroll with peek indicator
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: (185 * MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.25)).clamp(185, 235).toDouble(),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth = constraints.maxWidth;
                            // Card takes ~70% of screen, leaving ~30% for peek
                            // Peek shows ~24px of next card edge
                            final cardWidth = (screenWidth * 0.70).clamp(180.0, 280.0);
                            final cardSpacing = 8.0;
                            // Calculate padding: 24px left, enough right for last card + peek area
                            final horizontalPadding = 24.0;
                            // Extra right padding ensures smooth scroll end (peek area width)
                            final rightPadding = screenWidth - cardWidth - horizontalPadding;

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(left: horizontalPadding, right: rightPadding.clamp(24.0, 80.0)),
                              itemCount: featured.length,
                              itemBuilder: (context, index) {
                                final article = featured[index];
                                final isLast = index == featured.length - 1;
                                return StaggeredFadeIn(
                                  index: index,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: isLast ? 0 : cardSpacing),
                                    child: SizedBox(
                                      width: cardWidth,
                                      child: _FeaturedArticleCard(article: article, onTap: () => _openArticle(context, article)),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Browse Mode Section with Dropdown
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        // FittedBox scales content down proportionally on small screens
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'BROWSE BY',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textMuted, letterSpacing: 1),
                              ),
                              const SizedBox(width: 12),
                              _BrowseModeDropdown(currentMode: _browseMode, onChanged: (mode) => setState(() => _browseMode = mode)),
                              const SizedBox(width: 8),
                              _ContentTypeDropdown(currentFilter: _contentFilter, onChanged: (filter) => setState(() => _contentFilter = filter)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Dynamic browse list based on mode
                    _buildBrowseList(colors, bottomPadding, _contentFilter),
                  ], // end else
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /** Navigates to the [ArticleReaderScreen] for the given article. */
  void _openArticle(BuildContext context, Article article) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ArticleReaderScreen(article: article)));
  }

  /** Build dynamic browse list based on current mode */
  Widget _buildBrowseList(PointerColors colors, double bottomPadding, ContentFilter contentFilter) {
    switch (_browseMode) {
      case LibraryBrowseMode.topics:
        return _buildTopicsList(colors, bottomPadding, contentFilter);
      case LibraryBrowseMode.teachers:
        return _buildTeachersList(colors, bottomPadding, contentFilter);
      case LibraryBrowseMode.lineages:
        return _buildLineagesList(colors, bottomPadding, contentFilter);
      case LibraryBrowseMode.moods:
        return _buildMoodsList(colors, bottomPadding, contentFilter);
      case LibraryBrowseMode.saved:
        // Saved pointings are handled separately in the main build
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  /**
   * Builds a sliver list of topics with merged counts based on the active [contentFilter].
   *
   * When filtering by quotes, uses [TeachingRepository.topicCounts]; by articles,
   * uses [getArticleTopicCounts]; for all, merges both. Sorted by count descending.
   */
  Widget _buildTopicsList(PointerColors colors, double bottomPadding, ContentFilter contentFilter) {
    // Always show TopicTags with merged counts based on filter
    final Map<String, int> topicCounts;

    if (contentFilter == ContentFilter.quotes) {
      topicCounts = TeachingRepository.topicCounts;
    } else if (contentFilter == ContentFilter.articles) {
      topicCounts = getArticleTopicCounts();
    } else {
      // All - merge both counts
      final quoteCounts = TeachingRepository.topicCounts;
      final articleCounts = getArticleTopicCounts();
      topicCounts = Map<String, int>.from(quoteCounts);
      for (final entry in articleCounts.entries) {
        topicCounts[entry.key] = (topicCounts[entry.key] ?? 0) + entry.value;
      }
    }

    final sortedTopics = topicCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = sortedTopics[index];
          final topic = entry.key;
          final count = entry.value;

          return StaggeredFadeIn(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BrowseCard(
                icon: TopicTags.icon(topic),
                name: TopicTags.displayName(topic),
                description: 'Explore ${TopicTags.displayName(topic).toLowerCase()} teachings',
                count: count,
                onTap: () => _openTopic(context, topic, contentFilter),
              ),
            ),
          );
        }, childCount: sortedTopics.length),
      ),
    );
  }

  /** Navigates to [TopicTeachingsScreen] for the given topic with the active filter. */
  void _openTopic(BuildContext context, String topic, ContentFilter filter) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicTeachingsScreen(topic: topic, filter: filter),
      ),
    );
  }

  /** Builds a sliver list of teachers with counts based on the active [contentFilter]. */
  Widget _buildTeachersList(PointerColors colors, double bottomPadding, ContentFilter contentFilter) {
    // Get teachers based on content filter
    final Map<String, int> teacherCounts;
    if (contentFilter == ContentFilter.articles) {
      // Count articles per teacher
      teacherCounts = <String, int>{};
      for (final article in articles) {
        if (article.teacher != null) {
          teacherCounts[article.teacher!] = (teacherCounts[article.teacher!] ?? 0) + 1;
        }
      }
    } else if (contentFilter == ContentFilter.quotes) {
      teacherCounts = TeachingRepository.teacherCounts;
    } else {
      // All - merge both
      teacherCounts = Map<String, int>.from(TeachingRepository.teacherCounts);
      for (final article in articles) {
        if (article.teacher != null) {
          teacherCounts[article.teacher!] = (teacherCounts[article.teacher!] ?? 0) + 1;
        }
      }
    }

    final sortedTeachers = teacherCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    if (sortedTeachers.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text('No teachers found for this filter', style: TextStyle(color: colors.textMuted)),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = sortedTeachers[index];
          final teacher = entry.key;
          final count = entry.value;

          // Get lineage for this teacher (from first teaching)
          final teachingsSample = TeachingRepository.byTeacher(teacher);
          final lineage = teachingsSample.isNotEmpty ? traditions[teachingsSample.first.lineage]?.name ?? '' : '';

          return StaggeredFadeIn(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BrowseCard(
                icon: '🙏',
                name: teacher,
                description: lineage,
                count: count,
                onTap: () => _openTeacher(context, teacher, contentFilter),
              ),
            ),
          );
        }, childCount: sortedTeachers.length),
      ),
    );
  }

  /** Builds a sliver list of tradition lineages with counts based on the active [contentFilter]. */
  Widget _buildLineagesList(PointerColors colors, double bottomPadding, ContentFilter contentFilter) {
    // Build list of lineages with their counts based on filter
    final lineageData = <({Tradition tradition, TraditionInfo info, int count})>[];

    for (final tradition in Tradition.values) {
      final info = traditions[tradition]!;
      final int count;

      if (contentFilter == ContentFilter.articles) {
        count = getArticlesByTradition(tradition).length;
      } else if (contentFilter == ContentFilter.quotes) {
        count = TeachingRepository.byLineage(tradition).length;
      } else {
        // All - combined count
        final teachingCount = TeachingRepository.byLineage(tradition).length;
        final articleCount = getArticlesByTradition(tradition).length;
        count = teachingCount + articleCount;
      }

      // Include lineage if it has content matching the filter
      if (count > 0) {
        lineageData.add((tradition: tradition, info: info, count: count));
      }
    }

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final data = lineageData[index];

          return StaggeredFadeIn(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BrowseCard(
                icon: data.info.icon,
                name: data.info.name,
                description: data.info.description,
                count: data.count,
                onTap: () => _openLineage(context, data.tradition, data.info, contentFilter),
              ),
            ),
          );
        }, childCount: lineageData.length),
      ),
    );
  }

  /** Builds a sliver list of mood tags with counts based on the active [contentFilter]. */
  Widget _buildMoodsList(PointerColors colors, double bottomPadding, ContentFilter contentFilter) {
    // Build mood counts based on filter
    final Map<String, int> moodCounts;

    if (contentFilter == ContentFilter.articles) {
      moodCounts = getArticleMoodCounts();
    } else if (contentFilter == ContentFilter.quotes) {
      moodCounts = TeachingRepository.moodCounts;
    } else {
      // All - merge both counts
      final quoteCounts = TeachingRepository.moodCounts;
      final articleCounts = getArticleMoodCounts();
      moodCounts = <String, int>{};

      // Add all quote moods
      for (final entry in quoteCounts.entries) {
        moodCounts[entry.key] = entry.value;
      }
      // Add article moods (merge with existing)
      for (final entry in articleCounts.entries) {
        moodCounts[entry.key] = (moodCounts[entry.key] ?? 0) + entry.value;
      }
    }

    final sortedMoods = moodCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = sortedMoods[index];
          final mood = entry.key;
          final count = entry.value;

          return StaggeredFadeIn(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BrowseCard(
                icon: MoodTags.icon(mood),
                name: MoodTags.displayName(mood),
                description: 'Best for ${mood.toLowerCase()} moments',
                count: count,
                onTap: () => _openMood(context, mood, contentFilter),
              ),
            ),
          );
        }, childCount: sortedMoods.length),
      ),
    );
  }

  void _openTeacher(BuildContext context, String teacher, ContentFilter filter) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeacherTeachingsScreen(teacher: teacher, filter: filter),
      ),
    );
  }

  void _openLineage(BuildContext context, Tradition tradition, TraditionInfo info, ContentFilter filter) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LineageTeachingsScreen(tradition: tradition, info: info, filter: filter),
      ),
    );
  }

  void _openMood(BuildContext context, String mood, ContentFilter filter) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MoodTeachingsScreen(mood: mood, filter: filter),
      ),
    );
  }
}

/** Dropdown for browse mode selection */
class _BrowseModeDropdown extends StatelessWidget {
  final LibraryBrowseMode currentMode;
  final ValueChanged<LibraryBrowseMode> onChanged;

  const _BrowseModeDropdown({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 12,
      onTap: () => _showModeSelector(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(currentMode.icon, size: 16, color: colors.textPrimary),
          const SizedBox(width: 6),
          // Flexible allows text to shrink when space is constrained
          Flexible(
            child: Text(
              currentMode.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: colors.textMuted, size: 20),
        ],
      ),
    );
  }

  void _showModeSelector(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BrowseModeSheet(
        currentMode: currentMode,
        onSelected: (mode) {
          onChanged(mode);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/** Dropdown for content type filter (All/Articles/Quotes) */
class _ContentTypeDropdown extends StatelessWidget {
  final ContentFilter currentFilter;
  final ValueChanged<ContentFilter> onChanged;

  const _ContentTypeDropdown({required this.currentFilter, required this.onChanged});

  String get _label {
    switch (currentFilter) {
      case ContentFilter.all:
        return 'All';
      case ContentFilter.articles:
        return 'Articles';
      case ContentFilter.quotes:
        return 'Quotes';
    }
  }

  IconData get _icon {
    switch (currentFilter) {
      case ContentFilter.all:
        return Icons.grid_view_rounded;
      case ContentFilter.articles:
        return Icons.article_outlined;
      case ContentFilter.quotes:
        return Icons.format_quote_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 12,
      onTap: () => _showFilterSelector(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 16, color: colors.textPrimary),
          const SizedBox(width: 6),
          // Flexible allows text to shrink when space is constrained
          Flexible(
            child: Text(
              _label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: colors.textMuted, size: 20),
        ],
      ),
    );
  }

  void _showFilterSelector(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContentTypeSheet(
        currentFilter: currentFilter,
        onSelected: (filter) {
          onChanged(filter);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/** Bottom sheet for selecting content type filter (All/Articles/Quotes). */
class _ContentTypeSheet extends StatelessWidget {
  final ContentFilter currentFilter;
  final ValueChanged<ContentFilter> onSelected;

  const _ContentTypeSheet({required this.currentFilter, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterSheet<ContentFilter>(
      title: 'Show',
      currentValue: currentFilter,
      onSelected: onSelected,
      options: const [
        FilterOption(value: ContentFilter.all, label: 'All', icon: Icons.grid_view_rounded),
        FilterOption(value: ContentFilter.articles, label: 'Articles', icon: Icons.article_outlined),
        FilterOption(value: ContentFilter.quotes, label: 'Quotes', icon: Icons.format_quote_rounded),
      ],
    );
  }
}

/** Bottom sheet for selecting browse mode (Topics/Teachers/Lineages/Moods/Saved). */
class _BrowseModeSheet extends StatelessWidget {
  final LibraryBrowseMode currentMode;
  final ValueChanged<LibraryBrowseMode> onSelected;

  const _BrowseModeSheet({required this.currentMode, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterSheet<LibraryBrowseMode>(
      title: 'Browse by',
      currentValue: currentMode,
      onSelected: onSelected,
      options: LibraryBrowseMode.values.map((mode) => FilterOption(value: mode, label: mode.label, icon: mode.icon)).toList(),
    );
  }
}

/** Generic browse card for teachers, lineages, moods */
class _BrowseCard extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final int count;
  final VoidCallback onTap;

  const _BrowseCard({required this.icon, required this.name, required this.description, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: '$name. $description. $count teachings.',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: colors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text(icon, style: TextStyle(fontSize: 20, color: colors.accent)),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Count and arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textMuted),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: colors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/** Horizontal-scrolling card for a featured [Article] with tradition icon, reading time, and teacher. */
class _FeaturedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _FeaturedArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final traditionInfo = traditions[article.tradition]!;
    final isCompact = MediaQuery.of(context).size.width < 360;
    final titleFontSize = isCompact ? 16.0 : 18.0;
    final subtitleFontSize = isCompact ? 12.0 : 13.0;
    final metaFontSize = isCompact ? 11.0 : 12.0;

    return Semantics(
      button: true,
      label:
          '${article.title}. ${article.subtitle ?? ""}. ${article.readingTimeMinutes} minute read${article.teacher != null ? " by ${article.teacher}" : ""}. Featured article.',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tradition + reading time row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: colors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(traditionInfo.icon, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${article.readingTimeMinutes} min read',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: metaFontSize, color: colors.textMuted),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 10 : 12),

            // Title
            Text(
              article.title,
              style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w600, color: colors.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Subtitle
            if (article.subtitle != null)
              Text(
                article.subtitle!,
                style: TextStyle(fontSize: subtitleFontSize, color: colors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const Spacer(),

            // Teacher attribution
            if (article.teacher != null)
              Text(
                article.teacher!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: metaFontSize, color: colors.textMuted, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}

// ArticleReaderScreen extracted to article_reader_screen.dart
