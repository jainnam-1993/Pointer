import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('appRedirect after process death', () {
    test('the splash continues to the restored tab, not Home', () {
      final r = appRedirect(matchedLocation: '/library', location: '/library', onboardingCompleted: true, hasShownSplash: false);
      expect(r, '/splash?dest=${Uri.encodeComponent('/library')}');
    });

    test('a fresh launch starts at Home and the splash goes Home', () {
      final r = appRedirect(matchedLocation: '/', location: '/', onboardingCompleted: true, hasShownSplash: false);
      expect(r, '/splash?dest=${Uri.encodeComponent('/')}');
    });

    test('before onboarding, a restored tab still goes to onboarding', () {
      final r = appRedirect(matchedLocation: '/library', location: '/library', onboardingCompleted: false, hasShownSplash: false);
      expect(r, '/splash?dest=${Uri.encodeComponent('/onboarding')}');
    });

    test('after the splash, tabs pass through', () {
      expect(appRedirect(matchedLocation: '/library', location: '/library', onboardingCompleted: true, hasShownSplash: true), isNull);
    });
  });

  test('the router, the tab shell and every tab take part in state restoration', () async {
    SharedPreferences.setMockInitialValues({});
    setRouterSharedPreferences(await SharedPreferences.getInstance());
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    final shell = router.configuration.routes.whereType<StatefulShellRoute>().single;
    expect(shell.restorationScopeId, isNotNull);
    expect(shell.branches.map((b) => b.restorationScopeId), everyElement(isNotNull));
  });
}
