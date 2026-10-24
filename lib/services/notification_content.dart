/**
 * Notification content and action handling shared by every isolate.
 *
 * Everything here must work without the app's [ProviderContainer]: the
 * WorkManager task and the notification action receiver run in background
 * isolates where only [SharedPreferences], the plugin, and the bundled assets
 * are available.
 */
library;

import 'dart:math';
import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pointings.dart';
import 'pointing_selection.dart';
import 'storage_service.dart';

/** Action id of the Android "Save" button. Adds the shown pointing to favourites. */
const String notificationActionSave = 'save';

/** Action id of the Android "Another" button. Posts the next pointing in the rotation. */
const String notificationActionAnother = 'another';

/** Title used for every pointing notification. */
const String pointingNotificationTitle = "Today's Pointing";

/** Android small icon resource for notifications. */
const String notificationSmallIcon = '@drawable/ic_notification';

/** Time-of-day slot for a delivery time. Boundaries match the pre-overhaul cache: 5-11 morning, 11-17 midday, else evening. */
PointingContext notificationSlotFor(DateTime time) {
  final hour = time.hour;
  if (hour >= 5 && hour < 11) return PointingContext.morning;
  if (hour >= 11 && hour < 17) return PointingContext.midday;
  return PointingContext.evening;
}

/** Whether [pointing] may be delivered in [slot]: tagged for that slot or general. */
bool isEligibleForSlot(Pointing pointing, PointingContext slot) =>
    pointing.contexts.contains(slot) || pointing.contexts.contains(PointingContext.general);

/**
 * Slot-aware no-repeat rotation over the full notification content pool.
 *
 * Pointings fall into buckets: one per time-of-day slot (tagged for that
 * slot) and one shared general bucket (tagged general and no time slot), so
 * a general pointing is not repeated across slots within a cycle. A slot's
 * eligible pool (see [isEligibleForSlot]) is its bucket plus the general one. Each bucket is sorted by id, shuffled with a persisted seed, and
 * walked by a persisted cursor. A delivery picks the slot-tagged bucket with
 * probability [taggedRate] while it has unseen items, otherwise the general
 * bucket. A bucket restarts only when the slot has no unseen eligible item,
 * so the whole eligible pool is shown once before any repeat. iOS batches, the
 * Android WorkManager task, and "Another" all draw from this rotation.
 */
class NotificationRotation {
  NotificationRotation._();

  /** Share of deliveries drawn from slot-tagged pointings while unseen ones remain. */
  static const double taggedRate = 0.25;

  static String _key(String bucket, String field) => 'pointer_notification_rotation_${bucket}_$field';

  /** Take the next pointing for [at] (default now), [count] times. */
  static Future<List<Pointing>> take(
    SharedPreferences prefs,
    List<Pointing> pool,
    int count, {
    DateTime? at,
    Random? random,
    double Function(Pointing)? weight,
  }) => takeFor(prefs, pool, List.filled(count < 0 ? 0 : count, at ?? DateTime.now()), random: random, weight: weight);

  /**
   * Take from the pool the user selected: enabled traditions only, ordered
   * with affinity weights (see [PointingSelection]).
   */
  static Future<List<Pointing>> takeSelectedFor(SharedPreferences prefs, List<Pointing> all, List<DateTime> times, {Random? random}) {
    final selection = PointingSelection.fromPrefs(prefs);
    return takeFor(prefs, selection.eligible(all), times, random: random, weight: selection.weightOf);
  }

  /** Take one pointing per delivery time in [times], each matched to its slot. */
  static Future<List<Pointing>> takeFor(
    SharedPreferences prefs,
    List<Pointing> pool,
    List<DateTime> times, {
    Random? random,
    double Function(Pointing)? weight,
  }) async {
    if (pool.isEmpty || times.isEmpty) return const [];
    final rng = random ?? Random();
    final sorted = [...pool]..sort((a, b) => a.id.compareTo(b.id));
    const slots = {PointingContext.morning, PointingContext.midday, PointingContext.evening};
    final buckets = <String, _Bucket>{};
    _Bucket bucket(String name, bool Function(Pointing) test) => buckets[name] ??= _Bucket(
      sorted.where(test).toList(),
      prefs.getInt(_key(name, 'seed')) ?? rng.nextInt(1 << 31),
      prefs.getInt(_key(name, 'cursor')) ?? 0,
      weight,
    );
    final general = bucket('general', (p) => p.contexts.contains(PointingContext.general) && !p.contexts.any(slots.contains));

    final result = <Pointing>[];
    for (final time in times) {
      final slot = notificationSlotFor(time);
      final tagged = bucket(slot.name, (p) => p.contexts.contains(slot));
      if (tagged.items.isEmpty && general.items.isEmpty) continue;
      if (!tagged.hasUnseen && !general.hasUnseen) {
        tagged.restart(rng);
        general.restart(rng);
      } else if (!general.hasUnseen && general.items.isNotEmpty && tagged.items.isEmpty) {
        general.restart(rng);
      }
      final useTagged = tagged.hasUnseen && (!general.hasUnseen || rng.nextDouble() < taggedRate);
      result.add((useTagged ? tagged : general).take());
    }
    for (final entry in buckets.entries) {
      await prefs.setInt(_key(entry.key, 'seed'), entry.value.seed);
      await prefs.setInt(_key(entry.key, 'cursor'), entry.value.cursor);
    }
    return result;
  }
}

