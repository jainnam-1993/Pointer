/** Screen showing articles and quotes filtered by tradition/lineage. */
library;

import 'package:flutter/material.dart';
import '../../data/articles.dart';
import '../../data/pointings.dart';
import '../../data/teaching.dart';
import '../../theme/app_theme.dart';
import 'library_models.dart';
import 'teaching_detail_screen.dart';

/**
 * Screen showing articles and quotes filtered by spiritual tradition/lineage.
 *
 * Thin wrapper around [TeachingDetailScreen] that resolves lineage-specific
 * data and includes a tradition description widget.
 */
class LineageTeachingsScreen extends StatelessWidget {
  /** The tradition to filter content by. */
  final Tradition tradition;

  /** Display metadata (name, icon, description) for this tradition. */
  final TraditionInfo info;

  /** Content type filter propagated from the parent library screen. */
  final ContentFilter filter;

  const LineageTeachingsScreen({super.key, required this.tradition, required this.info, this.filter = ContentFilter.all});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final articles = getArticlesByTradition(tradition);
    final teachings = TeachingRepository.byLineage(tradition);

    return TeachingDetailScreen(
      title: '${info.icon} ${info.name}',
      subtitle: '${articles.length} articles, ${teachings.length} quotes',
      descriptionWidget: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(info.description, style: TextStyle(color: colors.textSecondary, fontSize: 15)),
        ),
      ),
      articles: articles,
      teachings: teachings,
      filter: filter,
    );
  }
}
