// Library Screen - Browse articles and teachings from non-dual traditions
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/articles.dart';
import '../data/pointings.dart';
import '../models/article.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
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

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  LibraryFilter _currentFilter = LibraryFilter.all;

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
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: featured.length,
                      itemBuilder: (context, index) {
                        final article = featured[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _FeaturedArticleCard(
                            article: article,
                            onTap: () => _openArticle(context, article),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Categories Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text(
                      'BROWSE BY TOPIC',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                // Category cards
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 120 + bottomPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = ArticleCategory.values[index];
                        final info = categoryInfoMap[category]!;
                        final articleCount =
                            getArticlesByCategory(category).length;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CategoryCard(
                            category: category,
                            info: info,
                            articleCount: articleCount,
                            onTap: () => _openCategory(
                                context, category, info, subscription.isPremium),
                          ),
                        );
                      },
                      childCount: ArticleCategory.values.length,
                    ),
                  ),
                ),
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

    return SizedBox(
      width: 260,
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

                        return Padding(
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

/// Full article reader screen
class ArticleReaderScreen extends StatelessWidget {
  final Article article;

  const ArticleReaderScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final traditionInfo = traditions[article.tradition]!;

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
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
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

                // Article header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        if (article.subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            article.subtitle!,
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
                              '${article.readingTimeMinutes} min read',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.textMuted,
                              ),
                            ),
                            if (article.teacher != null) ...[
                              const SizedBox(width: 16),
                              Icon(
                                Icons.person_outline,
                                size: 14,
                                color: colors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                article.teacher!,
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
                      content: article.content,
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
