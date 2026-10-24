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
    final posted = _Posted(id, title, body, notificationDetails, payload, DateTime.fromMillisecondsSinceEpoch(scheduledDate.millisecondsSinceEpoch));
    scheduled.add(posted);
    pending[id] = posted;
  }

  /** iOS model: requests waiting to fire, and notifications in Notification Center. */
  final pending = <int, _Posted>{};
  final delivered = <_Posted>[];

  /** Fire every pending request due by [time], as iOS would while the app is closed. */
  void deliverUntil(DateTime time) {
    final due = pending.values.where((p) => !p.at!.isAfter(time)).toList();
    for (final p in due) {
      pending.remove(p.id);
      delivered.add(p);
    }
  }

  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() async => [
    for (final p in pending.values) PendingNotificationRequest(p.id, p.title, p.body, p.payload),
  ];

  /** Like iOS: removes the pending request and any delivered notification with this id. */
  @override
  Future<void> cancel(int id, {String? tag}) async {
    pending.remove(id);
    delivered.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> cancelAll() async => throw StateError('cancelAll also clears delivered notifications on iOS');
}

int _rotationTaken(SharedPreferences prefs) =>
    prefs.getKeys().where((k) => k.startsWith('pointer_notification_rotation_') && k.endsWith('_cursor')).fold(0, (sum, k) => sum + prefs.getInt(k)!);

