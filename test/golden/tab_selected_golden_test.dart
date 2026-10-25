import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/lens_tab_bar.dart';

import 'golden_test_helpers.dart' show setupGoldenTests, teardownGoldenTests;

/** Golden of each tab selected, bar and rail, light and dark: the rest pill must be the same glass and size for all. */
void main() {
  setUpAll(setupGoldenTests);
  tearDownAll(teardownGoldenTests);
  const tabs = <LensTab>[(AppIcons.home, 'Today'), (AppIcons.library, 'Library'), (AppIcons.heart, 'Saved')];
  for (final dark in [false, true]) {
    for (final axis in [Axis.horizontal, Axis.vertical]) {
      for (var i = 0; i < tabs.length; i++) {
        final name = '${axis == Axis.horizontal ? 'bar' : 'rail'}_${dark ? 'dark' : 'light'}_${tabs[i].$2.toLowerCase()}';
        testWidgets('tab selected golden $name', (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: dark ? AppTheme.dark : AppTheme.light,
              home: Scaffold(
                backgroundColor: dark ? const Color(0xFF14121C) : const Color(0xFFF2EEE3),
                body: Center(
                  child: SizedBox(
                    width: axis == Axis.horizontal ? 300 : 72,
                    height: axis == Axis.horizontal ? 64 : 3 * 64 + 16,
                    child: LensTabBar(tabs: tabs, currentIndex: i, onTap: (_) {}, axis: axis),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await expectLater(find.byType(LensTabBar), matchesGoldenFile('goldens/tab_selected_$name.png'));
        });
      }
    }
  }
}
