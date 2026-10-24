import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/providers/core_providers.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/providers/content_providers.dart';
import 'package:pointer/services/notification_content.dart';
import 'package:pointer/services/pointing_selection.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadPointings();
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('PointingSelection', () {
    test('eligible keeps only enabled traditions and falls back to all when nothing matches', () {
      final zen = PointingSelection(enabled: {Tradition.zen});
      expect(zen.eligible(pointings), isNotEmpty);
      expect(zen.eligible(pointings).every((p) => p.tradition == Tradition.zen), isTrue);
      expect(PointingSelection.all.eligible(pointings), hasLength(pointings.length));
      final none = PointingSelection(enabled: {Tradition.zen});
      final advaitaOnly = pointings.where((p) => p.tradition == Tradition.advaita).toList();
      expect(none.eligible(advaitaOnly), hasLength(advaitaOnly.length));
    });

    test('affinity weighting puts the favoured tradition first more often', () {
      final scores = {for (final t in Tradition.values) t: 0.05};
      scores[Tradition.zen] = 1 - 0.05 * (Tradition.values.length - 1);
      final selection = PointingSelection(affinity: scores);
      final rng = Random(7);
      var zenInFirstTen = 0;
      for (var i = 0; i < 50; i++) {
        final order = selection.order(pointings, rng).take(10).map(getPointingById);
        zenInFirstTen += order.where((p) => p!.tradition == Tradition.zen).length;
      }
      final zenShare = pointings.where((p) => p.tradition == Tradition.zen).length / pointings.length;
      expect(zenInFirstTen / 500, greaterThan(zenShare * 1.5));
    });
  });

  group('Home follows Manage Lineages', () {
    test('round-robin only shows enabled traditions and re-filters on change', () async {
      final prefs = await SharedPreferences.getInstance();
      var selection = PointingSelection(enabled: {Tradition.zen});
      final notifier = CurrentPointingNotifier(StorageService(prefs), () => selection);
      expect(notifier.state.tradition, Tradition.zen);
      for (var i = 0; i < 30; i++) {
        notifier.nextPointing();
        expect(notifier.state.tradition, Tradition.zen);
      }

      selection = PointingSelection(enabled: {Tradition.advaita});
      notifier.applySelection();
      expect(notifier.state.tradition, Tradition.advaita);
      for (var i = 0; i < 30; i++) {
        notifier.nextPointing();
        expect(notifier.state.tradition, Tradition.advaita);
      }
    });
  });

  test('toggling traditions in Manage Lineages moves Home off disabled traditions', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);
    container.read(currentPointingProvider);
    final lineages = container.read(preferredTraditionsProvider.notifier);
    for (final t in Tradition.values.where((t) => t != Tradition.zen)) {
      lineages.toggle(t);
    }
    expect(container.read(currentPointingProvider).tradition, Tradition.zen);
    container.read(currentPointingProvider.notifier).nextPointing();
    expect(container.read(currentPointingProvider).tradition, Tradition.zen);
  });

  group('Notifications follow Manage Lineages', () {
    test('takeSelectedFor draws only from enabled traditions saved in prefs', () async {
      SharedPreferences.setMockInitialValues({StorageKeys.preferredTraditions: '["zen"]'});
      final prefs = await SharedPreferences.getInstance();
      final times = List.generate(20, (i) => DateTime(2026, 10, 23, 8 + (i % 12)));
      final batch = await NotificationRotation.takeSelectedFor(prefs, pointings, times, random: Random(1));
      expect(batch, isNotEmpty);
      expect(batch.every((p) => p.tradition == Tradition.zen), isTrue);
    });
  });
}
