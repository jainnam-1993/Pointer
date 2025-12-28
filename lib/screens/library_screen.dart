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
import '../services/aws_credential_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/animated_transitions.dart';
import '../widgets/article_tts_player.dart';
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
enum LibraryFilter { all, saved }

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

                // Featured articles horizontal scroll
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 185,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: featured.length,
                      itemBuilder: (context, index) {
                        final article = featured[index];
                        return StaggeredFadeIn(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _FeaturedArticleCard(
                              article: article,
                              onTap: () => _openArticle(context, article),
                            ),
                          ),
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
                      ],
                    ),
                  ),
                ),

                // Dynamic browse list based on mode
                _buildBrowseList(colors, bottomPadding, subscription.isPremium),
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
  Widget _buildBrowseList(PointerColors colors, double bottomPadding, bool isPremium) {
    switch (_browseMode) {
      case LibraryBrowseMode.topics:
        return _buildTopicsList(colors, bottomPadding, isPremium);
      case LibraryBrowseMode.teachers:
        return _buildTeachersList(colors, bottomPadding);
      case LibraryBrowseMode.lineages:
        return _buildLineagesList(colors, bottomPadding);
      case LibraryBrowseMode.moods:
        return _buildMoodsList(colors, bottomPadding);
    }
  }

  Widget _buildTopicsList(PointerColors colors, double bottomPadding, bool isPremium) {
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

  Widget _buildTeachersList(PointerColors colors, double bottomPadding) {
    final teacherCounts = TeachingRepository.teacherCounts;
    final sortedTeachers = teacherCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                  onTap: () => _openTeacher(context, teacher),
                ),
              ),
            );
          },
          childCount: sortedTeachers.length,
        ),
      ),
    );
  }

  Widget _buildLineagesList(PointerColors colors, double bottomPadding) {
    return SliverPadding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tradition = Tradition.values[index];
            final info = traditions[tradition]!;
            final teachingCount = TeachingRepository.byLineage(tradition).length;
            final articleCount = getArticlesByTradition(tradition).length;
            final totalCount = teachingCount + articleCount;

            return StaggeredFadeIn(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BrowseCard(
                  icon: info.icon,
                  name: info.name,
                  description: info.description,
                  count: totalCount,
                  onTap: () => _openLineage(context, tradition, info),
                ),
              ),
            );
          },
          childCount: Tradition.values.length,
        ),
      ),
    );
  }

  Widget _buildMoodsList(PointerColors colors, double bottomPadding) {
    final moodCounts = TeachingRepository.moodCounts;
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
                  onTap: () => _openMood(context, mood),
                ),
              ),
            );
          },
          childCount: sortedMoods.length,
        ),
      ),
    );
  }

  void _openTeacher(BuildContext context, String teacher) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeacherTeachingsScreen(teacher: teacher),
      ),
    );
  }

  void _openLineage(BuildContext context, Tradition tradition, TraditionInfo info) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LineageTeachingsScreen(tradition: tradition, info: info),
      ),
    );
  }

  void _openMood(BuildContext context, String mood) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MoodTeachingsScreen(mood: mood),
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.glassBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Browse by',
                style: Theme.of(context).textTheme.titleMedium,
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
              SizedBox(height: MediaQuery.of(context).padding.bottom),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.75).clamp(0.0, 260.0);

    return SizedBox(
      width: cardWidth,
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
  bool _showTTSPlayer = false;
  bool _ttsConfigured = false;

  @override
  void initState() {
    super.initState();
    _checkTTSConfig();
  }

  Future<void> _checkTTSConfig() async {
    final configured = await AWSCredentialService.instance.isConfigured();
    if (mounted) {
      setState(() => _ttsConfigured = configured);
    }
  }

  Future<void> _startTTS() async {
    final isPremium = ref.read(subscriptionProvider).isPremium;

    if (!isPremium) {
      // Show premium required message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Premium required for article audio'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Upgrade',
            onPressed: () {
              // Navigate to paywall would go here
            },
          ),
        ),
      );
      return;
    }

    if (!_ttsConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('TTS not configured. Enable in Settings → Developer.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _showTTSPlayer = true);

    try {
      await TTSService.instance.synthesizeAndPlay(
        widget.article.id,
        widget.article.content,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TTS error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final traditionInfo = traditions[widget.article.tradition]!;
    final isPremium = ref.watch(subscriptionProvider).isPremium;

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
                            // Stop TTS when leaving
                            if (_showTTSPlayer) {
                              TTSService.instance.stop();
                            }
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        // TTS button (only show if premium or configured)
                        if (isPremium || _ttsConfigured)
                          IconButton(
                            icon: Icon(
                              _showTTSPlayer
                                  ? Icons.headphones
                                  : Icons.headphones_outlined,
                              color: _showTTSPlayer
                                  ? colors.accent
                                  : colors.textPrimary,
                            ),
                            onPressed: _showTTSPlayer
                                ? () => setState(() => _showTTSPlayer = false)
                                : _startTTS,
                            tooltip: 'Listen to article',
                          ),
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

                // TTS Player (when active)
                if (_showTTSPlayer)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ArticleTTSPlayer(
                        articleId: widget.article.id,
                        onClose: () => setState(() => _showTTSPlayer = false),
                      ),
                    ),
                  ),

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
class TeacherTeachingsScreen extends StatelessWidget {
  final String teacher;

  const TeacherTeachingsScreen({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final teachings = TeachingRepository.byTeacher(teacher);
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
                                teacher,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                              Text(
                                '${teachings.length} teachings',
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

                // Teachings list
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
class LineageTeachingsScreen extends StatelessWidget {
  final Tradition tradition;
  final TraditionInfo info;

  const LineageTeachingsScreen({
    super.key,
    required this.tradition,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final teachings = TeachingRepository.byLineage(tradition);
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
                                '${teachings.length} teachings',
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

                // Teachings list
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
class MoodTeachingsScreen extends StatelessWidget {
  final String mood;

  const MoodTeachingsScreen({super.key, required this.mood});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final teachings = TeachingRepository.byMood(mood);
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
                                '${teachings.length} teachings',
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

                // Teachings list
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

/// Card for displaying a teaching
class _TeachingCard extends StatelessWidget {
  final Teaching teaching;

  const _TeachingCard({required this.teaching});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final traditionInfo = traditions[teaching.lineage]!;

    return GlassCard(
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
    );
  }
}
