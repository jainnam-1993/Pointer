import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/services/usage_tracking_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late UsageTrackingService service;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    service = UsageTrackingService(mockPrefs);
  });

  group('DailyUsage', () {
    test('initial creates usage with zero count', () {
      final usage = DailyUsage.initial();
      expect(usage.viewCount, 0);
      expect(usage.limitReached, false);
      expect(usage.remaining, DailyUsage.freeUserLimit);
    });

    test('limitReached returns true when at limit', () {
      final usage = DailyUsage(
        viewCount: DailyUsage.freeUserLimit,
        lastResetDate: '2025-01-01',
      );
      expect(usage.limitReached, true);
      expect(usage.remaining, 0);
    });

    test('copyWith creates new instance', () {
      final usage = DailyUsage(viewCount: 1, lastResetDate: '2025-01-01');
      final updated = usage.copyWith(viewCount: 2);
      expect(updated.viewCount, 2);
      expect(updated.lastResetDate, '2025-01-01');
      expect(usage.viewCount, 1); // original unchanged
    });

    test('toJson serializes correctly', () {
      final usage = DailyUsage(viewCount: 1, lastResetDate: '2025-01-01');
      final json = usage.toJson();
      expect(json['viewCount'], 1);
      expect(json['lastResetDate'], '2025-01-01');
    });

    test('fromJson deserializes correctly', () {
      final usage = DailyUsage.fromJson({
        'viewCount': 2,
        'lastResetDate': '2025-01-01',
      });
      expect(usage.viewCount, 2);
      expect(usage.lastResetDate, '2025-01-01');
    });
  });

  group('UsageTrackingService', () {
    test('getUsage returns initial when no stored data', () {
      when(() => mockPrefs.getString(any())).thenReturn(null);

      final usage = service.getUsage();
      expect(usage.viewCount, 0);
    });

    test('getUsage parses stored data', () {
      when(() => mockPrefs.getString(any()))
          .thenReturn('viewCount=3&lastResetDate=${_todayString()}');

      final usage = service.getUsage();
      expect(usage.viewCount, 3);
    });

    test('getUsage resets on new day', () {
      when(() => mockPrefs.getString(any()))
          .thenReturn('viewCount=3&lastResetDate=2020-01-01');
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      final usage = service.getUsage();
      expect(usage.viewCount, 0); // Reset for new day
    });

    test('incrementViewCount increases count', () async {
      when(() => mockPrefs.getString(any()))
          .thenReturn('viewCount=1&lastResetDate=${_todayString()}');
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      final usage = await service.incrementViewCount();
      expect(usage.viewCount, 2);
    });

    test('resetUsage resets to zero', () async {
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await service.resetUsage();

      verify(() => mockPrefs.setString(any(), any())).called(1);
    });
  });
}

String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
