import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/widgets/ambient.dart';

void main() {
  final clock = AmbientClock.instance;
  void listener() {}

  setUp(clock.debugReset);
  tearDown(() {
    clock.removeListener(listener);
    clock.debugReset();
  });

  testWidgets('runs at 30 fps while listened to, 15 fps in low power', (tester) async {
    clock.addListener(listener);
    expect(clock.isRunning, isTrue);
    expect(clock.interval, const Duration(microseconds: 33333));
    clock.debugSetLowPower(true);
    expect(clock.interval, const Duration(microseconds: 66667));
    clock.removeListener(listener);
    expect(clock.isRunning, isFalse);
  });

  testWidgets('follows battery saver changes the platform pushes while the app stays resumed', (tester) async {
    Future<void> push(bool lowPower) => tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      AmbientClock.powerChannel.name,
      AmbientClock.powerChannel.codec.encodeMethodCall(MethodCall('lowPowerModeChanged', lowPower)),
      (_) {},
    );

    clock.addListener(listener);
    expect(clock.interval, const Duration(microseconds: 33333));
    await push(true);
    expect(clock.interval, const Duration(microseconds: 66667));
    expect(clock.isRunning, isTrue);
    await push(false);
    expect(clock.interval, const Duration(microseconds: 33333));
    clock.removeListener(listener);
  });

  testWidgets('pauses when the app is backgrounded and resumes after', (tester) async {
    clock.addListener(listener);
    clock.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(clock.isRunning, isFalse);
    clock.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(clock.isRunning, isTrue);
    clock.removeListener(listener);
  });

  testWidgets('reduce motion holds the still frame', (tester) async {
    clock.addListener(listener);
    clock.setReduceMotion(true);
    expect(clock.isRunning, isFalse);
    expect(clock.value, kAmbientStillTime);
    clock.setReduceMotion(false);
    expect(clock.isRunning, isTrue);
    clock.removeListener(listener);
  });

  testWidgets('a modal sheet pauses the clock and closing it resumes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [AmbientRouteObserver()],
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (_) => const SizedBox(height: 200, child: Text('sheet')),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    clock.addListener(listener);
    expect(clock.isRunning, isTrue);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('sheet'), findsOneWidget);
    expect(clock.coverCount, 1);
    expect(clock.isRunning, isFalse);

    Navigator.of(tester.element(find.text('sheet'))).pop();
    await tester.pumpAndSettle();
    expect(clock.coverCount, 0);
    expect(clock.isRunning, isTrue);
    clock.removeListener(listener);
  });
}
