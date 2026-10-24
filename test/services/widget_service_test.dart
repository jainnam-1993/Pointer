import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/services/widget_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_setup.dart';

/** Fake App Group / HomeWidgetPreferences store behind the `home_widget` channel. */
class _FakeHomeWidget {
  final data = <String, Object?>{};
  final calls = <String>[];

  Future<Object?> handle(MethodCall call) async {
    calls.add(call.method);
    final args = call.arguments is Map ? Map<String, Object?>.from(call.arguments as Map) : const <String, Object?>{};
    switch (call.method) {
      case 'saveWidgetData':
        final id = args['id']! as String;
        if (args['data'] == null) {
          data.remove(id);
        } else {
          data[id] = args['data'];
        }
        return true;
      case 'getWidgetData':
        return data[args['id']] ?? args['defaultValue'];
      default:
        return true;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestPointings);

  late _FakeHomeWidget homeWidget;
  late List<String> nativeCalls;
  String? pendingTapId;

  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    homeWidget = _FakeHomeWidget();
    nativeCalls = [];
    pendingTapId = null;
    messenger.setMockMethodCallHandler(const MethodChannel('home_widget'), homeWidget.handle);
    messenger.setMockMethodCallHandler(WidgetService.widgetChannel, (call) async {
      nativeCalls.add(call.method);
      if (call.method == 'takePendingPointingId') {
        final id = pendingTapId;
        pendingTapId = null;
        return id;
      }
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(const MethodChannel('home_widget'), null);
    messenger.setMockMethodCallHandler(WidgetService.widgetChannel, null);
  });

  Future<SharedPreferences> prefsWith(List<String> favorites) async {
    SharedPreferences.setMockInitialValues({StorageKeys.favoritePointings: jsonEncode(favorites)});
    return SharedPreferences.getInstance();
  }

  List<String> favoritesIn(SharedPreferences prefs) => List<String>.from(jsonDecode(prefs.getString(StorageKeys.favoritePointings)!));

  group('Android (self-sufficient native widget)', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    test('a native widget save is visible after resume because prefs are reloaded', () async {
      final prefs = await prefsWith(['adv-1']);
      // The Kotlin widget writes flutter.pointer_favorites while the app is in the background.
      SharedPreferences.setMockInitialValues({
        StorageKeys.favoritePointings: jsonEncode(['adv-1', 'zen-1']),
      });
      expect(favoritesIn(prefs), ['adv-1'], reason: 'stale plugin cache before reload');

      await WidgetService(prefs).processPendingWidgetActions();

      expect(favoritesIn(prefs), ['adv-1', 'zen-1']);
      expect(StorageService(prefs).favorites, ['adv-1', 'zen-1']);
    });

    test('initialize drops the legacy pointings blob and never writes a new one', () async {
      final prefs = await prefsWith([]);
      homeWidget.data['pointings_cache'] = '[{"id":"x"}]';
      final service = WidgetService(prefs);

      await service.initialize();
      await service.populatePointingsCache();

      expect(homeWidget.data.containsKey('pointings_cache'), isFalse);
      expect(homeWidget.calls, isNot(contains('updateWidget')));
    });

    test('legacy single-slot pending save is added once, never toggled off', () async {
      final prefs = await prefsWith(['adv-1']);
      homeWidget.data['save_pending_id'] = 'adv-1';

      final changed = await WidgetService(prefs).processPendingWidgetActions();

      expect(changed, isFalse);
      expect(favoritesIn(prefs), ['adv-1']);
      expect(homeWidget.data.containsKey('save_pending_id'), isFalse);
    });

    test('favorites change asks the native widget to re-render, with no data copy', () async {
      final prefs = await prefsWith([]);
      await WidgetService(prefs).updateFavorites({'adv-1'});

      expect(nativeCalls, ['renderWidgets']);
      expect(homeWidget.data.containsKey('widget_favorites'), isFalse);
    });

    test('widget tap id is pulled once from MainActivity', () async {
      final service = WidgetService(await prefsWith([]));
      pendingTapId = 'zen-3';

      expect(await service.takePendingWidgetPointingId(), 'zen-3');
      expect(await service.takePendingWidgetPointingId(), isNull);
    });
  });

  group('iOS (App Group store)', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);

    test('queued Save intent ids are added idempotently and the queue is cleared', () async {
      final prefs = await prefsWith(['adv-1']);
      homeWidget.data['pending_saves'] = jsonEncode(['zen-1', 'adv-1', 'zen-1']);

      final changed = await WidgetService(prefs).processPendingWidgetActions();

      expect(changed, isTrue);
      expect(favoritesIn(prefs), ['adv-1', 'zen-1']);
      expect(homeWidget.data.containsKey('pending_saves'), isFalse);
      expect(jsonDecode(homeWidget.data['widget_favorites']! as String), unorderedEquals(['adv-1', 'zen-1']));
    });

    test('save then save again with the app closed keeps the pointing saved', () async {
      final prefs = await prefsWith([]);
      final service = WidgetService(prefs);
      homeWidget.data['pending_saves'] = jsonEncode(['adv-2']);
      await service.processPendingWidgetActions();
      homeWidget.data['pending_saves'] = jsonEncode(['adv-2']);
      await service.processPendingWidgetActions();

      expect(favoritesIn(prefs), ['adv-2']);
    });

    test('populatePointingsCache writes every pointing with id and display tradition', () async {
      final prefs = await prefsWith([]);
      await WidgetService(prefs).populatePointingsCache();

      final cache = (jsonDecode(homeWidget.data['pointings_cache']! as String) as List).cast<Map<String, dynamic>>();
      expect(cache, isNotEmpty);
      expect(cache.every((p) => (p['id'] as String).isNotEmpty), isTrue);
      expect(nativeCalls, isEmpty);
      expect(homeWidget.calls, contains('updateWidget'));
    });

    test('tap pull is Android-only', () async {
      pendingTapId = 'zen-3';
      expect(await WidgetService(await prefsWith([])).takePendingWidgetPointingId(), isNull);
    });
  });
}
