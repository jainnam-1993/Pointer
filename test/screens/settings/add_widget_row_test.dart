import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/settings/widget_section.dart';

Widget _app() => ProviderScope(
  overrides: [
    highContrastProvider.overrideWith((ref) => false),
    oledModeProvider.overrideWith((ref) => false),
    reduceMotionOverrideProvider.overrideWith((ref) => true),
  ],
  child: const MaterialApp(
    home: Scaffold(
      body: Padding(padding: EdgeInsets.all(16), child: AddWidgetRow()),
    ),
  ),
);

void main() {
  final calls = <String>[];
  late bool supported;

  setUp(() {
    calls.clear();
    supported = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(AddWidgetRow.channel, (call) async {
      calls.add(call.method);
      if (call.method == 'isPinWidgetSupported') return supported;
      if (call.method == 'requestPinWidget') return true;
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(AddWidgetRow.channel, null);
  });

  testWidgets('Android: shown when the launcher can pin, and a tap requests the pin', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.text('Add widget to Home Screen'), findsOneWidget);
    expect(find.bySemanticsLabel('Add widget to Home Screen'), findsOneWidget);
    await tester.tap(find.text('Add widget to Home Screen'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, ['isPinWidgetSupported', 'requestPinWidget']);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('Android: hidden when the launcher cannot pin', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    supported = false;
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.text('Add widget to Home Screen'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS: a tap opens the how-to sheet and never calls the pin API', (tester) async {
    // Phone-sized surface, so the whole sheet (and its Done button) is on screen.
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.tap(find.text('Add widget to Home Screen'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Add the widget'), findsOneWidget);
    for (final step in AddWidgetHowToSheet.steps) {
      expect(find.text(step), findsOneWidget);
    }
    expect(calls, isEmpty);
    await tester.tap(find.text('Done'));
    // The sheet's exit animation finishes, then the route is removed on the following frame.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Add the widget'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });
}
