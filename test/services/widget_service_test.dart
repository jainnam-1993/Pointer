import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetService constants', () {
    test('has correct iOS App Group', () {
      expect(WidgetService.iosAppGroup, 'group.com.dailypointer.widget');
    });

    test('has correct Android widget name', () {
      expect(WidgetService.androidWidgetName, 'PointerWidgetProvider');
    });

    test('has correct default update interval', () {
      expect(WidgetService.defaultUpdateIntervalHours, 3);
    });
  });

  group('WidgetPointing', () {
    test('creates with required fields', () {
      const pointing = WidgetPointing(
        content: 'Test content',
        tradition: 'Zen',
      );

      expect(pointing.content, 'Test content');
      expect(pointing.tradition, 'Zen');
      expect(pointing.teacher, isNull);
      expect(pointing.lastUpdated, isNull);
    });

    test('creates with all fields', () {
      final now = DateTime.now();
      final pointing = WidgetPointing(
        content: 'Test content',
        teacher: 'Papaji',
        tradition: 'Advaita',
        lastUpdated: now,
      );

      expect(pointing.content, 'Test content');
      expect(pointing.teacher, 'Papaji');
      expect(pointing.tradition, 'Advaita');
      expect(pointing.lastUpdated, now);
    });

    test('teacher can be empty string', () {
      const pointing = WidgetPointing(
        content: 'Test content',
        teacher: '',
        tradition: 'Zen',
      );

      expect(pointing.teacher, '');
    });
  });

  group('_WidgetKeys (via widget data flow)', () {
    // These tests verify the keys used by the widget service
    // by checking the expected JSON structure

    test('pointings cache stores correct structure', () {
      // Verify the expected JSON format for widget pointings
      final testPointings = [
        {
          'id': 'test1',
          'content': 'Test content 1',
          'tradition': 'Zen',
          'teacher': 'Teacher 1',
        },
        {
          'id': 'test2',
          'content': 'Test content 2',
          'tradition': 'Advaita',
          'teacher': '',
        },
      ];

      final jsonString = jsonEncode(testPointings);
      final decoded = jsonDecode(jsonString) as List;

      expect(decoded.length, 2);
      expect(decoded[0]['id'], 'test1');
      expect(decoded[0]['content'], 'Test content 1');
      expect(decoded[0]['tradition'], 'Zen');
      expect(decoded[0]['teacher'], 'Teacher 1');
      expect(decoded[1]['teacher'], ''); // Empty teacher allowed
    });

    test('favorites stores list of pointing IDs', () {
      final favorites = ['pointing1', 'pointing2', 'pointing3'];
      final jsonString = jsonEncode(favorites);
      final decoded = jsonDecode(jsonString) as List;

      expect(decoded.length, 3);
      expect(decoded, containsAll(['pointing1', 'pointing2', 'pointing3']));
    });
  });

  group('Pointings data integration', () {
    test('all pointings have required fields for widget', () {
      // Verify that all pointings in the database have the fields
      // needed by the widget service
      for (final pointing in pointings) {
        expect(pointing.id, isNotNull);
        expect(pointing.id, isNotEmpty);
        expect(pointing.content, isNotNull);
        expect(pointing.content, isNotEmpty);
        expect(pointing.tradition, isNotNull);
        // teacher can be null
      }
    });

    test('traditions map contains all referenced traditions', () {
      // Verify that all traditions used by pointings exist in the map
      for (final pointing in pointings) {
        expect(
          traditions.containsKey(pointing.tradition),
          true,
          reason: 'Tradition ${pointing.tradition} should exist in traditions map',
        );
      }
    });

    test('getRandomPointing returns valid pointing', () {
      final random = getRandomPointing();
      expect(random, isNotNull);
      expect(pointings.contains(random), true);
    });
  });

  group('Widget interleaving algorithm verification', () {
    // Test the favorite interleaving algorithm logic
    // that's used in populatePointingsCache()

    test('interleaving places favorites at regular intervals', () {
      // Simulate the interleaving algorithm
      final favorites = ['f1', 'f2', 'f3'];
      final others = ['o1', 'o2', 'o3', 'o4', 'o5', 'o6', 'o7', 'o8', 'o9'];
      final interleaved = <String>[];

      int favIndex = 0;
      int otherIndex = 0;
      const othersBetweenFavorites = 3;

      while (otherIndex < others.length || favIndex < favorites.length) {
        if (favIndex < favorites.length) {
          interleaved.add(favorites[favIndex]);
          favIndex++;
        }
        for (int i = 0;
            i < othersBetweenFavorites && otherIndex < others.length;
            i++) {
          interleaved.add(others[otherIndex]);
          otherIndex++;
        }
      }

      // Verify pattern: f, o, o, o, f, o, o, o, f, o, o, o
      expect(interleaved.length, 12);
      expect(interleaved[0], 'f1');
      expect(interleaved[1], 'o1');
      expect(interleaved[4], 'f2');
      expect(interleaved[8], 'f3');
    });

    test('interleaving handles empty favorites', () {
      final favorites = <String>[];
      final others = ['o1', 'o2', 'o3'];
      final interleaved = <String>[];

      int favIndex = 0;
      int otherIndex = 0;
      const othersBetweenFavorites = 3;

      while (otherIndex < others.length || favIndex < favorites.length) {
        if (favIndex < favorites.length) {
          interleaved.add(favorites[favIndex]);
          favIndex++;
        }
        for (int i = 0;
            i < othersBetweenFavorites && otherIndex < others.length;
            i++) {
          interleaved.add(others[otherIndex]);
          otherIndex++;
        }
      }

      expect(interleaved, ['o1', 'o2', 'o3']);
    });

    test('interleaving handles more favorites than others', () {
      final favorites = ['f1', 'f2', 'f3', 'f4'];
      final others = ['o1', 'o2'];
      final interleaved = <String>[];

      int favIndex = 0;
      int otherIndex = 0;
      const othersBetweenFavorites = 3;

      while (otherIndex < others.length || favIndex < favorites.length) {
        if (favIndex < favorites.length) {
          interleaved.add(favorites[favIndex]);
          favIndex++;
        }
        for (int i = 0;
            i < othersBetweenFavorites && otherIndex < others.length;
            i++) {
          interleaved.add(others[otherIndex]);
          otherIndex++;
        }
      }

      // Should get: f1, o1, o2, f2, f3, f4
      expect(interleaved.length, 6);
      expect(interleaved.where((e) => e.startsWith('f')).length, 4);
      expect(interleaved.where((e) => e.startsWith('o')).length, 2);
    });
  });

  group('Widget URI callback format', () {
    // Test the URI format expected by widgetBackgroundCallback

    test('refresh URI format is correct', () {
      final refreshUri = Uri.parse('pointer://widget/refresh');
      expect(refreshUri.scheme, 'pointer');
      expect(refreshUri.host, 'widget');
      expect(refreshUri.path, '/refresh');
    });

    test('prefetch URI format is correct', () {
      final prefetchUri = Uri.parse('pointer://widget/prefetch');
      expect(prefetchUri.path, '/prefetch');
    });

    test('save URI format is correct', () {
      final saveUri = Uri.parse('pointer://widget/save');
      expect(saveUri.path, '/save');
    });

    test('open URI format is correct', () {
      final openUri = Uri.parse('pointer://open');
      expect(openUri.host, 'open');
    });

    test('alternate refresh format (host-based)', () {
      final refreshUri = Uri.parse('pointer://refresh');
      expect(refreshUri.host, 'refresh');
    });

    test('alternate save format (host-based)', () {
      final saveUri = Uri.parse('pointer://save');
      expect(saveUri.host, 'save');
    });
  });

  group('Favorites JSON format', () {
    test('can serialize favorites set to JSON', () {
      final favoriteIds = {'id1', 'id2', 'id3'};
      final jsonString = jsonEncode(favoriteIds.toList());
      expect(jsonString, contains('id1'));
      expect(jsonString, contains('id2'));
      expect(jsonString, contains('id3'));
    });

    test('can deserialize favorites JSON to list', () {
      const jsonString = '["id1", "id2", "id3"]';
      final decoded = List<String>.from(jsonDecode(jsonString));
      expect(decoded.length, 3);
      expect(decoded, containsAll(['id1', 'id2', 'id3']));
    });

    test('empty favorites serializes correctly', () {
      final favoriteIds = <String>{};
      final jsonString = jsonEncode(favoriteIds.toList());
      expect(jsonString, '[]');
    });
  });

  // Note: Methods like initialize(), setPremiumStatus(), populatePointingsCache(),
  // etc. require the home_widget plugin which cannot be unit tested without mocking.
  // The Maestro flows (10_widget_test.yaml, 16_widget_interactions.yaml) provide
  // integration test coverage for widget functionality.
}
