/** Screen showing articles and quotes filtered by topic tag. */
library;

import 'package:flutter/material.dart';
import '../../data/articles.dart';
import '../../data/teaching.dart';
import 'library_models.dart';
import 'teaching_detail_screen.dart';

/**
 * Screen showing articles and quotes filtered by a [TopicTags] value.
 *
 * Thin wrapper around [TeachingDetailScreen] that resolves topic-specific data.
 * Enables the empty state for topics that may have no matching content.
 */
class TopicTeachingsScreen extends StatelessWidget {
  /** The topic tag string (from [TopicTags] constants) to filter by. */
  final String topic;

  /** Content type filter propagated from the parent library screen. */
  final ContentFilter filter;

  const TopicTeachingsScreen({super.key, required this.topic, this.filter = ContentFilter.all});

  @override
  Widget build(BuildContext context) {
    final articles = getArticlesByTopic(topic);
    final teachings = TeachingRepository.byTopic(topic);

    return TeachingDetailScreen(
      title: '${TopicTags.icon(topic)} ${TopicTags.displayName(topic)}',
      subtitle: '${articles.length} articles, ${teachings.length} quotes',
      articles: articles,
      teachings: teachings,
      filter: filter,
      showEmptyState: true,
    );
  }
}
