import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pointer/layout/adaptive.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/main_shell.dart';
import 'package:pointer/theme/app_theme.dart';

const _bookFold = DisplayFeature(bounds: Rect.fromLTWH(420, 0, 0, 884), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureHalfOpened);
const _tableFold = DisplayFeature(bounds: Rect.fromLTWH(0, 442, 841, 0), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureHalfOpened);
const _flatFold = DisplayFeature(bounds: Rect.fromLTWH(420, 0, 0, 884), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureFlat);
const _hinge = DisplayFeature(bounds: Rect.fromLTWH(400, 0, 40, 884), type: DisplayFeatureType.hinge, state: DisplayFeatureState.unknown);
const _cutout = DisplayFeature(bounds: Rect.fromLTWH(180, 0, 40, 30), type: DisplayFeatureType.cutout, state: DisplayFeatureState.unknown);

WindowLayout _layout(Size size, [List<DisplayFeature> features = const []]) =>
    WindowLayout.fromMediaQuery(MediaQueryData(size: size, displayFeatures: features));

void _setView(WidgetTester tester, Size size, [List<DisplayFeature> features = const []]) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.displayFeatures = features;
  addTearDown(tester.view.reset);
}

void main() {
  group('WindowSizeClass', () {
    test('breakpoints at 600 and 840', () {
      expect(WindowSizeClass.fromWidth(411), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(599.9), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(839), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1024), WindowSizeClass.expanded);
    });
  });

  group('WindowLayout', () {
    test('navigation type and pane count per size class', () {
      final compact = _layout(const Size(411, 923));
      final medium = _layout(const Size(700, 900));
      final expanded = _layout(const Size(841, 884));
      expect([compact.navigationType, compact.paneCount], [NavigationType.bottomBar, 1]);
      expect([medium.navigationType, medium.paneCount], [NavigationType.rail, 1]);
      expect([expanded.navigationType, expanded.paneCount], [NavigationType.rail, 2]);
    });

    test('postures from display features', () {
      expect(_layout(const Size(841, 884), [_bookFold]).posture, Posture.book);
      expect(_layout(const Size(841, 884), [_tableFold]).posture, Posture.tabletop);
      expect(_layout(const Size(841, 884), [_flatFold]).posture, Posture.flat, reason: 'a flat fold does not separate');
      expect(_layout(const Size(841, 884), [_cutout]).hinge, isNull);
      final hinge = _layout(const Size(840, 884), [_hinge]);
      expect(hinge.posture, Posture.book);
      expect(hinge.isOccluding, isTrue);
    });

    test('a vertical hinge makes even a medium window two pane', () {
      expect(
        _layout(const Size(700, 900), [
          const DisplayFeature(bounds: Rect.fromLTWH(350, 0, 0, 900), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureHalfOpened),
        ]).paneCount,
        2,
      );
    });
  });

  group('TwoPane', () {
    testWidgets('never puts content under an occluding hinge', (tester) async {
      _setView(tester, const Size(840, 884), [_hinge]);
      await tester.pumpWidget(
        const MaterialApp(
          home: TwoPane(primary: SizedBox.expand(), secondary: SizedBox.expand()),
        ),
      );
      expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, lessThanOrEqualTo(400));
      expect(tester.getRect(find.byKey(const ValueKey('pane-hinge'))).width, 40);
      expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, greaterThanOrEqualTo(440));
    });

    testWidgets('maps the hinge into a pane inset on the left', (tester) async {
      _setView(tester, const Size(841, 884), [_bookFold]);
      await tester.pumpWidget(
        const MaterialApp(
          home: Padding(
            padding: EdgeInsets.only(left: kRailWidth),
            child: TwoPane(primary: SizedBox.expand(), secondary: SizedBox.expand()),
          ),
        ),
      );
      expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, 420);
      expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, 420);
    });

    testWidgets('single pane on compact', (tester) async {
      _setView(tester, const Size(411, 923));
      await tester.pumpWidget(
        const MaterialApp(
          home: TwoPane(primary: Text('a'), secondary: Text('b')),
        ),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsNothing);
    });
  });

  testWidgets('TabletopSplit keeps the top above and the bottom below the hinge', (tester) async {
    _setView(tester, const Size(841, 884), [_tableFold]);
    await tester.pumpWidget(
      const MaterialApp(
        home: TabletopSplit(top: SizedBox.expand(), bottom: SizedBox.expand(), fallback: Text('flat')),
      ),
    );
    expect(tester.getRect(find.byKey(const ValueKey('tabletop-top'))).bottom, 442);
    expect(tester.getRect(find.byKey(const ValueKey('tabletop-bottom'))).top, 442);
  });

  group('MainShell navigation', () {
    Widget shellApp() {
      final router = GoRouter(
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) => MainShell(navigationShell: shell),
            branches: [
              for (final path in ['/', '/inquiry', '/library', '/settings'])
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: path,
                      builder: (context, state) => Center(child: Text('page $path')),
                    ),
                  ],
                ),
            ],
          ),
        ],
      );
      return ProviderScope(
        overrides: [zenModeProvider.overrideWith((ref) => false)],
        child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
      );
    }

    for (final (size, rail) in [
      (const Size(411, 923), false),
      (const Size(700, 900), true),
      (const Size(841, 884), true),
      (const Size(1024, 1366), true),
    ]) {
      testWidgets('${size.width.toInt()} wide uses ${rail ? 'the side rail' : 'the bottom bar'}', (tester) async {
        _setView(tester, size);
        await tester.pumpWidget(shellApp());
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('side-rail')), rail ? findsOneWidget : findsNothing);
        expect(find.bySemanticsLabel('Library tab'), findsOneWidget);
        if (rail) {
          // Content is padded clear of the rail; tapping a rail item switches tabs.
          expect(tester.getRect(find.text('page /')).center.dx, greaterThan(kRailWidth));
          await tester.tap(find.bySemanticsLabel('Library tab'));
          await tester.pumpAndSettle();
          expect(find.text('page /library'), findsOneWidget);
        }
      });
    }

    testWidgets('state survives a fold: bottom bar to rail keeps the selected tab', (tester) async {
      _setView(tester, const Size(411, 923));
      await tester.pumpWidget(shellApp());
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Settings tab'));
      await tester.pumpAndSettle();
      _setView(tester, const Size(841, 884));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('side-rail')), findsOneWidget);
      expect(find.text('page /settings'), findsOneWidget);
    });
  });
}
