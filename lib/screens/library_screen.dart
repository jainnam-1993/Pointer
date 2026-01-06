// Library Screen - Browse articles and teachings from non-dual traditions
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/articles.dart';
import '../data/pointings.dart';
import '../data/teaching.dart';
import '../models/article.dart';
import '../providers/providers.dart';
// TTS imports disabled - feature temporarily removed
// import '../services/aws_credential_service.dart';
// import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
// import '../widgets/article_tts_player.dart';  // TTS disabled
import '../widgets/glass_card.dart';

/// Category metadata for display
class CategoryInfo {
  final String name;
  final String icon;
  final String description;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.description,
  });
}

const categoryInfoMap = <ArticleCategory, CategoryInfo>{
  ArticleCategory.natureOfAwareness: CategoryInfo(
    name: 'Nature of Awareness',
    icon: '◯',
    description: 'Understanding consciousness itself',
  ),
  ArticleCategory.selfInquiry: CategoryInfo(
    name: 'Self-Inquiry',
    icon: '?',
    description: 'The investigation into "Who am I?"',
  ),
  ArticleCategory.everydayAwakening: CategoryInfo(
    name: 'Everyday Awakening',
    icon: '☀',
    description: 'Living wisdom in daily life',
  ),
  ArticleCategory.traditionalTeachings: CategoryInfo(
    name: 'Traditional Teachings',
    icon: '◇',
    description: 'Classic texts and ancient wisdom',
  ),
  ArticleCategory.modernPointers: CategoryInfo(
    name: 'Modern Pointers',
    icon: '✦',
    description: 'Contemporary teachers, fresh words',
  ),
};

/// Filter options for library content
enum LibraryFilter { all, articles, quotes, saved }

/// Browse mode for category navigation
enum LibraryBrowseMode {
  topics,
  teachers,
  lineages,
  moods,
}

extension LibraryBrowseModeExt on LibraryBrowseMode {
  String get label {
    switch (this) {
      case LibraryBrowseMode.topics:
        return 'Topics';
      case LibraryBrowseMode.teachers:
        return 'Teachers';
      case LibraryBrowseMode.lineages:
        return 'Lineages';
      case LibraryBrowseMode.moods:
        return 'Moods';
    }
  }

