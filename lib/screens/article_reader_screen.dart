/**
 * Full article reading screen with markdown rendering, share functionality,
 * and tradition-tagged header.
 */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pointings.dart';
import '../models/article.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';
import 'share_preview_screen.dart';

/**
 * Full article reader screen with markdown rendering and share support.
 *
 * Displays the [Article] title, subtitle, reading time, teacher attribution,
 * and markdown-rendered body. Includes a share button that creates a [Pointing]
 * from the article excerpt for [SharePreviewScreen].
 */
class ArticleReaderScreen extends ConsumerStatefulWidget {
  /** The article to display in the reader. */
  final Article article;

  const ArticleReaderScreen({super.key, required this.article});

  @override
  ConsumerState<ArticleReaderScreen> createState() => _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends ConsumerState<ArticleReaderScreen> {
  /** Creates a [Pointing] from the article excerpt and opens the [SharePreviewScreen]. */
  void _shareArticle(BuildContext context) {
    HapticFeedback.mediumImpact();
    final article = widget.article;
    final pointing = Pointing(
      id: 'article_${article.id}',
      content: article.excerpt ?? article.title,
      tradition: article.tradition,
      contexts: const [PointingContext.general],
      teacher: article.teacher,
      source: article.title,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.9,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SharePreviewScreen(pointing: pointing),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final traditionInfo = traditions[widget.article.tradition]!;

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
                        Consumer(
                          builder: (context, ref, _) {
                            final isSaved = ref.watch(articleFavoritesProvider).contains(widget.article.id);
                            return IconButton(
                              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? colors.accent : colors.textPrimary),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                ref.read(articleFavoritesProvider.notifier).toggle(widget.article.id);
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
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 48),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colors.glassBackground,
                              borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(height: 12),
                        Text(
                          widget.article.title,
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: colors.textPrimary, height: 1.2),
                        ),
                        if (widget.article.subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(widget.article.subtitle!, style: TextStyle(fontSize: 16, color: colors.textSecondary)),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 14, color: colors.textMuted),
                            const SizedBox(width: 4),
                            Text('${widget.article.readingTimeMinutes} min read', style: TextStyle(fontSize: 13, color: colors.textMuted)),
                            if (widget.article.teacher != null) ...[
                              const SizedBox(width: 16),
                              Icon(Icons.person_outline, size: 14, color: colors.textMuted),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.article.teacher!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 13, color: colors.textMuted),
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
                    padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 32 + bottomPadding),
                    child: _MarkdownContent(content: widget.article.content, colors: colors),
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
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: colors.accent.withValues(alpha: 0.5), width: 3)),
        ),
        blockquotePadding: const EdgeInsets.all(16),
        listBullet: TextStyle(color: colors.accent),
        strong: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
        em: TextStyle(fontStyle: FontStyle.italic, color: colors.textPrimary),
      ),
    );
  }
}
