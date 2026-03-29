import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/usage_providers.dart';
import 'package:pointer/services/usage_tracking_service.dart';

class MockUsageTrackingService extends Mock implements UsageTrackingService {}

void main() {
  group('DailyUsageNotifier', () {
    late MockUsageTrackingService mockService;
    late DailyUsageNotifier notifier;

    setUp(() {
      mockService = MockUsageTrackingService();
    });

    test('initializes with current usage from service', () {
      final usage = DailyUsage(viewCount: 3, lastResetDate: _todayString());
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);

      expect(notifier.state.viewCount, 3);
      expect(notifier.state.lastResetDate, _todayString());
      verify(() => mockService.getUsage()).called(1);
    });

    test('initializes with zero views when no prior usage', () {
      final usage = DailyUsage(viewCount: 0, lastResetDate: _todayString());
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);

      expect(notifier.state.viewCount, 0);
      expect(notifier.state.lastResetDate, _todayString());
    });

    test('recordView increments view count via service', () async {
      final initial = DailyUsage(viewCount: 0, lastResetDate: _todayString());
      final updated = DailyUsage(viewCount: 1, lastResetDate: _todayString());

      when(() => mockService.getUsage()).thenReturn(initial);
      when(() => mockService.incrementViewCount())
          .thenAnswer((_) async => updated);

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.state.viewCount, 0);

      await notifier.recordView();

      expect(notifier.state.viewCount, 1);
      verify(() => mockService.incrementViewCount()).called(1);
    });

    test('recordView updates state with each call', () async {
      final initial = DailyUsage(viewCount: 1, lastResetDate: _todayString());
      final afterSecond =
          DailyUsage(viewCount: 2, lastResetDate: _todayString());
      final afterThird =
          DailyUsage(viewCount: 3, lastResetDate: _todayString());

      when(() => mockService.getUsage()).thenReturn(initial);
      var callCount = 0;
      when(() => mockService.incrementViewCount()).thenAnswer((_) async {
        callCount++;
        return callCount == 1 ? afterSecond : afterThird;
      });

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.state.viewCount, 1);

      await notifier.recordView();
      expect(notifier.state.viewCount, 2);

      await notifier.recordView();
      expect(notifier.state.viewCount, 3);

      verify(() => mockService.incrementViewCount()).called(2);
    });

    test('reset clears usage to zero', () async {
      final initial = DailyUsage(viewCount: 5, lastResetDate: _todayString());
      final resetUsage =
          DailyUsage(viewCount: 0, lastResetDate: _todayString());

      var callCount = 0;
      when(() => mockService.getUsage()).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? initial : resetUsage;
      });
      when(() => mockService.resetUsage()).thenAnswer((_) async {});

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.state.viewCount, 5);

      await notifier.reset();

      expect(notifier.state.viewCount, 0);
      verify(() => mockService.resetUsage()).called(1);
    });

    test('reset then recordView starts from zero', () async {
      final initial = DailyUsage(viewCount: 3, lastResetDate: _todayString());
      final resetUsage =
          DailyUsage(viewCount: 0, lastResetDate: _todayString());
      final afterRecord =
          DailyUsage(viewCount: 1, lastResetDate: _todayString());

      var getCallCount = 0;
      when(() => mockService.getUsage()).thenAnswer((_) {
        getCallCount++;
        // 1st call: constructor, 2nd call: after reset
        return getCallCount == 1 ? initial : resetUsage;
      });
      when(() => mockService.resetUsage()).thenAnswer((_) async {});
      when(() => mockService.incrementViewCount())
          .thenAnswer((_) async => afterRecord);

      notifier = DailyUsageNotifier(mockService);
      expect(notifier.state.viewCount, 3);

      await notifier.reset();
      expect(notifier.state.viewCount, 0);

      await notifier.recordView();
      expect(notifier.state.viewCount, 1);
    });

    test('state reflects DailyUsage properties', () {
      final usage = DailyUsage(viewCount: 2, lastResetDate: '2026-02-08');
      when(() => mockService.getUsage()).thenReturn(usage);

      notifier = DailyUsageNotifier(mockService);

      expect(notifier.state.viewCount, 2);
      expect(notifier.state.lastResetDate, '2026-02-08');
    });
  });

  group('DailyUsage', () {
    test('stores raw view count', () {
      final usage = DailyUsage(viewCount: 1, lastResetDate: _todayString());
      expect(usage.viewCount, 1);
    });

    test('supports any view count value', () {
      final usage = DailyUsage(viewCount: 2, lastResetDate: _todayString());
      expect(usage.viewCount, 2);
    });

    test('initial factory creates zero-count usage for today', () {
      final usage = DailyUsage.initial();
      expect(usage.viewCount, 0);
      expect(usage.lastResetDate, _todayString());
    });

    test('copyWith creates modified copy', () {
      final original = DailyUsage(viewCount: 1, lastResetDate: '2026-01-01');
      final modified = original.copyWith(viewCount: 5);

      expect(modified.viewCount, 5);
      expect(modified.lastResetDate, '2026-01-01');
    });

    test('copyWith preserves unmodified fields', () {
      final original = DailyUsage(viewCount: 3, lastResetDate: '2026-02-08');
      final modified = original.copyWith(lastResetDate: '2026-02-09');

      expect(modified.viewCount, 3);
      expect(modified.lastResetDate, '2026-02-09');
    });
  });
}

String _todayString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
