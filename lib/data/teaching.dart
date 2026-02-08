/**
 * Unified teaching content model with comprehensive tagging.
 *
 * Provides [Teaching], [TeachingType], [TopicTags], [MoodTags], and the
 * [TeachingRepository] singleton that aggregates teachings from all sources
 * (converted [Pointing]s, teacher-specific collections, etc.).
 *
 * See also:
 * - [Pointing] in `pointings.dart` for the atomic pointing model
 * - [Article] in `models/article.dart` for longer-form library content
 */
library;

import 'pointings.dart';

/// Type of teaching content
enum TeachingType {
  /// Short direct pointer
  pointing,

  /// Longer written piece
  article,

  /// Transcribed talk
  talk,

  /// Book or satsang extract
  extract,

  /// Self-inquiry practice
  inquiry,
}

/**
 * Predefined topic tag constants for consistent content classification.
 *
 * Used by [Teaching.topicTags] and [Article.topicTags] to enable
 * topic-based browsing in [TopicTeachingsScreen].
 */
class TopicTags {
  TopicTags._();

  /// "Who am I?" and related investigative practices.
  static const selfInquiry = 'self-inquiry';

  /// Recognition of awareness as one's true nature.
  static const awareness = 'awareness';

  /// Formal and informal meditation practices.
  static const meditation = 'meditation';

  /// Awakening within interpersonal dynamics.
  static const relationship = 'relationship';

  /// Nature and transcendence of the thinking mind.
  static const mind = 'mind';

  /// Liberation from identification and suffering.
  static const freedom = 'freedom';

  /// Bhakti, prayer, and devotional surrender.
  static const devotion = 'devotion';

  /// The teaching power of stillness and quiet.
  static const silence = 'silence';

  /// Confrontation with mortality and the deathless.
  static const death = 'death';

  /// Spiritual renewal and cyclical transformation.
  static const rebirth = 'rebirth';

  /// Concrete techniques and disciplines.
  static const practice = 'practice';

  /// The nature and pursuit of awakening.
  static const enlightenment = 'enlightenment';

  /// Applying realization in everyday circumstances.
  static const life = 'life';

  /// The absolute reality underlying appearances.
  static const truth = 'truth';

  /// Resting as the present moment.
  static const presence = 'presence';

  /// Letting go of personal will and control.
  static const surrender = 'surrender';

  /// The constructed self-image and its dissolution.
  static const ego = 'ego';

  /// One's innate, original nature prior to conditioning.
  static const nature = 'nature';

  /// All available topic tags.
  static const all = [
    selfInquiry,
    awareness,
    meditation,
    relationship,
    mind,
    freedom,
    devotion,
    silence,
    death,
    rebirth,
    practice,
    enlightenment,
    life,
    truth,
    presence,
    surrender,
    ego,
    nature,
  ];

  /// Human-readable display names for topics
  static String displayName(String tag) {
    switch (tag) {
      case selfInquiry:
        return 'Self-Inquiry';
      case awareness:
        return 'Awareness';
      case meditation:
        return 'Meditation';
      case relationship:
        return 'Relationship';
      case mind:
        return 'Mind';
      case freedom:
        return 'Freedom';
      case devotion:
        return 'Devotion';
      case silence:
        return 'Silence';
      case death:
        return 'Death';
      case rebirth:
        return 'Rebirth';
      case practice:
        return 'Practice';
      case enlightenment:
        return 'Enlightenment';
      case life:
        return 'Daily Life';
      case truth:
        return 'Truth';
      case presence:
        return 'Presence';
      case surrender:
        return 'Surrender';
      case ego:
        return 'Ego';
      case nature:
        return 'True Nature';
      default:
        return tag;
    }
  }

  /// Icon for topic
  static String icon(String tag) {
    switch (tag) {
      case selfInquiry:
        return '?';
      case awareness:
        return '◯';
      case meditation:
        return '🧘';
      case relationship:
        return '♡';
      case mind:
        return '🧠';
      case freedom:
        return '🕊';
      case devotion:
        return '🙏';
      case silence:
        return '🤫';
      case death:
        return '☽';
      case rebirth:
        return '∞';
      case practice:
        return '⚡';
      case enlightenment:
        return '✦';
      case life:
        return '🌱';
      case truth:
        return '◇';
      case presence:
        return '•';
      case surrender:
        return '🌊';
      case ego:
        return '👤';
      case nature:
        return 'ॐ';
      default:
        return '•';
    }
  }
}

/**
 * Predefined mood/context tag constants for situational content delivery.
 *
 * Used by [Teaching.moodTags] and [Article.moodTags] to enable
 * mood-based browsing in [MoodTeachingsScreen].
 */
class MoodTags {
  MoodTags._();

  /// Early-morning contemplation.
  static const morning = 'morning';

  /// Midday pause or lunch-break reflection.
  static const midday = 'midday';

  /// Evening wind-down reflection.
  static const evening = 'evening';

  /// Helpful during stressful or anxious moments.
  static const stress = 'stress';

  /// Appropriate at any time of day.
  static const general = 'general';

  /// Deep, reflective, inward-looking tone.
  static const contemplative = 'contemplative';

  /// Joyful, encouraging, or inspiring tone.
  static const uplifting = 'uplifting';

  /// Provocative or destabilizing — questions assumptions.
  static const challenging = 'challenging';

  /// All available mood tags.
  static const all = [morning, midday, evening, stress, general, contemplative, uplifting, challenging];

