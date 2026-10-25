// Layout assertions on the matrix devices (no goldens): panes, hinges, rails and sheets.
@Tags(['overhaul-golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/layout/adaptive.dart';
import 'package:pointer/screens/settings_screen.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/donation_button.dart';
import 'package:pointer/widgets/glass_card.dart';

import 'matrix_harness.dart';

void main() {
  setUpMatrixSuite();

  group('adaptive layout', () {
    MatrixDevice device(String name) => matrixDevice(name);
    MatrixScreen screen(String name) => matrixScreen(name);

    // The hero pointing: the serif Text keyed by the pointing id inside Home's AnimatedSwitcher.
    final heroPointing = find.byWidgetPredicate(
      (w) => w is Text && w.key is ValueKey && w.style?.fontFamily == AppFonts.serif && (w.style?.fontSize ?? 0) >= AppType.display,
    );
    Key? pointingKey(WidgetTester tester) => tester.widgetList<Text>(heroPointing).last.key;

    // "Nothing looks cut off": at rest, every Featured card and Today's card sits wholly
    // inside its pane (or the window when single pane), on every device class.
    for (final name in ['phone', 'foldouter', 'foldinner', 'tablet', 'ipad13l']) {
      testWidgets('no Featured or Today card is partly visible at rest on $name', (tester) async {
        final d = device(name);
        Rect paneFor(Finder f) {
          for (final key in ['pane-primary', 'pane-secondary']) {
            final pane = find.ancestor(of: f, matching: find.byKey(ValueKey(key)));
            if (pane.evaluate().isNotEmpty) return tester.getRect(pane.first);
          }
          return Offset.zero & d.size;
        }

        bool whole(Rect r, Rect area) => r.left >= area.left - 0.5 && r.right <= area.right + 0.5;
        await pumpAt(tester, screen('library'), d);
        final cards = find.byWidgetPredicate((w) => w.key is ValueKey && '${(w.key as ValueKey).value}'.startsWith('featured-card-'));
        // Two panes show Featured in the detail pane at rest; a phone may have it below the fold.
        if (find.byKey(const ValueKey('library-list-detail')).evaluate().isNotEmpty) expect(cards, findsWidgets, reason: name);
        for (final e in cards.evaluate()) {
          final f = find.byWidget(e.widget);
          expect(whole(tester.getRect(f), paneFor(f)), isTrue, reason: '$name ${(e.widget.key as ValueKey).value} ${tester.getRect(f)}');
        }
        await pumpAt(tester, screen('home'), d);
        for (final e in find.byType(GlassCard).evaluate()) {
          final f = find.byWidget(e.widget);
          expect(whole(tester.getRect(f), Offset.zero & d.size), isTrue, reason: '$name Today card ${tester.getRect(f)}');
        }
      });
    }

    testWidgets('keyboard: arrow keys and Space step through pointings on Home', (tester) async {
      await pumpAt(tester, screen('home'), device('ipad13l'));
      final first = pointingKey(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(seconds: 1));
      final second = pointingKey(tester);
      expect(second, isNot(first));
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(seconds: 1));
      expect(pointingKey(tester), isNot(second));
    });

    testWidgets('home: the hero pointing steps up on regular width, and again on tablets (not the Fold)', (tester) async {
      for (final (name, size) in [
        ('phone', AppType.display),
        ('ipadthird', AppType.display),
        ('foldinner', AppType.hero),
        ('ipadhalf', AppType.hero),
        ('tablet10', AppType.hero),
        ('ipad13p', AppType.heroTablet),
        ('ipad13l', AppType.heroTablet),
      ]) {
        await pumpAt(tester, screen('home'), device(name));
        final text = tester.widgetList<Text>(heroPointing).last;
        expect(text.style?.fontSize, size, reason: name);
      }
    });

    testWidgets('notificationsheet: a centered form sheet on iPad, a bottom sheet in a Split View third (Escape: adaptive_test)', (tester) async {
      final sheet = screen('notificationsheet');
      for (final name in ['ipad11p', 'ipad13l']) {
        await pumpAt(tester, sheet, device(name));
        await sheet.drive!(tester);
        final panel = tester.getRect(find.byKey(const ValueKey('form-sheet-panel')));
        expect(panel.width, lessThanOrEqualTo(kFormSheetMaxWidth), reason: name);
        expect((panel.center.dx - device(name).size.width / 2).abs(), lessThan(1), reason: name);
      }
      await pumpAt(tester, sheet, device('ipadthird'));
      await sheet.drive!(tester);
      expect(find.byKey(const ValueKey('form-sheet-panel')), findsNothing);
      expect(find.byType(BottomSheet), findsOneWidget);
    });
    const medium = MatrixDevice('medium', Size(700, 900), 1);
    const hingeX = 420.0;
    const hingeY = 442.0;

    testWidgets('home: one card on phones, two panes on the Fold, one composed hero column on tall tablets', (tester) async {
      for (final d in [device('phone'), device('foldouter')]) {
        await pumpAt(tester, screen('home'), d);
        expect(find.byKey(const ValueKey('home-context-pane')), findsNothing, reason: d.name);
      }
      await pumpAt(tester, screen('home'), device('foldinner'));
      expect(find.byKey(const ValueKey('pane-primary')), findsOneWidget);
      expect(find.byKey(const ValueKey('home-context-pane')), findsOneWidget);
      for (final d in [medium, device('tablet')]) {
        await pumpAt(tester, screen('home'), d);
        expect(find.byKey(const ValueKey('hero-stack')), findsOneWidget, reason: d.name);
        // The context sits under the card, inside the card's column, not in a far pane.
        final card = tester.getRect(find.byType(GlassCard).first);
        final contextPane = tester.getRect(find.byKey(const ValueKey('home-context-pane')));
        expect(contextPane.top, greaterThan(card.bottom), reason: d.name);
        expect(contextPane.center.dx, closeTo(card.center.dx, card.width / 2), reason: d.name);
      }
    });

    testWidgets('home: panes sit on either side of a vertical hinge', (tester) async {
      await pumpAt(tester, screen('home'), device('foldhinge'));
      expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, lessThanOrEqualTo(hingeX));
      expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, greaterThanOrEqualTo(hingeX));
      expect(tester.getRect(find.byType(GlassCard).first).right, lessThanOrEqualTo(hingeX));
    });

    testWidgets('home: tabletop puts the pointing above the hinge and controls below', (tester) async {
      await pumpAt(tester, screen('home'), device('tabletop'));
      expect(tester.getRect(find.byType(GlassCard).first).bottom, lessThanOrEqualTo(hingeY));
      expect(tester.getRect(find.byKey(const ValueKey('home-tabletop-controls'))).top, greaterThanOrEqualTo(hingeY));
      expect(tester.getRect(find.text('Next')).top, greaterThanOrEqualTo(hingeY));
    });

    testWidgets('settings: two columns on expanded, split at the hinge', (tester) async {
      await pumpAt(tester, screen('settings'), device('foldouter'));
      expect(find.byKey(const ValueKey('settings-two-column')), findsNothing);
      await pumpAt(tester, screen('settings'), device('foldinner'));
      expect(find.byKey(const ValueKey('settings-two-column')), findsOneWidget);
      await pumpAt(tester, screen('settings'), device('foldhinge'));
      expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, lessThanOrEqualTo(hingeX));
      expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, greaterThanOrEqualTo(hingeX));
    });

    testWidgets('shell: bottom bar on compact, rail on medium and up, clear of the hinge', (tester) async {
      await pumpAt(tester, screen('shell'), device('foldouter'));
      expect(find.byKey(const ValueKey('side-rail')), findsNothing);
      expect(find.bySemanticsLabel('Library tab'), findsOneWidget);
      for (final d in [medium, device('foldinner'), device('tablet')]) {
        await pumpAt(tester, screen('shell'), d);
        expect(find.byKey(const ValueKey('side-rail')), findsOneWidget, reason: d.name);
      }
      await pumpAt(tester, screen('shell'), device('foldhinge'));
      expect(tester.getRect(find.byKey(const ValueKey('side-rail'))).right, lessThanOrEqualTo(hingeX));
      await pumpAt(tester, screen('shell'), device('tabletop'));
      final rail = tester.getRect(find.byKey(const ValueKey('side-rail')));
      expect(tester.getRect(find.bySemanticsLabel('Library tab')).top, greaterThanOrEqualTo(hingeY));
      expect(rail.top, greaterThanOrEqualTo(hingeY));
    });

    testWidgets('library: list and detail on expanded only', (tester) async {
      await pumpAt(tester, screen('library'), device('foldouter'));
      expect(find.byKey(const ValueKey('library-list-detail')), findsNothing);
      await pumpAt(tester, screen('library'), medium);
      expect(find.byKey(const ValueKey('library-list-detail')), findsNothing);
      expect(find.byType(ContentWidth), findsOneWidget);
      await pumpAt(tester, screen('library'), device('foldinner'));
      expect(find.byKey(const ValueKey('library-list-detail')), findsOneWidget);
      expect(find.byKey(const ValueKey('library-detail-featured')), findsOneWidget);
    });

    /// Fails if any text or icon straddles the vertical hinge at [hingeX].
    void expectNothingUnderHinge(WidgetTester tester, String name) {
      for (final finder in [find.byType(RichText), find.byType(Icon)]) {
        for (final element in finder.evaluate()) {
          final box = element.renderObject as RenderBox?;
          if (box == null || !box.hasSize || !box.attached) continue;
          final rect = box.localToGlobal(Offset.zero) & box.size;
          expect(rect.left < hingeX && rect.right > hingeX, isFalse, reason: '$name: ${element.widget} at $rect crosses the hinge');
        }
      }
    }

    for (final name in ['article', 'lineages', 'onboarding']) {
      testWidgets('$name: content stays off a vertical hinge', (tester) async {
        await pumpAt(tester, screen(name), device('foldhinge'));
        expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, lessThanOrEqualTo(hingeX), reason: name);
        expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, greaterThanOrEqualTo(hingeX), reason: name);
        expectNothingUnderHinge(tester, name);
        // Phones and unfolded tablets keep the single column.
        await pumpAt(tester, screen(name), device('phone'));
        expect(find.byKey(const ValueKey('pane-primary')), findsNothing, reason: name);
      });
    }

    testWidgets('lineages: on a hinge, info selects the tradition in the detail pane', (tester) async {
      await pumpAt(tester, screen('lineages'), device('foldhinge'));
      final first = traditions.keys.first;
      expect(find.byKey(ValueKey('lineages-detail-${first.name}')), findsOneWidget);
      await tester.tap(find.byIcon(AppIcons.info).at(1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byKey(ValueKey('lineages-detail-${traditions.keys.elementAt(1).name}')), findsOneWidget);
    });

    testWidgets('notificationsheet: tabletop opens below the hinge with Done reachable', (tester) async {
      final sheet = screen('notificationsheet');
      await pumpAt(tester, sheet, device('tabletop'));
      await sheet.drive!(tester);
      final sheetRect = tester.getRect(find.byType(NotificationTimesSheet));
      expect(sheetRect.top, greaterThanOrEqualTo(hingeY));
      final done = tester.getRect(find.byKey(const ValueKey('notification-sheet-done')));
      expect(done.top, greaterThanOrEqualTo(hingeY));
      expect(done.bottom, lessThanOrEqualTo(device('tabletop').size.height));
      // The schedule overflows the lower half: a soft bottom edge marks it as scrollable.
      expect(find.byKey(const ValueKey('notification-sheet-fade')), findsOneWidget);
      await tester.tap(find.text('Done'));
      await settleTransient(tester);
      expect(find.byType(NotificationTimesSheet), findsNothing);
    });

    testWidgets('notificationsheet: phone keeps the 70 percent sheet', (tester) async {
      final sheet = screen('notificationsheet');
      await pumpAt(tester, sheet, device('phone'));
      await sheet.drive!(tester);
      expect(tester.getRect(find.byType(NotificationTimesSheet)).height, lessThanOrEqualTo(device('phone').size.height * 0.7 + 0.5));
      expect(find.byKey(const ValueKey('notification-sheet-done')).hitTestable(), findsOneWidget);
      // Scrolled to the end nothing is hidden below, so the fade goes away.
      final position = tester
          .state<ScrollableState>(
            find.descendant(of: find.byKey(const ValueKey('notification-sheet-scroll')), matching: find.byType(Scrollable)).first,
          )
          .position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await settleTransient(tester);
      expect(find.byKey(const ValueKey('notification-sheet-fade')), findsNothing);
    });

    testWidgets('notificationsheet: no fade when the schedule fits', (tester) async {
      final sheet = screen('notificationsheet');
      await pumpAt(tester, sheet, device('tablet'));
      await sheet.drive!(tester);
      expect(find.byKey(const ValueKey('notification-sheet-fade')), findsNothing);
    });

    testWidgets('tip: the card is capped on wide windows and tiles keep phone proportions', (tester) async {
      final tip = screen('tip');
      for (final name in ['tablet', 'foldinner']) {
        await pumpAt(tester, tip, device(name));
        await tip.drive!(tester);
        expect(
          tester.getSize(find.descendant(of: find.byType(DonationButton), matching: find.byType(GlassCard)).first).width,
          lessThanOrEqualTo(kTipCardMaxWidth),
          reason: name,
        );
        // Two columns at the fixed 1.4 aspect ratio inside a phone-wide card: tiles stay phone sized.
        expect(tester.getSize(find.byType(GridView)).width, lessThanOrEqualTo(kTipCardMaxWidth), reason: name);
      }
    });
  });
}
