import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Task names for WorkManager
class WorkManagerTasks {
  static const String periodicNotification = 'periodicNotification';
  static const String oneTimeNotification = 'oneTimeNotification';
}

/// Storage keys for notification preferences
class _NotificationKeys {
  static const String enabled = 'pointer_notifications_enabled';
  static const String frequencyMinutes = 'pointer_notification_frequency';
  static const String startHour = 'pointer_notification_start_hour';
  static const String endHour = 'pointer_notification_end_hour';
}

/// Top-level callback dispatcher for WorkManager.
/// This MUST be a top-level function (not a class method).
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
      debugPrint('[WorkManager] Error executing task: $e');
      return false;
    }
  });
}

/// Show a notification from background context.
/// This runs without Flutter engine, so we use minimal dependencies.
Future<void> _showNotificationFromBackground() async {
  final prefs = await SharedPreferences.getInstance();

  // Check if notifications are enabled
  final enabled = prefs.getBool(_NotificationKeys.enabled) ?? false;
  if (!enabled) {
    debugPrint('[WorkManager] Notifications disabled, skipping');
    return;
  }

  // Check if we're within the notification window
  final now = DateTime.now();
  final startHour = prefs.getInt(_NotificationKeys.startHour) ?? 8;
  final endHour = prefs.getInt(_NotificationKeys.endHour) ?? 21;

  if (now.hour < startHour || now.hour >= endHour) {
    print('[WorkManager] Outside notification window ($startHour-$endHour), current hour: ${now.hour}');
    return;
  }

  // Initialize notifications plugin
  final plugin = FlutterLocalNotificationsPlugin();

  const androidSettings = AndroidInitializationSettings('@drawable/ic_notification');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

  await plugin.initialize(initSettings);

  // Show notification with a random pointing
  final pointing = _getRandomPointing();

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    "Today's Pointing",
    pointing['content'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        'pointings_v6',
        'Daily Pointings',
        channelDescription: 'Gentle reminders for your daily pointing',
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          pointing['content']!,
          contentTitle: "Today's Pointing",
          summaryText: pointing['tradition'],
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
      ),
    ),
    payload: pointing['id'],
  );

  debugPrint('[WorkManager] Notification shown successfully');
}

/// Get a random pointing for the notification.
/// Simplified version that doesn't require full data loading.
Map<String, String> _getRandomPointing() {
  // Sample pointings for background notifications
  // In a full implementation, you might load these from SharedPreferences cache
  final pointings = [
    {
      'id': 'bg_1',
      'content': 'You are not the body, not the mind. You are the awareness in which both appear.',
      'tradition': 'Advaita',
    },
    {
      'id': 'bg_2',
      'content': 'What is it that is aware right now? Look directly, without thinking.',
      'tradition': 'Direct Path',
    },
    {
      'id': 'bg_3',
      'content': 'Before thought arises, what are you?',
      'tradition': 'Zen',
    },
    {
      'id': 'bg_4',
      'content': 'Rest in the gap between thoughts. This is your natural state.',
      'tradition': 'Contemporary',
    },
    {
      'id': 'bg_5',
      'content': 'The one who is looking is what you are looking for.',
      'tradition': 'Advaita',
    },
  ];

  return pointings[Random().nextInt(pointings.length)];
}

/// Service for managing WorkManager-based notifications.
class WorkManagerService {
  static bool _isInitialized = false;

  /// Initialize WorkManager. Call once at app startup.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );

    _isInitialized = true;
    debugPrint('[WorkManagerService] Initialized');
  }

  /// Schedule periodic notifications.
  /// [frequencyMinutes] - How often to show notifications (minimum 15 minutes on Android)
  static Future<void> schedulePeriodicNotifications({
    required int frequencyMinutes,
    required int startHour,
    required int endHour,
  }) async {
    // Save preferences for background access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_NotificationKeys.enabled, true);
    await prefs.setInt(_NotificationKeys.frequencyMinutes, frequencyMinutes);
    await prefs.setInt(_NotificationKeys.startHour, startHour);
    await prefs.setInt(_NotificationKeys.endHour, endHour);

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

  /// Schedule a one-time notification after a delay.
  static Future<void> scheduleOneTimeNotification({
    required Duration delay,
    String? uniqueName,
  }) async {
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

  /// Cancel all scheduled WorkManager tasks.
  /// Note: Does NOT modify the enabled preference - that's managed by NotificationService.
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    debugPrint('[WorkManagerService] Cancelled all WorkManager tasks');
  }

  /// Cancel periodic notifications only.
  static Future<void> cancelPeriodic() async {
    await Workmanager().cancelByUniqueName(WorkManagerTasks.periodicNotification);
    debugPrint('[WorkManagerService] Cancelled periodic notifications');
  }
}
