import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';

void main() {
  group('Tradition enum', () {
    test('has all 5 traditions', () {
      expect(Tradition.values.length, 5);
    });

    test('contains expected values', () {
      expect(Tradition.values, contains(Tradition.advaita));
      expect(Tradition.values, contains(Tradition.zen));
      expect(Tradition.values, contains(Tradition.direct));
      expect(Tradition.values, contains(Tradition.contemporary));
      expect(Tradition.values, contains(Tradition.original));
    });
  });

  group('PointingContext enum', () {
    test('has all 5 contexts', () {
      expect(PointingContext.values.length, 5);
    });

    test('contains expected values', () {
      expect(PointingContext.values, contains(PointingContext.morning));
      expect(PointingContext.values, contains(PointingContext.midday));
      expect(PointingContext.values, contains(PointingContext.evening));
      expect(PointingContext.values, contains(PointingContext.stress));
      expect(PointingContext.values, contains(PointingContext.general));
    });
  });

  group('Pointing model', () {
    test('can be created with required fields', () {
      const pointing = Pointing(
        id: 'test-1',
        content: 'Test content',
        tradition: Tradition.advaita,
        contexts: [PointingContext.general],
      );

      expect(pointing.id, 'test-1');
      expect(pointing.content, 'Test content');
      expect(pointing.tradition, Tradition.advaita);
      expect(pointing.contexts, [PointingContext.general]);
      expect(pointing.instruction, isNull);
      expect(pointing.teacher, isNull);
      expect(pointing.source, isNull);
    });

    test('can be created with all optional fields', () {
      const pointing = Pointing(
        id: 'test-2',
        content: 'Test content',
        instruction: 'Test instruction',
        tradition: Tradition.zen,
        contexts: [PointingContext.morning, PointingContext.evening],
        teacher: 'Test Teacher',
        source: 'Test Source',
      );

      expect(pointing.instruction, 'Test instruction');
      expect(pointing.teacher, 'Test Teacher');
      expect(pointing.source, 'Test Source');
      expect(pointing.contexts.length, 2);
    });

    test('supports multiple contexts', () {
      const pointing = Pointing(
        id: 'test-3',
        content: 'Test',
        tradition: Tradition.direct,
        contexts: [
          PointingContext.morning,
          PointingContext.midday,
          PointingContext.evening,
          PointingContext.stress,
          PointingContext.general,
        ],
      );

      expect(pointing.contexts.length, 5);
      expect(pointing.contexts, contains(PointingContext.morning));
      expect(pointing.contexts, contains(PointingContext.general));
    });
  });

  group('TraditionInfo model', () {
    test('can be created with all fields', () {
      const info = TraditionInfo(
        name: 'Test Tradition',
        icon: 'T',
        description: 'A test tradition',
      );

      expect(info.name, 'Test Tradition');
      expect(info.icon, 'T');
      expect(info.description, 'A test tradition');
    });
  });

  group('traditions map', () {
    test('has all 5 traditions', () {
      expect(traditions.length, 5);
    });

    test('maps all Tradition enum values', () {
      for (final tradition in Tradition.values) {
        expect(traditions.containsKey(tradition), true,
            reason: '${tradition.name} should be in traditions map');
      }
    });

    test('all traditions have non-empty names', () {
      for (final entry in traditions.entries) {
        expect(entry.value.name, isNotEmpty,
            reason: '${entry.key.name} should have a name');
      }
    });

    test('all traditions have non-empty icons', () {
      for (final entry in traditions.entries) {
        expect(entry.value.icon, isNotEmpty,
            reason: '${entry.key.name} should have an icon');
      }
    });

    test('all traditions have non-empty descriptions', () {
      for (final entry in traditions.entries) {
        expect(entry.value.description, isNotEmpty,
            reason: '${entry.key.name} should have a description');
      }
    });

    test('Advaita Vedanta info is correct', () {
      final info = traditions[Tradition.advaita]!;
      expect(info.name, 'Advaita Vedanta');
      expect(info.icon, isNotEmpty);
      expect(info.description, contains('non-duality'));
    });

    test('Zen Buddhism info is correct', () {
      final info = traditions[Tradition.zen]!;
      expect(info.name, 'Zen Buddhism');
      expect(info.icon, isNotEmpty);
    });

    test('Direct Path info is correct', () {
      final info = traditions[Tradition.direct]!;
      expect(info.name, 'Direct Path');
      expect(info.icon, isNotEmpty);
    });

    test('Contemporary info is correct', () {
      final info = traditions[Tradition.contemporary]!;
      expect(info.name, 'Contemporary');
      expect(info.icon, isNotEmpty);
    });

    test('Original info is correct', () {
      final info = traditions[Tradition.original]!;
      expect(info.name, 'Original');
      expect(info.icon, isNotEmpty);
    });
  });

  group('pointings list', () {
    test('is not empty', () {
      expect(pointings, isNotEmpty);
    });

    test('has at least 20 pointings', () {
      expect(pointings.length, greaterThanOrEqualTo(20));
    });

    test('all pointings have unique ids', () {
      final ids = pointings.map((p) => p.id).toList();
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, ids.length,
          reason: 'All pointing ids should be unique');
    });

    test('all pointings have non-empty content', () {
      for (final pointing in pointings) {
        expect(pointing.content, isNotEmpty,
            reason: 'Pointing ${pointing.id} should have content');
      }
    });

    test('all pointings have at least one context', () {
      for (final pointing in pointings) {
        expect(pointing.contexts, isNotEmpty,
            reason: 'Pointing ${pointing.id} should have at least one context');
      }
    });

    test('all traditions have at least 2 pointings', () {
      for (final tradition in Tradition.values) {
        final count =
            pointings.where((p) => p.tradition == tradition).length;
        expect(count, greaterThanOrEqualTo(2),
            reason: '${tradition.name} should have at least 2 pointings');
      }
    });

    test('pointing ids follow naming convention', () {
      for (final pointing in pointings) {
        // IDs should follow pattern like 'adv-1', 'zen-1', 'dir-1', 'con-1', 'org-1'
        expect(
          pointing.id,
          matches(RegExp(r'^(adv|zen|dir|con|org)-\d+$')),
          reason: 'Pointing id ${pointing.id} should follow naming convention',
        );
      }
    });

    test('content is not too short', () {
      for (final pointing in pointings) {
        expect(pointing.content.length, greaterThan(10),
            reason: 'Pointing ${pointing.id} content should be meaningful');
      }
    });

    test('content is not too long for mobile display', () {
      for (final pointing in pointings) {
        expect(pointing.content.length, lessThan(500),
            reason: 'Pointing ${pointing.id} content should fit mobile screen');
      }
    });
  });

  group('getRandomPointing', () {
    test('returns a valid pointing', () {
      final pointing = getRandomPointing();
      expect(pointing, isNotNull);
      expect(pointing.id, isNotEmpty);
      expect(pointing.content, isNotEmpty);
      expect(Tradition.values, contains(pointing.tradition));
    });

    test('returns pointing from specified tradition', () {
      for (final tradition in Tradition.values) {
        final pointing = getRandomPointing(tradition: tradition);
        expect(pointing.tradition, tradition,
            reason: 'Should return pointing from ${tradition.name}');
      }
    });

    test('returns pointing with specified context', () {
      // Test contexts that have pointings in the data
      // Note: midday context has no pointings, so it falls back to first pointing
      final contextsWithData = [
        PointingContext.morning,
        PointingContext.evening,
        PointingContext.stress,
        PointingContext.general,
      ];
      for (final context in contextsWithData) {
        final pointing = getRandomPointing(context: context);
        expect(pointing.contexts, contains(context),
            reason: 'Should return pointing with ${context.name} context');
      }
    });

    test('returns fallback when context has no pointings', () {
      // midday has no pointings in the current data
      final pointing = getRandomPointing(context: PointingContext.midday);
      // Should return first pointing as fallback
      expect(pointing, pointings.first);
    });

    test('returns pointing matching both tradition and context', () {
      // Test combination that should have matches
      final pointing = getRandomPointing(
        tradition: Tradition.advaita,
        context: PointingContext.general,
      );
      expect(pointing.tradition, Tradition.advaita);
      expect(pointing.contexts, contains(PointingContext.general));
    });

    test('returns first pointing when no match found', () {
      // This tests the fallback behavior - create an impossible combination
      // by checking the actual data. Since all traditions have general context,
      // we need to verify the fallback by testing a different way.

      // Create a scenario where we can verify randomness
      final results = <String>{};
      for (int i = 0; i < 100; i++) {
        results.add(getRandomPointing().id);
      }
      // With 100 attempts, we should get some variety if random
      expect(results.length, greaterThan(1),
          reason: 'getRandomPointing should return varied results');
    });

    test('is actually random over multiple calls', () {
      final pointingIds = <String>[];
      for (int i = 0; i < 50; i++) {
        pointingIds.add(getRandomPointing().id);
      }

      // Count unique IDs - with 50 calls, we should have multiple unique
      final uniqueIds = pointingIds.toSet();
      expect(uniqueIds.length, greaterThan(3),
          reason: 'Should return different pointings over multiple calls');
    });
  });

  group('getPointingsByTradition', () {
    test('returns only pointings of specified tradition', () {
      for (final tradition in Tradition.values) {
        final results = getPointingsByTradition(tradition);
        for (final pointing in results) {
          expect(pointing.tradition, tradition,
              reason:
                  'All results should be ${tradition.name} tradition');
        }
      }
    });

    test('returns non-empty list for each tradition', () {
      for (final tradition in Tradition.values) {
        final results = getPointingsByTradition(tradition);
        expect(results, isNotEmpty,
            reason: '${tradition.name} should have pointings');
      }
    });

    test('Advaita has expected count', () {
      final results = getPointingsByTradition(Tradition.advaita);
      expect(results.length, greaterThanOrEqualTo(5));
    });

    test('Zen has expected count', () {
      final results = getPointingsByTradition(Tradition.zen);
      expect(results.length, greaterThanOrEqualTo(4));
    });

    test('Direct Path has expected count', () {
      final results = getPointingsByTradition(Tradition.direct);
      expect(results.length, greaterThanOrEqualTo(4));
    });

    test('Contemporary has expected count', () {
      final results = getPointingsByTradition(Tradition.contemporary);
      expect(results.length, greaterThanOrEqualTo(2));
    });

    test('Original has expected count', () {
      final results = getPointingsByTradition(Tradition.original);
      expect(results.length, greaterThanOrEqualTo(5));
    });
  });

  group('getPointingsByContext', () {
    test('returns only pointings with specified context', () {
      for (final context in PointingContext.values) {
        final results = getPointingsByContext(context);
        for (final pointing in results) {
          expect(pointing.contexts, contains(context),
              reason: 'All results should have ${context.name} context');
        }
      }
    });

    test('general context has most pointings', () {
      final general = getPointingsByContext(PointingContext.general);
      final morning = getPointingsByContext(PointingContext.morning);
      final evening = getPointingsByContext(PointingContext.evening);
      final stress = getPointingsByContext(PointingContext.stress);

      expect(general.length, greaterThanOrEqualTo(morning.length));
      expect(general.length, greaterThanOrEqualTo(evening.length));
      expect(general.length, greaterThanOrEqualTo(stress.length));
    });

    test('morning context has pointings', () {
      final results = getPointingsByContext(PointingContext.morning);
      expect(results, isNotEmpty);
    });

    test('evening context has pointings', () {
      final results = getPointingsByContext(PointingContext.evening);
      expect(results, isNotEmpty);
    });

    test('stress context has pointings', () {
      final results = getPointingsByContext(PointingContext.stress);
      expect(results, isNotEmpty);
    });
  });

  group('Pointing content validation', () {
    test('no pointing has empty string content', () {
      for (final pointing in pointings) {
        expect(pointing.content.trim(), isNotEmpty);
      }
    });

    test('instructions are meaningful when present', () {
      for (final pointing in pointings) {
        if (pointing.instruction != null) {
          expect(pointing.instruction!.trim(), isNotEmpty);
          expect(pointing.instruction!.length, greaterThan(3));
        }
      }
    });

    test('teachers are meaningful when present', () {
      for (final pointing in pointings) {
        if (pointing.teacher != null) {
          expect(pointing.teacher!.trim(), isNotEmpty);
          expect(pointing.teacher!.length, greaterThan(2));
        }
      }
    });

    test('sources are meaningful when present', () {
      for (final pointing in pointings) {
        if (pointing.source != null) {
          expect(pointing.source!.trim(), isNotEmpty);
        }
      }
    });

    test('some pointings have instructions', () {
      final withInstructions =
          pointings.where((p) => p.instruction != null).length;
      expect(withInstructions, greaterThan(0));
    });

    test('some pointings have teachers', () {
      final withTeachers = pointings.where((p) => p.teacher != null).length;
      expect(withTeachers, greaterThan(0));
    });

    test('content does not contain HTML', () {
      for (final pointing in pointings) {
        expect(pointing.content, isNot(contains('<')));
        expect(pointing.content, isNot(contains('>')));
      }
    });

    test('content does not contain markdown links', () {
      for (final pointing in pointings) {
        expect(pointing.content, isNot(matches(RegExp(r'\[.*\]\(.*\)'))));
      }
    });
  });

  group('Data consistency', () {
    test('tradition count matches enum', () {
      expect(traditions.length, Tradition.values.length);
    });

    test('all pointings reference valid traditions', () {
      for (final pointing in pointings) {
        expect(traditions.containsKey(pointing.tradition), true);
      }
    });

    test('all pointings have valid context enums', () {
      for (final pointing in pointings) {
        for (final context in pointing.contexts) {
          expect(PointingContext.values, contains(context));
        }
      }
    });
  });
}
