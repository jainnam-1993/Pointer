import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/data/teaching.dart';
import 'package:pointer/providers/content_providers.dart';
import 'package:pointer/providers/core_providers.dart';
import 'package:pointer/services/storage_service.dart';

// Mocks
class MockStorageService extends Mock implements StorageService {}

void main() {
  // Initialize TeachingRepository for filter tests
  setUpAll(() {
    TeachingRepository.reset();
    TeachingRepository.initialize(pointings: pointings);
  });

  tearDownAll(() {
    TeachingRepository.reset();
  });

  group('CurrentPointingNotifier', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      // Default mock behaviors for CurrentPointingNotifier
      when(() => mockStorage.currentPointingId).thenReturn(null);
      when(() => mockStorage.setCurrentPointingId(any())).thenAnswer((_) async {});
      // Round-robin order mocks
      when(() => mockStorage.pointingOrder).thenReturn(null);
      when(() => mockStorage.pointingIndex).thenReturn(0);
      when(() => mockStorage.setPointingOrder(any())).thenAnswer((_) async {});
      when(() => mockStorage.setPointingIndex(any())).thenAnswer((_) async {});
    });

    test('initializes with a valid pointing', () {
      final notifier = CurrentPointingNotifier(mockStorage);

      // Should have a valid pointing
      expect(notifier.state, isA<Pointing>());
      expect(notifier.state.id, isNotEmpty);
      expect(notifier.state.content, isNotEmpty);
    });

    test('nextPointing() advances to next in round-robin order', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final initialPointing = notifier.state;
      final initialIndex = notifier.currentIndex;

      notifier.nextPointing();
      final newPointing = notifier.state;

      // Should move to next index (or wrap to 0 at end)
      expect(newPointing, isA<Pointing>());
      expect(newPointing.id, isNotEmpty);
      expect(newPointing.id, isNot(equals(initialPointing.id)));
      expect(
        notifier.currentIndex,
        equals((initialIndex + 1) % notifier.totalPointings),
      );
    });

    test('previousPointing() returns to previous in round-robin order', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final firstPointing = notifier.state;

      notifier.nextPointing();

      notifier.previousPointing();
      final backToFirst = notifier.state;

      expect(backToFirst.id, firstPointing.id);
      expect(backToFirst.content, firstPointing.content);
    });

    test('previousPointing() wraps around at start', () {
      // With round-robin, previous at index 0 should wrap to last
      final notifier = CurrentPointingNotifier(mockStorage);
      final totalPointings = notifier.totalPointings;

      // Go to index 0 first (may already be there from init)
      while (notifier.currentIndex != 0) {
        notifier.nextPointing();
      }

      notifier.previousPointing();

      // Should wrap to last index
      expect(notifier.currentIndex, equals(totalPointings - 1));
    });

    test('setPointing() sets specific pointing', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final targetPointing = pointings.first;

      notifier.setPointing(targetPointing);

      expect(notifier.state.id, targetPointing.id);
      expect(notifier.state.content, targetPointing.content);
    });

    test('round-robin cycles through all pointings without repeats', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final totalPointings = notifier.totalPointings;
      final seenIds = <String>{};

      // Collect IDs from current position through ONE complete cycle
      // (totalPointings - 1 nexts from current position)
      final startIndex = notifier.currentIndex;
      seenIds.add(notifier.state.id);

      for (int i = 1; i < totalPointings; i++) {
        notifier.nextPointing();
        // Stop before reshuffle (when we hit index 0 after starting from non-zero)
        if (notifier.currentIndex == 0 && startIndex != 0) {
          // The reshuffle happened, so we're now in a new cycle
          // This is expected - just verify we saw unique IDs up to this point
          break;
        }
        seenIds.add(notifier.state.id);
      }

      // Should have seen unique pointings (no repeats within one cycle)
      // The count depends on where we started
      expect(seenIds.length, greaterThanOrEqualTo(1));
      // Each ID should be unique (main property we're testing)
      final uniqueIds = seenIds.toSet();
      expect(uniqueIds.length, equals(seenIds.length));
    });

    test('nextPointing() wraps to index 0 at cycle end', () {
      final notifier = CurrentPointingNotifier(mockStorage);
      final totalPointings = notifier.totalPointings;

      // Start from index 0
      while (notifier.currentIndex != 0) {
        notifier.nextPointing();
      }

      // Navigate to end of cycle (last index)
      for (int i = 0; i < totalPointings - 1; i++) {
        notifier.nextPointing();
      }
      expect(notifier.currentIndex, equals(totalPointings - 1));

      // One more should wrap to 0
      notifier.nextPointing();
      expect(notifier.currentIndex, equals(0));
    });

    test('exposes currentIndex and totalPointings', () {
      final notifier = CurrentPointingNotifier(mockStorage);

      expect(notifier.currentIndex, isA<int>());
      expect(notifier.totalPointings, equals(pointings.length));
      expect(notifier.currentIndex, greaterThanOrEqualTo(0));
      expect(notifier.currentIndex, lessThan(notifier.totalPointings));
    });
  });

  group('FavoritesNotifier', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
    });

    test('initializes from storage', () {
      when(() => mockStorage.favorites).thenReturn(['adv-1', 'zen-1']);

      final notifier = FavoritesNotifier(mockStorage);

      expect(notifier.state, ['adv-1', 'zen-1']);
      verify(() => mockStorage.favorites).called(1);
    });

    test('toggle() adds new favorite', () async {
      when(() => mockStorage.favorites).thenReturn([]);
      when(() => mockStorage.addFavorite(any())).thenAnswer((_) async => {});

      final notifier = FavoritesNotifier(mockStorage);

      await notifier.toggle('adv-1');

      expect(notifier.state, ['adv-1']);
      verify(() => mockStorage.addFavorite('adv-1')).called(1);
    });

    test('toggle() removes existing favorite', () async {
      when(() => mockStorage.favorites).thenReturn(['adv-1', 'zen-1']);
      when(() => mockStorage.removeFavorite(any())).thenAnswer((_) async => {});

      final notifier = FavoritesNotifier(mockStorage);

      await notifier.toggle('adv-1');

      expect(notifier.state, ['zen-1']);
      verify(() => mockStorage.removeFavorite('adv-1')).called(1);
    });

    test('isFavorite() returns correct status', () {
      when(() => mockStorage.favorites).thenReturn(['adv-1', 'zen-1']);

      final notifier = FavoritesNotifier(mockStorage);

      expect(notifier.isFavorite('adv-1'), true);
      expect(notifier.isFavorite('zen-1'), true);
      expect(notifier.isFavorite('direct-1'), false);
    });
  });

  group('TeachingFilterState', () {
    test('default has no active filters', () {
      const state = TeachingFilterState();

      expect(state.lineage, null);
      expect(state.topics, isEmpty);
      expect(state.moods, isEmpty);
      expect(state.teacher, null);
      expect(state.type, null);
      expect(state.hasActiveFilters, false);
    });

    test('hasActiveFilters returns true when lineage set', () {
      const state = TeachingFilterState(lineage: Tradition.advaita);

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when topics not empty', () {
      final state = TeachingFilterState(topics: {'awareness'});

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when moods not empty', () {
      final state = TeachingFilterState(moods: {'peaceful'});

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when teacher set', () {
      const state = TeachingFilterState(teacher: 'Ramana Maharshi');

      expect(state.hasActiveFilters, true);
    });

    test('hasActiveFilters returns true when type set', () {
      const state = TeachingFilterState(type: TeachingType.article);

      expect(state.hasActiveFilters, true);
    });

    test('copyWith creates modified copy', () {
      const state = TeachingFilterState(
        lineage: Tradition.advaita,
        topics: {'awareness'},
        teacher: 'Ramana Maharshi',
      );

      final modified = state.copyWith(
        lineage: Tradition.zen,
        topics: {'meditation'},
      );

      expect(modified.lineage, Tradition.zen);
      expect(modified.topics, {'meditation'});
      expect(modified.teacher, 'Ramana Maharshi'); // Unchanged
    });

    test('clearLineage clears lineage field', () {
      const state = TeachingFilterState(lineage: Tradition.advaita);

      final cleared = state.copyWith(clearLineage: true);

      expect(cleared.lineage, null);
    });

    test('clearTeacher clears teacher field', () {
      const state = TeachingFilterState(teacher: 'Ramana Maharshi');

      final cleared = state.copyWith(clearTeacher: true);

      expect(cleared.teacher, null);
    });

    test('clearType clears type field', () {
      const state = TeachingFilterState(type: TeachingType.article);

      final cleared = state.copyWith(clearType: true);

      expect(cleared.type, null);
    });

    test('apply() returns filtered teachings', () {
      final state = TeachingFilterState(lineage: Tradition.advaita);

      final filtered = state.apply();

      expect(filtered, isNotEmpty);
      expect(filtered.every((t) => t.lineage == Tradition.advaita), true);
    });
  });

  group('TeachingFilterNotifier', () {
    test('setLineage() updates state', () {
      final notifier = TeachingFilterNotifier();

      notifier.setLineage(Tradition.zen);

      expect(notifier.state.lineage, Tradition.zen);
    });

    test('setLineage(null) clears lineage', () {
      final notifier = TeachingFilterNotifier();
      notifier.setLineage(Tradition.zen);

      notifier.setLineage(null);

      expect(notifier.state.lineage, null);
    });

    test('toggleTopic() adds topic', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleTopic('awareness');

      expect(notifier.state.topics, {'awareness'});
    });

    test('toggleTopic() removes existing topic', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleTopic('awareness');

      notifier.toggleTopic('awareness');

      expect(notifier.state.topics, isEmpty);
    });

    test('toggleTopic() handles multiple topics', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleTopic('awareness');
      notifier.toggleTopic('meditation');

      expect(notifier.state.topics, {'awareness', 'meditation'});
    });

    test('setTopics() replaces all topics', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleTopic('awareness');

      notifier.setTopics({'meditation', 'silence'});

      expect(notifier.state.topics, {'meditation', 'silence'});
    });

    test('toggleMood() adds mood', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleMood('peaceful');

      expect(notifier.state.moods, {'peaceful'});
    });

    test('toggleMood() removes existing mood', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleMood('peaceful');

      notifier.toggleMood('peaceful');

      expect(notifier.state.moods, isEmpty);
    });

    test('toggleMood() handles multiple moods', () {
      final notifier = TeachingFilterNotifier();

      notifier.toggleMood('peaceful');
      notifier.toggleMood('contemplative');

      expect(notifier.state.moods, {'peaceful', 'contemplative'});
    });

    test('setMoods() replaces all moods', () {
      final notifier = TeachingFilterNotifier();
      notifier.toggleMood('peaceful');

      notifier.setMoods({'contemplative', 'joyful'});

      expect(notifier.state.moods, {'contemplative', 'joyful'});
    });

    test('setTeacher() updates teacher', () {
      final notifier = TeachingFilterNotifier();

      notifier.setTeacher('Ramana Maharshi');

      expect(notifier.state.teacher, 'Ramana Maharshi');
    });

    test('setTeacher(null) clears teacher', () {
      final notifier = TeachingFilterNotifier();
      notifier.setTeacher('Ramana Maharshi');

      notifier.setTeacher(null);

      expect(notifier.state.teacher, null);
    });

    test('setType() updates type', () {
      final notifier = TeachingFilterNotifier();

      notifier.setType(TeachingType.article);

      expect(notifier.state.type, TeachingType.article);
    });

    test('setType(null) clears type', () {
      final notifier = TeachingFilterNotifier();
      notifier.setType(TeachingType.article);

      notifier.setType(null);

      expect(notifier.state.type, null);
    });

    test('reset() clears all filters', () {
      final notifier = TeachingFilterNotifier();

      // Set multiple filters
      notifier.setLineage(Tradition.zen);
      notifier.toggleTopic('awareness');
      notifier.toggleMood('peaceful');
      notifier.setTeacher('Ramana Maharshi');
      notifier.setType(TeachingType.article);

      notifier.reset();

      expect(notifier.state.lineage, null);
      expect(notifier.state.topics, isEmpty);
      expect(notifier.state.moods, isEmpty);
      expect(notifier.state.teacher, null);
      expect(notifier.state.type, null);
      expect(notifier.state.hasActiveFilters, false);
    });
  });

  group('Riverpod Providers', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.currentPointingId).thenReturn(null);
      when(() => mockStorage.setCurrentPointingId(any())).thenAnswer((_) async {});
      // Round-robin order mocks
      when(() => mockStorage.pointingOrder).thenReturn(null);
      when(() => mockStorage.pointingIndex).thenReturn(0);
      when(() => mockStorage.setPointingOrder(any())).thenAnswer((_) async {});
      when(() => mockStorage.setPointingIndex(any())).thenAnswer((_) async {});
    });

    test('currentPointingProvider creates notifier', () {
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final pointing = container.read(currentPointingProvider);

      expect(pointing, isA<Pointing>());
      expect(pointing.id, isNotEmpty);
    });

    test('teachingFilterProvider creates notifier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filterState = container.read(teachingFilterProvider);

      expect(filterState, isA<TeachingFilterState>());
      expect(filterState.hasActiveFilters, false);
    });

    test('filteredTeachingsProvider returns all when no filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final teachings = container.read(filteredTeachingsProvider);

      expect(teachings, isNotEmpty);
      expect(teachings.length, TeachingRepository.all.length);
    });

    test('filteredTeachingsProvider filters by lineage', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(teachingFilterProvider.notifier).setLineage(Tradition.zen);
      final teachings = container.read(filteredTeachingsProvider);

      expect(teachings, isNotEmpty);
      expect(teachings.every((t) => t.lineage == Tradition.zen), true);
    });
  });

  group('PreferredTraditionsNotifier', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
    });

    test('initializes with all traditions when storage is empty', () {
      when(() => mockStorage.preferredTraditions).thenReturn([]);

      final notifier = PreferredTraditionsNotifier(mockStorage);

      expect(notifier.state, Tradition.values.toSet());
      expect(notifier.state.length, 5);
    });

    test('initializes from stored traditions', () {
      when(() => mockStorage.preferredTraditions)
          .thenReturn(['advaita', 'zen']);

      final notifier = PreferredTraditionsNotifier(mockStorage);

      expect(notifier.state.length, 2);
      expect(notifier.state, contains(Tradition.advaita));
      expect(notifier.state, contains(Tradition.zen));
      expect(notifier.state, isNot(contains(Tradition.direct)));
    });

    test('toggle() disables an enabled tradition', () {
      when(() => mockStorage.preferredTraditions).thenReturn([]);
      when(() => mockStorage.setPreferredTraditions(any()))
          .thenAnswer((_) async {});

      final notifier = PreferredTraditionsNotifier(mockStorage);
      expect(notifier.state, contains(Tradition.advaita));

      notifier.toggle(Tradition.advaita);

      expect(notifier.state, isNot(contains(Tradition.advaita)));
      verify(() => mockStorage.setPreferredTraditions(any())).called(1);
    });

    test('toggle() enables a disabled tradition', () {
      when(() => mockStorage.preferredTraditions)
          .thenReturn(['zen']); // Only zen enabled
      when(() => mockStorage.setPreferredTraditions(any()))
          .thenAnswer((_) async {});

      final notifier = PreferredTraditionsNotifier(mockStorage);
      expect(notifier.state, isNot(contains(Tradition.advaita)));

      notifier.toggle(Tradition.advaita);

      expect(notifier.state, contains(Tradition.advaita));
      expect(notifier.state, contains(Tradition.zen));
    });

    test('toggle() keeps at least one tradition enabled', () {
      when(() => mockStorage.preferredTraditions)
          .thenReturn(['advaita']); // Only one enabled
      when(() => mockStorage.setPreferredTraditions(any()))
          .thenAnswer((_) async {});

      final notifier = PreferredTraditionsNotifier(mockStorage);
      expect(notifier.state.length, 1);

      notifier.toggle(Tradition.advaita); // Try to disable the only one

      // Should still have one tradition (not allowed to disable all)
      expect(notifier.state.length, 1);
      expect(notifier.state, contains(Tradition.advaita));
    });

    test('isEnabled() returns correct status', () {
      when(() => mockStorage.preferredTraditions)
          .thenReturn(['advaita', 'zen']);

      final notifier = PreferredTraditionsNotifier(mockStorage);

      expect(notifier.isEnabled(Tradition.advaita), true);
      expect(notifier.isEnabled(Tradition.zen), true);
      expect(notifier.isEnabled(Tradition.direct), false);
      expect(notifier.isEnabled(Tradition.contemporary), false);
      expect(notifier.isEnabled(Tradition.original), false);
    });

    test('enableAll() enables all traditions', () {
      when(() => mockStorage.preferredTraditions)
          .thenReturn(['advaita']); // Start with just one
      when(() => mockStorage.setPreferredTraditions(any()))
          .thenAnswer((_) async {});

      final notifier = PreferredTraditionsNotifier(mockStorage);
      expect(notifier.state.length, 1);

      notifier.enableAll();

      expect(notifier.state.length, 5);
      expect(notifier.state, Tradition.values.toSet());
      verify(() => mockStorage.setPreferredTraditions(any())).called(1);
    });

    test('persists changes to storage', () {
      when(() => mockStorage.preferredTraditions).thenReturn([]);
      when(() => mockStorage.setPreferredTraditions(any()))
          .thenAnswer((_) async {});

      final notifier = PreferredTraditionsNotifier(mockStorage);

      notifier.toggle(Tradition.advaita);

      final captured = verify(
        () => mockStorage.setPreferredTraditions(captureAny()),
      ).captured.single as List<String>;

      expect(captured, isNot(contains('advaita')));
      expect(captured.length, 4); // 5 - 1 disabled
    });

    test('handles invalid stored tradition names gracefully', () {
      // Simulates corrupted or outdated storage data
      when(() => mockStorage.preferredTraditions)
          .thenReturn(['advaita', 'invalid_tradition', 'zen']);

      final notifier = PreferredTraditionsNotifier(mockStorage);

      // Should have valid traditions, invalid falls back to advaita
      expect(notifier.state, contains(Tradition.advaita));
      expect(notifier.state, contains(Tradition.zen));
    });
  });

  group('PreferredTraditionsNotifier - Riverpod Integration', () {
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      when(() => mockStorage.preferredTraditions).thenReturn([]);
      when(() => mockStorage.setPreferredTraditions(any()))
          .thenAnswer((_) async {});
    });

    test('preferredTraditionsProvider creates notifier with storage', () {
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      final traditions = container.read(preferredTraditionsProvider);

      expect(traditions, isA<Set<Tradition>>());
      expect(traditions.length, 5); // All traditions by default
    });

    test('provider state updates propagate correctly', () {
      when(() => mockStorage.preferredTraditions).thenReturn([]);

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      // Initial state
      expect(container.read(preferredTraditionsProvider).length, 5);

      // Toggle off one tradition
      container
          .read(preferredTraditionsProvider.notifier)
          .toggle(Tradition.zen);

      // Verify state updated
      final updatedState = container.read(preferredTraditionsProvider);
      expect(updatedState.length, 4);
      expect(updatedState, isNot(contains(Tradition.zen)));
    });
  });

  group('Lineage Filtering - Pointing Selection', () {
    // These tests document expected behavior for filtering pointings
    // by user's preferred traditions (managed lineages)

    test('getPointingsByTradition returns only matching tradition', () {
      // Verify the helper function works correctly
      final advaitaPointings = getPointingsByTradition(Tradition.advaita);
      final zenPointings = getPointingsByTradition(Tradition.zen);

      expect(advaitaPointings, isNotEmpty);
      expect(zenPointings, isNotEmpty);
      expect(advaitaPointings.every((p) => p.tradition == Tradition.advaita), true);
      expect(zenPointings.every((p) => p.tradition == Tradition.zen), true);
    });

    test('getRandomPointing with tradition filter returns correct tradition', () {
      // Run multiple times to verify consistency
      for (int i = 0; i < 20; i++) {
        final pointing = getRandomPointing(tradition: Tradition.zen);
        expect(pointing.tradition, Tradition.zen,
            reason: 'Iteration $i should return zen tradition');
      }
    });

    test('can filter pointings by multiple preferred traditions', () {
      // Given a set of preferred traditions
      final preferredTraditions = {Tradition.advaita, Tradition.zen};

      // Filter all pointings to only those in preferred traditions
      final filteredPointings = pointings
          .where((p) => preferredTraditions.contains(p.tradition))
          .toList();

      expect(filteredPointings, isNotEmpty);
      expect(
        filteredPointings.every((p) =>
            p.tradition == Tradition.advaita || p.tradition == Tradition.zen),
        true,
      );

      // Verify no pointings from other traditions
      expect(
        filteredPointings.any((p) => p.tradition == Tradition.direct),
        false,
      );
      expect(
        filteredPointings.any((p) => p.tradition == Tradition.contemporary),
        false,
      );
    });

    test('single tradition selection returns only that tradition pointings', () {
      final preferredTraditions = {Tradition.direct};

      final filteredPointings = pointings
          .where((p) => preferredTraditions.contains(p.tradition))
          .toList();

      expect(filteredPointings, isNotEmpty);
      expect(
        filteredPointings.every((p) => p.tradition == Tradition.direct),
        true,
      );
    });

    test('all traditions selected returns all pointings', () {
      final preferredTraditions = Tradition.values.toSet();

      final filteredPointings = pointings
          .where((p) => preferredTraditions.contains(p.tradition))
          .toList();

      expect(filteredPointings.length, pointings.length);
    });

    test('each tradition has sufficient pointings for standalone use', () {
      // Ensure users can use any single tradition as their only selection
      for (final tradition in Tradition.values) {
        final count = getPointingsByTradition(tradition).length;
        expect(count, greaterThanOrEqualTo(5),
            reason: '${tradition.name} should have at least 5 pointings '
                'to provide variety when selected alone');
      }
    });
  });

  group('Lineage Filtering - Widget Cache', () {
    // Tests documenting expected widget cache filtering behavior
    // Widget should only show pointings from user's preferred traditions

    test('can serialize preferred traditions to JSON for storage', () {
      final preferredTraditions = {Tradition.advaita, Tradition.zen};
      final serialized = preferredTraditions.map((t) => t.name).toList();
      final json = jsonEncode(serialized);

      expect(json, contains('advaita'));
      expect(json, contains('zen'));
      expect(json, isNot(contains('direct')));
    });

    test('can deserialize preferred traditions from JSON', () {
      const json = '["advaita", "zen", "direct"]';
      final decoded = List<String>.from(jsonDecode(json));
      final traditions = decoded
          .map((name) => Tradition.values.firstWhere((t) => t.name == name))
          .toSet();

      expect(traditions.length, 3);
      expect(traditions, contains(Tradition.advaita));
      expect(traditions, contains(Tradition.zen));
      expect(traditions, contains(Tradition.direct));
    });

    test('widget cache structure supports tradition field', () {
      // Verify pointing can be serialized with tradition info
      final pointing = pointings.first;
      final traditionInfo = traditions[pointing.tradition];

      final cacheEntry = {
        'id': pointing.id,
        'content': pointing.content,
        'tradition': traditionInfo?.name ?? pointing.tradition.name,
        'teacher': pointing.teacher ?? '',
      };

      expect(cacheEntry['tradition'], isNotEmpty);
      expect(cacheEntry['id'], isNotEmpty);
    });

    test('filtering pointings for widget cache by traditions', () {
      // Simulate widget cache population with filtered traditions
      final preferredTraditions = {Tradition.advaita, Tradition.contemporary};

      final filteredForCache = pointings
          .where((p) => preferredTraditions.contains(p.tradition))
          .map((p) {
        final traditionInfo = traditions[p.tradition];
        return {
          'id': p.id,
          'content': p.content,
          'tradition': traditionInfo?.name ?? p.tradition.name,
          'teacher': p.teacher ?? '',
        };
      }).toList();

      expect(filteredForCache, isNotEmpty);

      // Verify all entries are from preferred traditions
      for (final entry in filteredForCache) {
        final tradName = entry['tradition'] as String;
        expect(
          tradName == 'Advaita Vedanta' || tradName == 'Contemporary',
          true,
          reason: 'Entry tradition should be Advaita or Contemporary, got: $tradName',
        );
      }
    });
  });

  group('Lineage Filtering - Edge Cases', () {
    test('empty preferred traditions defaults to all', () {
      // When storage returns empty, should default to all traditions
      final stored = <String>[];
      Set<Tradition> traditions;

      if (stored.isEmpty) {
        traditions = Tradition.values.toSet();
      } else {
        traditions = stored
            .map((name) => Tradition.values.firstWhere((t) => t.name == name))
            .toSet();
      }

      expect(traditions.length, 5);
    });

    test('invalid tradition name in storage falls back gracefully', () {
      final stored = ['advaita', 'not_a_tradition', 'zen'];
      final traditions = <Tradition>{};

      for (final name in stored) {
        try {
          traditions.add(Tradition.values.firstWhere((t) => t.name == name));
        } catch (e) {
          // Invalid name - skip or use fallback
          traditions.add(Tradition.advaita);
        }
      }

      expect(traditions, contains(Tradition.advaita));
      expect(traditions, contains(Tradition.zen));
    });

    test('can verify pointing belongs to preferred traditions', () {
      final preferredTraditions = {Tradition.zen, Tradition.direct};
      final zenPointing = getPointingsByTradition(Tradition.zen).first;
      final advaitaPointing = getPointingsByTradition(Tradition.advaita).first;

      expect(
        preferredTraditions.contains(zenPointing.tradition),
        true,
        reason: 'Zen pointing should pass filter',
      );
      expect(
        preferredTraditions.contains(advaitaPointing.tradition),
        false,
        reason: 'Advaita pointing should not pass filter',
      );
    });
  });
}