  IconData get icon {
    switch (this) {
      case LibraryBrowseMode.topics:
        return Icons.topic_outlined;
      case LibraryBrowseMode.teachers:
        return Icons.person_outline;
      case LibraryBrowseMode.lineages:
        return Icons.account_tree_outlined;
      case LibraryBrowseMode.moods:
        return Icons.mood_outlined;
    }
  }
}

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryFilter _currentFilter = LibraryFilter.all;
  LibraryBrowseMode _browseMode = LibraryBrowseMode.topics;
  ContentFilter _contentFilter = ContentFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final featured = getFeaturedArticles(limit: 3);
    final subscription = ref.watch(subscriptionProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Library',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            // Filter dropdown
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.glassBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: colors.glassBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<LibraryFilter>(
                                  value: _currentFilter,
                                  isDense: true,
                                  dropdownColor: colors.cardBackground,
                                  borderRadius: BorderRadius.circular(12),
                                  icon: Icon(Icons.arrow_drop_down, color: colors.textSecondary, size: 20),
                                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                                  items: [
                                    DropdownMenuItem(
                                      value: LibraryFilter.all,
                                      child: Text('All', style: TextStyle(color: colors.textPrimary)),
                                    ),
                                    DropdownMenuItem(
                                      value: LibraryFilter.articles,
                                      child: Text('Articles', style: TextStyle(color: colors.textPrimary)),
                                    ),
                                    DropdownMenuItem(
                                      value: LibraryFilter.quotes,
                                      child: Text('Quotes', style: TextStyle(color: colors.textPrimary)),
                                    ),
                                    DropdownMenuItem(
                                      value: LibraryFilter.saved,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Saved', style: TextStyle(color: colors.textPrimary)),
                                          if (favorites.isNotEmpty) ...[
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: colors.accent.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${favorites.length}',
                                                style: TextStyle(color: colors.accent, fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _currentFilter = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentFilter == LibraryFilter.saved
                              ? 'Your saved pointings'
                              : 'Explore teachings and articles',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Show saved pointings if filtered
                if (_currentFilter == LibraryFilter.saved) ...[
                  if (favorites.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bookmark_border, size: 64, color: colors.textMuted),
                              const SizedBox(height: 16),
                              Text(
                                'No saved pointings yet',
                                style: TextStyle(color: colors.textMuted, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Long-press a pointing to save it',
                                style: TextStyle(color: colors.textMuted, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120 + bottomPadding),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final pointingId = favorites[index];
                            final pointing = pointings.firstWhere(
                              (p) => p.id == pointingId,
                              orElse: () => pointings.first,
                            );
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
                                    if (pointing.teacher != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        '— ${pointing.teacher}',
                                        style: TextStyle(color: colors.textMuted, fontSize: 13),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: favorites.length,
                        ),
                      ),
                    ),
                ] else ...[

                // Full Library is PREMIUM - show upgrade prompt for free users
                if (!subscription.isPremium) ...[
                  SliverFillRemaining(
                    child: _LibraryPremiumUpgrade(
                      onUpgrade: () => Navigator.of(context).pushNamed('/paywall'),
                    ),
                  ),
                ] else ...[
                // PREMIUM CONTENT BELOW

                // Featured Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      'FEATURED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                // Featured articles horizontal scroll with peek indicator
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 185,
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
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: rightPadding.clamp(24.0, 80.0),
                          ),
                          itemCount: featured.length,
                          itemBuilder: (context, index) {
                            final article = featured[index];
                            final isLast = index == featured.length - 1;
                            return StaggeredFadeIn(
                              index: index,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: isLast ? 0 : cardSpacing,
                                ),
                                child: SizedBox(
                                  width: cardWidth,
                                  child: _FeaturedArticleCard(
                                    article: article,
                                    onTap: () => _openArticle(context, article),
                                  ),
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
                    child: Row(
                      children: [
                        Text(
                          'BROWSE BY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _BrowseModeDropdown(
                          currentMode: _browseMode,
                          onChanged: (mode) => setState(() => _browseMode = mode),
                        ),
                        const Spacer(),
                        _ContentTypeDropdown(
                          currentFilter: _contentFilter,
                          onChanged: (filter) => setState(() => _contentFilter = filter),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dynamic browse list based on mode
                _buildBrowseList(colors, bottomPadding, subscription.isPremium, _contentFilter),
                ], // end premium content
                ], // end else
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openArticle(BuildContext context, Article article) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleReaderScreen(article: article),
      ),
    );
  }

  void _openCategory(BuildContext context, ArticleCategory category,
      CategoryInfo info, bool isPremium) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryArticlesScreen(
          category: category,
          info: info,
          isPremium: isPremium,
        ),
      ),
    );
  }

  /// Build dynamic browse list based on current mode
  Widget _buildBrowseList(PointerColors colors, double bottomPadding, bool isPremium, ContentFilter contentFilter) {
    switch (_browseMode) {
      case LibraryBrowseMode.topics:
        return _buildTopicsList(colors, bottomPadding, isPremium, contentFilter);
      case LibraryBrowseMode.teachers:
        return _buildTeachersList(colors, bottomPadding, contentFilter);
      case LibraryBrowseMode.lineages:
        return _buildLineagesList(colors, bottomPadding, contentFilter);
      case LibraryBrowseMode.moods:
        return _buildMoodsList(colors, bottomPadding, contentFilter);
    }
  }

  Widget _buildTopicsList(PointerColors colors, double bottomPadding, bool isPremium, ContentFilter contentFilter) {
    // Topics only show articles, hide if quotes filter selected
    if (contentFilter == ContentFilter.quotes) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Switch to "All" or "Articles" to browse by topic',
              style: TextStyle(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = ArticleCategory.values[index];
            final info = categoryInfoMap[category]!;
            final articleCount = getArticlesByCategory(category).length;

            return StaggeredFadeIn(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategoryCard(
                  category: category,
                  info: info,
                  articleCount: articleCount,
                  onTap: () => _openCategory(context, category, info, isPremium),
                ),
              ),
            );
          },
          childCount: ArticleCategory.values.length,
        ),
      ),
    );
  }

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

    final sortedTeachers = teacherCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedTeachers.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No teachers found for this filter',
              style: TextStyle(color: colors.textMuted),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = sortedTeachers[index];
            final teacher = entry.key;
            final count = entry.value;

            // Get lineage for this teacher (from first teaching)
            final teachingsSample = TeachingRepository.byTeacher(teacher);
            final lineage = teachingsSample.isNotEmpty
                ? traditions[teachingsSample.first.lineage]?.name ?? ''
                : '';

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
          },
          childCount: sortedTeachers.length,
        ),
      ),
    );
  }

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
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          },
          childCount: lineageData.length,
        ),
      ),
    );
  }

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

    final sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          },
          childCount: sortedMoods.length,
        ),
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

