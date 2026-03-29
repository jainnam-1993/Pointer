/**
 * Full article reading screen with markdown rendering, share functionality,
 * and tradition-tagged header.
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/articles.dart';
import '../data/pointings.dart';
import '../models/article.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import '../widgets/share_preview_helper.dart';

/**
 * Full article reader screen with markdown rendering and share support.
 *
 * Displays the [Article] title, subtitle, reading time, teacher attribution,
 * and markdown-rendered body. Includes a share button that creates a [Pointing]
 * from the article excerpt for [SharePreviewScreen].
 */
class ArticleReaderScreen extends ConsumerStatefulWidget {
  /** The article ID used to look up the article from the data layer. */
  final String articleId;

  const ArticleReaderScreen({super.key, required this.articleId});

  @override
  ConsumerState<ArticleReaderScreen> createState() => _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends ConsumerState<ArticleReaderScreen> {
  /** Resolved article from [widget.articleId], or null if not found. */
  late final Article? _article = getArticleById(widget.articleId);


  /** Lazy-loaded article content future. */
  late final Future<String> _contentFuture;

  @override
  void initState() {
    super.initState();
    // If the article already has content (e.g. from tests), use it directly;
    // otherwise lazy-load from the Markdown asset file.
    final existingContent = _article?.content;
    _contentFuture = existingContent != null
        ? Future.value(existingContent)
        : loadArticleContent(_article!.id);
  }

  /** Creates a [Pointing] from the article excerpt and opens the [SharePreviewScreen]. */
  void _shareArticle(BuildContext context) {
    HapticFeedback.mediumImpact();
    final article = _article!;
    final pointing = Pointing(
      id: 'article_${article.id}',
      content: article.excerpt ?? article.title,
      tradition: article.tradition,
      contexts: const [PointingContext.general],
      teacher: article.teacher,
      source: article.title,
    );
    showSharePreview(context, pointing);
  }

  @override
  Widget build(BuildContext context) {
    final article = _article;
    if (article == null) {
      // Article not found — go back gracefully
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: colors.textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, _) {
                            final isSaved = ref.watch(articleFavoritesProvider).contains(article.id);
                            return IconButton(
                              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? colors.accent : colors.textPrimary),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ref.read(articleFavoritesProvider.notifier).toggle(article.id);
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.share_outlined, color: colors.textPrimary),
                          onPressed: () => _shareArticle(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // Article header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: AppSpacing.screenH,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 48),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.glassBackground,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                              border: Border.all(color: colors.glassBorder),
                            ),
                            child: Text(
                              traditionInfo.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: colors.textMuted, fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          article.title,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary, height: 1.2),
                        ),
                        if (article.subtitle != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(article.subtitle!, style: TextStyle(fontSize: 16, color: colors.textSecondary)),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: colors.textMuted),
                            const SizedBox(width: AppSpacing.xs),
                            Text('${article.readingTimeMinutes} min read', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                            if (article.teacher != null) ...[
                              const SizedBox(width: AppSpacing.lg),
                              Icon(Icons.person_outline, size: 14, color: colors.textMuted),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  article.teacher!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: colors.textMuted),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Divider(color: colors.glassBorder),
                      ],
                    ),
                  ),
                ),

                // Article content (lazy-loaded)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.lg, bottom: AppSpacing.xxl + bottomPadding),
                    child: FutureBuilder<String>(
                      future: _contentFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                            child: Center(child: CircularProgressIndicator(color: colors.accent)),
                          );
                        }
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                            child: Center(
                              child: Text('Unable to load article content.', style: TextStyle(color: colors.textMuted)),
                            ),
                          );
                        }
                        return _MarkdownContent(content: snapshot.data!, colors: colors);
                      },
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

/**
 * Markdown content renderer using `flutter_markdown_plus`.
 *
 * Applies [PointerColors]-themed typography with styled blockquotes,
 * accent-colored bullet points, and selectable text.
 */
class _MarkdownContent extends StatelessWidget {
  /** Raw markdown content to render. */
  final String content;

  /** Theme colors for styling markdown elements. */
  final PointerColors colors;

  const _MarkdownContent({required this.content, required this.colors});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary),
        h2: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colors.textPrimary),
        h3: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: colors.textPrimary),
        p: TextStyle(fontSize: 16, color: colors.textPrimary, height: 1.6),
        blockquote: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: colors.textPrimary, height: 1.5),
        blockquoteDecoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border(left: BorderSide(color: colors.accent.withValues(alpha: 0.5), width: 3)),
        ),
        blockquotePadding: const EdgeInsets.all(AppSpacing.lg),
        listBullet: TextStyle(color: colors.accent),
        strong: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
        em: TextStyle(fontStyle: FontStyle.italic, color: colors.textPrimary),
      ),
    );
  }
}
