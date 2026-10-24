// Goldens for the Settings "Add widget to Home Screen" row (Android) and the iOS how-to sheet.
//   flutter test --update-goldens test/golden/add_widget_golden_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/screens/settings/widget_section.dart';
import 'golden_test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupGoldenTests();
  });

  tearDownAll(() {
    teardownGoldenTests();
  });

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      AddWidgetRow.channel,
      (call) async => call.method == 'isPinWidgetSupported' ? true : null,
    );
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(AddWidgetRow.channel, null);
  });

  testWidgets('add widget row (android)', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    await pumpForGolden(
      tester,
      createComponentTestWrapper(
        child: const Padding(padding: EdgeInsets.all(24), child: AddWidgetRow()),
      ),
      size: const Size(400, 200),
    );
    await tester.pump();
    await expectGoldenMatches(tester, 'add_widget_row_android');
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('add widget how-to sheet (ios)', (tester) async {
    await pumpForGolden(
      tester,
      createComponentTestWrapper(
        child: const Align(alignment: Alignment.bottomCenter, child: AddWidgetHowToSheet()),
      ),
      size: const Size(400, 420),
    );
    await expectGoldenMatches(tester, 'add_widget_howto_ios');
  });
}
