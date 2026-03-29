import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/pointings.dart';
import 'storage_service.dart';
import 'workmanager_service.dart';

/**
 * Quick schedule presets for one-tap notification configuration.
 *
 * Each preset maps to a [NotificationSchedule] with predefined
 * time window and frequency parameters.
 */
enum NotificationPreset {
  /** 6am-10am, every 2 hours — for morning practice. */
  morningOnly,

  /** 8am-9pm, every 3 hours — gentle reminders throughout the day. */
  throughoutDay,

  /** 5pm-10pm, every 2 hours — for evening contemplation. */
  eveningFocus,

  /** 8am-8pm, every 6 hours — least intrusive schedule. */
  minimal;

  String get label {
    switch (this) {
      case NotificationPreset.morningOnly:
        return 'Morning';
      case NotificationPreset.throughoutDay:
        return 'All day';
      case NotificationPreset.eveningFocus:
        return 'Evening';
      case NotificationPreset.minimal:
        return 'Minimal';
    }
  }

  String get description {
    switch (this) {
      case NotificationPreset.morningOnly:
        return '6am - 10am, every 2 hours';
      case NotificationPreset.throughoutDay:
        return '8am - 9pm, every 3 hours';
      case NotificationPreset.eveningFocus:
        return '5pm - 10pm, every 2 hours';
      case NotificationPreset.minimal:
        return '8am - 8pm, every 6 hours';
    }
  }

  NotificationSchedule get schedule {
    switch (this) {
      case NotificationPreset.morningOnly:
        return const NotificationSchedule(startHour: 6, endHour: 10, frequencyMinutes: 120);
      case NotificationPreset.throughoutDay:
        return const NotificationSchedule(startHour: 8, endHour: 21, frequencyMinutes: 180);
      case NotificationPreset.eveningFocus:
        return const NotificationSchedule(startHour: 17, endHour: 22, frequencyMinutes: 120);
      case NotificationPreset.minimal:
        return const NotificationSchedule(startHour: 8, endHour: 20, frequencyMinutes: 360);
    }
  }
}

/**
 * Notification schedule using a time-window + frequency model.
 *
 * Notifications fire at [frequencyMinutes] intervals between [startHour]:[startMinute]
 * and [endHour]:[endMinute], skipping any times that fall within the quiet-hours
 * window ([quietStartHour] to [quietEndHour]).
 *
 * Persisted as JSON via [NotificationService.saveSchedule].
 */
class NotificationSchedule {
  /** Hour (0-23) when the notification window opens. */
  final int startHour;

  /** Minute (0-59) offset for the window start. */
  final int startMinute;

  /** Hour (0-23) when the notification window closes. */
  final int endHour;

  /** Minute (0-59) offset for the window end. */
  final int endMinute;

  /** Interval in minutes between consecutive notifications (30-720). */
  final int frequencyMinutes;

  /** Hour (0-23) when quiet hours begin (no notifications). */
  final int quietStartHour;

  /** Hour (0-23) when quiet hours end. */
  final int quietEndHour;

  /** Whether this schedule is currently active. */
  final bool isEnabled;

  const NotificationSchedule({
    this.startHour = 8,
    this.startMinute = 0,
    this.endHour = 21,
    this.endMinute = 0,
    this.frequencyMinutes = 180, // 3 hours default
    this.quietStartHour = 22,
    this.quietEndHour = 7,
    this.isEnabled = true,
  });

