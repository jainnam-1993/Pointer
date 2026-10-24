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
import 'storage_service.dart';

/** Action id of the Android "Save" button. Adds the shown pointing to favourites. */
const String notificationActionSave = 'save';

/** Action id of the Android "Another" button. Posts the next pointing in the rotation. */
const String notificationActionAnother = 'another';

/** Title used for every pointing notification. */
const String pointingNotificationTitle = "Today's Pointing";

/** Android small icon resource for notifications. */
const String notificationSmallIcon = '@drawable/ic_notification';

/**
 * No-repeat rotation over the full notification content pool.
 *
 * The pool is sorted by id and shuffled with a persisted seed; a persisted
 * cursor walks that order. Every pointing is shown once before any repeats,
 * and a new seed starts the next cycle. iOS batches, the Android WorkManager
 * task, and the "Another" action all draw from this one rotation.
 */
class NotificationRotation {
  NotificationRotation._();

  static const String seedKey = 'pointer_notification_rotation_seed';
  static const String cursorKey = 'pointer_notification_rotation_cursor';

  /** Take the next [count] pointings from [pool] and advance the persisted cursor. */
  static Future<List<Pointing>> take(SharedPreferences prefs, List<Pointing> pool, int count, {Random? random}) async {
    if (pool.isEmpty || count <= 0) return const [];
    final rng = random ?? Random();
    final sorted = [...pool]..sort((a, b) => a.id.compareTo(b.id));

    var seed = prefs.getInt(seedKey) ?? rng.nextInt(1 << 31);
    var cursor = prefs.getInt(cursorKey) ?? 0;
    var order = [...sorted]..shuffle(Random(seed));

    final result = <Pointing>[];
    while (result.length < count) {
      if (cursor >= order.length) {
        seed = rng.nextInt(1 << 31);
        cursor = 0;
        order = [...sorted]..shuffle(Random(seed));
      }
      result.add(order[cursor++]);
    }

    await prefs.setInt(seedKey, seed);
    await prefs.setInt(cursorKey, cursor);
    return result;
  }
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
      final next = await NotificationRotation.take(prefs, await loadPool(), 1);
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
