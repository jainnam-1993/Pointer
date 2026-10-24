/**
 * Full article reading screen with markdown rendering, share functionality,
 * and tradition-tagged header.
 */
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/articles.dart';
import '../data/pointings.dart';
import '../models/article.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_ambient.dart';
import '../widgets/share_preview_helper.dart';
import '../utils/haptics.dart';
import '../utils/typography.dart';

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
    _contentFuture = existingContent != null ? Future.value(existingContent) : loadArticleContent(_article!.id);
  }

  /** Creates a [Pointing] from the article excerpt and opens the [SharePreviewScreen]. */
  void _shareArticle(BuildContext context) {
    Haptics.light();
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
          const Positioned.fill(child: RouteAmbient()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Width-driven reading measure: about 60-66 characters of 18 pt serif, centred on wide screens.
                final side = math.max(AppSpacing.xl, (constraints.maxWidth - kReadingMeasure) / 2);
                final gutter = EdgeInsets.symmetric(horizontal: side);
                return CustomScrollView(
                  slivers: [
                    // App bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: side - AppSpacing.md, vertical: AppSpacing.lg),
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
                                    Haptics.success();
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
                        padding: gutter,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: kReadingMeasure),
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
                              smartPunctuation(article.title),
                              style: TextStyle(
                                fontFamily: AppFonts.serif,
                                fontSize: AppType.display,
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            if (article.subtitle != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(smartPunctuation(article.subtitle!), style: TextStyle(fontSize: 16, color: colors.textSecondary)),
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
                        padding: EdgeInsets.only(left: side, right: side, top: AppSpacing.lg, bottom: AppSpacing.xxl + bottomPadding),
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
                            return _MarkdownContent(content: smartPunctuation(stripLeadingTitle(snapshot.data!, article.title)), colors: colors);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/** Maximum reading measure in logical pixels: about 60-66 characters of 18 pt Newsreader. */
const double kReadingMeasure = 560;

/**
 * Removes a leading Markdown H1 that repeats [title], so the reader shows the title once.
 * Matching ignores case, surrounding whitespace and trailing punctuation.
 */
String stripLeadingTitle(String content, String title) {
  final match = RegExp(r'^\s*#\s+(.+?)\s*(\r?\n|$)').firstMatch(content);
  if (match == null) return content;
  String norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  if (norm(match.group(1)!) != norm(title)) return content;
  return content.substring(match.end).trimLeft();
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
        // Long-form reading: serif body at 18/28, headings in the same serif family.
        h1: TextStyle(fontFamily: AppFonts.serif, fontSize: AppType.title, fontWeight: FontWeight.w500, color: colors.textPrimary, height: 1.3),
        h2: TextStyle(fontFamily: AppFonts.serif, fontSize: 20, fontWeight: FontWeight.w500, color: colors.textPrimary, height: 1.3),
        h3: TextStyle(fontFamily: AppFonts.serif, fontSize: AppType.headline, fontWeight: FontWeight.w600, color: colors.textPrimary, height: 1.35),
        p: TextStyle(fontFamily: AppFonts.serif, fontSize: 18, color: colors.textPrimary, height: 28 / 18),
        pPadding: const EdgeInsets.only(bottom: AppSpacing.xs),
        // Hanging italic quote: a hairline rule, no tinted box.
        blockquote: TextStyle(fontFamily: AppFonts.serif, fontSize: 18, fontStyle: FontStyle.italic, color: colors.textSecondary, height: 28 / 18),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.textMuted.withValues(alpha: 0.4), width: 1)),
        ),
        blockquotePadding: const EdgeInsets.only(left: AppSpacing.lg, top: AppSpacing.xs, bottom: AppSpacing.xs),
        listBullet: TextStyle(color: colors.accent),
        strong: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
        em: TextStyle(fontStyle: FontStyle.italic, color: colors.textPrimary),
      ),
    );
  }
}
