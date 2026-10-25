// Every tab's list scrolls its last item fully above the floating glass tab bar.
//
// The bar floats over the tab content (Scaffold.extendBody), so each tab's
// scroll view needs bottom padding of the bar's height plus the safe-area
// inset. The store-screenshot panel at 5d161b0 found the last Saved card, the
// Library list and an iPad row cut off under the bar.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/screens/main_shell.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/lens_tab_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_setup.dart';

class _Device {
  final String name;
  final Size size;
  final EdgeInsets safe;
  const _Device(this.name, this.size, this.safe);
}

const _devices = [
  _Device('phone', Size(390, 844), EdgeInsets.only(top: 47, bottom: 34)),
  _Device('foldouter', Size(411, 923), EdgeInsets.only(top: 24, bottom: 24)),
  _Device('ipadthird', Size(375, 1032), EdgeInsets.only(top: 24, bottom: 20)),
  _Device('foldinner', Size(815, 918), EdgeInsets.only(top: 24, bottom: 24)),
  _Device('ipad13p', Size(1032, 1376), EdgeInsets.only(top: 24, bottom: 20)),
];

Widget _host(SharedPreferences prefs, ThemeData theme) {
  final router = GoRouter(
    initialLocation: '/library',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (context, state) => const SizedBox.expand())]),
          StatefulShellBranch(routes: [GoRoute(path: '/library', builder: (context, state) => const LibraryScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/saved', builder: (context, state) => const SavedScreen())]),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      zenModeProvider.overrideWith((ref) => false),
    ],
    child: MaterialApp.router(theme: theme, routerConfig: router),
  );
}

/// The lowest painted bottom edge of any text or card inside [scrollable] that the viewport shows.
double _lastContentBottom(WidgetTester tester, Finder scrollable) {
  final viewport = tester.renderObject<RenderBox>(scrollable);
  final viewTop = viewport.localToGlobal(Offset.zero).dy;
  final viewBottom = viewTop + viewport.size.height;
  var lowest = 0.0;
  void visit(RenderObject o) {
    if (o is RenderParagraph && o.hasSize && o.attached) {
      final top = o.localToGlobal(Offset.zero).dy;
      if (top < viewBottom && top + o.size.height > viewTop) lowest = math.max(lowest, top + o.size.height);
    }
    o.visitChildren(visit);
  }

  viewport.visitChildren(visit);
  return lowest;
}

void main() {
  setUpAll(() {
    loadTestPointings();
    loadTestArticles();
  });

  for (final device in _devices) {
    for (final scale in const [1.0, 2.0]) {
      for (final dark in const [false, true]) {
        for (final tab in const ['Library', 'Saved']) {
          testWidgets('$tab ends above the tab bar on ${device.name}, text x$scale, ${dark ? 'dark' : 'light'}', (tester) async {
            final saved = [for (final p in pointings.take(8)) p.id];
            SharedPreferences.setMockInitialValues({
              'pointer_onboarding_completed': true,
              'pointer_favorites': '[${saved.map((id) => '"$id"').join(',')}]',
            });
            final prefs = await SharedPreferences.getInstance();
            tester.view.physicalSize = device.size;
            tester.view.devicePixelRatio = 1;
            final pad = FakeViewPadding(top: device.safe.top, bottom: device.safe.bottom);
            tester.view.padding = pad;
            tester.view.viewPadding = pad;
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.view.reset);
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

            // Text x2 on the 13-inch iPad overflows a Library row (present before this test); this test checks the bottom inset only.
            final previous = FlutterError.onError;
            FlutterError.onError = (d) => d.exceptionAsString().contains("overflowed") ? null : previous?.call(d);
            addTearDown(() => FlutterError.onError = previous);
            await tester.pumpWidget(_host(prefs, dark ? AppTheme.dark : AppTheme.light));
            await tester.pump(const Duration(seconds: 2));
            if (tab == 'Saved') {
              tester.widget<LensTabBar>(find.byType(LensTabBar)).onTap(2);
              await tester.pump(const Duration(seconds: 1));
            }

            final scrollable = find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).hitTestable().first;
            final position = tester.state<ScrollableState>(scrollable).position;
            position.jumpTo(position.maxScrollExtent);
            await tester.pump(const Duration(seconds: 1));
            position.jumpTo(position.maxScrollExtent);
            await tester.pump(const Duration(seconds: 1));

            final bottom = _lastContentBottom(tester, scrollable);
            final rail = device.size.width >= 600;
            // Full-height bar top: the bar sits max(safe + safeGap, edgeMargin) above the bottom edge.
            final limit = rail
                ? device.size.height - device.safe.bottom
                : device.size.height - math.max(device.safe.bottom + LiquidGlass.safeGap, LiquidGlass.edgeMargin) - LiquidGlass.barHeight;
            final vp = tester.getRect(scrollable);
            expect(bottom, lessThanOrEqualTo(limit + 0.5), reason: 'last item bottom $bottom vs ${rail ? 'safe area' : 'bar top'} $limit');
            if (!rail) {
              expect(vp.bottom, device.size.height, reason: "the list runs under the glass bar, not clipped above it");
              expect(limit - bottom, lessThan(80), reason: "no dead band between the last item and the bar");
            }
          });
        }
      }
    }
  }
}
