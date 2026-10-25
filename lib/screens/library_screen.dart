/**
 * Library screen for browsing articles and teachings from non-dual traditions.
 *
 * Provides multiple browse modes (topics, teachers, lineages, moods) with
 * ContentFilter support (all/articles/quotes). Features a horizontal-scrolling
 * featured articles section with peek indicator, browse mode and content type
 * dropdowns.
 *
 * Re-exports all library/ subfiles for backward compatibility.
 */
library;

import 'package:flutter/material.dart';

import '../layout/adaptive.dart';
import 'article_reader_screen.dart';

// flutter_markdown_plus moved to article_reader_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/articles.dart';
import '../data/pointings.dart';
import '../data/teaching.dart';
import '../models/article.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_transitions.dart';

import 'package:go_router/go_router.dart';

import '../widgets/empty_state.dart';
import '../widgets/pointer_scaffold.dart';
import '../widgets/share_preview_helper.dart';
import '../widgets/glass_card.dart';
import '../widgets/grouped_section.dart';
import 'library/library_models.dart';
import 'library/library_widgets.dart';
import 'library/teacher_teachings_screen.dart';
import 'library/lineage_teachings_screen.dart';
import 'library/mood_teachings_screen.dart';
import 'library/topic_teachings_screen.dart';
import '../utils/haptics.dart';
import '../utils/typography.dart';
import '../data/inquiries.dart';
import '../data/inquiry_sessions.dart';
import '../theme/app_icons.dart';

// Re-export all library subfiles for backward compatibility
export 'library/library_models.dart';
export 'library/library_widgets.dart';
export 'library/teaching_detail_screen.dart';
export 'library/teacher_teachings_screen.dart';
export 'library/lineage_teachings_screen.dart';
export 'library/mood_teachings_screen.dart';
export 'library/topic_teachings_screen.dart';

part 'saved_screen.dart';
part 'library/guided_inquiry_section.dart';

