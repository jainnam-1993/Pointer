// Article Data Model
// Represents articles/essays in the Library feature
//
// Articles contain markdown-formatted content from classic non-dual teachings,
// excerpts from books, and explanatory essays on spiritual concepts.

import '../data/pointings.dart';

/// Topic categories for articles
enum ArticleCategory {
  /// Explorations of the nature of awareness/consciousness
  natureOfAwareness,

  /// Self-inquiry methods and techniques
  selfInquiry,

  /// Applying awakening in daily life
  everydayAwakening,

  /// Teachings from traditional texts and masters
  traditionalTeachings,

  /// Contemporary pointers and modern expressions
  modernPointers,
}

/// Article model for Library content
class Article {
  /// Unique identifier
  final String id;

  /// Article title
  final String title;

  /// Optional subtitle/tagline
  final String? subtitle;

  /// Full article content in Markdown format
  final String content;

  /// Short preview text for list views
  final String? excerpt;

  /// Source tradition
  final Tradition tradition;

  /// Teacher/author attribution (if applicable)
  final String? teacher;

  /// Topic categories
  final List<ArticleCategory> categories;

  /// Estimated reading time in minutes
  final int readingTimeMinutes;

  /// When the article was added to the library
  final DateTime? dateAdded;

  /// Whether this is premium-only content
  final bool isPremium;

  /// Topic tags for filtering (uses TopicTags constants)
  final Set<String> topicTags;

  /// Mood tags for context-based browsing (uses MoodTags constants)
  final Set<String> moodTags;

  const Article({
    required this.id,
    required this.title,
    this.subtitle,
    required this.content,
    this.excerpt,
    required this.tradition,
    this.teacher,
    required this.categories,
    required this.readingTimeMinutes,
    this.dateAdded,
    this.isPremium = false,
    this.topicTags = const {},
    this.moodTags = const {},
  });

  /// Check if article belongs to a specific category
  bool hasCategory(ArticleCategory category) => categories.contains(category);

  /// Check if article is by a specific teacher
  bool isBy(String teacherName) =>
      teacher?.toLowerCase() == teacherName.toLowerCase();

  /// Check if article has a specific topic tag
  bool hasTopic(String topic) => topicTags.contains(topic);

  /// Check if article has a specific mood tag
  bool hasMood(String mood) => moodTags.contains(mood);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Article(id: $id, title: $title)';
}
