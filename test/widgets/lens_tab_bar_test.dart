import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/lens_tab_bar.dart';

/** The lens tab bar: high contrast draws no glass, every tab is a 44 pt target, and only the active tab has a label. */
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

  testWidgets('only the active tab shows a label; every tab is at least 44 pt', (tester) async {
    await pumpBar(tester, AppTheme.light);
    expect(find.text('Inquiry'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    for (final label in ['Home tab', 'Inquiry tab, selected', 'Library tab', 'Settings tab']) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget), reason: label);
      expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget), reason: label);
    }
  });
}
