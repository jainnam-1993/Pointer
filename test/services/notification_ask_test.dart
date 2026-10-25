import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/library_screen.dart' show SavedScreen;
import 'package:pointer/services/notification_ask.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late int asks;
  late int enables;

  Future<NotificationAskPolicy> policy(Map<String, Object> prefs, {required bool grant}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final p = await SharedPreferences.getInstance();
    return NotificationAskPolicy(
      p,
      requestPermission: () async {
        asks++;
        return grant;
      },
      enableNotifications: () async => enables++,
    );
  }

  setUp(() {
    asks = 0;
    enables = 0;
  });

  test('onboarding does not ask; the first Save asks once and enables on a grant', () async {
    final p = await policy({}, grant: true);
    await p.onOnboardingFinished();
    expect(asks, 0);
    await p.onSaved();
    await p.onSaved();
    expect([asks, enables], [1, 1]);
  });

  test('after a denial the app never asks again', () async {
    final p = await policy({}, grant: false);
    await p.onOnboardingFinished();
    await p.onSaved();
    await p.onSaved();
    await p.onSaved();
    expect([asks, enables], [1, 0]);
    expect(p.state, NotificationAsk.asked);
  });

  test('an install that went through the old onboarding, which asked, is not asked again', () async {
    final p = await policy({'pointer_onboarding_completed': true}, grant: true);
    await p.onSaved();
    expect(asks, 0);
  });

  testWidgets('Saved\'s empty state shows the heart, not the enso ring', (tester) async {
    SharedPreferences.setMockInitialValues({'pointer_onboarding_completed': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SavedScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    final icon = tester.widget<Icon>(find.byKey(const ValueKey('empty-state-icon')));
    expect(icon.icon, AppIcons.heart);
  });
}
