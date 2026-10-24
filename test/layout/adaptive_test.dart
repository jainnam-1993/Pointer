import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  group('foldable inner screen two panes', () {
    // vivo V2330 unfolded at the user's 432 dpi display size: 2200x2480 px at DPR 2.7.
    const vivo = Size(815, 918);

    test('a flat vertical fold makes a medium window two pane', () {
      const flat = DisplayFeature(bounds: Rect.fromLTWH(407, 0, 0, 918), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureFlat);
      final layout = _layout(vivo, [flat]);
      expect(layout.sizeClass, WindowSizeClass.medium);
      expect(layout.posture, Posture.flat, reason: 'a flat fold still does not separate content');
      expect(layout.paneCount, 2);
    });

    test('a near-square inner screen is two pane even with no reported fold', () {
      expect(_layout(vivo).paneCount, 2);
    });

    test('the same width with a phone aspect and no fold stays one pane', () {
      expect(_layout(const Size(815, 1300)).paneCount, 1);
      expect(_layout(const Size(815, 400)).paneCount, 1, reason: 'a landscape phone is not an inner screen');
    });

    test('a horizontal flat fold does not add a pane', () {
      const tableFlat = DisplayFeature(bounds: Rect.fromLTWH(0, 600, 700, 0), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureFlat);
      expect(_layout(const Size(700, 1200), [tableFlat]).paneCount, 1);
    });
  });

  group('TwoPane', () {
    testWidgets('primaryMinWidth floors a narrow flex split and caps at its share', (tester) async {
      Future<double> primaryWidth(double width) async {
        _setView(tester, Size(width, 918));
        await tester.pumpWidget(const MaterialApp(
          home: TwoPane(primaryFlex: 2, secondaryFlex: 3, primaryMinWidth: kListPaneMinWidth, primary: SizedBox.expand(), secondary: SizedBox.expand()),
        ));
        return tester.getSize(find.byKey(const ValueKey('pane-primary'))).width;
      }

      expect(await primaryWidth(841), kListPaneMinWidth, reason: '2/5 of 841 is 336, under the floor');
      expect(await primaryWidth(1200), 480, reason: 'a wide window keeps its flex split');
    });

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

    for (final modifier in [LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.controlLeft]) {
      testWidgets('${modifier.keyLabel}+1 to 4 select the tabs', (tester) async {
        _setView(tester, const Size(1376, 1032));
        await tester.pumpWidget(shellApp());
        await tester.pumpAndSettle();
        for (final (digit, path) in [
          (LogicalKeyboardKey.digit3, '/library'),
          (LogicalKeyboardKey.digit4, '/settings'),
          (LogicalKeyboardKey.digit1, '/'),
        ]) {
          await tester.sendKeyDownEvent(modifier);
          await tester.sendKeyEvent(digit);
          await tester.sendKeyUpEvent(modifier);
          await tester.pumpAndSettle();
          expect(find.text('page $path'), findsOneWidget, reason: path);
        }
      });
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

    for (final (size, swipes) in [(const Size(411, 923), true), (const Size(815, 918), false), (const Size(1024, 1366), false)]) {
      testWidgets('a sideways fling ${swipes ? 'changes' : 'does not change'} tabs at ${size.width.toInt()} wide', (tester) async {
        _setView(tester, size);
        await tester.pumpWidget(shellApp());
        await tester.pumpAndSettle();
        await tester.fling(find.text('page /'), const Offset(-300, 0), 1500);
        await tester.pumpAndSettle();
        expect(find.text(swipes ? 'page /inquiry' : 'page /'), findsOneWidget);
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

  group('modals on regular width', () {
    Future<BuildContext> pumpAt(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      return ctx;
    }

    testWidgets('DialogWidth caps a dialog card at kDialogMaxWidth', (tester) async {
      final ctx = await pumpAt(tester, const Size(1376, 1032));
      showDialog<void>(
        context: ctx,
        builder: (_) => const DialogWidth(
          child: Dialog(key: ValueKey('d'), child: Text('About')),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.descendant(of: find.byKey(const ValueKey('d')), matching: find.byType(Material)).first).width,
        lessThanOrEqualTo(kDialogMaxWidth),
      );
    });

    testWidgets('showAdaptiveSheet: centered panel on medium, bottom sheet on compact, Escape closes both', (tester) async {
      for (final (size, panel) in [(const Size(678, 1032), true), (const Size(375, 1032), false)]) {
        final ctx = await pumpAt(tester, size);
        showAdaptiveSheet<void>(
          context: ctx,
          builder: (_) => const SizedBox(height: 200, child: Text('sheet')),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('form-sheet-panel')), panel ? findsOneWidget : findsNothing, reason: '$size');
        expect(find.byType(BottomSheet), panel ? findsNothing : findsOneWidget, reason: '$size');
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('sheet'), findsNothing, reason: '$size: Escape closes');
      }
    });
  });
}
