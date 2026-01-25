// Article Reader Screen - Full article display with markdown rendering
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pointings.dart';
import '../models/article.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_gradient.dart';

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
                              Flexible(
                                child: Text(
                                  widget.article.teacher!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textMuted,
                                  ),
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