  NotificationSchedule copyWith({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    int? frequencyMinutes,
    int? quietStartHour,
    int? quietEndHour,
    bool? isEnabled,
  }) {
    return NotificationSchedule(
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  /** Calculate notification times within window for a given date. */
  List<DateTime> getNotificationTimes(DateTime date) {
    final times = <DateTime>[];
    var current = DateTime(date.year, date.month, date.day, startHour, startMinute);
    final end = DateTime(date.year, date.month, date.day, endHour, endMinute);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      if (!_isInQuietHours(current)) {
        times.add(current);
      }
      current = current.add(Duration(minutes: frequencyMinutes));
    }
    return times;
  }

  bool _isInQuietHours(DateTime time) {
    final hour = time.hour;
    if (quietStartHour > quietEndHour) {
      return hour >= quietStartHour || hour < quietEndHour;
    } else {
      return hour >= quietStartHour && hour < quietEndHour;
    }
  }

  Map<String, dynamic> toJson() => {
    'startHour': startHour,
    'startMinute': startMinute,
    'endHour': endHour,
    'endMinute': endMinute,
    'frequencyMinutes': frequencyMinutes,
    'quietStartHour': quietStartHour,
    'quietEndHour': quietEndHour,
    'isEnabled': isEnabled,
  };

  factory NotificationSchedule.fromJson(Map<String, dynamic> json) {
    final frequencyMinutes = json['frequencyMinutes'] ?? ((json['frequencyHours'] as int? ?? 3) * 60);

    return NotificationSchedule(
      startHour: json['startHour'] ?? 8,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 21,
      endMinute: json['endMinute'] ?? 0,
      frequencyMinutes: frequencyMinutes,
      quietStartHour: json['quietStartHour'] ?? 22,
      quietEndHour: json['quietEndHour'] ?? 7,
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  /** Format time for display (e.g., "8:00 AM"). */
  static String formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /** Get display summary (e.g., "Every 3 hours, 8am - 9pm"). */
  String get summary {
    final start = formatTime(startHour, startMinute);
    final end = formatTime(endHour, endMinute);
    final freqLabel = frequencyMinutes < 60
        ? 'Every $frequencyMinutes min'
        : 'Every ${frequencyMinutes ~/ 60} hour${frequencyMinutes >= 120 ? 's' : ''}';
    return '$freqLabel, $start - $end';
  }
}

/**
 * Service for managing local notifications with non-urgent styling.
 */
class NotificationService {
  final SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _localNotifications;
  static bool _timeZonesInitialized = false;
  static const int _iosScheduleIdBase = 50000;
  static const int _iosScheduleBatchLimit = 60;

  NotificationService(this._prefs, [FlutterLocalNotificationsPlugin? plugin]) : _localNotifications = plugin ?? FlutterLocalNotificationsPlugin();

  static const androidChannel = AndroidNotificationChannel(
    'pointings_v6',
    'Daily Pointings',
    description: 'Gentle reminders for your daily pointing',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('bell_chime'),
  );

  static const iosNotificationDetails = DarwinNotificationDetails(
    interruptionLevel: InterruptionLevel.passive,
    presentSound: false,
    presentBanner: false,
    presentList: true,
  );

  static const androidNotificationDetails = AndroidNotificationDetails(
    'pointings_v6',
    'Daily Pointings',
    channelDescription: 'Gentle reminders for your daily pointing',
    importance: Importance.max,
    priority: Priority.max,
    enableVibration: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('bell_chime'),
    styleInformation: BigTextStyleInformation(''),
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('save', 'Save', showsUserInterface: false, cancelNotification: false),
      AndroidNotificationAction('another', 'Another', showsUserInterface: false, cancelNotification: true),
    ],
  );

  static const notificationDetails = NotificationDetails(iOS: iosNotificationDetails, android: androidNotificationDetails);

  // ============================================================
  // Preferences Management
  // ============================================================

  /** Whether notifications are enabled. */
  bool get isNotificationsEnabled => _prefs.getBool(StorageKeys.notificationsEnabled) ?? false;

  /** Enable or disable notifications. */
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(StorageKeys.notificationsEnabled, enabled);
    if (enabled) {
      await cachePointingsForBackground();
      await scheduleAllNotifications();
    } else {
      await cancelAllNotifications();
    }
  }

  /** Cache pointings data for background notification access. */
  Future<void> cachePointingsForBackground() async {
    final morningPointings = pointings
        .where((p) => p.contexts.contains(PointingContext.morning) || p.contexts.contains(PointingContext.general))
        .take(20)
        .toList();

    final middayPointings = pointings
        .where((p) => p.contexts.contains(PointingContext.midday) || p.contexts.contains(PointingContext.general))
        .take(20)
        .toList();

    final eveningPointings = pointings
        .where((p) => p.contexts.contains(PointingContext.evening) || p.contexts.contains(PointingContext.general))
        .take(20)
        .toList();

    final cache = {
      'morning': morningPointings.map((p) => {'id': p.id, 'content': p.content, 'tradition': p.tradition.name, 'teacher': p.teacher}).toList(),
      'midday': middayPointings.map((p) => {'id': p.id, 'content': p.content, 'tradition': p.tradition.name, 'teacher': p.teacher}).toList(),
      'evening': eveningPointings.map((p) => {'id': p.id, 'content': p.content, 'tradition': p.tradition.name, 'teacher': p.teacher}).toList(),
    };

    await _prefs.setString(StorageKeys.notificationPointingsCache, jsonEncode(cache));
    debugPrint('[NotificationService] Cached ${morningPointings.length + middayPointings.length + eveningPointings.length} pointings for background');
  }

  /** Get the notification schedule (Phase 5.1 time window model). */
  NotificationSchedule getSchedule() {
    final stored = _prefs.getString(StorageKeys.notificationSchedule);
    if (stored == null) return const NotificationSchedule();
    return NotificationSchedule.fromJson(jsonDecode(stored));
  }

  /** Save notification schedule configuration. */
  Future<void> saveSchedule(NotificationSchedule schedule) async {
    final encoded = jsonEncode(schedule.toJson());
    await _prefs.setString(StorageKeys.notificationSchedule, encoded);
    await scheduleAllNotifications();
  }

  // ============================================================
  // Initialization
  // ============================================================

  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationResponse,
    void Function(NotificationResponse)? onBackgroundNotificationResponse,
  }) async {
    const initSettingsAndroid = AndroidInitializationSettings('@drawable/ic_notification');

    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: false,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );

    const initSettings = InitializationSettings(android: initSettingsAndroid, iOS: initSettingsIOS);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );

    await _configureAndroidChannel();
  }

  Future<void> _configureAndroidChannel() async {
    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermissions() async {
    final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosPlugin?.requestPermissions(alert: true, badge: true, sound: false);

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await androidPlugin?.requestNotificationsPermission();

    return (iosGranted ?? true) && (androidGranted ?? true);
  }

  Future<bool> checkPermissions() async {
    try {
      final iosPlugin = _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final iosSettings = await iosPlugin?.checkPermissions();
      final iosGranted = iosSettings?.isEnabled ?? true;

      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted = await androidPlugin?.areNotificationsEnabled() ?? true;

      return iosGranted && androidGranted;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // Scheduling (via WorkManager)
  // ============================================================

  Future<void> scheduleAllNotifications() async {
    await _localNotifications.cancelAll();
    if (Platform.isAndroid) {
      await WorkManagerService.cancelAll();
    }

    if (!isNotificationsEnabled) return;

    final schedule = getSchedule();
    if (!schedule.isEnabled) return;

    if (Platform.isIOS) {
      final count = await _scheduleIosBatchNotifications(schedule);
      debugPrint('[NotificationService] iOS batch scheduled: $count notifications');
      return;
    }

    debugPrint(
      '[NotificationService] Scheduling via WorkManager: freq=${schedule.frequencyMinutes}min, ${schedule.startHour}:00-${schedule.endHour}:00',
    );

    await WorkManagerService.schedulePeriodicNotifications(
      frequencyMinutes: schedule.frequencyMinutes,
      startHour: schedule.startHour,
      endHour: schedule.endHour,
    );

    debugPrint('[NotificationService] WorkManager scheduled successfully');
  }

  void _initializeTimeZonesIfNeeded() {
    if (_timeZonesInitialized) return;
    tz_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  Future<int> _scheduleIosBatchNotifications(NotificationSchedule schedule) async {
    _initializeTimeZonesIfNeeded();

    final now = DateTime.now();
    final windowStart = DateTime(now.year, now.month, now.day);
    final windowEnd = windowStart.add(const Duration(days: 14));
    final scheduledTimes = <DateTime>[];

    var day = windowStart;
    while (day.isBefore(windowEnd) && scheduledTimes.length < _iosScheduleBatchLimit) {
      final timesForDay = schedule.getNotificationTimes(day);
      for (final time in timesForDay) {
        if (!time.isAfter(now)) continue;
        scheduledTimes.add(time);
        if (scheduledTimes.length >= _iosScheduleBatchLimit) break;
      }
      day = day.add(const Duration(days: 1));
    }

    for (var i = 0; i < scheduledTimes.length; i++) {
      final localTime = scheduledTimes[i];
      final scheduledAtUtc = tz.TZDateTime.from(localTime.toUtc(), tz.UTC);
      final pointing = getRandomPointing();

      await _localNotifications.zonedSchedule(
        _iosScheduleIdBase + i,
        "Today's Pointing",
        pointing.content,
        scheduledAtUtc,
        _buildRichNotificationDetails(pointing),
        payload: pointing.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    return scheduledTimes.length;
  }

  Future<void> showImmediateNotification(Pointing pointing) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "Today's Pointing",
      pointing.content,
      _buildRichNotificationDetails(pointing),
      payload: pointing.id,
    );
  }

  NotificationDetails _buildRichNotificationDetails(Pointing pointing) {
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
          contentTitle: "Today's Pointing",
          summaryText: subtitle,
          htmlFormatBigText: false,
          htmlFormatContentTitle: false,
          htmlFormatSummaryText: false,
        ),
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction('save', 'Save', showsUserInterface: false, cancelNotification: false),
          AndroidNotificationAction('another', 'Another', showsUserInterface: false, cancelNotification: true),
        ],
      ),
    );
  }

  Future<void> sendTestNotification() async {
    final pointing = getRandomPointing();
    final traditionName = traditions[pointing.tradition]?.name ?? pointing.tradition.name;
    final attribution = pointing.teacher != null ? '— ${pointing.teacher}' : '';
    final subtitle = '$traditionName $attribution'.trim();

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "🧪 Test Notification",
      pointing.content,
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
          presentAlert: true,
          presentSound: true,
          presentBanner: true,
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
          styleInformation: BigTextStyleInformation(pointing.content, contentTitle: "🧪 Test Notification", summaryText: subtitle),
        ),
      ),
      payload: pointing.id,
    );
    debugPrint('[NotificationService] Test notification sent: ${pointing.id}');
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    if (Platform.isAndroid) {
      await WorkManagerService.cancelAll();
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  Future<void> debugPrintPendingNotifications() async {
    final pending = await getPendingNotifications();
    debugPrint('[NotificationService] ===== PENDING NOTIFICATIONS =====');
    debugPrint('[NotificationService] Total pending: ${pending.length}');
    debugPrint('[NotificationService] Mode: inexactAllowWhileIdle (no exact alarm permission needed)');
    for (final notification in pending) {
      debugPrint('[NotificationService]   ID: ${notification.id}, Title: ${notification.title}');
      debugPrint('[NotificationService]   Body: ${notification.body?.substring(0, (notification.body?.length ?? 0).clamp(0, 50))}...');
      debugPrint('[NotificationService]   Payload: ${notification.payload}');
    }
    debugPrint('[NotificationService] ================================');
  }
}
