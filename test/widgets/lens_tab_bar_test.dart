import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/lens_tab_bar.dart';

import '../helpers/app_fonts.dart';

/** The lens tab bar: high contrast draws no glass, every tab is a 44 pt target, and every tab shows its label, fitting its cell at text scale 1.3 and 2.0. */
void main() {
  const tabs = <LensTab>[
    (AppIcons.homeFilled, 'Home'),
    (AppIcons.inquiryFilled, 'Inquiry'),
    (AppIcons.libraryFilled, 'Library'),
    (AppIcons.settingsFilled, 'Settings'),
  ];

  Future<void> pumpBar(WidgetTester tester, ThemeData theme, {int index = 1}) => tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 358,
            height: 64,
            child: LensTabBar(tabs: tabs, currentIndex: index, onTap: (_) {}, axis: Axis.horizontal),
          ),
        ),
      ),
    ),
  );

  testWidgets('high contrast: no backdrop blur or lens, a bordered solid bar', (tester) async {
    for (final theme in [AppTheme.highContrastDark, AppTheme.highContrastLight]) {
      await pumpBar(tester, theme);
      expect(find.byType(BackdropFilter), findsNothing);
      final bar = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).map((d) => d.decoration).whereType<BoxDecoration>().first;
      expect(bar.border, isNotNull);
      expect(bar.boxShadow, isNull);
    }
  });

  testWidgets('dark theme: the capsule has a light hairline', (tester) async {
    await pumpBar(tester, AppTheme.dark);
    final bar = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox)).map((d) => d.decoration).whereType<BoxDecoration>().first;
    expect(bar.color, LensTabStyle.capsuleDark);
    expect(bar.border, isNotNull);
  });

  /** Labels the user can see: Text widgets whose Opacity ancestors are all non-zero. */
  List<String> visibleLabels(WidgetTester tester) => [
    for (final e in find.descendant(of: find.byType(LensTabBar), matching: find.byType(Text)).evaluate())
      if (tester.widgetList<Opacity>(find.ancestor(of: find.byWidget(e.widget), matching: find.byType(Opacity))).every((o) => o.opacity > 0))
        (e.widget as Text).data!,
  ];

  testWidgets('every tab shows its label once; every tab is at least 44 pt', (tester) async {
    await pumpBar(tester, AppTheme.light);
    expect(visibleLabels(tester)..sort(), ['Home', 'Inquiry', 'Library', 'Settings']);
    for (final label in ['Home tab', 'Inquiry tab, selected', 'Library tab', 'Settings tab']) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget), reason: label);
      expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget), reason: label);
    }
  });

  for (final scale in [1.3, 2.0]) {
    for (final axis in [Axis.horizontal, Axis.vertical]) {
      testWidgets('labels fit their cells at text scale $scale ($axis): no overflow, inside the bar', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Center(
                child: SizedBox(
                  width: axis == Axis.horizontal ? 358 : 72,
                  height: axis == Axis.horizontal ? 64 : 4 * 64 + 16,
                  child: LensTabBar(tabs: tabs, currentIndex: 1, onTap: (_) {}, axis: axis),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final bar = tester.getRect(find.byType(LensTabBar));
        for (final e in find.descendant(of: find.byType(LensTabBar), matching: find.byType(Text)).evaluate()) {
          final r = tester.getRect(find.byWidget(e.widget));
          expect(
            bar.inflate(1).contains(r.topLeft) && bar.inflate(1).contains(r.bottomRight),
            isTrue,
            reason: '${(e.widget as Text).data} $r in $bar',
          );
        }
      });
    }
  }

  test('inactive labels keep 4.5:1 on the resting bar in light and dark', () {
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
    }

    final light = LensBarLook.of(dark: false, highContrast: false);
    expect(ratio(light.inactive, Color.alphaBlend(light.capsule, PointerColors.light.background)), greaterThanOrEqualTo(4.5));
    final dark = LensBarLook.of(dark: true, highContrast: false);
    expect(ratio(dark.inactive, dark.capsule), greaterThanOrEqualTo(4.5));
  });

  group('lens state machine (native iOS 27 reference)', () {
    Future<List<int>> pumpLive(WidgetTester tester) async {
      final taps = <int>[];
      var index = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: StatefulBuilder(
            builder: (context, set) => Scaffold(
              body: Center(
                child: SizedBox(
                  width: 358,
                  height: 64,
                  child: LensTabBar(
                    tabs: tabs,
                    currentIndex: index,
                    onTap: (i) => set(() {
                      taps.add(i);
                      index = i;
                    }),
                    axis: Axis.horizontal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      return taps;
    }

    final lens = find.byKey(const ValueKey('tab-lens'));

    /** Rest: no lens (so no refraction shader), the active label at scale 1.0, a flat tinted pill. */
    void expectRest(WidgetTester tester, String activeLabel) {
      expect(lens, findsNothing);
      expect(find.byType(BackdropFilter).evaluate().length, lessThanOrEqualTo(1), reason: 'only the light bar frost; no lens refraction at rest');
      final scales = tester.widgetList<Transform>(find.ancestor(of: find.text(activeLabel), matching: find.byType(Transform)));
      for (final t in scales) {
        expect(t.transform.entry(0, 0), closeTo(1.0, 1e-6), reason: 'no magnification at rest');
      }
      // The resting glass pill (no lens, no refraction) marks the selected tab.
      expect(find.byKey(const ValueKey('tab-pill')), findsOneWidget, reason: 'a resting glass pill marks the selected tab');
    }

    testWidgets('rest on first build: flat pill, no lens, no magnification', (tester) async {
      await pumpLive(tester);
      expectRest(tester, 'Home');
      await tester.pumpAndSettle();
      expectRest(tester, 'Home');
    });

    testWidgets('pressed: the lens lifts under the finger; release settles and flattens it', (tester) async {
      final taps = await pumpLive(tester);
      final g = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Library tab')));
      // The tap's touch-down fires at the 100 ms press deadline; then the lift spring needs frames.
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 250));
      expect(lens, findsOneWidget);
      await g.up();
      await tester.pumpAndSettle();
      expect(taps, [2]);
      expectRest(tester, 'Library');
    });

    testWidgets('dragging: the lens follows the finger and selects where it is released', (tester) async {
      final taps = await pumpLive(tester);
      final from = tester.getCenter(find.bySemanticsLabel('Home tab, selected'));
      final to = tester.getCenter(find.bySemanticsLabel('Settings tab'));
      final g = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 100));
      for (var k = 1; k <= 10; k++) {
        await g.moveTo(Offset.lerp(from, to, k / 10)!);
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(lens, findsOneWidget);
      await g.up();
      await tester.pumpAndSettle();
      expect(taps.last, 3);
      expectRest(tester, 'Settings');
    });

    testWidgets('a fast flick selects the tab under the finger where it lifts, not where the lens lags', (tester) async {
      final taps = await pumpLive(tester);
      // Start on Library.
      await tester.tap(find.bySemanticsLabel('Library tab'));
      await tester.pumpAndSettle();
      final from = tester.getCenter(find.bySemanticsLabel('Library tab, selected'));
      final to = tester.getCenter(find.bySemanticsLabel('Home tab'));
      final g = await tester.startGesture(from);
      for (var k = 1; k <= 4; k++) {
        await g.moveTo(Offset.lerp(from, to, k / 6)!); // the moves stop two thirds of the way...
        await tester.pump(const Duration(milliseconds: 20));
      }
      await g.moveTo(to); // ...and the finger lifts at Home within about 100 ms
      await g.up();
      await tester.pumpAndSettle();
      expect(taps.last, 0);
      expectRest(tester, 'Home');
    });

    testWidgets('release flattens the lens in parallel with the move, in about 110 ms', (tester) async {
      await pumpLive(tester);
      final g = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Settings tab')));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 300));
      expect(lens, findsOneWidget);
      await g.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      expect(lens, findsNothing, reason: 'flat again well before the liquid move finishes');
      await tester.pumpAndSettle();
    });

    testWidgets('latency: the lens is lifting on the frame after pointer-down, and full within about 130 ms', (tester) async {
      await pumpLive(tester);
      final g = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Library tab')));
      await tester.pump(); // the frame after pointer-down: no tap slop, arena or long-press wait
      await tester.pump(const Duration(milliseconds: 16));
      expect(lens, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 120));
      final o = tester.widget<Opacity>(lens);
      expect(o.opacity, greaterThan(0.97), reason: 'fully lifted by about 130 ms');
      await g.up();
      await tester.pumpAndSettle();
    });

    testWidgets('light mode: the label on the lifted lens keeps at least 4.5:1 against the lens (658aba4 regression)', (tester) async {
      await pumpLive(tester);
      final g = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Library tab')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(lens, findsOneWidget);
      // The lens's own label (w600); the hidden cell label underneath is w500.
      final label = tester
          .widgetList<Text>(find.descendant(of: find.byType(LensTabBar), matching: find.text('Library')))
          .firstWhere((t) => t.style!.fontWeight == FontWeight.w600);
      final ink = label.style!.color!;
      // What the label sits on: the light background, under the light glass capsule, under the lens fill.
      final look = LensBarLook.of(dark: false, highContrast: false);
      final under = Color.alphaBlend(LensTabStyle.lensFallbackFill, Color.alphaBlend(look.capsule, PointerColors.light.background));
      double lum(Color c) => c.computeLuminance();
      final ratio = (math.max(lum(ink), lum(under)) + 0.05) / (math.min(lum(ink), lum(under)) + 0.05);
      expect(ratio, greaterThanOrEqualTo(4.5), reason: 'label ${ink.toARGB32().toRadixString(16)} on lens ${under.toARGB32().toRadixString(16)}');
      await g.up();
      await tester.pumpAndSettle();
    });

    testWidgets('a pressed lens draws its tab once: the cell icon under the lens is hidden from the backdrop', (tester) async {
      for (final axis in [Axis.horizontal, Axis.vertical]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: axis == Axis.horizontal ? 358 : 72,
                  height: axis == Axis.horizontal ? 64 : 4 * 64 + 16,
                  child: LensTabBar(tabs: tabs, currentIndex: 0, onTap: (_) {}, axis: axis),
                ),
              ),
            ),
          ),
        );
        final g = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Library tab')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(lens, findsOneWidget, reason: '$axis');
        final visibleLibraryIcons = tester
            .widgetList<Icon>(find.byIcon(AppIcons.libraryFilled))
            .where(
              (icon) =>
                  tester.widgetList<Opacity>(find.ancestor(of: find.byWidget(icon), matching: find.byType(Opacity))).every((o) => o.opacity > 0),
            )
            .length;
        expect(visibleLibraryIcons, 1, reason: 'exactly one Library glyph on screen while the lens is over it ($axis)');
        await g.up();
        await tester.pumpAndSettle();
      }
    });
  });

  group('uniform selected pill (user report, 2026-10-24)', () {
    Future<void> pumpAt(WidgetTester tester, Axis axis, int index, {double scale = 1.0}) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Center(
            child: SizedBox(
              width: axis == Axis.horizontal ? 358 : 72,
              height: axis == Axis.horizontal ? 64 : 4 * 64 + 16,
              child: LensTabBar(tabs: tabs, currentIndex: index, onTap: (_) {}, axis: axis),
            ),
          ),
        ),
      ),
    );

    for (final axis in [Axis.horizontal, Axis.vertical]) {
      testWidgets('every tab gets the same pill size, centred on its cell, and the same icon size ($axis)', (tester) async {
        Size? size;
        Offset? iconOffsetInPill;
        for (var i = 0; i < tabs.length; i++) {
          await pumpAt(tester, axis, i);
          await tester.pumpAndSettle();
          final pill = tester.getRect(find.byKey(const ValueKey('tab-pill')));
          size ??= pill.size;
          expect(pill.width, closeTo(size.width, 0.01), reason: 'tab $i');
          expect(pill.height, closeTo(size.height, 0.01), reason: 'tab $i');
          final cell = tester.getRect(find.bySemanticsLabel(RegExp('^${tabs[i].$2} tab, selected')));
          expect((pill.center - cell.center).distance, lessThan(0.5), reason: 'pill centred on tab $i');
          final icon = find.descendant(of: find.byType(LensTabBar), matching: find.byIcon(tabs[i].$1));
          final visible = icon.evaluate().map((e) => tester.getRect(find.byWidget(e.widget))).where((r) => pill.contains(r.center)).toList();
          expect(visible, isNotEmpty);
          expect(visible.first.width, closeTo(24, 0.01), reason: 'icon size is fixed for every tab');
          expect(visible.first.height, closeTo(24, 0.01), reason: 'icon size is fixed for every tab');
          final off = visible.first.center - pill.center;
          iconOffsetInPill ??= off;
          expect((off - iconOffsetInPill).distance, lessThan(0.5), reason: 'icon sits at the same place in every pill');
        }
      });

      for (final scale in [1.3, 2.0]) {
        testWidgets('at text scale $scale the pill size and icon size do not change; labels scale down, never clip ($axis)', (tester) async {
          await pumpAt(tester, axis, 0);
          await tester.pumpAndSettle();
          final base = tester.getRect(find.byKey(const ValueKey('tab-pill'))).size;
          await pumpAt(tester, axis, 0, scale: scale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final now = tester.getRect(find.byKey(const ValueKey('tab-pill'))).size;
          expect(now.width, closeTo(base.width, 0.01));
          expect(now.height, closeTo(base.height, 0.01));
          for (final e in find.descendant(of: find.byType(LensTabBar), matching: find.byType(Icon)).evaluate()) {
            final sz = tester.getSize(find.byWidget(e.widget));
            expect(sz.width, closeTo(24, 0.01));
            expect(sz.height, closeTo(24, 0.01));
          }
        });
      }
    }
  });

  group('labels inside the pill and the large label (merge review, 2026-10-24)', () {
    // The real fonts and the app's tabs, under a Scaffold as in the shell: the inherited Material text style (letter
    // spacing 0.25) and Inter's real advances are what made r12 clip "Library" to "Librar" on the rail. The test font
    // (Ahem) and a bare MaterialApp hid both.
    setUpAll(loadAppFonts);
    const shell = <LensTab>[(AppIcons.home, 'Today'), (AppIcons.library, 'Library'), (AppIcons.heart, 'Saved')];

    Future<void> pumpAt(WidgetTester tester, Axis axis, int index, double scale) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Center(
              child: SizedBox(
                width: axis == Axis.horizontal ? 358 : 72,
                height: axis == Axis.horizontal ? 64 : shell.length * 64 + 16,
                child: LensTabBar(tabs: shell, currentIndex: index, onTap: (_) {}, axis: axis),
              ),
            ),
          ),
        ),
      ),
    );

    for (final axis in [Axis.horizontal, Axis.vertical]) {
      for (final scale in [1.0, 1.3, 1.6, 2.0]) {
        testWidgets('every label lies inside its pill at text scale $scale ($axis)', (tester) async {
          await pumpAt(tester, axis, 0, scale);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          // One label size for the whole axis, selected or not (merge review: the selected label was smaller).
          final sizes = {
            for (final e in find.descendant(of: find.byType(LensTabBar), matching: find.byType(Text)).evaluate()) (e.widget as Text).style!.fontSize,
          };
          expect(sizes, hasLength(1), reason: 'label sizes $sizes');
          final pillSize = tester.getRect(find.byKey(const ValueKey('tab-pill'))).size;
          for (var i = 0; i < shell.length; i++) {
            final cell = tester.getRect(find.bySemanticsLabel(RegExp('^${shell[i].$2} tab')));
            final pill = Rect.fromCenter(center: cell.center, width: pillSize.width, height: pillSize.height).inflate(0.5);
            final painted = find.descendant(of: find.byType(LensTabBar), matching: find.text(shell[i].$2));
            expect(painted, findsWidgets);
            for (final e in painted.evaluate()) {
              // The painted text, not the Text box: the box is clamped to its slot, so it always "fits" even when the
              // last letters wrapped onto a hidden second line.
              final p = tester.renderObject<RenderParagraph>(find.descendant(of: find.byWidget(e.widget), matching: find.byType(RichText)));
              expect(p.didExceedMaxLines, isFalse, reason: '${shell[i].$2} wraps past one line (clipped) at $scale');
              final lineWidth = p.getMaxIntrinsicWidth(double.infinity);
              expect(lineWidth, lessThanOrEqualTo(p.size.width + 0.01), reason: '${shell[i].$2} needs $lineWidth, has ${p.size.width}');
              final r = tester.getRect(find.byWidget(e.widget));
              expect(pill.contains(r.topLeft) && pill.contains(r.bottomRight), isTrue, reason: '${shell[i].$2} $r outside pill $pill');
            }
          }
        });
      }
    }

    testWidgets('above the cap, a long press shows the tab label large; release hides it', (tester) async {
      await pumpAt(tester, Axis.vertical, 0, 2.0);
      await tester.pumpAndSettle();
      final g = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Library tab')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('tab-large-label')), findsOneWidget);
      expect(find.descendant(of: find.byKey(const ValueKey('tab-large-label')), matching: find.text('Library')), findsOneWidget);
      await g.up();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('tab-large-label')), findsNothing);
    });

    testWidgets('at or below the cap, a long press shows no large label', (tester) async {
      await pumpAt(tester, Axis.vertical, 0, 1.3);
      await tester.pumpAndSettle();
      final g = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Library tab')));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey('tab-large-label')), findsNothing);
      await g.up();
      await tester.pumpAndSettle();
    });
  });
}
