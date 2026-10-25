import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/lineages_screen.dart';
import 'package:pointer/screens/settings/appearance_section.dart';
import 'package:pointer/screens/settings/settings_banners.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_setup.dart';

class _MockPrefs extends Mock implements SharedPreferences {}

/// Every tappable control the design panel named (Reset, theme segments, banner Enable) meets
/// the platform minimum: 44 pt on iOS and 48 dp on Android.
void main() {
  late _MockPrefs prefs;

  setUpAll(() {
    loadTestPointings();
    AnimatedGradient.disableAnimations = true;
  });
  tearDownAll(() => AnimatedGradient.disableAnimations = false);

  setUp(() {
    prefs = _MockPrefs();
    when(() => prefs.getString(any())).thenReturn(null);
    when(() => prefs.getBool(any())).thenReturn(null);
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => prefs.setBool(any(), any())).thenAnswer((_) async => true);
  });

  Future<void> pump(WidgetTester tester, Widget child, {required bool scaffold}) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          oledModeProvider.overrideWith((ref) => false),
          reduceMotionOverrideProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: scaffold
              ? Scaffold(
                  body: SafeArea(child: SingleChildScrollView(child: child)),
                )
              : child,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> expectTargets(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  }

  testWidgets('Lineages (Back, Reset, tradition rows) meet the tap target minimums', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const LineagesScreen(), scaffold: false);
    await expectTargets(tester);
    handle.dispose();
  });

  testWidgets('Appearance theme segments and toggles meet the tap target minimums', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, const AppearanceSelector(), scaffold: true);
    await expectTargets(tester);
    handle.dispose();
  });

  testWidgets('Notification permission banner Enable meets the tap target minimums', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, NotificationPermissionBanner(onEnable: () {}), scaffold: true);
    await expectTargets(tester);
    handle.dispose();
  });
}