  /// Human-readable display names for moods
  static String displayName(String tag) {
    switch (tag) {
      case morning:
        return 'Morning';
      case midday:
        return 'Midday';
      case evening:
        return 'Evening';
      case stress:
        return 'When Stressed';
      case general:
        return 'Anytime';
      case contemplative:
        return 'Contemplative';
      case uplifting:
        return 'Uplifting';
      case challenging:
        return 'Challenging';
      default:
        return tag;
    }
  }

  /// Icon for mood
  static String icon(String tag) {
    switch (tag) {
      case morning:
        return '🌅';
      case midday:
        return '☀️';
      case evening:
        return '🌙';
      case stress:
        return '🌊';
      case general:
        return '◯';
      case contemplative:
        return '🪷';
      case uplifting:
        return '✨';
      case challenging:
        return '🔥';
      default:
        return '•';
    }
  }
}

/// Extended teaching model with comprehensive tagging
class Teaching {
  /// Unique identifier
  final String id;

  /// The teaching content (quote, excerpt, or short text)
  final String content;

  /// Optional instruction or practice hint
  final String? instruction;

  /// Teacher name
  final String teacher;

  /// Source book, talk, or satsang
  final String? source;

  /// Spiritual tradition/lineage
  final Tradition lineage;

  /// Topic tags (e.g., awareness, self-inquiry, freedom)
  final Set<String> topicTags;

  /// Mood/context tags (e.g., morning, stress, contemplative)
  final Set<String> moodTags;

  /// Content type
  final TeachingType type;

  /// URL to original source (if available)
  final String? sourceUrl;

  /// When this teaching was added
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

  /// Convert existing Pointing to Teaching
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

  /// Infer topic tags from content text
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

  /// Convert Teaching back to Pointing for sharing
  Pointing toPointing() => Pointing(
    id: id.startsWith('pointing_') ? id.substring(9) : id,
    content: content,
    instruction: instruction,
    tradition: lineage,
    contexts: moodTags.map((m) => PointingContext.values.firstWhere((c) => c.name == m, orElse: () => PointingContext.general)).toList(),
    teacher: teacher == 'Unknown' ? null : teacher,
    source: source,
  );

  /// Check if teaching matches the given filters
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

  /// Check if teaching has a specific topic
  bool hasTopic(String topic) => topicTags.contains(topic);

  /// Check if teaching has a specific mood
  bool hasMood(String mood) => moodTags.contains(mood);

  @override
  bool operator ==(Object other) => identical(this, other) || other is Teaching && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Teaching(id: $id, teacher: $teacher)';
}

/// Global teaching repository for aggregating teachings from multiple sources
class TeachingRepository {
  TeachingRepository._();

  static final List<Teaching> _allTeachings = [];
  static bool _initialized = false;

  /// All teachings in the repository
  static List<Teaching> get all => List.unmodifiable(_allTeachings);

  /// Whether the repository has been initialized
  static bool get isInitialized => _initialized;

  /// Add teachings to the repository
  static void addTeachings(List<Teaching> teachings) {
    _allTeachings.addAll(teachings);
  }

  /// Initialize the repository (call once at app startup)
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

  /// Clear and reinitialize (for testing)
  static void reset() {
    _allTeachings.clear();
    _initialized = false;
  }

  /// Filter teachings by various criteria
  static List<Teaching> filter({Tradition? lineage, Set<String>? topics, Set<String>? moods, String? teacher, TeachingType? type}) {
    return _allTeachings.where((t) => t.matchesFilters(lineage: lineage, topics: topics, moods: moods, teacher: teacher, type: type)).toList();
  }

  /// Get a random teaching, optionally filtered
  static Teaching? getRandom({Tradition? lineage, Set<String>? topics, Set<String>? moods}) {
    final filtered = filter(lineage: lineage, topics: topics, moods: moods);
    if (filtered.isEmpty) return null;
    filtered.shuffle();
    return filtered.first;
  }

  /// Get list of unique teachers
  static List<String> get uniqueTeachers {
    return _allTeachings.map((t) => t.teacher).toSet().toList()..sort();
  }

  /// Get count of teachings per topic
  static Map<String, int> get topicCounts {
    final counts = <String, int>{};
    for (final t in _allTeachings) {
      for (final topic in t.topicTags) {
        counts[topic] = (counts[topic] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Get count of teachings per mood
  static Map<String, int> get moodCounts {
    final counts = <String, int>{};
    for (final t in _allTeachings) {
      for (final mood in t.moodTags) {
        counts[mood] = (counts[mood] ?? 0) + 1;
      }
    }
    return counts;
  }

  /// Get count of teachings per lineage
  static Map<Tradition, int> get lineageCounts {
    final counts = <Tradition, int>{};
    for (final t in _allTeachings) {
      counts[t.lineage] = (counts[t.lineage] ?? 0) + 1;
    }
    return counts;
  }

  /// Get count of teachings per teacher
  static Map<String, int> get teacherCounts {
    final counts = <String, int>{};
    for (final t in _allTeachings) {
      counts[t.teacher] = (counts[t.teacher] ?? 0) + 1;
    }
    return counts;
  }

  /// Get teachings by a specific teacher
  static List<Teaching> byTeacher(String teacher) {
    return _allTeachings.where((t) => t.teacher.toLowerCase() == teacher.toLowerCase()).toList();
  }

  /// Get teachings by lineage
  static List<Teaching> byLineage(Tradition lineage) {
    return _allTeachings.where((t) => t.lineage == lineage).toList();
  }

  /// Get teachings by topic
  static List<Teaching> byTopic(String topic) {
    return _allTeachings.where((t) => t.topicTags.contains(topic)).toList();
  }

  /// Get teachings by mood
  static List<Teaching> byMood(String mood) {
    return _allTeachings.where((t) => t.moodTags.contains(mood)).toList();
  }
}
