import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;
import 'package:workmanager/workmanager.dart';

import '../data/pointings.dart';
import 'notification_content.dart';
import 'notification_service.dart';
import 'storage_service.dart';

/**
 * Task name constants registered with the [Workmanager] plugin.
 *
 * These identifiers are used both when scheduling tasks and inside
 * [callbackDispatcher] to route execution to the correct handler.
 */
class WorkManagerTasks {
  /** Repeating notification task, fires at the configured frequency. */
  static const String periodicNotification = 'periodicNotification';

  /** Single-fire notification task, used for one-off delayed reminders. */
  static const String oneTimeNotification = 'oneTimeNotification';
}

/**
 * Top-level callback dispatcher for WorkManager.
 * This MUST be a top-level function (not a class method).
 */
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[WorkManager] Executing task: $task');

    try {
      switch (task) {
        case WorkManagerTasks.periodicNotification:
        case WorkManagerTasks.oneTimeNotification:
          await _showNotificationFromBackground();
          break;
        default:
          debugPrint('[WorkManager] Unknown task: $task');
      }
      return true;
    } catch (e) {
      // Returning false signals WorkManager to retry the task on next schedule
      debugPrint('[WorkManager] Error executing task: $e');
      return false;
    }
  });
}

/**
 * Show the next rotation pointing from the WorkManager background isolate.
 *
 * Applies [NotificationSchedule.allows], the same rule iOS batches use, so
 * window minutes and quiet hours behave identically on both platforms.
 */
Future<void> _showNotificationFromBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final plugin = FlutterLocalNotificationsPlugin();
  final posted = await postScheduledPointing(prefs: prefs, plugin: plugin, loadPool: loadNotificationPool, initialize: initializePluginForBackground);
  debugPrint('[WorkManager] Scheduled pointing posted: $posted');
}

/**
 * Post the next pointing when notifications are enabled and [now] passes the schedule rule.
 *
 * Returns the posted pointing id, or null when nothing was posted.
 */
@visibleForTesting
Future<String?> postScheduledPointing({
  required SharedPreferences prefs,
  required FlutterLocalNotificationsPlugin plugin,
  required Future<List<Pointing>> Function() loadPool,
  Future<void> Function(FlutterLocalNotificationsPlugin)? initialize,
  DateTime? now,
}) async {
  if (!(prefs.getBool(StorageKeys.notificationsEnabled) ?? false)) return null;

  final stored = prefs.getString(StorageKeys.notificationSchedule);
  final schedule = stored == null ? const NotificationSchedule() : NotificationSchedule.fromJson(jsonDecode(stored) as Map<String, dynamic>);
  final current = now ?? DateTime.now();
  if (!schedule.isEnabled || !schedule.allows(current)) {
    debugPrint('[WorkManager] Outside schedule at $current, skipping');
    return null;
  }

  var pool = const <Pointing>[];
  try {
    pool = await loadPool();
  } catch (e) {
    debugPrint('[WorkManager] Pool load failed, using fallback: $e');
  }
  final next = await NotificationRotation.takeSelectedFor(prefs, pool.isEmpty ? _fallbackPointings : pool, [current]);
  await initialize?.call(plugin);
  await showPointingNotification(plugin, next.first, now: current);
  return next.first.id;
}

/** Fallback pointings if the content asset cannot be loaded. */
const _fallbackPointings = <Pointing>[
  Pointing(
    id: 'fallback_1',
    content: 'You are not the body, not the mind. You are the awareness in which both appear.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
  ),
  Pointing(id: 'fallback_3', content: 'Before thought arises, what are you?', tradition: Tradition.zen, contexts: [PointingContext.general]),
];

/**
 * Service for scheduling background notifications via the WorkManager plugin.
 *
 * WorkManager tasks survive app kills and device reboots, making them
 * more reliable than `AlarmManager`-based scheduling. All methods are
 * static — no instance state is required.
 *
 * Notification content comes from the full pointing pool via [NotificationRotation].
 */
class WorkManagerService {
  static bool _isInitialized = false;

  /** Initialize WorkManager. Call once at app startup. */
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Workmanager().initialize(callbackDispatcher);

    _isInitialized = true;
    debugPrint('[WorkManagerService] Initialized');
  }

  /**
   * Schedule periodic notifications.
   * [frequencyMinutes] - How often to show notifications (minimum 15 minutes on Android)
   */
  static Future<void> schedulePeriodicNotifications({required int frequencyMinutes, required int startHour, required int endHour}) async {
    // Save preferences for background access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.notificationsEnabled, true);
    await prefs.setInt(StorageKeys.notificationFrequency, frequencyMinutes);
    await prefs.setInt(StorageKeys.notificationStartHour, startHour);
    await prefs.setInt(StorageKeys.notificationEndHour, endHour);

    // Cancel existing work
    await Workmanager().cancelByUniqueName(WorkManagerTasks.periodicNotification);

    // WorkManager has a minimum period of 15 minutes on Android
    final effectiveFrequency = frequencyMinutes < 15 ? 15 : frequencyMinutes;

    // Register periodic task
    await Workmanager().registerPeriodicTask(
      WorkManagerTasks.periodicNotification,
      WorkManagerTasks.periodicNotification,
      frequency: Duration(minutes: effectiveFrequency),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );

    debugPrint('[WorkManagerService] Scheduled periodic notifications every $effectiveFrequency minutes');
  }

  /** Schedule a one-time notification after a delay. */
  static Future<void> scheduleOneTimeNotification({required Duration delay, String? uniqueName}) async {
    final taskName = uniqueName ?? 'oneTime_${DateTime.now().millisecondsSinceEpoch}';

    await Workmanager().registerOneOffTask(
      taskName,
      WorkManagerTasks.oneTimeNotification,
      initialDelay: delay,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    debugPrint('[WorkManagerService] Scheduled one-time notification in ${delay.inMinutes} minutes');
  }

  /**
   * Cancel all scheduled WorkManager tasks.
   * Note: Does NOT modify the enabled preference - that's managed by NotificationService.
   */
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    debugPrint('[WorkManagerService] Cancelled all WorkManager tasks');
  }

  /** Cancel periodic notifications only. */
  static Future<void> cancelPeriodic() async {
    await Workmanager().cancelByUniqueName(WorkManagerTasks.periodicNotification);
    debugPrint('[WorkManagerService] Cancelled periodic notifications');
  }
}
