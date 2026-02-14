import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/articles.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/screens/article_reader_screen.dart';
import 'package:pointer/screens/history_screen.dart';
import 'package:pointer/screens/home_screen.dart';
import 'package:pointer/screens/inquiry_player_screen.dart';
import 'package:pointer/screens/inquiry_screen.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/screens/lineages_screen.dart';
import 'package:pointer/screens/onboarding_screen.dart';
import 'package:pointer/screens/settings_screen.dart';

import '../golden/golden_test_helpers.dart';

class _ResponsiveDevice {
  const _ResponsiveDevice(this.name, this.size);

  final String name;
  final Size size;
}

class _ScreenCase {
  const _ScreenCase({required this.name, required this.builder, this.initialPointing});

  final String name;
  final Widget Function() builder;
  final Pointing? initialPointing;
}

Future<void> _pumpAndAssertResponsive(
  WidgetTester tester, {
  required _ScreenCase screen,
  required _ResponsiveDevice device,
  double textScaleFactor = 1.0,
}) async {
  final prefs = await createMockPrefs();

  await pumpForGolden(
    tester,
    createGoldenTestApp(
      child: screen.builder(),
      prefs: prefs,
      size: device.size,
      initialPointing: screen.initialPointing,
      textScaleFactor: textScaleFactor,
    ),
    size: device.size,
  );

  final initialException = tester.takeException();
  if (initialException != null) {
    fail('${screen.name} should not throw on ${device.name} at ${textScaleFactor}x text scale\n$initialException');
  }

  final verticalScrollables = find.byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down);
  if (verticalScrollables.evaluate().isNotEmpty) {
    await tester.drag(verticalScrollables.first, const Offset(0, -320));
    await tester.pump(const Duration(milliseconds: 400));
    final postScrollException = tester.takeException();
    if (postScrollException != null) {
      fail('${screen.name} should remain stable after scrolling on ${device.name}\n$postScrollException');
    }
  }
}

void main() {
  setUpAll(() async {
    await setupGoldenTests();
  });

  tearDownAll(() {
    teardownGoldenTests();
  });

  const devices = [
    _ResponsiveDevice('iphone_se_1', Size(320, 568)),
    _ResponsiveDevice('iphone_se_2', Size(375, 667)),
    _ResponsiveDevice('small_android', Size(360, 640)),
  ];

  final screens = <_ScreenCase>[
    const _ScreenCase(name: 'home', builder: HomeScreen.new, initialPointing: goldenTestPointing),
    const _ScreenCase(name: 'inquiry', builder: InquiryScreen.new),
    _ScreenCase(
      name: 'inquiry_player',
      builder: () => const InquiryPlayerScreen(inquiryId: '1'),
    ),
    const _ScreenCase(name: 'library', builder: LibraryScreen.new),
    const _ScreenCase(name: 'lineages', builder: LineagesScreen.new),
    const _ScreenCase(name: 'settings', builder: SettingsScreen.new),
    const _ScreenCase(name: 'history', builder: HistoryScreen.new),
    const _ScreenCase(name: 'onboarding', builder: OnboardingScreen.new),
    _ScreenCase(
      name: 'article_reader',
      builder: () => ArticleReaderScreen(article: articles.first),
    ),
  ];

  group('Responsive layout - default text scale', () {
    for (final screen in screens) {
      for (final device in devices) {
        testWidgets('${screen.name} on ${device.name}', (tester) async {
          await _pumpAndAssertResponsive(tester, screen: screen, device: device);
        });
      }
    }
  });

  group('Responsive layout - larger text scale', () {
    final textScaleScreens = screens.where((screen) {
      return screen.name == 'home' ||
          screen.name == 'inquiry' ||
          screen.name == 'library' ||
          screen.name == 'onboarding' ||
          screen.name == 'settings';
    });

    for (final screen in textScaleScreens) {
      for (final device in devices) {
        testWidgets('${screen.name} on ${device.name} with 1.3x text', (tester) async {
          await _pumpAndAssertResponsive(tester, screen: screen, device: device, textScaleFactor: 1.3);
        });
      }
    }
  });
}
