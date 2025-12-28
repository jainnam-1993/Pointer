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
      test('channel has high importance with custom sound', () {
        final channel = NotificationService.androidChannel;

        expect(channel.importance, Importance.high);
      });

      test('channel has vibration disabled', () {
        final channel = NotificationService.androidChannel;

        expect(channel.enableVibration, false);
      });

      test('channel has custom bell chime sound enabled', () {
        final channel = NotificationService.androidChannel;

        expect(channel.playSound, true);
      });

      test('channel has correct id and name', () {
        final channel = NotificationService.androidChannel;

        expect(channel.id, 'pointings_v3');
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
      test('uses high importance for heads-up display', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.importance, Importance.high);
      });

      test('uses high priority for immediate delivery', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.priority, Priority.high);
      });

      test('uses correct channel', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.channelId, 'pointings_v3');
      });

      test('has vibration disabled', () {
        final details = NotificationService.androidNotificationDetails;

        expect(details.enableVibration, false);
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

        // Android: high importance with custom sound, no vibration
        expect(notificationDetails.android!.importance, Importance.high);
        expect(notificationDetails.android!.priority, Priority.high);
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
  });
}
