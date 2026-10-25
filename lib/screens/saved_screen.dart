part of 'library_screen.dart';

/**
 * The Saved tab: saved articles and saved pointings, read from the same
 * favorites the Library's old Saved filter used, so an upgrade keeps them.
 */
class SavedScreen extends ConsumerStatefulWidget {
  const SavedScreen({super.key});

  @override
  ConsumerState<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends ConsumerState<SavedScreen> {
  void _openArticle(BuildContext context, Article article) {
    Haptics.light();
    context.push('/article/${article.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final favorites = ref.watch(favoritesProvider);
    final savedArticleIds = ref.watch(articleFavoritesProvider);

    final list = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Semantics(header: true, child: Text('Saved', style: Theme.of(context).textTheme.displayLarge)),
          ),
        ),
        if (favorites.isEmpty && savedArticleIds.isEmpty)
          SliverFillRemaining(
            child: EmptyStateWidget(
              icon: AppIcons.heart,
              title: 'Nothing saved yet.',
              subtitle: 'Tap the heart on a pointing or an article to keep it here.',
              actionLabel: 'Go to Today',
              onAction: () => context.go('/'),
            ),
          ),

        // Saved articles section
        if (savedArticleIds.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text('ARTICLES', style: AppTextStyles.sectionHeader(context)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverTileGrid(
              itemBuilder: (context, index) {
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
                                Haptics.light();
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
              },
              itemCount: savedArticleIds.length,
            ),
          ),
        ],

        // Saved pointings section
        if (favorites.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text('POINTINGS', style: AppTextStyles.sectionHeader(context)),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 120 + bottomPadding),
            sliver: SliverTileGrid(
              itemBuilder: (context, index) {
                final pointingId = favorites[index];
                final pointing = pointings.firstWhere((p) => p.id == pointingId, orElse: () => pointings.first);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.fromLTRB(20, 20, 8, 4),
                    // Sized to its content: the quote spans the card, and the actions share the
                    // attribution's row, so a short quote leaves no empty band.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          // The Today pointing style (Newsreader), one step down for a list card.
                          child: Text(
                            smartPunctuation(pointing.content),
                            style: AppTextStyles.pointingText(context).copyWith(fontSize: AppType.title),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: pointing.teacher == null
                                  ? const SizedBox.shrink()
                                  : Text('— ${pointing.teacher}', style: AppTextStyles.teacherText(context).copyWith(color: colors.textSecondary)),
                            ),
                            GestureDetector(
                              onTap: () {
                                Haptics.light();
                                ref.read(favoritesProvider.notifier).toggle(pointingId);
                              },
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(child: Icon(Icons.favorite, size: 22, color: colors.accent)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Haptics.light();
                                showSharePreview(context, pointing);
                              },
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(child: Icon(AppIcons.share, size: 22, color: colors.textSecondary)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: favorites.length,
            ),
          ),
        ],
      ],
    );
    final layout = WindowLayout.of(context);
    return PointerScaffold(body: layout.sizeClass == WindowSizeClass.compact ? list : ContentWidth(maxWidth: wideContentMaxWidth(layout), child: list));
  }
}