class _Bucket {
  final List<Pointing> items;
  int seed;
  int cursor;
  final double Function(Pointing)? weight;
  late List<Pointing> order;

  _Bucket(this.items, this.seed, this.cursor, this.weight) {
    _shuffle();
  }

  bool get hasUnseen => cursor < items.length;
  void _shuffle() {
    final w = weight;
    order = w == null ? ([...items]..shuffle(Random(seed))) : PointingSelection.all.weightedShuffle(items, w, Random(seed));
  }

  void restart(Random rng) {
    seed = rng.nextInt(1 << 31);
    cursor = 0;
    _shuffle();
  }

  Pointing take() => order[cursor++];
}

/** Android action buttons shown on every pointing notification. */
const List<AndroidNotificationAction> pointingNotificationActions = <AndroidNotificationAction>[
  AndroidNotificationAction(notificationActionSave, 'Save', showsUserInterface: false, cancelNotification: false),
  AndroidNotificationAction(notificationActionAnother, 'Another', showsUserInterface: false, cancelNotification: true),
];

/** Platform details for a pointing notification, used by every code path that posts one. */
NotificationDetails buildPointingNotificationDetails(Pointing pointing) {
  final traditionName = traditions[pointing.tradition]?.name ?? pointing.tradition.name;
  final attribution = pointing.teacher != null ? '— ${pointing.teacher}' : '';
  final subtitle = '$traditionName $attribution'.trim();

  return NotificationDetails(
    iOS: DarwinNotificationDetails(
      interruptionLevel: InterruptionLevel.passive,
      presentSound: false,
      presentBanner: false,
      presentList: true,
      subtitle: subtitle,
    ),
    android: AndroidNotificationDetails(
      'pointings_v6',
      'Daily Pointings',
      channelDescription: 'Gentle reminders for your daily pointing',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('bell_chime'),
      styleInformation: BigTextStyleInformation(
        pointing.content,
        contentTitle: pointingNotificationTitle,
        summaryText: subtitle,
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
        htmlFormatSummaryText: false,
      ),
      actions: pointingNotificationActions,
    ),
  );
}

/** Post [pointing] now through [plugin]. */
Future<void> showPointingNotification(FlutterLocalNotificationsPlugin plugin, Pointing pointing, {DateTime? now}) {
  final id = ((now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000) & 0x7fffffff;
  return plugin.show(id, pointingNotificationTitle, pointing.content, buildPointingNotificationDetails(pointing), payload: pointing.id);
}

/**
 * Apply a notification action button press.
 *
 * - `save` adds the payload id to favourites. It never removes one, so a
 *   repeated press is a no-op.
 * - `another` posts the next pointing from [NotificationRotation].
 *
 * Plain taps (`actionId == null`) are routing, handled by the main isolate.
 */
Future<void> handleNotificationAction(
  NotificationResponse response, {
  required SharedPreferences prefs,
  required FlutterLocalNotificationsPlugin plugin,
  required Future<List<Pointing>> Function() loadPool,
}) async {
  switch (response.actionId) {
    case notificationActionSave:
      final id = response.payload;
      if (id == null || id.isEmpty) return;
      await StorageService(prefs).addFavorite(id);
      debugPrint('[NotificationAction] Saved $id');
    case notificationActionAnother:
      final next = await NotificationRotation.takeSelectedFor(prefs, await loadPool(), [DateTime.now()]);
      if (next.isEmpty) return;
      await showPointingNotification(plugin, next.first);
      debugPrint('[NotificationAction] Posted ${next.first.id}');
  }
}

/** Load the full pointing pool from the bundled asset (no-op when already loaded). */
Future<List<Pointing>> loadNotificationPool() async {
  await loadPointings();
  return pointings;
}

/** Initialize the plugin in a background isolate so it can post notifications. */
Future<void> initializePluginForBackground(FlutterLocalNotificationsPlugin plugin) async {
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings(notificationSmallIcon),
      iOS: DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false),
    ),
    onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
  );
}

/**
 * Entry point for notification actions delivered to a background isolate.
 *
 * Self-contained: it opens its own [SharedPreferences] (reloaded so it sees
 * the main isolate's latest writes) and its own plugin instance.
 */
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  debugPrint('[NotificationAction] Background action=${response.actionId} payload=${response.payload}');
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final plugin = FlutterLocalNotificationsPlugin();
    if (response.actionId == notificationActionAnother) {
      await initializePluginForBackground(plugin);
    }
    await handleNotificationAction(response, prefs: prefs, plugin: plugin, loadPool: loadNotificationPool);
  } catch (e) {
    debugPrint('[NotificationAction] Background action failed: $e');
  }
}
