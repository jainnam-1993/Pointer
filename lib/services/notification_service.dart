import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/pointings.dart';
import 'notification_content.dart';
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
      if (allows(current)) {
        times.add(current);
      }
      current = current.add(Duration(minutes: frequencyMinutes));
    }
    return times;
  }

  /**
   * The single delivery rule shared by iOS batches and the Android WorkManager task.
   *
   * True when [time] falls inside the window, inclusive at both ends to the
   * minute, and outside quiet hours.
   */
  bool allows(DateTime time) {
    final minute = time.hour * 60 + time.minute;
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    final inWindow = start <= end ? (minute >= start && minute <= end) : (minute >= start || minute <= end);
    return inWindow && !_isInQuietHours(time);
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
    actions: pointingNotificationActions,
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
      await scheduleAllNotifications();
    } else {
      await cancelScheduledNotifications();
    }
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
  // Scheduling
  // ============================================================

  /** Minimum time between automatic iOS batch refills. */
  static const Duration refillInterval = Duration(hours: 6);

  /** Epoch millis of the last iOS batch build. */
  static const String lastRefillKey = 'pointer_notification_last_refill_ms';

  /** JSON map of each pending iOS request id this service owns to its fire time (epoch millis). */
  static const String iosScheduledKey = 'pointer_notification_ios_scheduled';

  /** Next iOS request id to hand out; ids rotate through [_iosIdSpan] values and are never reused while pending. */
  static const String _iosNextIdKey = 'pointer_notification_ios_next_id';

  /**
   * Size of the iOS id range. Ids are not reused soon, because cancelling or
   * replacing an id on iOS also removes a delivered notification with that id.
   */
  static const int _iosIdSpan = 10000;

  static bool _ownsIosId(int id) => id >= _iosScheduleIdBase && id < _iosScheduleIdBase + _iosIdSpan;

  /** Test-only platform override; null means use [Platform]. */
  @visibleForTesting
  static TargetPlatform? platformOverride;

  static bool get _isIOS => platformOverride != null ? platformOverride == TargetPlatform.iOS : Platform.isIOS;
  static bool get _isAndroid => platformOverride != null ? platformOverride == TargetPlatform.android : Platform.isAndroid;

  /**
   * Top up the iOS pending batch when it is due. The one entry point for
   * automatic refills, called at startup and on every app resume.
   *
   * A refill never touches delivered notifications and keeps every pending
   * request: it schedules only the tail after the last pending time, so the
   * rotation advances by exactly the number of new requests.
   *
   * Throttled to once per [refillInterval]. Returns whether a refill ran.
   * Android needs no refill: its WorkManager task is periodic.
   */
  Future<bool> refillIfDue({DateTime? now}) async {
    if (!_isIOS || !isNotificationsEnabled) return false;
    final current = now ?? DateTime.now();
    final last = _prefs.getInt(lastRefillKey);
    if (last != null) {
      final elapsed = current.difference(DateTime.fromMillisecondsSinceEpoch(last));
      if (!elapsed.isNegative && elapsed < refillInterval) return false;
    }
    final schedule = getSchedule();
    if (!schedule.isEnabled) return false;
    final count = await _topUpIosBatch(schedule, current);
    await _prefs.setInt(lastRefillKey, current.millisecondsSinceEpoch);
    debugPrint('[NotificationService] iOS refill scheduled $count new notifications');
    return true;
  }

  /**
   * Rebuild the schedule after an explicit change from Settings: cancel the
   * pending pointings and schedule afresh. Delivered notifications stay in
   * Notification Center.
   */
  Future<void> scheduleAllNotifications({DateTime? now}) async {
    await cancelScheduledNotifications();

    if (!isNotificationsEnabled) return;

    final schedule = getSchedule();
    if (!schedule.isEnabled) return;

    if (_isIOS) {
      final current = now ?? DateTime.now();
      final count = await _topUpIosBatch(schedule, current);
      await _prefs.setInt(lastRefillKey, current.millisecondsSinceEpoch);
      debugPrint('[NotificationService] iOS batch scheduled: $count notifications');
      return;
    }
    if (!_isAndroid) return;

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

  Map<int, int> _readIosScheduled() {
    final stored = _prefs.getString(iosScheduledKey);
    if (stored == null) return {};
    try {
      return (jsonDecode(stored) as Map<String, dynamic>).map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeIosScheduled(Map<int, int> scheduled) =>
      _prefs.setString(iosScheduledKey, jsonEncode(scheduled.map((k, v) => MapEntry('$k', v))));

  /**
   * Keep the pending requests this service owns and schedule pointings for the
   * delivery times after the last one, up to [_iosScheduleBatchLimit] pending
   * within 14 days of [now]. Owned pending requests with no recorded time
   * (from an older build) are cancelled one by one and rebuilt. Returns the
   * number of new requests.
   */
  Future<int> _topUpIosBatch(NotificationSchedule schedule, DateTime now) async {
    _initializeTimeZonesIfNeeded();

    final recorded = _readIosScheduled();
    final kept = <int, int>{};
    for (final request in await _localNotifications.pendingNotificationRequests()) {
      if (!_ownsIosId(request.id)) continue;
      final at = recorded[request.id];
      if (at != null) {
        kept[request.id] = at;
      } else {
        await _localNotifications.cancel(request.id);
      }
    }

    var after = now;
    for (final at in kept.values) {
      final time = DateTime.fromMillisecondsSinceEpoch(at);
      if (time.isAfter(after)) after = time;
    }
    final times = _iosDeliveryTimes(schedule, now, after, _iosScheduleBatchLimit - kept.length);

    final batch = await NotificationRotation.takeSelectedFor(_prefs, pointings, times);
    var nextId = _prefs.getInt(_iosNextIdKey) ?? _iosScheduleIdBase;
    for (var i = 0; i < batch.length; i++) {
      while (!_ownsIosId(nextId) || kept.containsKey(nextId)) {
        nextId = _ownsIosId(nextId) ? nextId + 1 : _iosScheduleIdBase;
      }
      final id = nextId++;
      final pointing = batch[i];
      await _localNotifications.zonedSchedule(
        id,
        pointingNotificationTitle,
        pointing.content,
        tz.TZDateTime.from(times[i].toUtc(), tz.UTC),
        _buildRichNotificationDetails(pointing),
        payload: pointing.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      kept[id] = times[i].millisecondsSinceEpoch;
    }
    await _prefs.setInt(_iosNextIdKey, nextId);
    await _writeIosScheduled(kept);
    return batch.length;
  }

  /** Up to [limit] delivery times strictly after [after], within 14 days of the day of [now]. */
  static List<DateTime> _iosDeliveryTimes(NotificationSchedule schedule, DateTime now, DateTime after, int limit) {
    final times = <DateTime>[];
    if (limit <= 0) return times;
    final windowEnd = DateTime(now.year, now.month, now.day).add(const Duration(days: 14));
    var day = DateTime(after.year, after.month, after.day);
    while (day.isBefore(windowEnd) && times.length < limit) {
      for (final time in schedule.getNotificationTimes(day)) {
        if (!time.isAfter(after)) continue;
        times.add(time);
        if (times.length >= limit) break;
      }
      day = day.add(const Duration(days: 1));
    }
    return times;
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

  NotificationDetails _buildRichNotificationDetails(Pointing pointing) => buildPointingNotificationDetails(pointing);

  Future<void> sendTestNotification() async {
    final pointing = getRandomPointing();
    final traditionName = traditions[pointing.tradition]?.name ?? pointing.tradition.name;
    final attribution = pointing.teacher != null ? '— ${pointing.teacher}' : '';
    final subtitle = '$traditionName $attribution'.trim();

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "Test notification",
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
          styleInformation: BigTextStyleInformation(pointing.content, contentTitle: "Test notification", summaryText: subtitle),
        ),
      ),
      payload: pointing.id,
    );
    debugPrint('[NotificationService] Test notification sent: ${pointing.id}');
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /**
   * Stop future pointings: cancel the pending iOS requests this service owns,
   * one id at a time, or the Android WorkManager task. Never calls the
   * plugin's cancelAll, which on iOS also clears delivered notifications.
   */
  Future<void> cancelScheduledNotifications() async {
    if (_isIOS) {
      for (final request in await _localNotifications.pendingNotificationRequests()) {
        if (_ownsIosId(request.id)) await _localNotifications.cancel(request.id);
      }
      await _prefs.remove(iosScheduledKey);
    } else if (_isAndroid) {
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
