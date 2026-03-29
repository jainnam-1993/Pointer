import '../data/pointings.dart';

/**
 * Unified teacher model combining biographical data with library profile.
 *
 * Merges the former lightweight [Teacher] (used by [TeacherSheet]) with
 * the extended [TeacherProfile] (used by [LibraryScreen]) into a single
 * model loaded from `assets/data/teachers.json`.
 *
 * Contains essential biographical metadata, key teachings, cross-references
 * to related articles and pointings, and optional profile fields (quote,
 * location, image).
 */
class Teacher {
  /** Display name (e.g., `'Ramana Maharshi'`). */
  final String name;

  /** Biographical summary. */
  final String? bio;

  /** Life dates (e.g., `'1879-1950'` or `'born 1960'`). */
  final String? dates;

  /** Primary spiritual tradition. See [Tradition]. */
  final Tradition tradition;

  /** Descriptive tags for search and categorization. */
  final List<String> tags;

  /** Asset path for teacher image (optional). */
  final String? imageAsset;

  /** Key teachings or concepts associated with this teacher. */
  final List<String> keyTeachings;

  /** Short quote or summary of their teaching. */
  final String? quote;

  /** Location/lineage information (e.g., "Tiruvannamalai, India"). */
  final String? location;

  /** IDs of related articles in the library. */
  final List<String> articleIds;

  /** IDs of related pointings. */
  final List<String> pointingIds;

  const Teacher({
    required this.name,
    this.bio,
    this.dates,
    required this.tradition,
    this.tags = const [],
    this.imageAsset,
    this.keyTeachings = const [],
    this.quote,
    this.location,
    this.articleIds = const [],
    this.pointingIds = const [],
  });

  /** Deserialize from JSON map (e.g., from `assets/data/teachers.json`). */
  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      name: json['name'] as String,
      bio: json['bio'] as String?,
      dates: json['dates'] as String?,
      tradition: Tradition.values.firstWhere(
        (t) => t.name == json['tradition'],
        orElse: () => Tradition.contemporary,
      ),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      imageAsset: json['imageAsset'] as String?,
      keyTeachings: (json['keyTeachings'] as List<dynamic>?)?.cast<String>() ?? const [],
      quote: json['quote'] as String?,
      location: json['location'] as String?,
      articleIds: (json['articleIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      pointingIds: (json['pointingIds'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  /** Check if this teacher has a specific article. */
  bool hasArticle(String articleId) => articleIds.contains(articleId);

  /** Check if this teacher has a specific pointing. */
  bool hasPointing(String pointingId) => pointingIds.contains(pointingId);

  /** Check if this teacher is from the given tradition. */
  bool isFromTradition(Tradition t) => tradition == t;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Teacher && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'Teacher(name: $name)';
}
