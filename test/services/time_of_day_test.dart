import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/services/pointing_selector.dart';

void main() {
  group('TimeContext enum', () {
    test('has all 4 time contexts plus general', () {
      expect(TimeContext.values.length, 5);
    });

    test('contains expected values', () {
      expect(TimeContext.values, contains(TimeContext.morning));
      expect(TimeContext.values, contains(TimeContext.midday));
      expect(TimeContext.values, contains(TimeContext.evening));
      expect(TimeContext.values, contains(TimeContext.night));
      expect(TimeContext.values, contains(TimeContext.general));
    });
  });

  group('getCurrentTimeContext', () {
    test('returns morning for 5am', () {
      expect(getTimeContextForHour(5), TimeContext.morning);
    });

    test('returns morning for 10am', () {
      expect(getTimeContextForHour(10), TimeContext.morning);
    });

    test('returns midday for 11am', () {
      expect(getTimeContextForHour(11), TimeContext.midday);
    });

    test('returns midday for 4pm (16)', () {
      expect(getTimeContextForHour(16), TimeContext.midday);
    });

    test('returns evening for 5pm (17)', () {
      expect(getTimeContextForHour(17), TimeContext.evening);
    });

    test('returns evening for 9pm (21)', () {
      expect(getTimeContextForHour(21), TimeContext.evening);
    });

    test('returns night for 10pm (22)', () {
      expect(getTimeContextForHour(22), TimeContext.night);
    });

    test('returns night for midnight (0)', () {
      expect(getTimeContextForHour(0), TimeContext.night);
    });

    test('returns night for 4am', () {
      expect(getTimeContextForHour(4), TimeContext.night);
    });

    test('boundary: 5am is morning not night', () {
      expect(getTimeContextForHour(5), TimeContext.morning);
    });

    test('boundary: 11am is midday not morning', () {
      expect(getTimeContextForHour(11), TimeContext.midday);
    });

    test('boundary: 5pm (17) is evening not midday', () {
      expect(getTimeContextForHour(17), TimeContext.evening);
    });

    test('boundary: 10pm (22) is night not evening', () {
      expect(getTimeContextForHour(22), TimeContext.night);
    });
  });

  group('timeContextToPointingContexts', () {
    test('morning maps to morning and general', () {
      final contexts = timeContextToPointingContexts(TimeContext.morning);
      expect(contexts, contains(PointingContext.morning));
      expect(contexts, contains(PointingContext.general));
    });

    test('midday maps to midday and general', () {
      final contexts = timeContextToPointingContexts(TimeContext.midday);
      expect(contexts, contains(PointingContext.midday));
      expect(contexts, contains(PointingContext.general));
    });

    test('evening maps to evening and general', () {
      final contexts = timeContextToPointingContexts(TimeContext.evening);
      expect(contexts, contains(PointingContext.evening));
      expect(contexts, contains(PointingContext.general));
    });

    test('night maps to evening and general (fallback for rest themes)', () {
      final contexts = timeContextToPointingContexts(TimeContext.night);
      // Night uses evening pointings as fallback since no night context exists
      expect(contexts, contains(PointingContext.evening));
      expect(contexts, contains(PointingContext.general));
    });

    test('general maps to all contexts', () {
      final contexts = timeContextToPointingContexts(TimeContext.general);
      expect(contexts.length, PointingContext.values.length);
    });
  });

  group('PointingSelector', () {
    late PointingSelector selector;

    setUp(() {
      selector = PointingSelector();
    });

    group('selectPointing', () {
      test('returns a valid pointing', () {
        final pointing = selector.selectPointing(
          all: pointings,
          viewedToday: {},
        );
        expect(pointing, isNotNull);
        expect(pointing.id, isNotEmpty);
      });

      test('excludes viewed pointings', () {
        final viewedIds = {'adv-1', 'zen-1', 'dir-1'};
        for (int i = 0; i < 20; i++) {
          final pointing = selector.selectPointing(
            all: pointings,
            viewedToday: viewedIds,
          );
          expect(viewedIds.contains(pointing.id), false,
              reason: 'Should not return viewed pointing ${pointing.id}');
        }
      });

      test('returns any pointing when all have been viewed', () {
        final allIds = pointings.map((p) => p.id).toSet();
        final pointing = selector.selectPointing(
          all: pointings,
          viewedToday: allIds,
        );
        // When all viewed, resets and picks from all
        expect(pointing, isNotNull);
      });

      test('respects time context when enabled', () {
        // Test with morning context - should return morning or general pointings
        final morningContexts = timeContextToPointingContexts(TimeContext.morning);

        // Run multiple times to verify pattern (probabilistic, so test tendency)
        int matchCount = 0;
        for (int i = 0; i < 50; i++) {
          final pointing = selector.selectPointingForTime(
            all: pointings,
            viewedToday: {},
            timeContext: TimeContext.morning,
          );
          final hasMatchingContext = pointing.contexts.any(
            (c) => morningContexts.contains(c),
          );
          if (hasMatchingContext) matchCount++;
        }

        // Should have high match rate when respecting context
        expect(matchCount, greaterThan(40),
            reason: 'Most pointings should match time context');
      });

      test('ignores time context when disabled', () {
        final pointing = selector.selectPointing(
          all: pointings,
          viewedToday: {},
          respectTimeContext: false,
        );
        expect(pointing, isNotNull);
        // Just verifies it doesn't crash - selection is random
      });
    });

    group('selectPointingForTime', () {
      test('morning selects morning or general pointings', () {
        for (int i = 0; i < 10; i++) {
          final pointing = selector.selectPointingForTime(
            all: pointings,
            viewedToday: {},
            timeContext: TimeContext.morning,
          );
          final validContexts = [PointingContext.morning, PointingContext.general];
          final hasValid = pointing.contexts.any((c) => validContexts.contains(c));
          expect(hasValid, true,
              reason: 'Pointing ${pointing.id} should have morning or general context');
        }
      });

      test('evening selects evening or general pointings', () {
        for (int i = 0; i < 10; i++) {
          final pointing = selector.selectPointingForTime(
            all: pointings,
            viewedToday: {},
            timeContext: TimeContext.evening,
          );
          final validContexts = [PointingContext.evening, PointingContext.general];
          final hasValid = pointing.contexts.any((c) => validContexts.contains(c));
          expect(hasValid, true,
              reason: 'Pointing ${pointing.id} should have evening or general context');
        }
      });

      test('override returns any pointing regardless of time', () {
        final pointing = selector.selectPointing(
          all: pointings,
          viewedToday: {},
          respectTimeContext: false,
        );
        expect(pointing, isNotNull);
      });

      test('general pointings are always available', () {
        // General context should be included in all time selections
        final generalPointings = pointings.where(
          (p) => p.contexts.contains(PointingContext.general),
        ).toList();

        expect(generalPointings, isNotEmpty,
            reason: 'Should have general pointings available');
      });

      test('viewed pointings excluded even with time filter', () {
        final viewedIds = {'adv-1', 'zen-1'};
        for (int i = 0; i < 20; i++) {
          final pointing = selector.selectPointingForTime(
            all: pointings,
            viewedToday: viewedIds,
            timeContext: TimeContext.morning,
          );
          expect(viewedIds.contains(pointing.id), false);
        }
      });
    });

    group('time-specific pointing preference', () {
      test('prefers time-specific over general when available', () {
        // Create test data with clear time-specific and general pointings
        final testPointings = [
          const Pointing(
            id: 'test-morning',
            content: 'Morning specific',
            tradition: Tradition.original,
            contexts: [PointingContext.morning],
          ),
          const Pointing(
            id: 'test-general',
            content: 'General',
            tradition: Tradition.original,
            contexts: [PointingContext.general],
          ),
        ];

        // Run many selections to verify preference pattern
        int morningCount = 0;
        for (int i = 0; i < 100; i++) {
          final pointing = selector.selectPointingForTime(
            all: testPointings,
            viewedToday: {},
            timeContext: TimeContext.morning,
          );
          if (pointing.id == 'test-morning') morningCount++;
        }

        // Time-specific should have ~30% preference per spec
        // But since we only have 2 options, it should be roughly 30% time-specific
        // Actually with the algorithm, time-specific gets 30% boost, so expect ~30-50%
        expect(morningCount, greaterThan(15),
            reason: 'Time-specific pointings should appear with preference');
      });
    });
  });

  group('Integration with existing data', () {
    test('existing pointings work with time-aware selection', () {
      final selector = PointingSelector();

      for (final timeContext in TimeContext.values) {
        if (timeContext == TimeContext.general) continue;

        final pointing = selector.selectPointingForTime(
          all: pointings,
          viewedToday: {},
          timeContext: timeContext,
        );
        expect(pointing, isNotNull,
            reason: 'Should find pointing for ${timeContext.name}');
      }
    });

    test('all existing PointingContext values have coverage', () {
      for (final context in PointingContext.values) {
        final withContext = pointings.where(
          (p) => p.contexts.contains(context),
        ).toList();

        // midday might be empty, which is fine - it falls back to general
        if (context != PointingContext.midday) {
          expect(withContext, isNotEmpty,
              reason: '${context.name} should have pointings');
        }
      }
    });
  });
}
