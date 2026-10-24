import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/utils/motion.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:pointer/widgets/pointer_switch.dart';
import 'package:pointer/widgets/pointer_toast.dart';

Widget _host(Widget child, {double scale = 1.0, double width = 320, bool reduceMotion = false, ThemeData? theme}) {
  return ProviderScope(
    key: ValueKey(reduceMotion),
    overrides: [highContrastProvider.overrideWith((ref) => false), reduceMotionOverrideProvider.overrideWith((ref) => reduceMotion ? true : null)],
    child: MaterialApp(
      theme: theme ?? AppTheme.dark,
      home: MediaQuery(
        data: MediaQueryData(size: Size(width, 800), textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('text scaling at 200%', () {
    final components = <String, Widget Function()>{
      'GlassButton': () => GlassButton(label: 'Begin the inquiry', onPressed: () {}),
      'GlassCard with a pointing': () => GlassCard(
        child: Builder(builder: (context) => Text('What is aware of these words right now?', style: AppTextStyles.pointingText(context))),
      ),
      'PointerSwitch in a settings row': () => Row(
        children: [
          const Expanded(child: Text('Animations')),
          PointerSwitch(value: true, onChanged: (_) {}),
        ],
      ),
    };
    for (final theme in [AppTheme.dark, AppTheme.light]) {
      for (final c in components.entries) {
        testWidgets('${c.key} does not clip (${theme.brightness.name})', (tester) async {
          await tester.pumpWidget(_host(theme: theme, scale: 2.0, c.value()));
          await tester.pump(Motion.calm);
          final e = tester.takeException();
          expect(e, isNull, reason: e is FlutterError ? e.toStringDeep() : '$e');
        });
      }
    }

    testWidgets('styles are not pre-scaled (Text applies the scale once)', (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        _host(
          scale: 2.0,
          Builder(
            builder: (context) {
              style = AppTextStyles.pointingText(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(style.fontSize, AppType.display);
      expect(style.fontFamily, AppFonts.serif);
    });

    testWidgets('root clamp caps the text scale at 2x', (tester) async {
      late double scaled;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(3.0)),
          child: MediaQuery.withClampedTextScaling(
            minScaleFactor: 0.85,
            maxScaleFactor: 2.0,
            child: Builder(
              builder: (context) {
                scaled = MediaQuery.textScalerOf(context).scale(10);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(scaled, 20);
    });
  });

  group('type scale', () {
    test('has six sizes and shared styles use only those sizes', () {
      expect(AppType.scale.toSet().length, 6);
    });
  });

  group('touch targets', () {
    testWidgets('GlassButton and PointerSwitch are at least 48x48', (tester) async {
      await tester.pumpWidget(
        _host(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassButton(label: 'OK', onPressed: () {}),
              PointerSwitch(value: false, onChanged: (_) {}),
            ],
          ),
        ),
      );
      final button = tester.getSize(find.byType(GlassButton));
      final toggle = tester.getSize(find.byType(PointerSwitch));
      expect(button.height, greaterThanOrEqualTo(48));
      expect(button.width, greaterThanOrEqualTo(48));
      expect(toggle.height, greaterThanOrEqualTo(48));
      expect(toggle.width, greaterThanOrEqualTo(48));
    });
  });

  group('controls', () {
    testWidgets('glass button has no ink ripple and scales on press', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(GlassButton(label: 'Press', onPressed: () => taps++)));
      expect(find.descendant(of: find.byType(GlassButton), matching: find.byType(InkWell)), findsNothing);
      final gesture = await tester.startGesture(tester.getCenter(find.text('Press')));
      await tester.pump(Motion.instant);
      final scale = tester.widget<AnimatedScale>(find.descendant(of: find.byType(GlassButton), matching: find.byType(AnimatedScale)));
      expect(scale.scale, Motion.pressScale);
      await gesture.up();
      await tester.pump(Motion.instant);
      expect(taps, 1);
    });

    testWidgets('switch uses the accent track', (tester) async {
      await tester.pumpWidget(_host(PointerSwitch(value: true, onChanged: (_) {})));
      final sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.activeTrackColor, PointerColors.dark.accent);
    });

    testWidgets('toast shows, announces, and dismisses itself', (tester) async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(onPressed: () => PointerToast.show(context, 'Saved'), child: const Text('go')),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(Motion.standard);
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(Motion.standard);
      await tester.pump();
      expect(find.text('Saved'), findsNothing);
    });
  });

  group('motion', () {
    testWidgets('Motion.reduce honors the app Animations toggle and the system flag', (tester) async {
      late bool viaToggle, viaSystem, neither;
      await tester.pumpWidget(_host(reduceMotion: true, Builder(builder: (c) => Text('${viaToggle = Motion.reduce(c)}'))));
      await tester.pumpWidget(_host(Builder(builder: (c) => Text('${neither = Motion.reduce(c)}'))));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(builder: (c) => Text('${viaSystem = Motion.reduce(c)}', textDirection: TextDirection.ltr)),
        ),
      );
      expect(viaToggle, isTrue);
      expect(viaSystem, isTrue);
      expect(neither, isFalse);
    });
  });

  group('icons', () {
    test('tip-tier icons are distinct from each other and from the tabs', () {
      final tabs = {AppIcons.home, AppIcons.inquiry, AppIcons.library, AppIcons.settings, AppIcons.homeActive, AppIcons.inquiryActive};
      final tips = [AppIcons.tipTea, AppIcons.tipCushion, AppIcons.tipIncense, AppIcons.tipRetreat];
      expect(tips.toSet().length, tips.length);
      expect(tips.any(tabs.contains), isFalse);
    });

    test('no lotus or seated-figure glyphs remain in lib/', () {
      for (final banned in ['Icons.self_improvement', 'Icons.spa', 'flowerLotus']) {
        expect(_libContains(banned), isFalse, reason: banned);
      }
    });
  });
}

bool _libContains(String needle) {
  return Directory(
    'lib',
  ).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).any((f) => f.readAsStringSync().contains(needle));
}
