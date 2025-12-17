import '../data/pointings.dart';

/// Teacher information model for expandable teacher info feature
class Teacher {
  final String name;
  final String? bio;
  final String? dates;
  final Tradition tradition;
  final List<String> tags;

  const Teacher({
    required this.name,
    this.bio,
    this.dates,
    required this.tradition,
    this.tags = const [],
  });
}
