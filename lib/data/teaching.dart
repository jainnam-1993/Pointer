/**
 * Unified teaching content model with comprehensive tagging.
 *
 * Provides [Teaching], [TeachingType], and the [TeachingRepository] singleton
 * that aggregates teachings from all sources (converted [Pointing]s,
 * teacher-specific collections, etc.).
 *
 * [TopicTags] and [MoodTags] are defined in `tags.dart` and re-exported here
 * for backward compatibility.
 *
 * See also:
 * - [Pointing] in `pointings.dart` for the atomic pointing model
 * - [Article] in `models/article.dart` for longer-form library content
 */
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import 'pointings.dart';
import 'tags.dart';
export 'tags.dart';

/** Type of teaching content */
enum TeachingType {
  /** Short direct pointer */
  pointing,

  /** Longer written piece */
  article,

  /** Transcribed talk */
  talk,

  /** Book or satsang extract */
  extract,

  /** Self-inquiry practice */
  inquiry,
}

/** Extended teaching model with comprehensive tagging */
class Teaching {
  /** Unique identifier */
  final String id;

  /** The teaching content (quote, excerpt, or short text) */
  final String content;

  /** Optional instruction or practice hint */
  final String? instruction;

  /** Teacher name */
  final String teacher;

  /** Source book, talk, or satsang */
  final String? source;

  /** Spiritual tradition/lineage */
  final Tradition lineage;

  /** Topic tags (e.g., awareness, self-inquiry, freedom) */
  final Set<String> topicTags;

  /** Mood/context tags (e.g., morning, stress, contemplative) */
  final Set<String> moodTags;

  /** Content type */
  final TeachingType type;

  /** URL to original source (if available) */
  final String? sourceUrl;

  /** When this teaching was added */
  final DateTime? dateAdded;

  const Teaching({
    required this.id,
    required this.content,
    this.instruction,
    required this.teacher,
    this.source,
    required this.lineage,
    required this.topicTags,
    required this.moodTags,
    required this.type,
    this.sourceUrl,
    this.dateAdded,
  });

