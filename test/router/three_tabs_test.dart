import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer/data/inquiries.dart';
import 'package:pointer/data/inquiry_sessions.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/router.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_setup.dart';

void main() {
  setUpAll(loadTestPointings);

  test('every guided session plays its own inquiry', () {
    for (final s in inquirySessions) {
      expect(getInquiryById(s.inquiryId), isNotNull, reason: '${s.title} -> ${s.inquiryId}');
    }
    expect(inquirySessions.map((s) => s.inquiryId).toSet().length, inquirySessions.length, reason: 'no two sessions share an inquiry');
  });

  group('three tabs after the restructure', () {
    late GoRouter router;
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      setRouterSharedPreferences(await SharedPreferences.getInstance());
      router = ProviderContainer().read(routerProvider);
    });

    test('the shell has Today, Library and Saved, and a new restoration id', () {
      final shell = router.configuration.routes.whereType<StatefulShellRoute>().single;
      final paths = [for (final b in shell.branches) (b.routes.single as GoRoute).path];
      expect(paths, ['/', '/library', '/saved']);
      // The old 'shell' id restored a 4-tab index; a new id drops it, and the restored path picks the tab.
      expect(shell.restorationScopeId, isNot('shell'));
    });

    test('old /inquiry and /settings links still resolve', () {
      final top = router.configuration.routes.whereType<GoRoute>();
      expect(top.where((r) => r.path == '/inquiry').single.redirect, isNotNull);
      final settings = top.where((r) => r.path == '/settings').single;
      expect(settings.pageBuilder, isNotNull, reason: 'a root sheet route, so go(/settings) still works');
    });
  });

  testWidgets('pointings saved before the upgrade show in Saved', (tester) async {
    final kept = pointings.first;
    SharedPreferences.setMockInitialValues({'pointer_onboarding_completed': true, 'pointer_favorites': '["${kept.id}"]'});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: SavedScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Saved'), findsWidgets);
    expect(find.text('Nothing saved yet.'), findsNothing);
    expect(find.textContaining(kept.content.substring(0, 20)), findsWidgets);
  });
}
