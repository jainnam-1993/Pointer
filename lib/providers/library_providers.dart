/**
 * Library providers - Articles, teachers, search, and filtering.
 *
 * Provides the data layer for the Library screen with ~15 providers covering:
 * - [Article] access: all, by tradition/category/teacher/ID, featured
 * - [Teacher] access: all, by name/tradition, with articles/pointings
 * - Full-text search across articles and teachers via [librarySearchQueryProvider]
 * - Tradition and category filter state for the filtered article list
 * - Statistics: counts, reading time, per-tradition breakdowns
 * - Cross-references between articles and teacher profiles
 *
 * All providers are read-only derivations from the static [articles] and
 * [teachers] data sets. Search and filter state is ephemeral (not persisted).
 */
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/articles.dart';
import '../data/teachers.dart';
import '../data/pointings.dart';
import '../models/article.dart';
import '../models/teacher.dart';

// ============================================================
// Article Providers
// ============================================================

/** Provides all articles */
final articlesProvider = Provider<List<Article>>((ref) => articles);

/** Provides articles filtered by tradition */
final articlesByTraditionProvider = Provider.family<List<Article>, Tradition>((ref, tradition) {
  return getArticlesByTradition(tradition);
});

/** Provides articles filtered by category */
final articlesByCategoryProvider = Provider.family<List<Article>, ArticleCategory>((ref, category) {
  return getArticlesByCategory(category);
});

/** Provides articles filtered by teacher */
final articlesByTeacherProvider = Provider.family<List<Article>, String>((ref, teacherName) {
  return getArticlesByTeacher(teacherName);
});

/** Provides a single article by ID */
final articleByIdProvider = Provider.family<Article?, String>((ref, id) {
  return getArticleById(id);
});

/** Provides featured articles (top picks) */
final featuredArticlesProvider = Provider<List<Article>>((ref) {
  return getFeaturedArticles(limit: 5);
});

/** Provides article count by tradition */
final articleCountByTraditionProvider = Provider.family<int, Tradition>((ref, tradition) {
  return getArticlesByTradition(tradition).length;
});

/** Provides article count by category */
final articleCountByCategoryProvider = Provider.family<int, ArticleCategory>((ref, category) {
  return getArticlesByCategory(category).length;
});

// ============================================================
// Teacher Providers
// ============================================================

/** Provides all teachers */
final teacherProfilesProvider = Provider<List<Teacher>>((ref) => allTeachers);

/** Provides teacher by name (case-insensitive) */
final teacherByNameProvider = Provider.family<Teacher?, String>((ref, name) {
  return getTeacherProfile(name);
});

/** Provides teachers filtered by tradition */
final teachersByTraditionProvider = Provider.family<List<Teacher>, Tradition>((ref, tradition) {
  return getTeachersByTradition(tradition);
});

/** Provides teachers who have related articles */
final teachersWithArticlesProvider = Provider<List<Teacher>>((ref) {
  return getTeachersWithArticles();
});

/** Provides teachers who have related pointings */
final teachersWithPointingsProvider = Provider<List<Teacher>>((ref) {
  return getTeachersWithPointings();
});

/** Provides all teacher names */
final teacherNamesProvider = Provider<List<String>>((ref) {
  return getAllTeacherNames();
});

// ============================================================
// Search Providers
// ============================================================

/** Current search query state */
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

/**
 * Provides [Article] search results matching [librarySearchQueryProvider].
 *
 * Searches across title, subtitle, excerpt, content, and teacher name.
 * Returns an empty list when the query is empty.
 */
final articleSearchResultsProvider = Provider<List<Article>>((ref) {
  final query = ref.watch(librarySearchQueryProvider).trim();
  if (query.isEmpty) return const [];
  return searchArticles(query);
});

/**
 * Provides [Teacher] search results matching [librarySearchQueryProvider].
 *
 * Searches across name, bio, and key teachings list.
 * Returns an empty list when the query is empty.
 */
final teacherSearchResultsProvider = Provider<List<Teacher>>((ref) {
  return searchTeacherProfiles(ref.watch(librarySearchQueryProvider));
});

// ============================================================
// Filter State Providers
// ============================================================

/** Selected tradition filter for articles */
final selectedTraditionFilterProvider = StateProvider<Tradition?>((ref) => null);

/** Selected category filter for articles */
final selectedCategoryFilterProvider = StateProvider<ArticleCategory?>((ref) => null);

/**
 * Articles filtered by the active [selectedTraditionFilterProvider] and [selectedCategoryFilterProvider].
 *
 * Returns all articles when no filters are active. Filters are AND-composed
 * (both tradition and category must match when both are set).
 */
final filteredArticlesProvider = Provider<List<Article>>((ref) {
  final tradition = ref.watch(selectedTraditionFilterProvider);
  final category = ref.watch(selectedCategoryFilterProvider);

  var result = articles.toList();

  if (tradition != null) {
    result = result.where((a) => a.tradition == tradition).toList();
  }

  if (category != null) {
    result = result.where((a) => a.hasCategory(category)).toList();
  }

  return result;
});

// ============================================================
// Statistics Providers
// ============================================================

/** Total article count */
final totalArticleCountProvider = Provider<int>((ref) => articles.length);

/** Total teacher count */
final totalTeacherCountProvider = Provider<int>((ref) => allTeachers.length);

/** Total reading time across all articles */
final totalReadingTimeProvider = Provider<int>((ref) {
  return articles.fold(0, (sum, a) => sum + a.readingTimeMinutes);
});

/** Articles per tradition statistics */
final articlesPerTraditionProvider = Provider<Map<Tradition, int>>((ref) {
  final map = <Tradition, int>{};
  for (final tradition in Tradition.values) {
    map[tradition] = articles.where((a) => a.tradition == tradition).length;
  }
  return map;
});

/** Teachers per tradition statistics */
final teachersPerTraditionProvider = Provider<Map<Tradition, int>>((ref) {
  final map = <Tradition, int>{};
  for (final tradition in Tradition.values) {
    map[tradition] = getTeachersByTradition(tradition).length;
  }
  return map;
});

// ============================================================
// Cross-Reference Providers
// ============================================================

/** Returns [Article]s linked to a [Teacher] via [Teacher.articleIds]. */
final articlesForTeacherProvider = Provider.family<List<Article>, Teacher>((ref, teacher) {
  return articles.where((a) => teacher.articleIds.contains(a.id)).toList();
});

/**
 * Returns the [Teacher] for an [Article] by matching [Article.teacher] name.
 *
 * Returns `null` if the article has no teacher attribution or the teacher is not found.
 */
final teacherForArticleProvider = Provider.family<Teacher?, Article>((ref, article) {
  if (article.teacher == null) return null;
  return getTeacherProfile(article.teacher!);
});
