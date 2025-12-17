// Library Providers
// State management for the Library feature - articles and teacher profiles
//
// Provides filtering, searching, and access to library content.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/articles.dart';
import '../data/teacher_profiles.dart';
import '../data/pointings.dart';
import '../models/article.dart';
import '../models/teacher_profile.dart';

// ============================================================
// Article Providers
// ============================================================

/// Provides all articles
final articlesProvider = Provider<List<Article>>((ref) => articles);

/// Provides articles filtered by tradition
final articlesByTraditionProvider =
    Provider.family<List<Article>, Tradition>((ref, tradition) {
  return articles.where((a) => a.tradition == tradition).toList();
});

/// Provides articles filtered by category
final articlesByCategoryProvider =
    Provider.family<List<Article>, ArticleCategory>((ref, category) {
  return articles.where((a) => a.hasCategory(category)).toList();
});

/// Provides articles filtered by teacher
final articlesByTeacherProvider =
    Provider.family<List<Article>, String>((ref, teacherName) {
  return articles.where((a) => a.isBy(teacherName)).toList();
});

/// Provides a single article by ID
final articleByIdProvider =
    Provider.family<Article?, String>((ref, id) {
  try {
    return articles.firstWhere((a) => a.id == id);
  } catch (e) {
    return null;
  }
});

/// Provides featured articles (non-premium, top picks)
final featuredArticlesProvider = Provider<List<Article>>((ref) {
  return articles.where((a) => !a.isPremium).take(5).toList();
});

/// Provides premium-only articles
final premiumArticlesProvider = Provider<List<Article>>((ref) {
  return articles.where((a) => a.isPremium).toList();
});

/// Provides article count by tradition
final articleCountByTraditionProvider =
    Provider.family<int, Tradition>((ref, tradition) {
  return articles.where((a) => a.tradition == tradition).length;
});

/// Provides article count by category
final articleCountByCategoryProvider =
    Provider.family<int, ArticleCategory>((ref, category) {
  return articles.where((a) => a.hasCategory(category)).length;
});

// ============================================================
// Teacher Profile Providers
// ============================================================

/// Provides all teacher profiles
final teacherProfilesProvider =
    Provider<List<TeacherProfile>>((ref) => teacherProfiles);

/// Provides teacher profile by name
final teacherByNameProvider =
    Provider.family<TeacherProfile?, String>((ref, name) {
  try {
    return teacherProfiles.firstWhere(
      (t) => t.name.toLowerCase() == name.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
});

/// Provides teachers filtered by tradition
final teachersByTraditionProvider =
    Provider.family<List<TeacherProfile>, Tradition>((ref, tradition) {
  return teacherProfiles
      .where((t) => t.primaryTradition == tradition)
      .toList();
});

/// Provides teachers who have related articles
final teachersWithArticlesProvider = Provider<List<TeacherProfile>>((ref) {
  return teacherProfiles.where((t) => t.articleIds.isNotEmpty).toList();
});

/// Provides teachers who have related pointings
final teachersWithPointingsProvider = Provider<List<TeacherProfile>>((ref) {
  return teacherProfiles.where((t) => t.pointingIds.isNotEmpty).toList();
});

/// Provides all teacher names
final teacherNamesProvider = Provider<List<String>>((ref) {
  return teacherProfiles.map((t) => t.name).toList();
});

// ============================================================
// Search Providers
// ============================================================

/// Current search query state
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

/// Provides search results for articles
final articleSearchResultsProvider = Provider<List<Article>>((ref) {
  final query = ref.watch(librarySearchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) {
    return [];
  }

  return articles.where((a) {
    return a.title.toLowerCase().contains(query) ||
        (a.subtitle?.toLowerCase().contains(query) ?? false) ||
        (a.excerpt?.toLowerCase().contains(query) ?? false) ||
        a.content.toLowerCase().contains(query) ||
        (a.teacher?.toLowerCase().contains(query) ?? false);
  }).toList();
});

/// Provides search results for teachers
final teacherSearchResultsProvider = Provider<List<TeacherProfile>>((ref) {
  final query = ref.watch(librarySearchQueryProvider).toLowerCase().trim();

  if (query.isEmpty) {
    return [];
  }

  return teacherProfiles.where((t) {
    return t.name.toLowerCase().contains(query) ||
        (t.bio?.toLowerCase().contains(query) ?? false) ||
        t.keyTeachings.any((kt) => kt.toLowerCase().contains(query));
  }).toList();
});

// ============================================================
// Filter State Providers
// ============================================================

/// Selected tradition filter for articles
final selectedTraditionFilterProvider =
    StateProvider<Tradition?>((ref) => null);

/// Selected category filter for articles
final selectedCategoryFilterProvider =
    StateProvider<ArticleCategory?>((ref) => null);

/// Filtered articles based on current filters
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

/// Total article count
final totalArticleCountProvider = Provider<int>((ref) => articles.length);

/// Total teacher count
final totalTeacherCountProvider =
    Provider<int>((ref) => teacherProfiles.length);

/// Total reading time across all articles
final totalReadingTimeProvider = Provider<int>((ref) {
  return articles.fold(0, (sum, a) => sum + a.readingTimeMinutes);
});

/// Articles per tradition statistics
final articlesPerTraditionProvider =
    Provider<Map<Tradition, int>>((ref) {
  final map = <Tradition, int>{};
  for (final tradition in Tradition.values) {
    map[tradition] = articles.where((a) => a.tradition == tradition).length;
  }
  return map;
});

/// Teachers per tradition statistics
final teachersPerTraditionProvider =
    Provider<Map<Tradition, int>>((ref) {
  final map = <Tradition, int>{};
  for (final tradition in Tradition.values) {
    map[tradition] =
        teacherProfiles.where((t) => t.primaryTradition == tradition).length;
  }
  return map;
});

// ============================================================
// Cross-Reference Providers
// ============================================================

/// Get articles related to a teacher profile
final articlesForTeacherProvider =
    Provider.family<List<Article>, TeacherProfile>((ref, teacher) {
  return articles.where((a) => teacher.articleIds.contains(a.id)).toList();
});

/// Get teacher for an article (if attributed)
final teacherForArticleProvider =
    Provider.family<TeacherProfile?, Article>((ref, article) {
  if (article.teacher == null) return null;

  try {
    return teacherProfiles.firstWhere(
      (t) => t.name.toLowerCase() == article.teacher!.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
});