/// Dropdown for browse mode selection
class _BrowseModeDropdown extends StatelessWidget {
  final LibraryBrowseMode currentMode;
  final ValueChanged<LibraryBrowseMode> onChanged;

  const _BrowseModeDropdown({
    required this.currentMode,
    required this.onChanged,
  });

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
          Text(
            currentMode.label,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
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

/// Dropdown for content type filter (All/Articles/Quotes)
class _ContentTypeDropdown extends StatelessWidget {
  final ContentFilter currentFilter;
  final ValueChanged<ContentFilter> onChanged;

  const _ContentTypeDropdown({
    required this.currentFilter,
    required this.onChanged,
  });

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
          Text(
            _label,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
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

/// Bottom sheet for content type selection
class _ContentTypeSheet extends StatelessWidget {
  final ContentFilter currentFilter;
  final ValueChanged<ContentFilter> onSelected;

  const _ContentTypeSheet({
    required this.currentFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Show',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildOption(context, ContentFilter.all, 'All', Icons.grid_view_rounded),
              _buildOption(context, ContentFilter.articles, 'Articles', Icons.article_outlined),
              _buildOption(context, ContentFilter.quotes, 'Quotes', Icons.format_quote_rounded),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, ContentFilter filter, String label, IconData icon) {
    final colors = context.colors;
    final isSelected = filter == currentFilter;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colors.accent : colors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colors.accent : colors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: colors.accent)
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        onSelected(filter);
      },
    );
  }
}

class _BrowseModeSheet extends StatelessWidget {
  final LibraryBrowseMode currentMode;
  final ValueChanged<LibraryBrowseMode> onSelected;

  const _BrowseModeSheet({
    required this.currentMode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            // Use solid background for better contrast - consistent with settings sheets
            color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Browse by',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...LibraryBrowseMode.values.map((mode) {
                final isSelected = mode == currentMode;
                return ListTile(
                  leading: Icon(
                    mode.icon,
                    color: isSelected ? colors.accent : colors.textMuted,
                  ),
                  title: Text(
                    mode.label,
                    style: TextStyle(
                      color: isSelected ? colors.accent : colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: colors.accent)
                      : null,
                  onTap: () => onSelected(mode),
                );
              }),
              // Account for bottom nav bar (80px) + system safe area
              SizedBox(height: 80 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic browse card for teachers, lineages, moods
class _BrowseCard extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final int count;
  final VoidCallback onTap;

  const _BrowseCard({
    required this.icon,
    required this.name,
    required this.description,
    required this.count,
    required this.onTap,
  });

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
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: colors.accent,
                  ),
                ),
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: colors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _FeaturedArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final traditionInfo = traditions[article.tradition]!;

    return Semantics(
      button: true,
      label: '${article.title}. ${article.subtitle ?? ""}. ${article.readingTimeMinutes} minute read${article.teacher != null ? " by ${article.teacher}" : ""}. Featured article.',
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
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    traditionInfo.icon,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${article.readingTimeMinutes} min read',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              article.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Subtitle
            if (article.subtitle != null)
              Text(
                article.subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const Spacer(),

            // Teacher attribution
            if (article.teacher != null)
              Text(
                article.teacher!,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ArticleCategory category;
  final CategoryInfo info;
  final int articleCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.info,
    required this.articleCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: '${info.name}. ${info.description}. $articleCount articles.',
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  info.icon,
                  style: TextStyle(
                    fontSize: 20,
                    color: colors.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Count and arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$articleCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: colors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen showing articles in a specific category
class CategoryArticlesScreen extends StatelessWidget {
  final ArticleCategory category;
  final CategoryInfo info;
  final bool isPremium;

  const CategoryArticlesScreen({
    super.key,
    required this.category,
    required this.info,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categoryArticles = getArticlesByCategory(category);
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
                                info.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                '${categoryArticles.length} articles',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Articles list
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 32 + bottomPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final article = categoryArticles[index];
                        final isLocked = article.isPremium && !isPremium;

                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ArticleListItem(
                              article: article,
                              isLocked: isLocked,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                if (isLocked) {
                                  // Show paywall
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Premium article - unlock with subscription'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: colors.glassBackground,
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ArticleReaderScreen(article: article),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                      childCount: categoryArticles.length,
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

class _ArticleListItem extends StatelessWidget {
  final Article article;
  final bool isLocked;
  final VoidCallback onTap;

  const _ArticleListItem({
    required this.article,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label:
          '${article.title}. ${article.subtitle ?? ""}. ${article.readingTimeMinutes} minute read${isLocked ? ". Premium content, locked" : ""}',
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
                    Row(
                      children: [
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (article.isPremium) ...[
                          const SizedBox(width: 8),
                          Icon(
                            isLocked ? Icons.lock_outline : Icons.auto_awesome,
                            size: 14,
                            color: colors.accent,
                          ),
                        ],
                      ],
                    ),
                    if (article.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        article.subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${article.readingTimeMinutes} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                        if (article.teacher != null) ...[
                          Text(
                            ' · ',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                          ),
                          Text(
                            article.teacher!,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full article reader screen with TTS support
class ArticleReaderScreen extends ConsumerStatefulWidget {
  final Article article;

  const ArticleReaderScreen({
    super.key,
    required this.article,
  });

  @override
  ConsumerState<ArticleReaderScreen> createState() => _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends ConsumerState<ArticleReaderScreen> {
  // TTS feature disabled - keeping state vars for future re-enablement
  // ignore: unused_field
  final bool _showTTSPlayer = false;
  // ignore: unused_field
  final bool _ttsConfigured = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final traditionInfo = traditions[widget.article.tradition]!;
    // TTS disabled - isPremium check no longer needed here

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
                          icon: Icon(Icons.close, color: colors.textPrimary),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        // TTS button disabled - feature temporarily removed
                        // TODO: Re-enable when TTS feature is ready
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.glassBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.glassBorder),
                          ),
                          child: Text(
                            traditionInfo.name,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // TTS Player disabled - feature temporarily removed
                // TODO: Re-enable when TTS feature is ready

                // Article header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showTTSPlayer) const SizedBox(height: 16),
                        Text(
                          widget.article.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        if (widget.article.subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.article.subtitle!,
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: colors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.article.readingTimeMinutes} min read',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textMuted,
                              ),
                            ),
                            if (widget.article.teacher != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: colors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.article.teacher!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(color: colors.glassBorder),
                      ],
                    ),
                  ),
                ),

                // Article content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: 32 + bottomPadding,
                    ),
                    child: _MarkdownContent(
                      content: widget.article.content,
                      colors: colors,
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

/// Markdown content renderer using flutter_markdown
class _MarkdownContent extends StatelessWidget {
  final String content;
  final PointerColors colors;

  const _MarkdownContent({
    required this.content,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        h2: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        h3: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        p: TextStyle(
          fontSize: 16,
          color: colors.textPrimary,
          height: 1.6,
        ),
        blockquote: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: colors.textPrimary,
          height: 1.5,
        ),
        blockquoteDecoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: colors.accent.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
        ),
        blockquotePadding: const EdgeInsets.all(16),
        listBullet: TextStyle(color: colors.accent),
        strong: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

// ============================================================
// Teaching Detail Screens (Phase 6)
// ============================================================

/// Screen showing teachings by a specific teacher
class TeacherTeachingsScreen extends ConsumerStatefulWidget {
  final String teacher;
  final ContentFilter filter;

  const TeacherTeachingsScreen({super.key, required this.teacher, this.filter = ContentFilter.all});

  @override
  ConsumerState<TeacherTeachingsScreen> createState() => _TeacherTeachingsScreenState();
}

class _TeacherTeachingsScreenState extends ConsumerState<TeacherTeachingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final allTeachings = TeachingRepository.byTeacher(widget.teacher);
    final allArticles = getArticlesByTeacher(widget.teacher);

    // Apply filter
    final teachings = widget.filter == ContentFilter.articles ? <Teaching>[] : allTeachings;
    final articles = widget.filter == ContentFilter.quotes ? <Article>[] : allArticles;

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final subscriptionState = ref.watch(subscriptionProvider);
    final isPremium = subscriptionState.tier == SubscriptionTier.premium;

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
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                '${articles.length} articles, ${teachings.length} quotes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = articles[index];
                          final isLocked = article.isPremium && !isPremium;

                          return StaggeredFadeIn(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ArticleListItem(
                                article: article,
                                isLocked: isLocked,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (isLocked) {
                                    // Show paywall
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Premium article - unlock with subscription'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: colors.glassBackground,
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ArticleReaderScreen(
                                          article: article,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        childCount: articles.length,
                      ),
                    ),
                  ),
                ],

                // Quotes section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      articles.isNotEmpty ? 24 : 16,
                      24,
                      12,
                    ),
                    child: Text(
                      'QUOTES (${teachings.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 32 + bottomPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final teaching = teachings[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TeachingCard(teaching: teaching),
                          ),
                        );
                      },
                      childCount: teachings.length,
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

/// Screen showing teachings by lineage/tradition
class LineageTeachingsScreen extends ConsumerWidget {
  final Tradition tradition;
  final TraditionInfo info;
  final ContentFilter filter;

  const LineageTeachingsScreen({
    super.key,
    required this.tradition,
    required this.info,
    this.filter = ContentFilter.all,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final allTeachings = TeachingRepository.byLineage(tradition);
    final allArticles = getArticlesByTradition(tradition);

    // Apply filter
    final teachings = filter == ContentFilter.articles ? <Teaching>[] : allTeachings;
    final articles = filter == ContentFilter.quotes ? <Article>[] : allArticles;

    final isPremium = ref.watch(subscriptionProvider).isPremium;
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
                                  Text(info.icon, style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    info.name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${articles.length} articles · ${teachings.length} quotes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
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
                    child: Text(
                      info.description,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // Articles section (if any)
                if (articles.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _SectionHeader(title: 'Articles', count: articles.length),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = articles[index];
                          final isLocked = article.isPremium && !isPremium;
                          return StaggeredFadeIn(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ArticleListItem(
                                article: article,
                                isLocked: isLocked,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (isLocked) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Premium article - unlock with subscription'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: colors.glassBackground,
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArticleReaderScreen(article: article),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        childCount: articles.length,
                      ),
                    ),
                  ),
                ],

                // Quotes section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      articles.isNotEmpty ? 24 : 0,
                      24,
                      12,
                    ),
                    child: _SectionHeader(
                      title: 'Quotes',
                      count: teachings.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 32 + bottomPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final teaching = teachings[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TeachingCard(teaching: teaching),
                          ),
                        );
                      },
                      childCount: teachings.length,
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

/// Screen showing teachings by mood
class MoodTeachingsScreen extends ConsumerWidget {
  final String mood;
  final ContentFilter filter;

  const MoodTeachingsScreen({super.key, required this.mood, this.filter = ContentFilter.all});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final allArticles = getArticlesByMood(mood);
    final allTeachings = TeachingRepository.byMood(mood);

    // Apply filter
    final articles = filter == ContentFilter.quotes ? <Article>[] : allArticles;
    final teachings = filter == ContentFilter.articles ? <Teaching>[] : allTeachings;

    final isPremium = ref.watch(subscriptionProvider).isPremium;
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
                                  Text(
                                    MoodTags.icon(mood),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    MoodTags.displayName(mood),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${articles.length} articles, ${teachings.length} quotes',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.textSecondary,
                                ),
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
                      child: _SectionHeader(
                        title: 'Articles',
                        count: articles.length,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final article = articles[index];
                          final isLocked = article.isPremium && !isPremium;

                          return StaggeredFadeIn(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ArticleListItem(
                                article: article,
                                isLocked: isLocked,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (isLocked) {
                                    // Show paywall
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Premium article - unlock with subscription'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: colors.glassBackground,
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArticleReaderScreen(article: article),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        childCount: articles.length,
                      ),
                    ),
                  ),
                ],

                // Quotes section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _SectionHeader(
                      title: 'Quotes',
                      count: teachings.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 32 + bottomPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final teaching = teachings[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TeachingCard(teaching: teaching),
                          ),
                        );
                      },
                      childCount: teachings.length,
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

/// Filter mode for content display
enum ContentFilter { all, articles, quotes }

/// Section header for separated content sections
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card for displaying a teaching
class _TeachingCard extends StatelessWidget {
  final Teaching teaching;

  const _TeachingCard({required this.teaching});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final traditionInfo = traditions[teaching.lineage]!;

    return Semantics(
      label: '${teaching.content}. By ${teaching.teacher}. ${traditionInfo.name} tradition.',
      child: GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          Text(
            teaching.content,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // Footer: Teacher and lineage
          Row(
            children: [
              Text(
                '— ${teaching.teacher}',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      traditionInfo.icon,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      traditionInfo.name,
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 11,
                      ),
                    ),
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
                  child: Text(
                    TopicTags.displayName(tag),
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

/// Premium upgrade prompt for free users trying to access the library
class _LibraryPremiumUpgrade extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _LibraryPremiumUpgrade({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final goldColor = colors.gold;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Premium icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: goldColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: goldColor,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Unlock the Full Library',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Browse teachings by topic, teacher, lineage, and mood. '
              'Access featured articles and extended commentary.',
              style: TextStyle(
                fontSize: 15,
                color: colors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // What's included
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.glassBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.glassBorder),
              ),
              child: Column(
                children: [
                  _FeatureRow(icon: Icons.library_books, text: 'Full article library'),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.notifications_active, text: 'Daily notifications'),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.widgets, text: 'Home screen widget'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upgrade button
            GlassButton(
              label: 'Upgrade to Premium',
              onPressed: onUpgrade,
              icon: Icon(Icons.auto_awesome, color: goldColor, size: 18),
            ),

            const SizedBox(height: 16),

            // Free features reminder
            Text(
              'Free forever: Unlimited pointings & saved favorites',
              style: TextStyle(
                fontSize: 12,
                color: colors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.gold),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
