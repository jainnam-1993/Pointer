import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/services/notification_content.dart';
import 'package:pointer/services/notification_service.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/services/workmanager_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class _Posted {
  final int id;
  final String? title;
  final String? body;
  final NotificationDetails? details;
  final String? payload;
  final DateTime? at;
  _Posted(this.id, this.title, this.body, this.details, this.payload, [this.at]);
}

/** Records what the service hands to the plugin; every other call throws. */
class _RecordingPlugin extends Fake implements FlutterLocalNotificationsPlugin {
  final shown = <_Posted>[];
  final scheduled = <_Posted>[];
  int cancelAllCalls = 0;

  @override
  Future<void> show(int id, String? title, String? body, NotificationDetails? notificationDetails, {String? payload}) async {
    shown.add(_Posted(id, title, body, notificationDetails, payload));
  }

  @override
  Future<void> zonedSchedule(
    int id,
    String? title,
    String? body,
    tz.TZDateTime scheduledDate,
    NotificationDetails notificationDetails, {
    required UILocalNotificationDateInterpretation uiLocalNotificationDateInterpretation,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduled.add(_Posted(id, title, body, notificationDetails, payload, DateTime.fromMillisecondsSinceEpoch(scheduledDate.millisecondsSinceEpoch)));
  }

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

List<Pointing> _pool(int n) => [
  for (var i = 0; i < n; i++) Pointing(id: 'p${i.toString().padLeft(3, '0')}', content: 'Pointing $i', tradition: Tradition.zen, contexts: const []),
];

Future<SharedPreferences> _prefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  group('NotificationRotation', () {
    test('shows every pointing once before any repeats, across calls', () async {
      final prefs = await _prefs();
      final pool = _pool(25);
      final seen = <String>[];
      for (var i = 0; i < 5; i++) {
        seen.addAll((await NotificationRotation.take(prefs, pool, 5, random: Random(1))).map((p) => p.id));
      }
      expect(seen.toSet(), hasLength(25));
      final nextCycle = await NotificationRotation.take(prefs, pool, 25, random: Random(2));
      expect(nextCycle.map((p) => p.id).toSet(), hasLength(25));
    });

    test('order does not depend on pool order', () async {
      final a = await NotificationRotation.take(await _prefs({NotificationRotation.seedKey: 7}), _pool(10), 10);
      final b = await NotificationRotation.take(await _prefs({NotificationRotation.seedKey: 7}), _pool(10).reversed.toList(), 10);
      expect(a.map((p) => p.id), b.map((p) => p.id));
    });
  });

  group('NotificationSchedule.allows (shared iOS and Android rule)', () {
    const schedule = NotificationSchedule(startHour: 8, startMinute: 30, endHour: 21, endMinute: 30, quietStartHour: 12, quietEndHour: 13);
    DateTime at(int h, int m) => DateTime(2026, 10, 23, h, m);

    test('honors window minutes, inclusive at both ends', () {
      expect(schedule.allows(at(8, 29)), isFalse);
      expect(schedule.allows(at(8, 30)), isTrue);
      expect(schedule.allows(at(21, 30)), isTrue);
      expect(schedule.allows(at(21, 31)), isFalse);
    });

    test('skips quiet hours', () {
      expect(schedule.allows(at(11, 59)), isTrue);
      expect(schedule.allows(at(12, 0)), isFalse);
      expect(schedule.allows(at(12, 59)), isFalse);
      expect(schedule.allows(at(13, 0)), isTrue);
    });

    test('iOS batch times use the same rule', () {
      final times = schedule.copyWith(frequencyMinutes: 60).getNotificationTimes(at(0, 0));
      expect(times.first, at(8, 30));
      expect(times.last, at(21, 30));
      expect(times.where((t) => t.hour == 12), isEmpty);
      expect(times.every(schedule.allows), isTrue);
    });
  });

  group('iOS refill', () {
    late _RecordingPlugin plugin;

    setUp(() {
      NotificationService.platformOverride = TargetPlatform.iOS;
      plugin = _RecordingPlugin();
      initPointingsForTest(_pool(200));
    });
    tearDown(() => NotificationService.platformOverride = null);

    test('refills at most once per 6 hours and rotates content', () async {
      final prefs = await _prefs({StorageKeys.notificationsEnabled: true});
      final service = NotificationService(prefs, plugin);
      final t0 = DateTime(2026, 10, 23, 7);

      expect(await service.refillIfDue(now: t0), isTrue);
      final first = plugin.scheduled.length;
      expect(first, 60);
      expect(plugin.scheduled.map((p) => p.payload).toSet(), hasLength(60));
      expect(plugin.scheduled.every((p) => const NotificationSchedule().allows(p.at!)), isTrue);
      expect(plugin.scheduled.every((p) => p.at!.isAfter(t0)), isTrue);

      expect(await service.refillIfDue(now: t0.add(const Duration(hours: 5, minutes: 59))), isFalse);
      expect(plugin.scheduled.length, first);

      expect(await service.refillIfDue(now: t0.add(const Duration(hours: 6))), isTrue);
      expect(plugin.scheduled.length, 120);
      expect(plugin.scheduled.map((p) => p.payload).toSet(), hasLength(120), reason: 'no repeats across refills');
      expect(plugin.cancelAllCalls, 2);
    });

    test('does nothing when notifications are disabled or on Android', () async {
      final disabled = NotificationService(await _prefs(), plugin);
      expect(await disabled.refillIfDue(now: DateTime(2026, 10, 23)), isFalse);

      NotificationService.platformOverride = TargetPlatform.android;
      final android = NotificationService(await _prefs({StorageKeys.notificationsEnabled: true}), plugin);
      expect(await android.refillIfDue(now: DateTime(2026, 10, 23)), isFalse);
      expect(plugin.scheduled, isEmpty);
    });
  });

  group('Notification actions (background handler core)', () {
    late _RecordingPlugin plugin;
    setUp(() => plugin = _RecordingPlugin());

    NotificationResponse response(String? action, String? payload) =>
        NotificationResponse(notificationResponseType: NotificationResponseType.selectedNotificationAction, actionId: action, payload: payload);

    test('Save adds the pointing and is idempotent, never a toggle', () async {
      final prefs = await _prefs({
        StorageKeys.favoritePointings: jsonEncode(['p001']),
      });
      Future<List<Pointing>> pool() async => _pool(3);

      await handleNotificationAction(response(notificationActionSave, 'p002'), prefs: prefs, plugin: plugin, loadPool: pool);
      await handleNotificationAction(response(notificationActionSave, 'p002'), prefs: prefs, plugin: plugin, loadPool: pool);
      await handleNotificationAction(response(notificationActionSave, 'p001'), prefs: prefs, plugin: plugin, loadPool: pool);

      expect(StorageService(prefs).favorites, ['p001', 'p002']);
      expect(plugin.shown, isEmpty);
    });

    test('Another posts the next real pointing with actions, not the test notification', () async {
      final prefs = await _prefs();
      final pool = _pool(4);
      for (var i = 0; i < 4; i++) {
        await handleNotificationAction(response(notificationActionAnother, 'p000'), prefs: prefs, plugin: plugin, loadPool: () async => pool);
      }
      expect(plugin.shown, hasLength(4));
      expect(plugin.shown.map((p) => p.payload).toSet(), hasLength(4));
      for (final posted in plugin.shown) {
        expect(posted.title, pointingNotificationTitle);
        expect(posted.body, pool.firstWhere((p) => p.id == posted.payload).content);
        expect(posted.details!.android!.actions!.map((a) => a.id), [notificationActionSave, notificationActionAnother]);
      }
    });
  });

  group('Android WorkManager task', () {
    late _RecordingPlugin plugin;
    setUp(() => plugin = _RecordingPlugin());

    Future<SharedPreferences> enabled(NotificationSchedule schedule) =>
        _prefs({StorageKeys.notificationsEnabled: true, StorageKeys.notificationSchedule: jsonEncode(schedule.toJson())});

    test('posts from the full pool inside the window and skips quiet hours and minutes outside it', () async {
      const schedule = NotificationSchedule(startHour: 8, startMinute: 30, endHour: 20, quietStartHour: 12, quietEndHour: 13);
      final prefs = await enabled(schedule);
      Future<List<Pointing>> pool() async => _pool(50);

      expect(await postScheduledPointing(prefs: prefs, plugin: plugin, loadPool: pool, now: DateTime(2026, 10, 23, 8, 15)), isNull);
      expect(await postScheduledPointing(prefs: prefs, plugin: plugin, loadPool: pool, now: DateTime(2026, 10, 23, 12, 30)), isNull);
      final id = await postScheduledPointing(prefs: prefs, plugin: plugin, loadPool: pool, now: DateTime(2026, 10, 23, 8, 30));
      expect(id, isNotNull);
      expect(plugin.shown.single.payload, id);
      expect(plugin.shown.single.details!.android!.actions, isNotEmpty);
    });

    test('does not post when notifications are disabled', () async {
      final prefs = await _prefs();
      expect(await postScheduledPointing(prefs: prefs, plugin: plugin, loadPool: () async => _pool(5), now: DateTime(2026, 10, 23, 10)), isNull);
      expect(plugin.shown, isEmpty);
    });
  });
}
