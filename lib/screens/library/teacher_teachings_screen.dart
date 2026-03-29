/** Screen showing articles and quotes by a specific teacher. */
library;

import 'package:flutter/material.dart';
import '../../data/articles.dart';
import '../../data/teaching.dart';
import 'library_models.dart';
import 'teaching_detail_screen.dart';

/**
 * Screen showing articles and quotes by a specific teacher.
 *
 * Thin wrapper around [TeachingDetailScreen] that resolves teacher-specific
 * data and passes it to the unified detail screen.
 */
class TeacherTeachingsScreen extends StatelessWidget {
  /** The teacher name to filter content by. */
  final String teacher;

  /** Content type filter propagated from the parent library screen. */
  final ContentFilter filter;

  const TeacherTeachingsScreen({super.key, required this.teacher, this.filter = ContentFilter.all});

  @override
  Widget build(BuildContext context) {
    final articles = getArticlesByTeacher(teacher);
    final teachings = TeachingRepository.byTeacher(teacher);

    return TeachingDetailScreen(
      title: teacher,
      subtitle: '${articles.length} articles, ${teachings.length} quotes',
      articles: articles,
      teachings: teachings,
      filter: filter,
    );
  }
}
