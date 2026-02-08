// Library models - enums, data classes, and extensions for the library screen
import 'package:flutter/material.dart';
import '../../data/teaching.dart';
import '../../models/article.dart';

/// Extension to sort teachings with unviewed first (viewed items sink down)
extension TeachingListSorting on List<Teaching> {
  /// Returns a new list sorted with unviewed teachings first, then viewed
  List<Teaching> sortedByViewedStatus(Set<String> viewedIds) {
    final copy = List<Teaching>.from(this);
    copy.sort((a, b) {
      final aViewed = viewedIds.contains(a.id);
      final bViewed = viewedIds.contains(b.id);
      if (aViewed && !bViewed) return 1;  // viewed sinks down
      if (!aViewed && bViewed) return -1; // unviewed stays up
      return 0; // maintain relative order
    });
    return copy;
  }
}

/// Category metadata for display
class CategoryInfo {
  final String name;
  final String icon;
  final String description;

  const CategoryInfo({
    required this.name,
    required this.icon,
    required this.description,
  });
}

const categoryInfoMap = <ArticleCategory, CategoryInfo>{
  ArticleCategory.natureOfAwareness: CategoryInfo(
    name: 'Nature of Awareness',
    icon: '◯',
    description: 'Understanding consciousness itself',
  ),
  ArticleCategory.selfInquiry: CategoryInfo(
    name: 'Self-Inquiry',
    icon: '?',
    description: 'The investigation into "Who am I?"',
  ),
  ArticleCategory.everydayAwakening: CategoryInfo(
    name: 'Everyday Awakening',
    icon: '☀',
    description: 'Living wisdom in daily life',
  ),
  ArticleCategory.traditionalTeachings: CategoryInfo(
    name: 'Traditional Teachings',
    icon: '◇',
    description: 'Classic texts and ancient wisdom',
  ),
  ArticleCategory.modernPointers: CategoryInfo(
    name: 'Modern Pointers',
    icon: '✦',
    description: 'Contemporary teachers, fresh words',
  ),
};

/// Browse mode for category navigation
enum LibraryBrowseMode {
  topics,
  teachers,
  lineages,
  moods,
  saved,
}

extension LibraryBrowseModeExt on LibraryBrowseMode {
  String get label {
    switch (this) {
      case LibraryBrowseMode.topics:
        return 'Topics';
      case LibraryBrowseMode.teachers:
        return 'Teachers';
      case LibraryBrowseMode.lineages:
        return 'Lineages';
      case LibraryBrowseMode.moods:
        return 'Moods';
      case LibraryBrowseMode.saved:
        return 'Saved';
    }
  }

  IconData get icon {
    switch (this) {
      case LibraryBrowseMode.topics:
        return Icons.topic_outlined;
      case LibraryBrowseMode.teachers:
        return Icons.person_outline;
      case LibraryBrowseMode.lineages:
        return Icons.account_tree_outlined;
      case LibraryBrowseMode.moods:
        return Icons.mood_outlined;
      case LibraryBrowseMode.saved:
        return Icons.bookmark_outline;
    }
  }
}

/// Filter mode for content display
enum ContentFilter { all, articles, quotes }
