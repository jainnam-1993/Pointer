/** Screen showing articles filtered by a specific ArticleCategory. */
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/articles.dart';
import '../../models/article.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_gradient.dart';
import '../../widgets/animated_transitions.dart';
import '../article_reader_screen.dart';
import 'library_models.dart';
import 'library_widgets.dart';

/**
 * Screen showing articles filtered by a specific [ArticleCategory].
 *
 * Displays the category name and article count in the header, with a scrollable
 * list of [ArticleListItem] widgets. Premium articles are locked behind
 * subscription unless [kFreeAccessEnabled] is true.
 */
class CategoryArticlesScreen extends StatelessWidget {
  /// The article category to filter by.
  final ArticleCategory category;

  /// Display metadata (name, icon, description) for this category.
  final CategoryInfo info;

  /// Whether the current user has premium access.
  final bool isPremium;

  const CategoryArticlesScreen({super.key, required this.category, required this.info, required this.isPremium});

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
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: colors.textPrimary),
                              ),
                              Text('${categoryArticles.length} articles', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Articles list
                SliverPadding(
                  padding: EdgeInsets.only(left: 24, right: 24, bottom: 32 + bottomPadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final article = categoryArticles[index];
                      final isLocked = !kFreeAccessEnabled && article.isPremium && !isPremium;

                      return StaggeredFadeIn(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ArticleListItem(
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleReaderScreen(article: article)));
                              }
                            },
                          ),
                        ),
                      );
                    }, childCount: categoryArticles.length),
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
