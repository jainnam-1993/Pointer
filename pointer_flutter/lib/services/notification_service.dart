import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/pointings.dart';

/// Storage keys for notification settings
class NotificationStorageKeys {
  static const notificationTimes = 'pointer_notification_times';
  static const notificationsEnabled = 'pointer_notifications_enabled';
}

/// Model for scheduled notification times
class NotificationTime {
  final String id;
  final int hour;
  final int minute;
  final bool enabled;
  final String label;

  const NotificationTime({
    required this.id,
    required this.hour,
    required this.minute,
    required this.enabled,
    required this.label,
  });

  NotificationTime copyWith({
    String? id,
    int? hour,
    int? minute,
    bool? enabled,
    String? label,
  }) {
    return NotificationTime(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
        'label': label,
      };

  factory NotificationTime.fromJson(Map<String, dynamic> json) {
    return NotificationTime(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      enabled: json['enabled'] as bool,
      label: json['label'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTime &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          hour == other.hour &&
          minute == other.minute &&
          enabled == other.enabled &&
          label == other.label;

  @override
  int get hashCode =>
      id.hashCode ^ hour.hashCode ^ minute.hashCode ^ enabled.hashCode ^ label.hashCode;
}

/// Default notification times
const defaultNotificationTimes = <NotificationTime>[
  NotificationTime(id: 'morning', hour: 8, minute: 0, enabled: true, label: 'Morning'),
  NotificationTime(id: 'afternoon', hour: 14, minute: 0, enabled: true, label: 'Afternoon'),
  NotificationTime(id: 'evening', hour: 20, minute: 0, enabled: true, label: 'Evening'),
];

/// Callback for handling notification taps (must be top-level for background)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Handle background notification tap
  debugPrint('Notification tapped in background: ${response.payload}');
}

/// Service for managing local notifications
class NotificationService {
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _notifications;
  final Random _random = Random();

  static const _channelId = 'pointings';
  static const _channelName = 'Daily Pointings';
  static const _channelDescription = 'Notifications for daily non-dual pointings';

  NotificationService(this._prefs)
      : _notifications = FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  Future<void> initialize() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    final String timeZoneName = await _getLocalTimeZone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS/macOS initialization settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize plugin
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _createAndroidChannel();
    }
  }

  /// Get local timezone name
  Future<String> _getLocalTimeZone() async {
    try {
      // On most platforms, this gives us the local timezone
      final now = DateTime.now();
      final offset = now.timeZoneOffset;

      // Map common offsets to timezone names
      // In production, use flutter_timezone package for accurate detection
      if (offset.inHours == -8) return 'America/Los_Angeles';
      if (offset.inHours == -7) return 'America/Denver';
      if (offset.inHours == -6) return 'America/Chicago';
      if (offset.inHours == -5) return 'America/New_York';
      if (offset.inHours == 0) return 'Europe/London';
      if (offset.inHours == 1) return 'Europe/Paris';
      if (offset.inHours == 5 && offset.inMinutes == 30) return 'Asia/Kolkata';
      if (offset.inHours == 8) return 'Asia/Shanghai';
      if (offset.inHours == 9) return 'Asia/Tokyo';

      // Default to UTC if timezone unknown
      return 'UTC';
    } catch (e) {
      return 'UTC';
    }
  }

  /// Create Android notification channel
  Future<void> _createAndroidChannel() async {
    final channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: false,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      ledColor: const Color(0xFF9333EA),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Payload contains pointing ID - can be used to navigate to specific pointing
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: false,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  /// Check if notifications are enabled in app settings
  bool get isNotificationsEnabled {
    return _prefs.getBool(NotificationStorageKeys.notificationsEnabled) ?? false;
  }

  /// Set notifications enabled state
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(NotificationStorageKeys.notificationsEnabled, enabled);

    if (enabled) {
      final granted = await requestPermissions();
      if (granted) {
        await scheduleAllNotifications();
      }
    } else {
      await cancelAllNotifications();
    }
  }

  /// Get saved notification times or defaults
  List<NotificationTime> getNotificationTimes() {
    final stored = _prefs.getString(NotificationStorageKeys.notificationTimes);
    if (stored == null) return List.from(defaultNotificationTimes);

    try {
      final List<dynamic> decoded = jsonDecode(stored);
      return decoded.map((e) => NotificationTime.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return List.from(defaultNotificationTimes);
    }
  }

  /// Save notification times and reschedule
  Future<void> saveNotificationTimes(List<NotificationTime> times) async {
    final encoded = jsonEncode(times.map((t) => t.toJson()).toList());
    await _prefs.setString(NotificationStorageKeys.notificationTimes, encoded);
    await scheduleAllNotifications();
  }

  /// Schedule all enabled notifications
  Future<void> scheduleAllNotifications() async {
    // Cancel existing notifications first
    await cancelAllNotifications();

    if (!isNotificationsEnabled) return;

    final times = getNotificationTimes();

    for (final time in times) {
      if (time.enabled) {
        await _scheduleDailyNotification(time);
      }
    }
  }

  /// Schedule a single daily notification
  Future<void> _scheduleDailyNotification(NotificationTime time) async {
    final pointing = getRandomPointing();
    final notificationId = _getNotificationId(time.id);

    // Calculate next occurrence
    final scheduledDate = _nextInstanceOfTime(time.hour, time.minute);

    // Truncate content for notification body
    final body = pointing.content.length > 100
        ? '${pointing.content.substring(0, 100)}...'
        : pointing.content;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
      color: Color(0xFF9333EA),
      category: AndroidNotificationCategory.reminder,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      presentBanner: true,
      presentList: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      'A Pointing Awaits',
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: pointing.id,
    );
  }

  /// Calculate next occurrence of given time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Generate consistent notification ID from string ID
  int _getNotificationId(String id) {
    // Simple hash to get consistent int ID
    return id.hashCode.abs() % 100000;
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Send a test notification immediately
  Future<void> sendTestNotification() async {
    final pointing = getRandomPointing();

    final body = pointing.content.length > 100
        ? '${pointing.content.substring(0, 100)}...'
        : pointing.content;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      enableVibration: true,
      color: Color(0xFF9333EA),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
      presentBanner: true,
      presentList: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notifications.show(
      _random.nextInt(100000),
      'Test Notification',
      body,
      details,
      payload: '${pointing.id}:test',
    );
  }

  /// Get pending notification requests (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return _notifications.pendingNotificationRequests();
  }
}

