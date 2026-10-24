import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/onboarding_screen.dart';
import 'package:pointer/services/notification_service.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockNotificationService extends Mock implements NotificationService {}

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockNotificationService notifications;
  late MockStorageService storage;

  setUpAll(() => AnimatedGradient.disableAnimations = true);

  setUp(() {
    notifications = MockNotificationService();
    storage = MockStorageService();
    when(() => storage.settings).thenReturn(const AppSettings());
    when(() => storage.setOnboardingCompleted(any())).thenAnswer((_) async {});
    when(() => notifications.setNotificationsEnabled(any())).thenAnswer((_) async {});
  });

  Future<void> reachLastPageAndTapEnable(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('HOME')),
        GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationServiceProvider.overrideWithValue(notifications),
          storageServiceProvider.overrideWithValue(storage),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
          highContrastProvider.overrideWith((ref) => false),
        ],
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    await tester.tap(find.text('Enable Notifications'));
    await tester.pumpAndSettle();
  }

  testWidgets('rationale Continue is its own tappable button node', (tester) async {
    when(() => notifications.requestPermissions()).thenAnswer((_) async => true);
    final handle = tester.ensureSemantics();
    await reachLastPageAndTapEnable(tester);

    final continueText = find.descendant(of: find.byType(Dialog), matching: find.text('Continue'));
    expect(
      tester.getSemantics(continueText),
      containsSemantics(label: 'Continue', isButton: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('rationale, then granting permission enables notifications', (tester) async {
    when(() => notifications.requestPermissions()).thenAnswer((_) async => true);
    await reachLastPageAndTapEnable(tester);

    expect(find.text('A few quiet pointings a day'), findsOneWidget);
    verifyNever(() => notifications.requestPermissions());

    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Continue')));
    await tester.pumpAndSettle();

    verify(() => notifications.requestPermissions()).called(1);
    verify(() => notifications.setNotificationsEnabled(true)).called(1);
    verify(() => storage.setOnboardingCompleted(true)).called(1);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('denying permission finishes onboarding without enabling', (tester) async {
    when(() => notifications.requestPermissions()).thenAnswer((_) async => false);
    await reachLastPageAndTapEnable(tester);
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Continue')));
    await tester.pumpAndSettle();

    verifyNever(() => notifications.setNotificationsEnabled(any()));
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Not now on the rationale skips the system prompt and stays', (tester) async {
    await reachLastPageAndTapEnable(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    verifyNever(() => notifications.requestPermissions());
    expect(find.text('Enable Notifications'), findsOneWidget);
  });
}
