// Teacher Profile Data Model
// Represents detailed profiles of spiritual teachers in the Library feature
//
// Teacher profiles provide biographical information and context about the
// masters and contemporary teachers whose teachings appear in the app.

import '../data/pointings.dart';

/// Detailed teacher profile for the Library
class TeacherProfile {
  /// Full name of the teacher
  final String name;

  /// Biographical description
  final String? bio;

  /// Life dates (e.g., "1879-1950" or "born 1960")
  final String? dates;

  /// Primary spiritual tradition
  final Tradition primaryTradition;

  /// Asset path for teacher image (optional)
  final String? imageAsset;

  /// Key teachings or concepts associated with this teacher
  final List<String> keyTeachings;

  /// IDs of related articles in the library
  final List<String> articleIds;

  /// IDs of related pointings
  final List<String> pointingIds;

  /// Short quote or summary of their teaching
  final String? quote;

  /// Location/lineage information (e.g., "Tiruvannamalai, India")
  final String? location;

  const TeacherProfile({
    required this.name,
    this.bio,
    this.dates,
    required this.primaryTradition,
    this.imageAsset,
    this.keyTeachings = const [],
    this.articleIds = const [],
    this.pointingIds = const [],
    this.quote,
    this.location,
  });

  /// Check if this teacher has a specific article
  bool hasArticle(String articleId) => articleIds.contains(articleId);

  /// Check if this teacher has a specific pointing
  bool hasPointing(String pointingId) => pointingIds.contains(pointingId);

  /// Check if this teacher is from the given tradition
  bool isFromTradition(Tradition tradition) => primaryTradition == tradition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherProfile &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TeacherProfile(name: $name)';
}