  /** Deserialize from JSON map (e.g., from `assets/data/teachings.json`). */
  factory Teaching.fromJson(Map<String, dynamic> json) {
    return Teaching(
      id: json['id'] as String,
      content: json['content'] as String,
      instruction: json['instruction'] as String?,
      teacher: json['teacher'] as String,
      source: json['source'] as String?,
      lineage: Tradition.values.firstWhere(
        (t) => t.name == json['lineage'],
        orElse: () => Tradition.contemporary,
      ),
      topicTags: (json['topicTags'] as List<dynamic>?)?.cast<String>().toSet() ?? const <String>{},
      moodTags: (json['moodTags'] as List<dynamic>?)?.cast<String>().toSet() ?? const <String>{},
      type: TeachingType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TeachingType.extract,
      ),
      sourceUrl: json['sourceUrl'] as String?,
      dateAdded: json['dateAdded'] != null ? DateTime.tryParse(json['dateAdded'] as String) : null,
    );
  }

  /** Convert existing Pointing to Teaching */
  factory Teaching.fromPointing(Pointing p) {
    return Teaching(
      id: 'pointing_${p.id}',
      content: p.content,
      instruction: p.instruction,
      teacher: p.teacher ?? 'Unknown',
      source: p.source,
      lineage: p.tradition,
      topicTags: _inferTopics(p.content),
      moodTags: p.contexts.map((c) => c.name).toSet(),
      type: TeachingType.pointing,
    );
  }

  /** Infer topic tags from content text */
  static Set<String> _inferTopics(String content) {
    final topics = <String>{};
    final lower = content.toLowerCase();

    if (lower.contains('awareness') || lower.contains('conscious')) {
      topics.add(TopicTags.awareness);
    }
    if (lower.contains('inquiry') || lower.contains('who am i')) {
      topics.add(TopicTags.selfInquiry);
    }
    if (lower.contains('mind') || lower.contains('thought')) {
      topics.add(TopicTags.mind);
    }
    if (lower.contains('free') || lower.contains('liberation')) {
      topics.add(TopicTags.freedom);
    }
    if (lower.contains('silence') || lower.contains('quiet')) {
      topics.add(TopicTags.silence);
    }
    if (lower.contains('meditat')) {
      topics.add(TopicTags.meditation);
    }
    if (lower.contains('truth') || lower.contains('reality')) {
      topics.add(TopicTags.truth);
    }
    if (lower.contains('enlighten') || lower.contains('awaken')) {
      topics.add(TopicTags.enlightenment);
    }
    if (lower.contains('present') || lower.contains('now')) {
      topics.add(TopicTags.presence);
    }
    if (lower.contains('ego') || lower.contains('self-image')) {
      topics.add(TopicTags.ego);
    }
    if (lower.contains('surrender') || lower.contains('let go')) {
      topics.add(TopicTags.surrender);
    }
    if (lower.contains('practice') || lower.contains('technique')) {
      topics.add(TopicTags.practice);
    }
    if (lower.contains('love') || lower.contains('bhakti') || lower.contains('prayer') || lower.contains('devoti')) {
      topics.add(TopicTags.devotion);
    }
    if (lower.contains('relat') || lower.contains('togeth')) {
      topics.add(TopicTags.relationship);
    }
    if (lower.contains('death') || lower.contains('dying') || lower.contains('mortal')) {
      topics.add(TopicTags.death);
    }
    if (lower.contains('rebirth') || lower.contains('renewal') || lower.contains('reincarn')) {
      topics.add(TopicTags.rebirth);
    }
    if (lower.contains('daily') || lower.contains('everyday') || lower.contains('ordinary') || lower.contains('mundane')) {
      topics.add(TopicTags.life);
    }
    if (lower.contains('nature') || lower.contains('essence') || lower.contains('innate') || lower.contains('original face')) {
      topics.add(TopicTags.nature);
    }

    return topics.isEmpty ? {TopicTags.awareness} : topics;
  }

  /** Convert Teaching back to Pointing for sharing */
  Pointing toPointing() => Pointing(
    id: id.startsWith('pointing_') ? id.substring(9) : id,
    content: content,
    instruction: instruction,
    tradition: lineage,
    contexts: moodTags.map((m) => PointingContext.values.firstWhere((c) => c.name == m, orElse: () => PointingContext.general)).toList(),
    teacher: teacher == 'Unknown' ? null : teacher,
    source: source,
  );

  /** Check if teaching matches the given filters */
  bool matchesFilters({Tradition? lineage, Set<String>? topics, Set<String>? moods, String? teacher, TeachingType? type}) {
    if (lineage != null && this.lineage != lineage) return false;
    if (topics != null && topics.isNotEmpty && topicTags.intersection(topics).isEmpty) {
      return false;
    }
    if (moods != null && moods.isNotEmpty && moodTags.intersection(moods).isEmpty) {
      return false;
    }
    if (teacher != null && this.teacher.toLowerCase() != teacher.toLowerCase()) {
      return false;
    }
    if (type != null && this.type != type) return false;
    return true;
  }

  /** Check if teaching has a specific topic */
  bool hasTopic(String topic) => topicTags.contains(topic);

  /** Check if teaching has a specific mood */
  bool hasMood(String mood) => moodTags.contains(mood);

  @override
  bool operator ==(Object other) => identical(this, other) || other is Teaching && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Teaching(id: $id, teacher: $teacher)';
}

/** Global teaching repository for aggregating teachings from multiple sources */
class TeachingRepository {
  TeachingRepository._();

  static final List<Teaching> _allTeachings = [];
  static bool _initialized = false;

  /** All teachings in the repository */
  static List<Teaching> get all => List.unmodifiable(_allTeachings);

  /** Whether the repository has been initialized */
  static bool get isInitialized => _initialized;

  /** Add teachings to the repository */
  static void addTeachings(List<Teaching> teachings) {
    _allTeachings.addAll(teachings);
  }

