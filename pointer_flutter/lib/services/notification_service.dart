import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/pointings.dart';

/// Notification time configuration.
class NotificationTime {
  final String id;
  final int hour;
  final int minute;
  final bool isEnabled;

  const NotificationTime({
    required this.id,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
  });

  NotificationTime copyWith({
    String? id,
    int? hour,
    int? minute,
    bool? isEnabled,
  }) {
    return NotificationTime(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'isEnabled': isEnabled,
      };

  factory NotificationTime.fromJson(Map<String, dynamic> json) {
    return NotificationTime(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}

/// Storage keys for notification preferences.
class _NotificationStorageKeys {
  static const notificationsEnabled = 'pointer_notifications_enabled';
  static const notificationTimes = 'pointer_notification_times';
}

/// Service for managing local notifications with non-urgent styling.
///
/// Notifications are configured to be mindful and non-intrusive:
/// - iOS: Uses passive interruption level (respects Focus modes)
/// - Android: Uses low importance channel (no sound, no peek)
/// - No vibration or sound by default
/// - Visible only in notification center, not as banners
class NotificationService {
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationService(this._prefs, [FlutterLocalNotificationsPlugin? plugin])
      : _localNotifications = plugin ?? FlutterLocalNotificationsPlugin();

  /// Android notification channel with low importance for non-urgent delivery.
  ///
  /// Low importance ensures:
  /// - No sound
  /// - No heads-up notification (peek)
  /// - Appears in notification shade only
  static const androidChannel = AndroidNotificationChannel(
    'pointings',
    'Daily Pointings',
    description: 'Gentle reminders for your daily pointing',
    importance: Importance.low,
    enableVibration: false,
    playSound: false,
  );

  /// iOS notification details with passive interruption level.
  ///
  /// Passive interruption ensures:
  /// - Respects Focus modes
  /// - No sound
  /// - No banner (no visual interruption)
  /// - Shows in notification list only
  static const iosNotificationDetails = DarwinNotificationDetails(
    interruptionLevel: InterruptionLevel.passive,
    presentSound: false,
    presentBanner: false,
    presentList: true,
  );

  /// Android notification details using the low-importance channel.
  static const androidNotificationDetails = AndroidNotificationDetails(
    'pointings',
    'Daily Pointings',
    channelDescription: 'Gentle reminders for your daily pointing',
    importance: Importance.low,
    priority: Priority.low,
    enableVibration: false,
    playSound: false,
  );

  /// Combined notification details for cross-platform use.
  static const notificationDetails = NotificationDetails(
    iOS: iosNotificationDetails,
    android: androidNotificationDetails,
  );

  // ============================================================
  // Preferences Management
  // ============================================================

  /// Whether notifications are enabled.
  bool get isNotificationsEnabled =>
      _prefs.getBool(_NotificationStorageKeys.notificationsEnabled) ?? false;

  /// Enable or disable notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_NotificationStorageKeys.notificationsEnabled, enabled);
    if (enabled) {
      await scheduleAllNotifications();
    } else {
      await cancelAllNotifications();
    }
  }

  /// Get configured notification times.
  List<NotificationTime> getNotificationTimes() {
    final stored = _prefs.getString(_NotificationStorageKeys.notificationTimes);
    if (stored == null) return [];
    final List<dynamic> decoded = jsonDecode(stored);
    return decoded
        .map((e) => NotificationTime.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Save notification times configuration.
  Future<void> saveNotificationTimes(List<NotificationTime> times) async {
    final encoded = jsonEncode(times.map((t) => t.toJson()).toList());
    await _prefs.setString(_NotificationStorageKeys.notificationTimes, encoded);
    await scheduleAllNotifications();
  }

  // ============================================================
  // Initialization
  // ============================================================

  /// Initialize the notification service.
  ///
  /// Sets up platform-specific configurations and creates the Android
  /// notification channel.
  Future<void> initialize() async {
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotifications.initialize(initSettings);

    // Create the Android notification channel
    await _configureAndroidChannel();
  }

  /// Configure the Android notification channel.
  Future<void> _configureAndroidChannel() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  /// Request notification permissions from the user.
  Future<bool> requestPermissions() async {
    // iOS permissions
    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: false, // We don't need sound for non-urgent notifications
    );

    // Android 13+ permissions
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final androidGranted = await androidPlugin?.requestNotificationsPermission();

    return (iosGranted ?? true) && (androidGranted ?? true);
  }

  // ============================================================
  // Scheduling
  // ============================================================

  /// Schedule all configured notifications.
  Future<void> scheduleAllNotifications() async {
    await cancelAllNotifications();

    if (!isNotificationsEnabled) return;

    final times = getNotificationTimes();
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      if (time.isEnabled) {
        await _scheduleDaily(i, time);
      }
    }
  }

  /// Schedule a daily notification at the specified time.
  Future<void> _scheduleDaily(int id, NotificationTime time) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final pointing = getRandomPointing();

    await _localNotifications.zonedSchedule(
      id,
      "Today's Pointing",
      pointing.content,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: pointing.id,
    );
  }

  /// Schedule a pointing notification at the specified time.
  Future<void> schedulePointing({
    required int id,
    required Pointing pointing,
    required DateTime scheduledTime,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      "Today's Pointing",
      pointing.content,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: pointing.id,
    );
  }

  /// Show an immediate notification for a pointing.
  Future<void> showImmediateNotification(Pointing pointing) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "Today's Pointing",
      pointing.content,
      notificationDetails,
      payload: pointing.id,
    );
  }

  /// Send a test notification.
  Future<void> sendTestNotification() async {
    final pointing = getRandomPointing();
    await showImmediateNotification(pointing);
  }

  /// Cancel a scheduled notification.
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}
