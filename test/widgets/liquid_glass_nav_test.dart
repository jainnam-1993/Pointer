import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/reduce_transparency.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/liquid_glass_nav.dart';

/** Acceptance checks for the Liquid Glass tab bar (CalmGlassBrief 3.2, 3.3 and 3.5). */
void main() {
  const tabs = <LiquidTab>[
    (AppIcons.home, AppIcons.homeActive, 'Home'),
    (AppIcons.inquiry, AppIcons.inquiryActive, 'Inquiry'),
    (AppIcons.library, AppIcons.libraryActive, 'Library'),
    (AppIcons.settings, AppIcons.settingsActive, 'Settings'),
  ];

  Future<void> pumpBar(WidgetTester tester, int index, {bool reduceMotion = false, bool minimized = false, bool highContrast = false}) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: MediaQueryData(size: const Size(390, 844), disableAnimations: reduceMotion, highContrast: highContrast),
          child: Scaffold(
            body: BackdropGroup(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: minimized ? LiquidGlassNav.minimizedWidth(tabs.length) : 358,
                  height: minimized ? LiquidGlass.barMinimizedHeight : LiquidGlass.barHeight,
                  child: LiquidGlassNav(tabs: tabs, currentIndex: index, onTap: (_) {}, axis: Axis.horizontal, minimized: minimized),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Rect pill(WidgetTester tester) => tester.getRect(find.byKey(const ValueKey('liquid-pill')));

  test('stretch grows with speed and caps at 22%', () {
    expect(liquidStretch(0), 0);
    expect(liquidStretch(240), closeTo(0.1, 1e-9));
    expect(liquidStretch(-240), closeTo(0.1, 1e-9));
    expect(liquidStretch(5000), LiquidGlass.stretchMax);
  });

  testWidgets('one grouped blur at sigma 14 and a capsule 64 tall', (tester) async {
    await pumpBar(tester, 0);
    final blurs = tester.widgetList<BackdropFilter>(find.byType(BackdropFilter)).toList();
    expect(blurs, hasLength(1));
    expect(blurs.single.filter, ImageFilter.blur(sigmaX: 14, sigmaY: 14));
    expect(tester.getSize(find.byType(LiquidGlassNav)).height, LiquidGlass.barHeight);
  });

  testWidgets('pill sits under the selected tab, inset 6 and concentric', (tester) async {
    await pumpBar(tester, 0);
    final p = pill(tester);
    final bar = tester.getRect(find.byType(LiquidGlassNav));
    expect(p.height, LiquidGlass.barHeight - 2 * LiquidGlass.pillInset);
    expect(p.top - bar.top, LiquidGlass.pillInset);
    expect(p.left - bar.left, greaterThanOrEqualTo(LiquidGlass.pillInset));
    expect(p.center.dx, closeTo(tester.getCenter(find.text('Home')).dx, 0.5));
  });

  testWidgets('pill travels on the liquid spring: it stretches, overshoots once and settles under the new tab', (tester) async {
    await pumpBar(tester, 0);
    final base = pill(tester).width;
    await pumpBar(tester, 2);
    final target = tester.getCenter(find.text('Library')).dx;
    var maxWidth = 0.0;
    var maxX = 0.0;
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      maxWidth = maxWidth < pill(tester).width ? pill(tester).width : maxWidth;
      maxX = maxX < pill(tester).center.dx ? pill(tester).center.dx : maxX;
    }
    await tester.pumpAndSettle();
    expect(maxWidth, greaterThan(base));
    expect(maxWidth, lessThanOrEqualTo(base * (1 + LiquidGlass.stretchMax) + 0.01));
    expect(maxX, greaterThan(target), reason: 'one visible overshoot');
    expect(pill(tester).center.dx, closeTo(target, 0.5));
    expect(pill(tester).width, closeTo(base, 0.01));
  });

  testWidgets('Reduce Motion: the pill does not travel; it is under the new tab on the next frame', (tester) async {
    await pumpBar(tester, 0, reduceMotion: true);
    await pumpBar(tester, 3, reduceMotion: true);
    await tester.pump();
    expect(pill(tester).center.dx, closeTo(tester.getCenter(find.text('Settings')).dx, 0.5));
    await tester.pumpAndSettle();
  });

  testWidgets('minimized bar is icons only, 48 tall, with a round pill and 44 pt targets', (tester) async {
    await pumpBar(tester, 1, minimized: true);
    await tester.pumpAndSettle();
    expect(find.text('Inquiry'), findsNothing);
    expect(tester.getSize(find.byType(LiquidGlassNav)).height, LiquidGlass.barMinimizedHeight);
    expect(pill(tester).width, pill(tester).height);
    for (final label in ['Home tab', 'Inquiry tab, selected', 'Library tab', 'Settings tab']) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget), reason: label);
      expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget), reason: label);
    }
  });

  testWidgets('Reduce Transparency drops the live blur and keeps the pill', (tester) async {
    ReduceTransparency.instance.debugSet(true);
    addTearDown(() => ReduceTransparency.instance.debugSet(false));
    await pumpBar(tester, 1);
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byKey(const ValueKey('liquid-pill')), findsOneWidget);
  });

  testWidgets('Android fallback: high contrast also drops the live blur', (tester) async {
    await pumpBar(tester, 1, highContrast: true);
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
