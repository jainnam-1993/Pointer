import '../data/pointings.dart';

/**
 * Lightweight teacher model used by the expandable teacher-info sheet.
 *
 * Contains essential biographical metadata displayed in [TeacherSheet].
 * For richer profiles with key teachings and cross-references, see
 * [TeacherProfile] in `models/teacher_profile.dart`.
 */
class Teacher {
  /** Display name (e.g., `'Ramana Maharshi'`). */
  final String name;

  /** Short biographical summary. */
  final String? bio;

  /** Life dates (e.g., `'1879-1950'` or `'born 1960'`). */
  final String? dates;

  /** Primary spiritual tradition. See [Tradition]. */
  final Tradition tradition;

  /** Descriptive tags for search and categorization. */
  final List<String> tags;

  const Teacher({required this.name, this.bio, this.dates, required this.tradition, this.tags = const []});
}
