import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/services/pointing_selector.dart';

void main() {
  group('TimeContext enum', () {
    test('defines all time contexts', () {
      expect(TimeContext.values, hasLength(5));
      expect(TimeContext.values, contains(TimeContext.morning));
      expect(TimeContext.values, contains(TimeContext.midday));
      expect(TimeContext.values, contains(TimeContext.evening));
      expect(TimeContext.values, contains(TimeContext.night));
      expect(TimeContext.values, contains(TimeContext.general));
    });
  });

  group('getTimeContextForHour', () {
    test('returns morning for hours 5-10', () {
      expect(getTimeContextForHour(5), TimeContext.morning);
      expect(getTimeContextForHour(7), TimeContext.morning);
      expect(getTimeContextForHour(10), TimeContext.morning);
    });

    test('returns midday for hours 11-16', () {
      expect(getTimeContextForHour(11), TimeContext.midday);
      expect(getTimeContextForHour(14), TimeContext.midday);
      expect(getTimeContextForHour(16), TimeContext.midday);
    });

    test('returns evening for hours 17-21', () {
      expect(getTimeContextForHour(17), TimeContext.evening);
      expect(getTimeContextForHour(19), TimeContext.evening);
      expect(getTimeContextForHour(21), TimeContext.evening);
    });

    test('returns night for hours 22-4', () {
      expect(getTimeContextForHour(22), TimeContext.night);
      expect(getTimeContextForHour(23), TimeContext.night);
      expect(getTimeContextForHour(0), TimeContext.night);
      expect(getTimeContextForHour(2), TimeContext.night);
      expect(getTimeContextForHour(4), TimeContext.night);
    });

    test('handles boundary hours correctly', () {
      expect(getTimeContextForHour(4), TimeContext.night);
      expect(getTimeContextForHour(5), TimeContext.morning);
      expect(getTimeContextForHour(10), TimeContext.morning);
      expect(getTimeContextForHour(11), TimeContext.midday);
      expect(getTimeContextForHour(16), TimeContext.midday);
      expect(getTimeContextForHour(17), TimeContext.evening);
      expect(getTimeContextForHour(21), TimeContext.evening);
      expect(getTimeContextForHour(22), TimeContext.night);
    });
  });

  group('timeContextToPointingContexts', () {
    test('morning returns morning and general contexts', () {
      final contexts = timeContextToPointingContexts(TimeContext.morning);
      expect(contexts, hasLength(2));
      expect(contexts, contains(PointingContext.morning));
      expect(contexts, contains(PointingContext.general));
    });

    test('midday returns midday and general contexts', () {
      final contexts = timeContextToPointingContexts(TimeContext.midday);
      expect(contexts, hasLength(2));
      expect(contexts, contains(PointingContext.midday));
      expect(contexts, contains(PointingContext.general));
    });

    test('evening returns evening and general contexts', () {
      final contexts = timeContextToPointingContexts(TimeContext.evening);
      expect(contexts, hasLength(2));
      expect(contexts, contains(PointingContext.evening));
      expect(contexts, contains(PointingContext.general));
    });

    test('night returns evening and general contexts (fallback)', () {
      final contexts = timeContextToPointingContexts(TimeContext.night);
      expect(contexts, hasLength(2));
      expect(contexts, contains(PointingContext.evening));
      expect(contexts, contains(PointingContext.general));
    });

    test('general returns all pointing contexts', () {
      final contexts = timeContextToPointingContexts(TimeContext.general);
      expect(contexts, hasLength(PointingContext.values.length));
      for (final context in PointingContext.values) {
        expect(contexts, contains(context));
      }
    });
  });

  group('PointingSelector', () {
    // Test data
    final testPointings = [
      const Pointing(
        id: 'test-1',
        content: 'Morning pointing',
        tradition: Tradition.advaita,
        contexts: [PointingContext.morning],
      ),
      const Pointing(
        id: 'test-2',
        content: 'Midday pointing',
        tradition: Tradition.zen,
        contexts: [PointingContext.midday],
      ),
      const Pointing(
        id: 'test-3',
        content: 'Evening pointing',
        tradition: Tradition.direct,
        contexts: [PointingContext.evening],
      ),
      const Pointing(
        id: 'test-4',
        content: 'General pointing',
        tradition: Tradition.contemporary,
        contexts: [PointingContext.general],
      ),
      const Pointing(
        id: 'test-5',
        content: 'Morning and general pointing',
        tradition: Tradition.advaita,
        contexts: [PointingContext.morning, PointingContext.general],
      ),
    ];

    group('selectPointing', () {
      test('returns a pointing from the list', () {
        final selector = PointingSelector(random: Random(42));
        final pointing = selector.selectPointing(
          all: testPointings,
          viewedToday: {},
          respectTimeContext: false,
        );

        expect(testPointings, contains(pointing));
      });

      test('excludes viewed pointings when possible', () {
        final selector = PointingSelector(random: Random(42));
        final viewedIds = {'test-1', 'test-2', 'test-3'};

        // Run multiple times to ensure consistency
        for (var i = 0; i < 10; i++) {
          final pointing = selector.selectPointing(
            all: testPointings,
            viewedToday: viewedIds,
            respectTimeContext: false,
          );

          expect(viewedIds, isNot(contains(pointing.id)));
        }
      });

      test('falls back to all pointings when all viewed', () {
        final selector = PointingSelector(random: Random(42));
        final allIds = testPointings.map((p) => p.id).toSet();

        final pointing = selector.selectPointing(
          all: testPointings,
          viewedToday: allIds,
          respectTimeContext: false,
        );

        expect(testPointings, contains(pointing));
      });

      test('uses seeded Random for deterministic selection', () {
        final selector1 = PointingSelector(random: Random(42));
        final selector2 = PointingSelector(random: Random(42));

        final pointing1 = selector1.selectPointing(
          all: testPointings,
          viewedToday: {},
          respectTimeContext: false,
        );

        final pointing2 = selector2.selectPointing(
          all: testPointings,
          viewedToday: {},
          respectTimeContext: false,
        );

        expect(pointing1.id, equals(pointing2.id));
      });

      test('returns different results with different seeds', () {
        final selector1 = PointingSelector(random: Random(42));
        final selector2 = PointingSelector(random: Random(123));

        final results1 = <String>{};
        final results2 = <String>{};

        // Collect multiple selections to ensure different distributions
        for (var i = 0; i < 20; i++) {
          final p1 = selector1.selectPointing(
            all: testPointings,
            viewedToday: {},
            respectTimeContext: false,
          );
          final p2 = selector2.selectPointing(
            all: testPointings,
            viewedToday: {},
            respectTimeContext: false,
          );
          results1.add(p1.id);
          results2.add(p2.id);
        }

        // Different seeds should produce different selections over time
        // (Though not guaranteed in every single call)
        expect(results1.length > 1 || results2.length > 1, isTrue);
      });
    });

    group('selectPointingForTime', () {
      test('filters by morning time context', () {
        final selector = PointingSelector(random: Random(42));

        // Run multiple times to check consistency
        for (var i = 0; i < 10; i++) {
          final pointing = selector.selectPointingForTime(
            all: testPointings,
            viewedToday: {},
            timeContext: TimeContext.morning,
          );

          // Should be morning or general pointing
          expect(
            pointing.contexts.any((c) =>
                c == PointingContext.morning || c == PointingContext.general),
            isTrue,
            reason: 'Pointing ${pointing.id} should have morning or general context',
          );
        }
      });

      test('filters by midday time context', () {
        final selector = PointingSelector(random: Random(42));

        for (var i = 0; i < 10; i++) {
          final pointing = selector.selectPointingForTime(
            all: testPointings,
            viewedToday: {},
            timeContext: TimeContext.midday,
          );

          expect(
            pointing.contexts.any((c) =>
                c == PointingContext.midday || c == PointingContext.general),
            isTrue,
            reason: 'Pointing ${pointing.id} should have midday or general context',
          );
        }
      });

      test('filters by evening time context', () {
        final selector = PointingSelector(random: Random(42));

        for (var i = 0; i < 10; i++) {
          final pointing = selector.selectPointingForTime(
            all: testPointings,
            viewedToday: {},
            timeContext: TimeContext.evening,
          );

          expect(
            pointing.contexts.any((c) =>
                c == PointingContext.evening || c == PointingContext.general),
            isTrue,
            reason: 'Pointing ${pointing.id} should have evening or general context',
          );
        }
      });

      test('night uses evening contexts as fallback', () {
        final selector = PointingSelector(random: Random(42));

        for (var i = 0; i < 10; i++) {
          final pointing = selector.selectPointingForTime(
            all: testPointings,
            viewedToday: {},
            timeContext: TimeContext.night,
          );

          expect(
            pointing.contexts.any((c) =>
                c == PointingContext.evening || c == PointingContext.general),
            isTrue,
            reason: 'Night pointing ${pointing.id} should use evening or general context',
          );
        }
      });

      test('falls back when no contextual matches', () {
        final morningOnlyPointings = [
          const Pointing(
            id: 'morning-only',
            content: 'Morning only',
            tradition: Tradition.advaita,
            contexts: [PointingContext.morning],
          ),
        ];

        final selector = PointingSelector(random: Random(42));

        // Request evening pointing when only morning available
        final pointing = selector.selectPointingForTime(
          all: morningOnlyPointings,
          viewedToday: {},
          timeContext: TimeContext.evening,
        );

        expect(pointing.id, equals('morning-only'));
      });

      test('excludes viewed pointings', () {
        final selector = PointingSelector(random: Random(42));
        final viewedIds = {'test-1'};

        for (var i = 0; i < 10; i++) {
          final pointing = selector.selectPointingForTime(
            all: testPointings,
            viewedToday: viewedIds,
            timeContext: TimeContext.morning,
          );

          expect(pointing.id, isNot(equals('test-1')));
        }
      });

      test('resets when all pointings viewed', () {
        final selector = PointingSelector(random: Random(42));
        final allIds = testPointings.map((p) => p.id).toSet();

        final pointing = selector.selectPointingForTime(
          all: testPointings,
          viewedToday: allIds,
          timeContext: TimeContext.morning,
        );

        expect(testPointings, contains(pointing));
      });

      test('general time context allows all pointings', () {
        final selector = PointingSelector(random: Random(42));
        final selectedIds = <String>{};

        // Run enough times to potentially see all pointings
        for (var i = 0; i < 100; i++) {
          final pointing = selector.selectPointingForTime(
            all: testPointings,
            viewedToday: {},
            timeContext: TimeContext.general,
          );
          selectedIds.add(pointing.id);
        }

        // With general context, all pointings should be selectable
        // (probabilistically, we should see multiple over 100 tries)
        expect(selectedIds.length, greaterThan(1));
      });

      test('respects time-specific preference probability', () {
        // Create test data with clear time-specific vs general split
        final morningPointings = [
          const Pointing(
            id: 'morning-specific',
            content: 'Morning specific',
            tradition: Tradition.advaita,
            contexts: [PointingContext.morning],
          ),
          const Pointing(
            id: 'general-1',
            content: 'General 1',
            tradition: Tradition.zen,
            contexts: [PointingContext.general],
          ),
          const Pointing(
            id: 'general-2',
            content: 'General 2',
            tradition: Tradition.direct,
            contexts: [PointingContext.general],
          ),
        ];

        final selector = PointingSelector(random: Random(42));
        var timeSpecificCount = 0;
        var generalCount = 0;

        // Run many iterations to check distribution
        for (var i = 0; i < 100; i++) {
          final pointing = selector.selectPointingForTime(
            all: morningPointings,
            viewedToday: {},
            timeContext: TimeContext.morning,
          );

          if (pointing.id == 'morning-specific') {
            timeSpecificCount++;
          } else {
            generalCount++;
          }
        }

        // Both time-specific and general pointings should be selected
        // (30% chance for time-specific means both should appear)
        expect(timeSpecificCount, greaterThan(0));
        expect(generalCount, greaterThan(0));
      });
    });
  });
}