/**
 * Main library screen with featured articles, browse-by navigation, and saved pointings.
 *
 * Browse modes include [LibraryBrowseMode.topics], [LibraryBrowseMode.teachers],
 * [LibraryBrowseMode.lineages] and [LibraryBrowseMode.moods]. Saved items have their own tab ([SavedScreen]).
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

  /** Article shown in the detail pane on two-pane windows. */
  String? _selectedArticleId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final featured = getFeaturedArticles(limit: 3);

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
      child: PointerScaffold(
        body: _adaptiveBody(
          context,
          CustomScrollView(
            slivers: [
              // Header with filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(header: true, child: Text('Library', style: Theme.of(context).textTheme.displayLarge)),
                      const SizedBox(height: 4),
                      Text('Explore teachings and articles', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
                    ],
                  ),
                ),
              ),

              // Guided Inquiry leads Library: the old Inquiry tab's sessions (P2).
              ..._guidedInquirySlivers(context, colors),

              // Featured: whole cards in a grid that fits the width, never a strip
              // that runs past an edge. In two panes it moves to the detail pane,
              // which it fills until a reading is chosen.
              if (!WindowLayout.of(context).showsListDetail) ...[
                SliverToBoxAdapter(child: _FeaturedHeader(colors: colors)),
                SliverToBoxAdapter(
                  child: _FeaturedGrid(featured: featured, onOpen: (a) => _openArticle(context, a)),
                ),
              ],

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
                        Text('BROWSE BY', style: AppTextStyles.sectionHeader(context)),
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
              _buildBrowseList(colors, _contentFilter),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * List and detail on two-pane windows: the library list on the left and
   * the selected article (or a quiet placeholder) on the right, split at a
   * vertical hinge when there is one. Single pane returns [list] unchanged.
   */
  Widget _adaptiveBody(BuildContext context, Widget list) {
    final layout = WindowLayout.of(context);
    if (!layout.showsListDetail) return layout.sizeClass == WindowSizeClass.compact ? list : ContentWidth(child: list);
    final selected = _selectedArticleId;
    return TwoPane(
      key: const ValueKey('library-list-detail'),
      twoPane: true,
      primaryFlex: 2,
      secondaryFlex: 3,
      // A 2:3 split leaves the list under 300 dp on an 815 dp unfolded fold,
      // where topic names like "Awareness" broke mid-word.
      primaryMinWidth: kListPaneMinWidth,
      primary: list,
      secondary: selected == null
          ? _FeaturedOverview(
              key: const ValueKey('library-detail-featured'),
              featured: getFeaturedArticles(limit: featuredOverviewCount(layout)),
              onOpen: (article) => _openArticle(context, article),
            )
          : ArticleReaderScreen(
              key: ValueKey('library-detail-$selected'),
              articleId: selected,
              onClose: () => setState(() => _selectedArticleId = null),
            ),
    );
  }

  /** Navigates to the [ArticleReaderScreen] for the given article. */
  void _openArticle(BuildContext context, Article article) {
    Haptics.light();
    if (WindowLayout.of(context).showsListDetail) {
      setState(() => _selectedArticleId = article.id);
      return;
    }
    context.push('/article/${article.id}');
  }

  /** Build dynamic browse list based on current mode */
  Widget _buildBrowseList(PointerColors colors, ContentFilter contentFilter) {
    switch (_browseMode) {
      case LibraryBrowseMode.topics:
        return _buildTopicsList(colors, contentFilter);
      case LibraryBrowseMode.teachers:
        return _buildTeachersList(colors, contentFilter);
      case LibraryBrowseMode.lineages:
        return _buildLineagesList(colors, contentFilter);
      case LibraryBrowseMode.moods:
        return _buildMoodsList(colors, contentFilter);
    }
  }

  /**
   * Builds a sliver list of topics with merged counts based on the active [contentFilter].
   *
   * When filtering by quotes, uses [TeachingRepository.topicCounts]; by articles,
   * uses [getArticleTopicCounts]; for all, merges both. Sorted by count descending.
   */
  Widget _buildTopicsList(PointerColors colors, ContentFilter contentFilter) {
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
      padding: EdgeInsets.only(left: 24, right: 24, bottom: scrollEndInset(context)),
      sliver: SliverToBoxAdapter(
        child: GroupedSection(
          separatorIndent: 74,
          itemBuilder: (context, index) {
            final entry = sortedTopics[index];
            final topic = entry.key;
            final count = entry.value;

            return StaggeredFadeIn(
              index: index,
              child: Padding(
                padding: EdgeInsets.zero,
                child: _BrowseCard(
                  icon: TopicTags.icon(topic),
                  name: TopicTags.displayName(topic),
                  description: 'Explore ${TopicTags.displayName(topic).toLowerCase()} teachings',
                  count: count,
                  onTap: () => _openTopic(context, topic, contentFilter),
                ),
              ),
            );
          },
          itemCount: sortedTopics.length,
        ),
      ),
    );
  }

  /** Navigates to [TopicTeachingsScreen] for the given topic with the active filter. */
  void _openTopic(BuildContext context, String topic, ContentFilter filter) {
    Haptics.light();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => TopicTeachingsScreen(topic: topic, filter: filter),
      ),
    );
  }

  /** Builds a sliver list of teachers with counts based on the active [contentFilter]. */
  Widget _buildTeachersList(PointerColors colors, ContentFilter contentFilter) {
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
      return const SliverToBoxAdapter(
        child: EmptyStateWidget(title: 'No teachers here yet.', subtitle: 'Try another filter above.'),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: scrollEndInset(context)),
      sliver: SliverToBoxAdapter(
        child: GroupedSection(
          separatorIndent: 74,
          itemBuilder: (context, index) {
            final entry = sortedTeachers[index];
            final teacher = entry.key;
            final count = entry.value;

            // Get lineage for this teacher (from first teaching)
            final teachingsSample = TeachingRepository.byTeacher(teacher);
            final lineage = teachingsSample.isNotEmpty ? traditions[teachingsSample.first.lineage]?.name ?? '' : '';

            return StaggeredFadeIn(
              index: index,
              child: Padding(
                padding: EdgeInsets.zero,
                child: _BrowseCard(
                  icon: AppIcons.teacher,
                  name: teacher,
                  description: lineage,
                  count: count,
                  onTap: () => _openTeacher(context, teacher, contentFilter),
                ),
              ),
            );
          },
          itemCount: sortedTeachers.length,
        ),
      ),
    );
  }

  /** Builds a sliver list of tradition lineages with counts based on the active [contentFilter]. */
  Widget _buildLineagesList(PointerColors colors, ContentFilter contentFilter) {
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
      padding: EdgeInsets.only(left: 24, right: 24, bottom: scrollEndInset(context)),
      sliver: SliverToBoxAdapter(
        child: GroupedSection(
          separatorIndent: 74,
          itemBuilder: (context, index) {
            final data = lineageData[index];

            return StaggeredFadeIn(
              index: index,
              child: Padding(
                padding: EdgeInsets.zero,
                child: _BrowseCard(
                  icon: data.info.lineIcon,
                  name: data.info.name,
                  description: data.info.description,
                  count: data.count,
                  onTap: () => _openLineage(context, data.tradition, data.info, contentFilter),
                ),
              ),
            );
          },
          itemCount: lineageData.length,
        ),
      ),
    );
  }

  /** Builds a sliver list of mood tags with counts based on the active [contentFilter]. */
  Widget _buildMoodsList(PointerColors colors, ContentFilter contentFilter) {
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
      padding: EdgeInsets.only(left: 24, right: 24, bottom: scrollEndInset(context)),
      sliver: SliverToBoxAdapter(
        child: GroupedSection(
          separatorIndent: 74,
          itemBuilder: (context, index) {
            final entry = sortedMoods[index];
            final mood = entry.key;
            final count = entry.value;

            return StaggeredFadeIn(
              index: index,
              child: Padding(
                padding: EdgeInsets.zero,
                child: _BrowseCard(
                  icon: MoodTags.icon(mood),
                  name: MoodTags.displayName(mood),
                  description: 'Best for ${mood.toLowerCase()} moments',
                  count: count,
                  onTap: () => _openMood(context, mood, contentFilter),
                ),
              ),
            );
          },
          itemCount: sortedMoods.length,
        ),
      ),
    );
  }

  void _openTeacher(BuildContext context, String teacher, ContentFilter filter) {
    Haptics.light();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => TeacherTeachingsScreen(teacher: teacher, filter: filter),
      ),
    );
  }

  void _openLineage(BuildContext context, Tradition tradition, TraditionInfo info, ContentFilter filter) {
    Haptics.light();
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => LineageTeachingsScreen(tradition: tradition, info: info, filter: filter),
      ),
    );
  }

  void _openMood(BuildContext context, String mood, ContentFilter filter) {
    Haptics.light();
    Navigator.of(context, rootNavigator: true).push(
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
    Haptics.selection();
    showAdaptiveSheet(
      context: context,
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
    Haptics.selection();
    showAdaptiveSheet(
      context: context,
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
  final IconData icon;
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
      child: GroupedRow(
        onTap: onTap,
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: colors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Icon(icon, size: 22, color: colors.accent)),
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
                    // Wrap rather than clip: the count column takes width from a narrow list column.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Count and chevron on one baseline (design 24)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textMuted),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: colors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/** Narrowest a Featured card gets before the grid drops a column. */
const double kFeaturedCardMinWidth = 168;

const double _featuredGap = 12;

/** Base height of a Featured card per text size; the grid uses 60% of it as a floor and otherwise fits content. */
double _featuredCardHeight(BuildContext context) => (185 * MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.25)).clamp(185, 235).toDouble();

/** Columns that fit [width] with every card at least [kFeaturedCardMinWidth]. */
int featuredColumns(double width, int count, {bool balanced = false}) {
  final fit = ((width + _featuredGap) / (kFeaturedCardMinWidth + _featuredGap)).floor().clamp(1, count < 1 ? 1 : count);
  // Tablets: every row full (balancedColumns); elsewhere the old fit, so the Fold and phones keep their grid.
  return balanced ? balancedColumns(fit, count) : fit;
}

class _FeaturedHeader extends StatelessWidget {
  final PointerColors colors;
  const _FeaturedHeader({required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
    child: Semantics(header: true, child: Text('FEATURED', style: AppTextStyles.sectionHeader(context))),
  );
}

/**
 * Featured articles as whole cards: as many equal columns as fit the width,
 * wrapping to a new row, so no card is ever half-shown at rest.
 */
class _FeaturedGrid extends StatelessWidget {
  final List<Article> featured;
  final void Function(Article) onOpen;

  const _FeaturedGrid({required this.featured, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    // A floor so a row of short cards still reads as cards, not chips.
    final minHeight = _featuredCardHeight(context) * 0.6;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = featuredColumns(constraints.maxWidth, featured.length, balanced: WindowLayout.of(context).isTabletCanvas);
          final width = (constraints.maxWidth - _featuredGap * (cols - 1)) / cols;
          // Rows sized to their content: each row is as tall as its tallest card
          // (IntrinsicHeight), so cards line up without the empty band a fixed
          // height left between the subtitle and the author.
          final rows = <List<(int, Article)>>[];
          for (final entry in featured.indexed) {
            if (entry.$1 % cols == 0) rows.add([]);
            rows.last.add(entry);
          }
          return Column(
            key: const ValueKey('featured-grid'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (r, row) in rows.indexed) ...[
                if (r > 0) const SizedBox(height: _featuredGap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (j, (i, article)) in row.indexed) ...[
                        if (j > 0) const SizedBox(width: _featuredGap),
                        StaggeredFadeIn(
                          index: i,
                          child: ConstrainedBox(
                            key: ValueKey('featured-card-$i'),
                            constraints: BoxConstraints.tightFor(width: width).copyWith(minHeight: minHeight),
                            child: _FeaturedArticleCard(article: article, onTap: () => onOpen(article)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/** The detail pane before a reading is chosen: the Featured readings, whole, with a quiet hint. */
class _FeaturedOverview extends StatelessWidget {
  final List<Article> featured;
  final void Function(Article) onOpen;

  const _FeaturedOverview({super.key, required this.featured, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: !WindowLayout.of(context).isTabletCanvas
          ? ListView(
              padding: const EdgeInsets.only(top: 20, bottom: 48),
              children: [
                _FeaturedHeader(colors: colors),
                _FeaturedGrid(featured: featured, onOpen: onOpen),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text(
                    'Or choose a reading from the list.',
                    style: TextStyle(fontFamily: AppFonts.serif, fontStyle: FontStyle.italic, fontSize: AppType.callout, color: colors.textMuted),
                  ),
                ),
              ],
            )
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(child: _FeaturedHeader(colors: colors)),
                SliverToBoxAdapter(
                  child: _FeaturedGrid(featured: featured, onOpen: onOpen),
                ),
                // The rest of the pane: a real empty state for the reader, centred in the space left below Featured.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    key: const ValueKey('library-detail-empty'),
                    icon: AppIcons.library,
                    title: 'Choose a reading',
                    subtitle: 'Pick a teaching or article from the list, and it opens here.',
                  ),
                ),
              ],
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
                  child: Semantics(excludeSemantics: true, label: traditionInfo.name, child: Icon(traditionInfo.lineIcon, size: 13.2)),
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

            const SizedBox(height: 8),
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
