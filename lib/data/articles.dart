/**
 * Article data layer — JSON metadata loader + lazy Markdown content.
 *
 * At startup, [loadArticles] reads `assets/data/articles.json` and builds
 * in-memory indexes for fast filtering by tradition, category, teacher,
 * topic, and mood. The full Markdown body for each article is lazy-loaded
 * on demand via [loadArticleContent].
 *
 * See also:
 * - [Article] in `models/article.dart` for the data model
 * - [LibraryScreen] for the browsing UI
 * - [ArticleReaderScreen] for the reading experience
 */
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/article.dart';
import 'pointings.dart';

// ============================================================
// Master list and pre-built indexes (populated by loadArticles)
// ============================================================

/** Master list of all [Article] records (metadata only, no content body). */
late List<Article> articles;

late Map<String, Article> _articlesById;
late Map<Tradition, List<Article>> _articlesByTradition;
late Map<String, List<Article>> _articlesByTeacher;
late Map<ArticleCategory, List<Article>> _articlesByCategory;
late Map<String, List<Article>> _articlesByTopic;
late Map<String, List<Article>> _articlesByMood;

bool _articlesLoaded = false;

// ============================================================
// Startup loader
// ============================================================

/**
 * Load article metadata from `assets/data/articles.json` and build indexes.
 *
 * Must be called once during app initialization (see [AppInitializer]).
 * Subsequent calls are no-ops.
 */
Future<void> loadArticles() async {
  if (_articlesLoaded) return;

  final jsonString = await rootBundle.loadString('assets/data/articles.json');
  final list = (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
  articles = list.map((e) => Article.fromJson(e)).toList(growable: false);

  // Build indexes
  _articlesById = {for (final a in articles) a.id: a};

  _articlesByTradition = {};
  _articlesByTeacher = {};
  _articlesByCategory = {};
  _articlesByTopic = {};
  _articlesByMood = {};

  for (final a in articles) {
    _articlesByTradition.putIfAbsent(a.tradition, () => []).add(a);

    if (a.teacher != null) {
      final key = a.teacher!.toLowerCase();
      _articlesByTeacher.putIfAbsent(key, () => []).add(a);
    }

    for (final c in a.categories) {
      _articlesByCategory.putIfAbsent(c, () => []).add(a);
    }

    for (final t in a.topicTags) {
      _articlesByTopic.putIfAbsent(t, () => []).add(a);
    }

    for (final m in a.moodTags) {
      _articlesByMood.putIfAbsent(m, () => []).add(a);
    }
  }

  _articlesLoaded = true;
}

// ============================================================
// Lazy content loader
// ============================================================

/**
 * Lazy-load the full Markdown body for a single article.
 *
 * Reads from `assets/articles/{articleId}.md`. The result is not cached
 * here — callers (e.g. [ArticleReaderScreen]) should manage their own
 * lifecycle.
 */
Future<String> loadArticleContent(String articleId) async {
  return rootBundle.loadString('assets/articles/$articleId.md');
}

// ============================================================
// Query helpers (all use pre-built indexes)
// ============================================================

/** Get a single article by ID. */
Article? getArticleById(String id) => _articlesById[id];

/** Get articles filtered by tradition. */
List<Article> getArticlesByTradition(Tradition tradition) {
  return _articlesByTradition[tradition] ?? const [];
}

/** Get articles filtered by category. */
List<Article> getArticlesByCategory(ArticleCategory category) {
  return _articlesByCategory[category] ?? const [];
}

/** Get articles filtered by teacher. */
List<Article> getArticlesByTeacher(String teacherName) {
  return _articlesByTeacher[teacherName.toLowerCase()] ?? const [];
}

/** Get featured articles (top picks). */
List<Article> getFeaturedArticles({int limit = 5}) {
  return articles.take(limit).toList();
}

/**
 * Search articles by title, subtitle, or excerpt.
 *
 * Content search is not available here because content is lazy-loaded.
 * For full-text search including body, load content on demand.
 */
List<Article> searchArticles(String query) {
  final lowerQuery = query.toLowerCase();
  return articles.where((a) {
    return a.title.toLowerCase().contains(lowerQuery) ||
        (a.subtitle?.toLowerCase().contains(lowerQuery) ?? false) ||
        (a.excerpt?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();
}

/** Get articles by topic tag. */
List<Article> getArticlesByTopic(String topic) {
  return _articlesByTopic[topic] ?? const [];
}

/** Get articles by mood tag. */
List<Article> getArticlesByMood(String mood) {
  return _articlesByMood[mood] ?? const [];
}

/** Get count of articles per topic tag. */
Map<String, int> getArticleTopicCounts() {
  return {for (final entry in _articlesByTopic.entries) entry.key: entry.value.length};
}

/** Get count of articles per mood tag. */
Map<String, int> getArticleMoodCounts() {
  return {for (final entry in _articlesByMood.entries) entry.key: entry.value.length};
}

// ============================================================
// Test support
// ============================================================

/**
 * Reset loaded state (for unit tests that need to re-initialize).
 *
 * Not intended for production use.
 */
void resetArticlesForTesting() {
  _articlesLoaded = false;
}