  /** Initialize the repository (call once at app startup) */
  static void initialize({List<Pointing>? pointings, List<Teaching>? additionalTeachings}) {
    if (_initialized) return;

    // Convert existing pointings
    if (pointings != null) {
      _allTeachings.addAll(pointings.map(Teaching.fromPointing));
    }

    // Add any additional teachings
    if (additionalTeachings != null) {
      _allTeachings.addAll(additionalTeachings);
    }

    _initialized = true;
  }

  /**
   * Load teachings from `assets/data/teachings.json` and add to the repository.
   *
   * Validates topic and mood tags against [TopicTags.all] and [MoodTags.all].
   * Invalid tags trigger an assertion failure in debug mode.
   */
  static Future<void> loadFromAsset() async {
    final jsonString = await rootBundle.loadString('assets/data/teachings.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    final teachings = jsonList.map((e) => Teaching.fromJson(e as Map<String, dynamic>)).toList();
    _validateTags(teachings);
    _allTeachings.addAll(teachings);
  }

  /** Validate that all topic and mood tags reference known constants. */
  static void _validateTags(List<Teaching> teachings) {
    for (final t in teachings) {
      for (final tag in t.topicTags) {
        assert(TopicTags.all.contains(tag), 'Unknown topic tag: "$tag" in teaching ${t.id}');
      }
      for (final tag in t.moodTags) {
        assert(MoodTags.all.contains(tag), 'Unknown mood tag: "$tag" in teaching ${t.id}');
      }
    }
  }

  /** Clear and reinitialize (for testing) */
  static void reset() {
    _allTeachings.clear();
    _initialized = false;
  }

  /** Filter teachings by various criteria */
  static List<Teaching> filter({Tradition? lineage, Set<String>? topics, Set<String>? moods, String? teacher, TeachingType? type}) {
    return _allTeachings.where((t) => t.matchesFilters(lineage: lineage, topics: topics, moods: moods, teacher: teacher, type: type)).toList();
  }

  /** Get a random teaching, optionally filtered */
  static Teaching? getRandom({Tradition? lineage, Set<String>? topics, Set<String>? moods}) {
    final filtered = filter(lineage: lineage, topics: topics, moods: moods);
    if (filtered.isEmpty) return null;
    filtered.shuffle();
    return filtered.first;
  }

  /** Get list of unique teachers */
  static List<String> get uniqueTeachers {
    return _allTeachings.map((t) => t.teacher).toSet().toList()..sort();
  }

  /** Get count of teachings per topic */
  static Map<String, int> get topicCounts {
    final counts = <String, int>{};
    for (final t in _allTeachings) {
      for (final topic in t.topicTags) {
        counts[topic] = (counts[topic] ?? 0) + 1;
      }
    }
    return counts;
  }

  /** Get count of teachings per mood */
  static Map<String, int> get moodCounts {
    final counts = <String, int>{};
    for (final t in _allTeachings) {
      for (final mood in t.moodTags) {
        counts[mood] = (counts[mood] ?? 0) + 1;
      }
    }
    return counts;
  }

  /** Get count of teachings per lineage */
  static Map<Tradition, int> get lineageCounts {
    final counts = <Tradition, int>{};
    for (final t in _allTeachings) {
      counts[t.lineage] = (counts[t.lineage] ?? 0) + 1;
    }
    return counts;
  }

  /** Get count of teachings per teacher */
  static Map<String, int> get teacherCounts {
    final counts = <String, int>{};
    for (final t in _allTeachings) {
      counts[t.teacher] = (counts[t.teacher] ?? 0) + 1;
    }
    return counts;
  }

  /** Get teachings by a specific teacher */
  static List<Teaching> byTeacher(String teacher) {
    return _allTeachings.where((t) => t.teacher.toLowerCase() == teacher.toLowerCase()).toList();
  }

  /** Get teachings by lineage */
  static List<Teaching> byLineage(Tradition lineage) {
    return _allTeachings.where((t) => t.lineage == lineage).toList();
  }

  /** Get teachings by topic */
  static List<Teaching> byTopic(String topic) {
    return _allTeachings.where((t) => t.topicTags.contains(topic)).toList();
  }

  /** Get teachings by mood */
  static List<Teaching> byMood(String mood) {
    return _allTeachings.where((t) => t.moodTags.contains(mood)).toList();
  }
}
