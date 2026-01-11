import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/pointings.dart';
import 'workmanager_service.dart';

/// Notification time configuration (legacy - kept for migration).
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

/// Quick schedule presets for one-tap configuration (Phase 5.3).
enum NotificationPreset {
  morningOnly,
  throughoutDay,
  eveningFocus,
  minimal,
  testEveryMinute; // Debug preset for testing

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
      case NotificationPreset.testEveryMinute:
        return '🧪 Test';
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
      case NotificationPreset.testEveryMinute:
        return 'Every 1 minute (testing only)';
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
      case NotificationPreset.testEveryMinute:
        return const NotificationSchedule(startHour: 0, endHour: 23, endMinute: 59, frequencyMinutes: 1, quietStartHour: 24, quietEndHour: 24);
    }
  }
}

/// Notification schedule with time window + frequency model (Phase 5.1).
class NotificationSchedule {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int frequencyMinutes;
  final int quietStartHour;
  final int quietEndHour;
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

  /// Calculate notification times within window for a given date.
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
      // Quiet hours span midnight (e.g., 22:00 - 07:00)
      return hour >= quietStartHour || hour < quietEndHour;
    } else {
      // Quiet hours same day (e.g., 14:00 - 16:00)
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
    // Backward compatibility: convert old frequencyHours to minutes
    final frequencyMinutes = json['frequencyMinutes'] ??
        ((json['frequencyHours'] as int? ?? 3) * 60);

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

  /// Format time for display (e.g., "8:00 AM").
  static String formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  /// Get display summary (e.g., "Every 3 hours, 8am - 9pm").
  String get summary {
    final start = formatTime(startHour, startMinute);
    final end = formatTime(endHour, endMinute);
    final freqLabel = frequencyMinutes < 60
        ? 'Every $frequencyMinutes min'
        : 'Every ${frequencyMinutes ~/ 60} hour${frequencyMinutes >= 120 ? 's' : ''}';
    return '$freqLabel, $start - $end';
  }
}

/// Storage keys for notification preferences.
class _NotificationStorageKeys {
  static const notificationsEnabled = 'pointer_notifications_enabled';
  static const notificationTimes = 'pointer_notification_times'; // Legacy
  static const notificationSchedule = 'pointer_notification_schedule';
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

  /// Android notification channel with custom chime sound.
  ///
  /// High importance with custom sound ensures:
  /// - Sound plays on notification
  /// - Heads-up notification appears
  /// - Appears in notification shade
  static const androidChannel = AndroidNotificationChannel(
    'pointings_v6',
    'Daily Pointings',
    description: 'Gentle reminders for your daily pointing',
    importance: Importance.max,  // Try MAX importance
    enableVibration: true,  // Enable vibration to trigger audio
    playSound: true,
    sound: RawResourceAndroidNotificationSound('bell_chime'),
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

  /// Android notification details with custom bell chime.
  /// Uses BigTextStyle for rich notifications with expandable text.
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
      AndroidNotificationAction(
        'save',
        'Save',
        showsUserInterface: false,
        cancelNotification: false,
      ),
      AndroidNotificationAction(
        'another',
        'Another',
        showsUserInterface: false,
        cancelNotification: true,
      ),
    ],
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

  /// Save notification times configuration (legacy).
  Future<void> saveNotificationTimes(List<NotificationTime> times) async {
    final encoded = jsonEncode(times.map((t) => t.toJson()).toList());
    await _prefs.setString(_NotificationStorageKeys.notificationTimes, encoded);
    await scheduleAllNotifications();
  }

  /// Get the notification schedule (Phase 5.1 time window model).
  NotificationSchedule getSchedule() {
    final stored = _prefs.getString(_NotificationStorageKeys.notificationSchedule);
    if (stored == null) return const NotificationSchedule();
    return NotificationSchedule.fromJson(jsonDecode(stored));
  }

