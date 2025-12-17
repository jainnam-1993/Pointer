import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/models/mood.dart';
import 'package:pointer/data/pointings.dart';

void main() {
  group('Mood enum', () {
    test('has exactly 8 mood values', () {
      expect(Mood.values.length, 8);
    });

    test('contains all expected mood values', () {
      expect(Mood.values, contains(Mood.peaceful));
      expect(Mood.values, contains(Mood.anxious));
      expect(Mood.values, contains(Mood.curious));
      expect(Mood.values, contains(Mood.restless));
      expect(Mood.values, contains(Mood.grateful));
      expect(Mood.values, contains(Mood.heavy));
      expect(Mood.values, contains(Mood.open));
      expect(Mood.values, contains(Mood.seeking));
    });
  });

  group('moodInfo map', () {
    test('contains entries for all mood values', () {
      for (final mood in Mood.values) {
        expect(moodInfo.containsKey(mood), true,
            reason: 'moodInfo should contain $mood');
      }
    });

    test('has exactly 8 entries', () {
      expect(moodInfo.length, 8);
    });
  });

  group('MoodInfo properties', () {
    test('peaceful has all required properties', () {
      final info = moodInfo[Mood.peaceful]!;
      expect(info.name, 'Peaceful');
      expect(info.emoji, '🧘');
      expect(info.description, 'Calm and centered');
      expect(info.icon, Icons.spa);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('anxious has all required properties', () {
      final info = moodInfo[Mood.anxious]!;
      expect(info.name, 'Anxious');
      expect(info.emoji, '😰');
      expect(info.description, 'Worried or stressed');
      expect(info.icon, Icons.storm);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('curious has all required properties', () {
      final info = moodInfo[Mood.curious]!;
      expect(info.name, 'Curious');
      expect(info.emoji, '🤔');
      expect(info.description, 'Open to inquiry');
      expect(info.icon, Icons.lightbulb_outline);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('restless has all required properties', () {
      final info = moodInfo[Mood.restless]!;
      expect(info.name, 'Restless');
      expect(info.emoji, '💨');
      expect(info.description, 'Unsettled energy');
      expect(info.icon, Icons.air);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('grateful has all required properties', () {
      final info = moodInfo[Mood.grateful]!;
      expect(info.name, 'Grateful');
      expect(info.emoji, '🙏');
      expect(info.description, 'Appreciative');
      expect(info.icon, Icons.favorite_outline);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('heavy has all required properties', () {
      final info = moodInfo[Mood.heavy]!;
      expect(info.name, 'Heavy');
      expect(info.emoji, '🌑');
      expect(info.description, 'Weighed down');
      expect(info.icon, Icons.cloud);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('open has all required properties', () {
      final info = moodInfo[Mood.open]!;
      expect(info.name, 'Open');
      expect(info.emoji, '✨');
      expect(info.description, 'Receptive');
      expect(info.icon, Icons.all_inclusive);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('seeking has all required properties', () {
      final info = moodInfo[Mood.seeking]!;
      expect(info.name, 'Seeking');
      expect(info.emoji, '🔍');
      expect(info.description, 'Looking for truth');
      expect(info.icon, Icons.explore);
      expect(info.matchingContexts, isNotEmpty);
    });

    test('all moods have non-null properties', () {
      for (final mood in Mood.values) {
        final info = moodInfo[mood]!;
        expect(info.name, isNotEmpty, reason: '$mood should have a name');
        expect(info.emoji, isNotEmpty, reason: '$mood should have an emoji');
        expect(info.description, isNotEmpty,
            reason: '$mood should have a description');
        expect(info.icon, isNotNull, reason: '$mood should have an icon');
        expect(info.matchingContexts, isNotEmpty,
            reason: '$mood should have matching contexts');
      }
    });

    test('all moods have unique names', () {
      final names = <String>{};
      for (final mood in Mood.values) {
        final info = moodInfo[mood]!;
        expect(names.add(info.name), true,
            reason: 'Mood name "${info.name}" is duplicated');
      }
      expect(names.length, Mood.values.length);
    });

    test('all moods have unique emojis', () {
      final emojis = <String>{};
      for (final mood in Mood.values) {
        final info = moodInfo[mood]!;
        expect(emojis.add(info.emoji), true,
            reason: 'Mood emoji "${info.emoji}" is duplicated');
      }
      expect(emojis.length, Mood.values.length);
    });
  });

  group('MoodInfo matchingContexts validation', () {
    // Valid PointingContext string values
    final validContexts = PointingContext.values.map((c) => c.name).toSet();

    test('peaceful has valid contexts', () {
      final info = moodInfo[Mood.peaceful]!;
      expect(info.matchingContexts, ['morning', 'general']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('anxious has valid contexts', () {
      final info = moodInfo[Mood.anxious]!;
      expect(info.matchingContexts, ['stress', 'general']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('curious has valid contexts', () {
      final info = moodInfo[Mood.curious]!;
      expect(info.matchingContexts, ['general', 'morning']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('restless has valid contexts', () {
      final info = moodInfo[Mood.restless]!;
      expect(info.matchingContexts, ['stress', 'evening']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('grateful has valid contexts', () {
      final info = moodInfo[Mood.grateful]!;
      expect(info.matchingContexts, ['morning', 'evening', 'general']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('heavy has valid contexts', () {
      final info = moodInfo[Mood.heavy]!;
      expect(info.matchingContexts, ['stress', 'evening']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('open has valid contexts', () {
      final info = moodInfo[Mood.open]!;
      expect(info.matchingContexts, ['morning', 'general']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('seeking has valid contexts', () {
      final info = moodInfo[Mood.seeking]!;
      expect(info.matchingContexts, ['general', 'midday']);
      for (final context in info.matchingContexts) {
        expect(validContexts.contains(context), true,
            reason: 'Context "$context" is not a valid PointingContext');
      }
    });

    test('all moods have only valid PointingContext values', () {
      for (final mood in Mood.values) {
        final info = moodInfo[mood]!;
        for (final context in info.matchingContexts) {
          expect(validContexts.contains(context), true,
              reason:
                  'Mood $mood has invalid context "$context". Valid contexts are: ${validContexts.join(", ")}');
        }
      }
    });

    test('all PointingContext values are used in at least one mood', () {
      final usedContexts = <String>{};
      for (final mood in Mood.values) {
        final info = moodInfo[mood]!;
        usedContexts.addAll(info.matchingContexts);
      }

      for (final context in PointingContext.values) {
        expect(usedContexts.contains(context.name), true,
            reason:
                'PointingContext.${context.name} is not used in any mood matching');
      }
    });
  });

  group('MoodInfo constructor', () {
    test('creates valid MoodInfo instance', () {
      const testInfo = MoodInfo(
        name: 'Test Mood',
        emoji: '🧪',
        description: 'A test mood',
        icon: Icons.science,
        matchingContexts: ['general'],
      );

      expect(testInfo.name, 'Test Mood');
      expect(testInfo.emoji, '🧪');
      expect(testInfo.description, 'A test mood');
      expect(testInfo.icon, Icons.science);
      expect(testInfo.matchingContexts, ['general']);
    });

    test('creates MoodInfo with multiple matching contexts', () {
      const testInfo = MoodInfo(
        name: 'Multi Context',
        emoji: '🌈',
        description: 'Multiple contexts',
        icon: Icons.view_module,
        matchingContexts: ['morning', 'evening', 'general'],
      );

      expect(testInfo.matchingContexts.length, 3);
      expect(testInfo.matchingContexts, contains('morning'));
      expect(testInfo.matchingContexts, contains('evening'));
      expect(testInfo.matchingContexts, contains('general'));
    });
  });
}
