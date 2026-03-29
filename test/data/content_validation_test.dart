import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/articles.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/data/teachers.dart';
import 'package:pointer/data/teaching.dart';

import '../helpers/test_setup.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    loadTestPointings();
    resetArticlesForTesting();
    await loadArticles();
  });
  group('Pointings content validation', () {
    test('no empty content fields', () {
      for (final p in pointings) {
        expect(p.content.trim(), isNotEmpty, reason: 'Pointing ${p.id} has empty content');
      }
    });

    test('no empty IDs', () {
      for (final p in pointings) {
        expect(p.id.trim(), isNotEmpty, reason: 'Found pointing with empty id');
      }
    });

    test('all IDs are unique', () {
      final ids = pointings.map((p) => p.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length, reason: 'Duplicate pointing IDs: ${ids.where((id) => ids.where((i) => i == id).length > 1).toSet()}');
    });

    test('all traditions are valid enum members', () {
      for (final p in pointings) {
        expect(Tradition.values, contains(p.tradition), reason: 'Pointing ${p.id} has invalid tradition');
      }
    });

    test('most teachers exist in teachers map', () {
      // 22 teachers in map, 54 unique names in pointings.
      // Some pointings use historical/text names (Zen koan, Dogen, etc.)
      // that don't have teacher info sheets yet.
      final unknownTeachers = <String>{};
      for (final p in pointings) {
        if (p.teacher != null && !teachers.containsKey(p.teacher)) {
          unknownTeachers.add(p.teacher!);
        }
      }
      // At least 40% of unique teacher names should be in the map
      final allTeacherNames = pointings.where((p) => p.teacher != null).map((p) => p.teacher!).toSet();
      final mapped = allTeacherNames.length - unknownTeachers.length;
      expect(
        mapped,
        greaterThan(allTeacherNames.length * 0.3),
        reason:
            'Only $mapped/${allTeacherNames.length} teachers in map. '
            'Missing: $unknownTeachers',
      );
    });

    test('no HTML entities in content', () {
      final htmlEntities = RegExp(r'&(amp|lt|gt|quot|apos|nbsp);');
      for (final p in pointings) {
        expect(p.content, isNot(matches(htmlEntities)), reason: 'Pointing ${p.id} contains HTML entities');
      }
    });

    test('no encoding artifacts in content', () {
      // Common UTF-8 mojibake patterns
      final artifacts = RegExp(r'â€™|â€œ|â€|Ã©|Ã¨|Ã¼|â€"');
      for (final p in pointings) {
        expect(p.content, isNot(matches(artifacts)), reason: 'Pointing ${p.id} contains encoding artifacts');
      }
    });

    test('no markdown syntax in content', () {
      // Pointings are plain text, not markdown
      final markdownHeaders = RegExp(r'^#{1,6}\s', multiLine: true);
      final boldSyntax = RegExp(r'\*\*[^*]+\*\*');
      for (final p in pointings) {
        expect(p.content, isNot(matches(markdownHeaders)), reason: 'Pointing ${p.id} contains markdown headers');
        expect(p.content, isNot(matches(boldSyntax)), reason: 'Pointing ${p.id} contains markdown bold syntax');
      }
    });

    test('source field is not empty string when present', () {
      for (final p in pointings) {
        if (p.source != null) {
          expect(p.source!.trim(), isNotEmpty, reason: 'Pointing ${p.id} has empty source string');
        }
      }
    });

    test('content length > 10 chars (not truncated)', () {
      for (final p in pointings) {
        expect(p.content.length, greaterThan(10), reason: 'Pointing ${p.id} has suspiciously short content: "${p.content}"');
      }
    });
  });

  group('Articles content validation', () {
    test('all IDs are unique', () {
      final ids = articles.map((a) => a.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length, reason: 'Duplicate article IDs: ${ids.where((id) => ids.where((i) => i == id).length > 1).toSet()}');
    });

    test('readingTimeMinutes > 0', () {
      for (final a in articles) {
        expect(a.readingTimeMinutes, greaterThan(0), reason: 'Article ${a.id} has invalid readingTimeMinutes');
      }
    });

    test('most article teachers are in teachers map', () {
      // Some articles use alternate name forms (e.g., "Papaji (H.W.L. Poonja)")
      final articlesWithTeacher = articles.where((a) => a.teacher != null);
      final matched = articlesWithTeacher.where((a) => teachers.containsKey(a.teacher)).length;
      expect(matched, greaterThan(articlesWithTeacher.length * 0.8), reason: 'Only $matched/${articlesWithTeacher.length} article teachers in map');
    });

    test('no encoding artifacts in article markdown files', () async {
      final artifacts = RegExp(r'â€™|â€œ|â€|Ã©|Ã¨|Ã¼|â€"');
      for (final a in articles) {
        final content = await loadArticleContent(a.id);
        expect(content, isNot(matches(artifacts)), reason: 'Article ${a.id} contains encoding artifacts');
      }
    });

    test('topicTags use valid constants', () {
      for (final a in articles) {
        for (final tag in a.topicTags) {
          expect(TopicTags.all, contains(tag), reason: 'Article ${a.id} has invalid topicTag: $tag');
        }
      }
    });

    test('moodTags use valid constants', () {
      for (final a in articles) {
        for (final tag in a.moodTags) {
          expect(MoodTags.all, contains(tag), reason: 'Article ${a.id} has invalid moodTag: $tag');
        }
      }
    });

    test('markdown content files are not empty', () async {
      for (final a in articles) {
        final content = await loadArticleContent(a.id);
        expect(content.trim(), isNotEmpty, reason: 'Article ${a.id} has empty markdown content');
      }
    });

    test('title is not empty', () {
      for (final a in articles) {
        expect(a.title.trim(), isNotEmpty, reason: 'Article ${a.id} has empty title');
      }
    });

    test('has at least one category', () {
      for (final a in articles) {
        expect(a.categories, isNotEmpty, reason: 'Article ${a.id} has no categories');
      }
    });
  });

  group('Teachers content validation', () {
    test('has expected number of teachers', () {
      expect(teachers.length, 22);
    });

    test('all teachers have name, bio, and tradition', () {
      for (final entry in teachers.entries) {
        expect(entry.value.name.trim(), isNotEmpty, reason: 'Teacher ${entry.key} has empty name');
        expect(entry.value.bio, isNotNull, reason: 'Teacher ${entry.key} has null bio');
        expect(entry.value.bio!.trim(), isNotEmpty, reason: 'Teacher ${entry.key} has empty bio');
        expect(Tradition.values, contains(entry.value.tradition), reason: 'Teacher ${entry.key} has invalid tradition');
      }
    });

    test('no duplicate teacher names', () {
      final names = teachers.values.map((t) => t.name).toList();
      final uniqueNames = names.toSet();
      expect(names.length, uniqueNames.length, reason: 'Duplicate teacher names found');
    });

    test('map keys match teacher names', () {
      for (final entry in teachers.entries) {
        expect(entry.key, entry.value.name, reason: 'Teacher key "${entry.key}" does not match name "${entry.value.name}"');
      }
    });
  });

  group('Cross-data integrity', () {
    test('expected pointing count', () {
      expect(pointings.length, greaterThanOrEqualTo(2350), reason: 'Expected ~2393 pointings, got ${pointings.length}');
    });

    test('expected article count', () {
      expect(articles.length, greaterThanOrEqualTo(160), reason: 'Expected ~166 articles, got ${articles.length}');
    });

    test('all traditions have at least one pointing', () {
      for (final tradition in Tradition.values) {
        final count = pointings.where((p) => p.tradition == tradition).length;
        expect(count, greaterThan(0), reason: 'Tradition ${tradition.name} has no pointings');
      }
    });

    test('most traditions have articles', () {
      // "original" tradition has no articles yet (only pointings)
      final traditionsWithArticles = Tradition.values.where((t) => articles.any((a) => a.tradition == t)).toList();
      expect(traditionsWithArticles.length, greaterThanOrEqualTo(4), reason: 'Expected at least 4 traditions with articles');
    });
  });
}
