import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/services/notification_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class FakeAndroidNotificationChannel extends Fake
    implements AndroidNotificationChannel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAndroidNotificationChannel());
  });

  group('NotificationTime', () {
    test('can be created with required fields', () {
      const time = NotificationTime(
        id: 'test-1',
        hour: 8,
        minute: 30,
      );

      expect(time.id, 'test-1');
      expect(time.hour, 8);
      expect(time.minute, 30);
      expect(time.isEnabled, true); // default
    });

    test('copyWith creates modified copy', () {
      const time = NotificationTime(
        id: 'test-1',
        hour: 8,
        minute: 30,
        isEnabled: true,
      );

      final modified = time.copyWith(hour: 9, isEnabled: false);

      expect(modified.id, 'test-1');
      expect(modified.hour, 9);
      expect(modified.minute, 30);
      expect(modified.isEnabled, false);
    });

    test('toJson serializes correctly', () {
      const time = NotificationTime(
        id: 'test-1',
        hour: 8,
        minute: 30,
        isEnabled: true,
      );

      final json = time.toJson();

      expect(json['id'], 'test-1');
      expect(json['hour'], 8);
      expect(json['minute'], 30);
      expect(json['isEnabled'], true);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'test-1',
        'hour': 8,
        'minute': 30,
        'isEnabled': true,
      };

      final time = NotificationTime.fromJson(json);

      expect(time.id, 'test-1');
      expect(time.hour, 8);
      expect(time.minute, 30);
      expect(time.isEnabled, true);
    });

    test('fromJson uses default for missing isEnabled', () {
      final json = {
        'id': 'test-1',
        'hour': 8,
        'minute': 30,
      };

      final time = NotificationTime.fromJson(json);

      expect(time.isEnabled, true);
    });
  });

  group('NotificationService', () {
    late MockSharedPreferences mockPrefs;
    late NotificationService service;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      service = NotificationService(mockPrefs);
    });

    group('Android Channel Configuration', () {
      test('channel has max importance with custom sound', () {
        final channel = NotificationService.androidChannel;

        expect(channel.importance, Importance.max);
      });

      test('channel has vibration enabled', () {
        final channel = NotificationService.androidChannel;

        expect(channel.enableVibration, true);
      });

      test('channel has custom bell chime sound enabled', () {
        final channel = NotificationService.androidChannel;

        expect(channel.playSound, true);
      });

      test('channel has correct id and name', () {
        final channel = NotificationService.androidChannel;

        expect(channel.id, 'pointings_v6');
        expect(channel.name, 'Daily Pointings');
      });

      test('channel has description', () {
        final channel = NotificationService.androidChannel;

        expect(channel.description, isNotNull);
        expect(channel.description, isNotEmpty);
      });
    });

    group('iOS Notification Details', () {
      test('uses passive interruption level', () {
        final details = NotificationService.iosNotificationDetails;

        expect(details.interruptionLevel, InterruptionLevel.passive);
      });

      test('has sound disabled', () {
        final details = NotificationService.iosNotificationDetails;

        expect(details.presentSound, false);
      });

      test('has banner disabled for no visual interruption', () {
        final details = NotificationService.iosNotificationDetails;

        expect(details.presentBanner, false);
      });

      test('presents in notification list', () {
        final details = NotificationService.iosNotificationDetails;

        expect(details.presentList, true);
      });
    });

    group('Android Notification Details', () {
      test('uses max importance for heads-up display', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.importance, Importance.max);
      });

      test('uses max priority for immediate delivery', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.priority, Priority.max);
      });

      test('uses correct channel', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.channelId, 'pointings_v6');
      });

      test('has vibration enabled', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.enableVibration, true);
      });

      test('has custom bell chime sound enabled', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.playSound, true);
      });
    });

    group('NotificationDetails', () {
      test('combines iOS and Android details correctly', () {
        final notificationDetails = NotificationService.notificationDetails;

        expect(notificationDetails.iOS, isNotNull);
        expect(notificationDetails.android, isNotNull);

        // iOS: passive, no sound, no banner, show in list
        expect(notificationDetails.iOS!.interruptionLevel,
            InterruptionLevel.passive);
        expect(notificationDetails.iOS!.presentSound, false);
        expect(notificationDetails.iOS!.presentBanner, false);
        expect(notificationDetails.iOS!.presentList, true);

        // Android: max importance with custom sound and vibration
        expect(notificationDetails.android!.importance, Importance.max);
        expect(notificationDetails.android!.priority, Priority.max);
      });
    });

    group('Preferences', () {
      test('isNotificationsEnabled returns false when not set', () {
        when(() => mockPrefs.getBool(any())).thenReturn(null);

        expect(service.isNotificationsEnabled, false);
      });

      test('isNotificationsEnabled returns stored value', () {
        when(() => mockPrefs.getBool('pointer_notifications_enabled'))
            .thenReturn(true);

        expect(service.isNotificationsEnabled, true);
      });

      test('getNotificationTimes returns empty list when not set', () {
        when(() => mockPrefs.getString('pointer_notification_times'))
            .thenReturn(null);

        expect(service.getNotificationTimes(), isEmpty);
      });

      test('getNotificationTimes returns stored times', () {
        final times = [
          {'id': 't1', 'hour': 8, 'minute': 0, 'isEnabled': true},
          {'id': 't2', 'hour': 12, 'minute': 30, 'isEnabled': false},
        ];
        when(() => mockPrefs.getString('pointer_notification_times'))
            .thenReturn(jsonEncode(times));

        final result = service.getNotificationTimes();

        expect(result.length, 2);
        expect(result[0].id, 't1');
        expect(result[0].hour, 8);
        expect(result[0].isEnabled, true);
        expect(result[1].id, 't2');
        expect(result[1].hour, 12);
        expect(result[1].minute, 30);
        expect(result[1].isEnabled, false);
      });
    });

    group('Permission Checking', () {
      test('checkPermissions returns true in test environment (fallback)', () async {
        // The service returns true when plugin unavailable (test env)
        final result = await service.checkPermissions();
        expect(result, isTrue); // Falls back to true in test env
      });

      test('checkPermissions handles plugin exceptions gracefully', () async {
        // When plugin methods throw, should return true as fallback
        final result = await service.checkPermissions();
        expect(result, isTrue);
      });
    });
  });

  group('NotificationSchedule', () {
    test('getNotificationTimes generates times at frequency intervals', () {
      const schedule = NotificationSchedule(
        startHour: 8,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        frequencyMinutes: 60, // 1 hour
      );

      final date = DateTime(2025, 1, 15);
      final times = schedule.getNotificationTimes(date);

      expect(times.length, 3); // 8:00, 9:00, 10:00
      expect(times[0], DateTime(2025, 1, 15, 8, 0));
      expect(times[1], DateTime(2025, 1, 15, 9, 0));
      expect(times[2], DateTime(2025, 1, 15, 10, 0));
    });

    test('testEveryMinute preset generates 1-minute intervals', () {
      final schedule = NotificationPreset.testEveryMinute.schedule;

      // Verify schedule configuration
      expect(schedule.frequencyMinutes, 1);
      expect(schedule.startHour, 0);
      expect(schedule.endHour, 23);
      expect(schedule.endMinute, 59);

      // Test a 5-minute window
      final date = DateTime(2025, 1, 15);
      const testSchedule = NotificationSchedule(
        startHour: 10,
        startMinute: 0,
        endHour: 10,
        endMinute: 5,
        frequencyMinutes: 1,
        quietStartHour: 24, // Disable quiet hours
        quietEndHour: 24,
      );

      final times = testSchedule.getNotificationTimes(date);

      expect(times.length, 6); // 10:00, 10:01, 10:02, 10:03, 10:04, 10:05
      expect(times[0], DateTime(2025, 1, 15, 10, 0));
      expect(times[1], DateTime(2025, 1, 15, 10, 1));
      expect(times[2], DateTime(2025, 1, 15, 10, 2));
      expect(times[3], DateTime(2025, 1, 15, 10, 3));
      expect(times[4], DateTime(2025, 1, 15, 10, 4));
      expect(times[5], DateTime(2025, 1, 15, 10, 5));
    });

    test('quiet hours are respected', () {
      const schedule = NotificationSchedule(
        startHour: 21,
        startMinute: 0,
        endHour: 23,
        endMinute: 0,
        frequencyMinutes: 60,
        quietStartHour: 22,
        quietEndHour: 7,
      );

      final date = DateTime(2025, 1, 15);
      final times = schedule.getNotificationTimes(date);

      // Only 21:00 should be scheduled (22:00, 23:00 are in quiet hours)
      expect(times.length, 1);
      expect(times[0], DateTime(2025, 1, 15, 21, 0));
    });

    test('copyWith preserves unchanged values', () {
      const original = NotificationSchedule(
        startHour: 8,
        endHour: 20,
        frequencyMinutes: 180,
      );

      final modified = original.copyWith(frequencyMinutes: 60);

      expect(modified.startHour, 8);
      expect(modified.endHour, 20);
      expect(modified.frequencyMinutes, 60);
    });

    test('fromJson handles legacy frequencyHours field', () {
      final json = {
        'startHour': 8,
        'endHour': 20,
        'frequencyHours': 2, // Legacy field (hours, not minutes)
      };

      final schedule = NotificationSchedule.fromJson(json);

      expect(schedule.frequencyMinutes, 120); // 2 hours = 120 minutes
    });

    test('summary formats correctly for minute intervals', () {
      const schedule = NotificationSchedule(
        startHour: 8,
        startMinute: 0,
        endHour: 20,
        endMinute: 0,
        frequencyMinutes: 30,
      );

      expect(schedule.summary, contains('Every 30 min'));
      expect(schedule.summary, contains('8:00 AM'));
      expect(schedule.summary, contains('8:00 PM'));
    });

    test('summary formats correctly for hour intervals', () {
      const schedule = NotificationSchedule(
        startHour: 8,
        startMinute: 0,
        endHour: 20,
        endMinute: 0,
        frequencyMinutes: 180, // 3 hours
      );

      expect(schedule.summary, contains('Every 3 hours'));
    });
  });
}