List<Pointing> _pool(int n) => [
  for (var i = 0; i < n; i++)
    Pointing(id: 'p${i.toString().padLeft(3, '0')}', content: 'Pointing $i', tradition: Tradition.zen, contexts: const [PointingContext.general]),
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
      final a = await NotificationRotation.take(await _prefs(), _pool(10), 10, random: Random(7));
      final b = await NotificationRotation.take(await _prefs(), _pool(10).reversed.toList(), 10, random: Random(7));
      expect(a.map((p) => p.id), b.map((p) => p.id));
    });
  });

  group('Slot-aware rotation', () {
    Pointing tagged(String id, List<PointingContext> contexts) => Pointing(id: id, content: id, tradition: Tradition.zen, contexts: contexts);
    final pool = [
      for (var i = 0; i < 40; i++) tagged('g$i', const [PointingContext.general]),
      for (var i = 0; i < 8; i++) tagged('m$i', const [PointingContext.morning]),
      for (var i = 0; i < 8; i++) tagged('e$i', const [PointingContext.evening]),
      for (var i = 0; i < 4; i++) tagged('s$i', const [PointingContext.stress]),
    ];
    final morning = DateTime(2026, 10, 23, 7);
    final evening = DateTime(2026, 10, 23, 19);

    test('slot boundaries match the old cache', () {
      expect(notificationSlotFor(DateTime(2026, 1, 1, 4, 59)), PointingContext.evening);
      expect(notificationSlotFor(DateTime(2026, 1, 1, 5)), PointingContext.morning);
      expect(notificationSlotFor(DateTime(2026, 1, 1, 11)), PointingContext.midday);
      expect(notificationSlotFor(DateTime(2026, 1, 1, 17)), PointingContext.evening);
    });

    test('no evening-only or other-slot pointing in a morning slot', () async {
      final prefs = await _prefs();
      final picks = await NotificationRotation.takeFor(prefs, pool, List.filled(144, morning), random: Random(3));
      expect(picks.where((p) => p.id.startsWith('e') || p.id.startsWith('s')), isEmpty);
    });

    test('slot-tagged pointings surface early and each eligible pool is covered before repeating', () async {
      final prefs = await _prefs();
      final first = await NotificationRotation.takeFor(prefs, pool, List.filled(48, morning), random: Random(5));
      expect(first.map((p) => p.id).toSet(), hasLength(48), reason: 'one full cycle of the 48 eligible, no repeats');
      expect(first.take(20).where((p) => p.id.startsWith('m')), isNotEmpty, reason: 'morning ones are mixed in, not left to the end');
      final eveningPicks = await NotificationRotation.takeFor(prefs, pool, List.filled(8, evening), random: Random(6));
      expect(eveningPicks.map((p) => p.id).toSet(), {
        for (var i = 0; i < 8; i++) 'e$i',
      }, reason: 'general pool already seen this cycle, so evening shows its own first');
    });

    test('a general pointing is not repeated across slots within a cycle', () async {
      final prefs = await _prefs();
      final times = [for (var i = 0; i < 24; i++) i.isEven ? morning : evening];
      final picks = await NotificationRotation.takeFor(prefs, pool, times, random: Random(9));
      final general = picks.where((p) => p.id.startsWith('g')).map((p) => p.id).toList();
      expect(general.toSet(), hasLength(general.length));
    });

    test('Another and the Android task use the delivery time slot', () async {
      final prefs = await _prefs();
      final picks = await NotificationRotation.take(prefs, pool, 30, at: evening, random: Random(8));
      expect(picks.where((p) => p.id.startsWith('m')), isEmpty);
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

    test('refills at most once per 6 hours, only topping up what was delivered', () async {
      final prefs = await _prefs({StorageKeys.notificationsEnabled: true});
      final service = NotificationService(prefs, plugin);
      final t0 = DateTime(2026, 10, 23, 7);

      expect(await service.refillIfDue(now: t0), isTrue);
      expect(plugin.scheduled, hasLength(60));
      expect(plugin.scheduled.map((p) => p.payload).toSet(), hasLength(60));
      expect(plugin.scheduled.every((p) => const NotificationSchedule().allows(p.at!)), isTrue);
      expect(plugin.scheduled.every((p) => p.at!.isAfter(t0)), isTrue);

      expect(await service.refillIfDue(now: t0.add(const Duration(hours: 5, minutes: 59))), isFalse);
      expect(plugin.scheduled, hasLength(60));

      final t1 = t0.add(const Duration(hours: 6));
      plugin.deliverUntil(t1);
      final deliveredCount = plugin.delivered.length;
      expect(deliveredCount, greaterThan(0));
      expect(await service.refillIfDue(now: t1), isTrue);
      expect(plugin.scheduled, hasLength(60 + deliveredCount));
      expect(plugin.pending, hasLength(60));
      expect(plugin.scheduled.map((p) => p.payload).toSet(), hasLength(60 + deliveredCount), reason: 'no repeats across refills');
      expect(plugin.scheduled.map((p) => p.id).toSet(), hasLength(60 + deliveredCount), reason: 'ids are not reused');
    });

    test('a refill leaves delivered notifications and pending requests intact', () async {
      final prefs = await _prefs({StorageKeys.notificationsEnabled: true});
      final service = NotificationService(prefs, plugin);
      final t0 = DateTime(2026, 10, 23, 7);
      await service.refillIfDue(now: t0);

      final t1 = DateTime(2026, 10, 23, 20);
      plugin.deliverUntil(t1);
      final delivered = plugin.delivered.map((p) => p.id).toList();
      expect(delivered.length, greaterThanOrEqualTo(3));
      final before = {for (final e in plugin.pending.entries) e.key: e.value.payload};
      final lastPending = plugin.pending.values.map((p) => p.at!).reduce((a, b) => a.isAfter(b) ? a : b);

      await service.refillIfDue(now: t1);

      expect(plugin.delivered.map((p) => p.id), delivered);
      for (final e in before.entries) {
        expect(plugin.pending[e.key]?.payload, e.value);
      }
      final added = plugin.pending.values.where((p) => !before.containsKey(p.id));
      expect(added, hasLength(delivered.length));
      expect(added.every((p) => p.at!.isAfter(lastPending)), isTrue, reason: 'only the tail after the last pending time');
    });

    test('the rotation moves by exactly the newly scheduled count', () async {
      final prefs = await _prefs({StorageKeys.notificationsEnabled: true});
      final service = NotificationService(prefs, plugin);
      final t0 = DateTime(2026, 10, 23, 7);
      await service.refillIfDue(now: t0);
      expect(_rotationTaken(prefs), 60);

      // Nothing delivered (phone off): the next refill must not consume or skip anything.
      await service.refillIfDue(now: t0.add(NotificationService.refillInterval));
      expect(_rotationTaken(prefs), 60);
      expect(plugin.scheduled, hasLength(60));

      final t2 = DateTime(2026, 10, 24, 12);
      plugin.deliverUntil(t2);
      final before = plugin.scheduled.length;
      await service.refillIfDue(now: t2);
      final added = plugin.scheduled.length - before;
      expect(added, greaterThan(0));
      expect(_rotationTaken(prefs), 60 + added);
    });

    test('cancels owned pending requests left by an older build with no recorded time', () async {
      plugin.pending[50001] = _Posted(50001, 'old', 'old', null, 'p001', DateTime(2026, 10, 24));
      plugin.pending[7] = _Posted(7, 'other', 'other', null, null, DateTime(2026, 10, 24));
      final service = NotificationService(await _prefs({StorageKeys.notificationsEnabled: true}), plugin);
      await service.refillIfDue(now: DateTime(2026, 10, 23, 7));
      expect(plugin.pending.values.where((p) => p.title == 'old'), isEmpty);
      expect(plugin.pending.containsKey(7), isTrue, reason: 'ids outside the owned range are left alone');
      expect(plugin.pending.values.where((p) => p.title == pointingNotificationTitle), hasLength(60));
    });

    test('a Settings change rebuilds pending requests without touching delivered ones', () async {
      final prefs = await _prefs({StorageKeys.notificationsEnabled: true});
      final service = NotificationService(prefs, plugin);
      final now = DateTime.now();
      await service.scheduleAllNotifications(now: now);
      plugin.deliverUntil(plugin.pending.values.map((p) => p.at!).reduce((a, b) => a.isBefore(b) ? a : b).add(const Duration(hours: 4)));
      final delivered = plugin.delivered.map((p) => p.id).toList();
      expect(delivered, isNotEmpty);
      final oldPending = plugin.pending.keys.toSet();

      const changed = NotificationSchedule(frequencyMinutes: 240, startHour: 9, endHour: 18);
      await service.saveSchedule(changed);

      expect(plugin.delivered.map((p) => p.id), delivered);
      expect(plugin.pending.keys.toSet().intersection(oldPending), isEmpty);
      expect(plugin.pending, isNotEmpty);
      expect(plugin.pending.values.every((p) => changed.allows(p.at!)), isTrue);
    });

    test('disabling cancels pending requests and keeps delivered ones', () async {
      final service = NotificationService(await _prefs({StorageKeys.notificationsEnabled: true}), plugin);
      await service.scheduleAllNotifications(now: DateTime(2026, 10, 23, 7));
      plugin.deliverUntil(DateTime(2026, 10, 23, 20));
      final delivered = plugin.delivered.length;
      await service.setNotificationsEnabled(false);
      expect(plugin.pending, isEmpty);
      expect(plugin.delivered, hasLength(delivered));
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