  /// Save notification schedule configuration.
  Future<void> saveSchedule(NotificationSchedule schedule) async {
    final encoded = jsonEncode(schedule.toJson());
    await _prefs.setString(_NotificationStorageKeys.notificationSchedule, encoded);
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
    // Use dedicated notification icon (white-only for Android status bar)
    const initSettingsAndroid = AndroidInitializationSettings(
      '@drawable/ic_notification',
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

    // Note: We use inexact alarms which don't require SCHEDULE_EXACT_ALARM permission.
    // This is better for battery life and sufficient for a meditation app.

    return (iosGranted ?? true) && (androidGranted ?? true);
  }

  /// Check if notification permissions are currently granted without requesting.
  Future<bool> checkPermissions() async {
    try {
      // iOS: check current permission status
      final iosPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final iosSettings = await iosPlugin?.checkPermissions();
      final iosGranted = iosSettings?.isEnabled ?? true;

      // Android: check if notifications are enabled
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final androidGranted = await androidPlugin?.areNotificationsEnabled() ?? true;

      return iosGranted && androidGranted;
    } catch (_) {
      // In test environment or if plugin not available, assume granted
      return true;
    }
  }

  // ============================================================
  // Scheduling (via WorkManager)
  // ============================================================

  /// Schedule all configured notifications using WorkManager.
  /// WorkManager survives app kills and is more reliable than AlarmManager.
  Future<void> scheduleAllNotifications() async {
    // Cancel any existing WorkManager tasks
    await WorkManagerService.cancelAll();

    if (!isNotificationsEnabled) return;

    final schedule = getSchedule();
    if (!schedule.isEnabled) return;

    print('[NotificationService] Scheduling via WorkManager: freq=${schedule.frequencyMinutes}min, ${schedule.startHour}:00-${schedule.endHour}:00');

    // Use WorkManager for periodic notifications
    await WorkManagerService.schedulePeriodicNotifications(
      frequencyMinutes: schedule.frequencyMinutes,
      startHour: schedule.startHour,
      endHour: schedule.endHour,
    );

    print('[NotificationService] WorkManager scheduled successfully');
  }

  /// Show an immediate notification for a pointing.
  Future<void> showImmediateNotification(Pointing pointing) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "Today's Pointing",
      pointing.content,
      _buildRichNotificationDetails(pointing),
      payload: pointing.id,
    );
  }

  /// Build rich notification details with full pointing content.
  /// Android: Uses BigTextStyle for expandable text with tradition badge.
  /// iOS: Uses subtitle for tradition/teacher attribution.
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
          AndroidNotificationAction(
            'save',
            'Save',
            showsUserInterface: false,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            'another',
            'Another',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
    );
  }

  /// Send a test notification with visible banner (unlike passive daily notifications).
  Future<void> sendTestNotification() async {
    final pointing = getRandomPointing();
    final traditionName = traditions[pointing.tradition]?.name ?? pointing.tradition.name;
    final attribution = pointing.teacher != null ? '— ${pointing.teacher}' : '';
    final subtitle = '$traditionName $attribution'.trim();

    // Test notifications show visible banner (unlike passive daily notifications)
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      "🧪 Test Notification",
      pointing.content,
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active, // Visible!
          presentSound: true,
          presentBanner: true, // Show banner for test
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
            contentTitle: "🧪 Test Notification",
            summaryText: subtitle,
          ),
        ),
      ),
      payload: pointing.id,
    );
    print('[NotificationService] Test notification sent: ${pointing.id}');
  }

  /// Cancel a scheduled notification.
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all scheduled notifications (both local and WorkManager).
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    await WorkManagerService.cancelAll();
  }

  /// Get list of pending notifications for debugging.
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Debug: Print all pending notifications to console.
  Future<void> debugPrintPendingNotifications() async {
    final pending = await getPendingNotifications();
    print('[NotificationService] ===== PENDING NOTIFICATIONS =====');
    print('[NotificationService] Total pending: ${pending.length}');
    print('[NotificationService] Mode: inexactAllowWhileIdle (no exact alarm permission needed)');
    for (final notification in pending) {
      print('[NotificationService]   ID: ${notification.id}, Title: ${notification.title}');
      print('[NotificationService]   Body: ${notification.body?.substring(0, (notification.body?.length ?? 0).clamp(0, 50))}...');
      print('[NotificationService]   Payload: ${notification.payload}');
    }
    print('[NotificationService] ================================');
  }
}
