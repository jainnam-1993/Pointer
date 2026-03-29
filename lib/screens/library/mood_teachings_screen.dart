/** Screen showing articles and quotes filtered by mood tag. */
library;

import 'package:flutter/material.dart';
import '../../data/articles.dart';
import '../../data/teaching.dart';
import 'library_models.dart';
import 'teaching_detail_screen.dart';

/**
 * Screen showing articles and quotes filtered by a [MoodTags] value.
 *
 * Thin wrapper around [TeachingDetailScreen] that resolves mood-specific data.
 */
class MoodTeachingsScreen extends StatelessWidget {
  /** The mood tag string (from [MoodTags] constants) to filter by. */
  final String mood;

  /** Content type filter propagated from the parent library screen. */
  final ContentFilter filter;

  const MoodTeachingsScreen({super.key, required this.mood, this.filter = ContentFilter.all});

  @override
  Widget build(BuildContext context) {
    final articles = getArticlesByMood(mood);
    final teachings = TeachingRepository.byMood(mood);

    return TeachingDetailScreen(
      title: '${MoodTags.icon(mood)} ${MoodTags.displayName(mood)}',
      subtitle: '${articles.length} articles, ${teachings.length} quotes',
      articles: articles,
      teachings: teachings,
      filter: filter,
    );
  }
}
