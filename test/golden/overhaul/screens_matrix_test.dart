// Overhaul visual regression matrix.
//
// Renders every key screen through the real widgets on a matrix of device
// classes (phones, Pixel 9 Pro Fold outer/inner, hinge postures, tablet) in
// dark and light themes. Time and animations are frozen so output is
// deterministic on the golden host (the Linux devdesk).
//
// Regenerate:
//   flutter test --update-goldens --tags overhaul-golden test/golden/overhaul/
// Verify:
//   flutter test --tags overhaul-golden test/golden/overhaul/
// Before/after contact sheets:
//   tool/visual_diff.sh <rev-a> <rev-b> [out-dir]
//
// Goldens: test/golden/overhaul/goldens/<screen>_<device>_<theme>.png
@Tags(['overhaul-golden'])
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/theme/app_icons.dart';
import 'package:pointer/data/articles.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/layout/adaptive.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:pointer/models/article.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/screens/article_reader_screen.dart';
import 'package:pointer/screens/home_screen.dart';
import 'package:pointer/screens/main_shell.dart';
import 'package:pointer/screens/library_screen.dart';
import 'package:pointer/screens/lineages_screen.dart';
import 'package:pointer/screens/onboarding_screen.dart';
import 'package:pointer/screens/settings_screen.dart';
import 'package:pointer/screens/share_preview_screen.dart';
import 'package:pointer/services/donation_service.dart';
import 'package:pointer/services/notification_service.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/ambient.dart';
import 'package:pointer/widgets/donation_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../golden_test_helpers.dart' show setupGoldenTests, teardownGoldenTests, createMockPrefs, goldenTestPointing;

/// Article rendered by the reader golden (content preloaded from disk).
const _readerArticleId = 'art_iam_that_001';

/// A device class in the matrix. Sizes are logical pixels.
class MatrixDevice {
  final String name;
  final Size size;
  final double dpr;
  final EdgeInsets safeArea;
  final List<DisplayFeature> displayFeatures;

  const MatrixDevice(this.name, this.size, this.dpr, {this.safeArea = EdgeInsets.zero, this.displayFeatures = const []});
}

const _foldInner = Size(841, 884);

/// Device matrix shared by every screen.
const matrixDevices = <MatrixDevice>[
  MatrixDevice('smallphone', Size(375, 667), 2, safeArea: EdgeInsets.only(top: 20)),
  MatrixDevice('phone', Size(390, 844), 3, safeArea: EdgeInsets.only(top: 47, bottom: 34)),
  MatrixDevice('foldouter', Size(411, 923), 2.625, safeArea: EdgeInsets.only(top: 24, bottom: 24)),
  MatrixDevice('foldinner', _foldInner, 2.625, safeArea: EdgeInsets.only(top: 24, bottom: 24)),
  MatrixDevice(
    'foldhinge',
    _foldInner,
    2.625,
    safeArea: EdgeInsets.only(top: 24, bottom: 24),
    displayFeatures: [
      DisplayFeature(bounds: Rect.fromLTWH(420, 0, 0, 884), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureHalfOpened),
    ],
  ),
  MatrixDevice(
    'tabletop',
    _foldInner,
    2.625,
    safeArea: EdgeInsets.only(top: 24, bottom: 24),
    displayFeatures: [
      DisplayFeature(bounds: Rect.fromLTWH(0, 442, 841, 0), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureHalfOpened),
    ],
  ),
  MatrixDevice('tablet', Size(1024, 1366), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20)),
];

enum MatrixTheme { dark, light }

class _MockNotificationService extends Mock implements NotificationService {}

class _MockInAppPurchase extends Mock implements InAppPurchase {}

class _FakeDonationService extends DonationService {
  _FakeDonationService() : super(_MockInAppPurchase());

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<List<ProductDetails>> loadProducts() async => _tipProducts;

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => const Stream.empty();

  @override
  Future<bool> purchaseProduct(ProductDetails product) async => true;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  void dispose() {}
}

class _FixedDonationNotifier extends DonationNotifier {
  _FixedDonationNotifier(super.service);

  @override
  Future<void> initialize() async {
    state = DonationState(isAvailable: true, isLoading: false, products: _tipProducts);
  }
}

final _tipProducts = [
  ProductDetails(id: 'tip_small', title: 'Tea', description: 'Buy me a tea', price: r'$0.99', rawPrice: 0.99, currencyCode: 'USD'),
  ProductDetails(id: 'tip_medium', title: 'Cushion', description: 'Buy me a cushion', price: r'$4.99', rawPrice: 4.99, currencyCode: 'USD'),
  ProductDetails(id: 'tip_large', title: 'Incense', description: 'Buy me incense', price: r'$9.99', rawPrice: 9.99, currencyCode: 'USD'),
  ProductDetails(id: 'tip_generous', title: 'Retreat', description: 'Fund a retreat', price: r'$24.99', rawPrice: 24.99, currencyCode: 'USD'),
];

late _MockNotificationService _notifications;

/// Loads Roboto and Material Icons from the Flutter SDK; the app's bundled and
/// package fonts come from [loadAppFonts] in setupGoldenTests.
Future<void> _loadSdkFonts() async {
  final exe = Platform.resolvedExecutable;
  final idx = exe.indexOf('${Platform.pathSeparator}bin${Platform.pathSeparator}cache${Platform.pathSeparator}');
  final root = Platform.environment['FLUTTER_ROOT'] ?? (idx >= 0 ? exe.substring(0, idx) : null);
  if (root == null) return;
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) return;
  final roboto = FontLoader('Roboto');
  for (final f in dir.listSync().whereType<File>()) {
    final name = f.uri.pathSegments.last;
    if (name.startsWith('Roboto-') && name.endsWith('.ttf')) {
      roboto.addFont(Future.value(ByteData.view(f.readAsBytesSync().buffer)));
    }
  }
  await roboto.load();
  final icons = File('${dir.path}/MaterialIcons-Regular.otf');
  if (icons.existsSync()) {
    await (FontLoader('MaterialIcons')..addFont(Future.value(ByteData.view(icons.readAsBytesSync().buffer)))).load();
  }
  // Phosphor icon fonts ship in the package; without them every glyph renders as tofu.
  for (final (family, file) in const [
    ('Phosphor', 'Phosphor.ttf'),
    ('PhosphorRegular', 'Phosphor.ttf'),
    ('PhosphorLight', 'Phosphor-Light.ttf'),
    ('PhosphorFill', 'Phosphor-Fill.ttf'),
  ]) {
    await (FontLoader('packages/phosphor_flutter/$family')..addFont(rootBundle.load('packages/phosphor_flutter/lib/fonts/$file'))).load();
  }
}

/// Initializes articles and preloads the reader article body so no asset IO is needed.
void _loadArticlesWithReaderContent() {
  final list = (jsonDecode(File('assets/data/articles.json').readAsStringSync()) as List<dynamic>).cast<Map<String, dynamic>>();
  final parsed = list.map(Article.fromJson).map((a) {
    if (a.id != _readerArticleId) return a;
    return Article(
      id: a.id,
      title: a.title,
      subtitle: a.subtitle,
      content: File('assets/articles/${a.id}.md').readAsStringSync(),
      excerpt: a.excerpt,
      tradition: a.tradition,
      teacher: a.teacher,
      categories: a.categories,
      readingTimeMinutes: a.readingTimeMinutes,
      dateAdded: a.dateAdded,
      topicTags: a.topicTags,
      moodTags: a.moodTags,
    );
  }).toList();
  initArticlesForTest(parsed);
}

/// The real app themes; fonts are bundled, so goldens render Inter and Newsreader.
ThemeData _theme(MatrixTheme theme) => theme == MatrixTheme.dark ? AppTheme.dark : AppTheme.light;

Widget _app({required Widget home, required SharedPreferences prefs, required MatrixTheme theme}) {
  final mode = theme == MatrixTheme.dark ? AppThemeMode.dark : AppThemeMode.light;
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      storageServiceProvider.overrideWith((ref) => StorageService(prefs)),
      settingsProvider.overrideWith((ref) => SettingsNotifier(StorageService(prefs))),
      themeModeProvider.overrideWith((ref) => mode),
      notificationServiceProvider.overrideWithValue(_notifications),
      highContrastProvider.overrideWith((ref) => false),
      oledModeProvider.overrideWith((ref) => false),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
      zenModeProvider.overrideWith((ref) => false),
      donationProvider.overrideWith((ref) => _FixedDonationNotifier(_FakeDonationService())),
      currentPointingProvider.overrideWith((ref) {
        final notifier = CurrentPointingNotifier(ref.watch(storageServiceProvider));
        notifier.setPointing(goldenTestPointing);
        return notifier;
      }),
    ],
    child: MaterialApp(debugShowCheckedModeBanner: false, theme: _theme(theme), home: home),
  );
}

/// Host page used for the sheet and the tip section: real background plus a launch point.
class _HostPage extends StatelessWidget {
  final Widget? body;
  const _HostPage({this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(
            child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: body ?? const SizedBox.expand()),
          ),
        ],
      ),
    );
  }
}

/// A screen in the matrix: how to build it and how to drive it into the captured state.
/// Hosts the real [MainShell] under a GoRouter so shell goldens show the navigation chrome.
class _ShellHost extends StatefulWidget {
  const _ShellHost();

  @override
  State<_ShellHost> createState() => _ShellHostState();
}

class _ShellHostState extends State<_ShellHost> {
  late final GoRouter _router = GoRouter(
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())],
          ),
          for (final path in ['/inquiry', '/library', '/settings'])
            StatefulShellBranch(
              routes: [GoRoute(path: path, builder: (context, state) => const SizedBox.shrink())],
            ),
        ],
      ),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Router.withConfig(config: _router);
}

class MatrixScreen {
  final String name;
  final bool onboardingCompleted;
  final Widget Function() build;
  final Future<void> Function(WidgetTester tester)? drive;

  const MatrixScreen(this.name, this.build, {this.onboardingCompleted = true, this.drive});
}

final matrixScreens = <MatrixScreen>[
  MatrixScreen(
    'onboarding',
    () => const OnboardingScreen(),
    onboardingCompleted: false,
    // First page reveals word by word after a 1.5 s delay; capture the fully revealed page.
    drive: (tester) => _settleTransient(tester, frames: 80),
  ),
  MatrixScreen('home', () => const HomeScreen()),
  // The real MainShell (bottom bar on compact, side rail on medium and up) around Home.
  MatrixScreen('shell', () => const _ShellHost()),
  MatrixScreen('library', () => const Scaffold(body: LibraryScreen())),
  MatrixScreen('settings', () => const SettingsScreen()),
  MatrixScreen('lineages', () => const LineagesScreen()),
  MatrixScreen('article', () => const ArticleReaderScreen(articleId: _readerArticleId)),
  MatrixScreen(
    'notificationsheet',
    () => const _HostPage(),
    drive: (tester) async {
      // Same call as SettingsScreen._showNotificationTimesSheet.
      showModalBottomSheet<void>(
        context: tester.element(find.byType(_HostPage)),
        anchorPoint: sheetAnchorPoint(tester.element(find.byType(_HostPage))),
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => const NotificationTimesSheet(),
      );
      await _settleTransient(tester);
    },
  ),
  MatrixScreen('sharepreview', () => const SharePreviewScreen(pointing: goldenTestPointing)),
  MatrixScreen(
    'tip',
    () => const _HostPage(body: SingleChildScrollView(child: DonationButton())),
    drive: (tester) async {
      await tester.tap(find.text('Support Development'), warnIfMissed: false);
      await _settleTransient(tester);
    },
  ),
];

/// Overflow is part of the documented current state on some devices; record it
/// in the log instead of failing, since the golden shows the overflow stripes.
bool _isLayoutOverflow(FlutterErrorDetails d) => d.exceptionAsString().contains('overflowed');

/// Goldens render at DPR 1.0 to keep the matrix small (under 10 MB). Layout depends only on
/// logical size, so [MatrixDevice.dpr] documents the real device and is not used for capture.
const _goldenDpr = 1.0;

Future<void> _capture(WidgetTester tester, MatrixScreen screen, MatrixDevice device, MatrixTheme theme) async {
  final view = tester.view;
  view.physicalSize = device.size * _goldenDpr;
  view.devicePixelRatio = _goldenDpr;
  final pad = FakeViewPadding(
    left: device.safeArea.left * _goldenDpr,
    top: device.safeArea.top * _goldenDpr,
    right: device.safeArea.right * _goldenDpr,
    bottom: device.safeArea.bottom * _goldenDpr,
  );
  view.padding = pad;
  view.viewPadding = pad;
  view.displayFeatures = device.displayFeatures;
  addTearDown(view.reset);

  final prefs = await createMockPrefs(onboardingCompleted: screen.onboardingCompleted);

  final previous = FlutterError.onError;
  final overflows = <String>[];
  FlutterError.onError = (details) {
    if (_isLayoutOverflow(details)) {
      overflows.add(details.exceptionAsString().split('\n').first);
    } else {
      previous?.call(details);
    }
  };
  try {
    await tester.pumpWidget(_app(home: screen.build(), prefs: prefs, theme: theme));
    await tester.pump(const Duration(seconds: 2));
    // A single long pump renders only the first frame of entrance animations (the
    // Library featured row stayed at opacity 0); step frames so they finish.
    await _settleTransient(tester);
    if (screen.drive != null) await screen.drive!(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/${screen.name}_${device.name}_${theme.name}.png'));
    // Unmount so pending timers and repeating animations are disposed.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  } finally {
    FlutterError.onError = previous;
  }
  if (overflows.isNotEmpty) {
    // ignore: avoid_print
    print('[overhaul-golden] ${screen.name}_${device.name}_${theme.name}: ${overflows.length} overflow(s): ${overflows.toSet().join('; ')}');
  }
}

/// Light theme on tablet and the two hinge postures (same pixels as foldinner today) is a
/// representative subset to keep the matrix under 10 MB.
const _lightSubsetDevices = {'tablet', 'foldhinge', 'tabletop'};
const _tabletLightScreens = {'home', 'settings'};

void main() {
  setUpAll(() async {
    await setupGoldenTests();
    AnimatedGradient.disableAnimations = true;
    AnimatedGradient.debugPeriodOverride = TimeOfDayPeriod.night;
    // Load the ambient FragmentProgram up front so goldens show the shader, not the fallback.
    expect(await AmbientShader.ensureLoaded(), isNotNull, reason: 'shaders/ambient.frag must load under flutter test');
    _loadArticlesWithReaderContent();
    registerFallbackValue(const NotificationSchedule());
    _notifications = _MockNotificationService();
    when(() => _notifications.checkPermissions()).thenAnswer((_) async => true);
    when(() => _notifications.isNotificationsEnabled).thenReturn(false);
    when(() => _notifications.getSchedule()).thenReturn(const NotificationSchedule());
    when(() => _notifications.saveSchedule(any())).thenAnswer((_) async {});
    await _loadSdkFonts();
  });

  tearDownAll(() {
    AnimatedGradient.debugPeriodOverride = null;
    teardownGoldenTests();
  });

  for (final screen in matrixScreens) {
    group(screen.name, () {
      for (final device in matrixDevices) {
        for (final theme in MatrixTheme.values) {
          if (_lightSubsetDevices.contains(device.name) && theme == MatrixTheme.light && !_tabletLightScreens.contains(screen.name)) continue;
          testWidgets('${screen.name} ${device.name} ${theme.name}', (tester) => _capture(tester, screen, device, theme));
        }
      }
    });
  }

  group('adaptive layout', () {
    MatrixDevice device(String name) => matrixDevices.firstWhere((d) => d.name == name);
    MatrixScreen screen(String name) => matrixScreens.firstWhere((s) => s.name == name);
    const medium = MatrixDevice('medium', Size(700, 900), 1);
    const hingeX = 420.0;
    const hingeY = 442.0;

    testWidgets('home: one pane on compact and medium, pointing plus context on expanded', (tester) async {
      for (final d in [device('phone'), device('foldouter'), medium]) {
        await _pumpAt(tester, screen('home'), d);
        expect(find.byKey(const ValueKey('home-context-pane')), findsNothing, reason: d.name);
      }
      for (final d in [device('foldinner'), device('tablet')]) {
        await _pumpAt(tester, screen('home'), d);
        expect(find.byKey(const ValueKey('pane-primary')), findsOneWidget, reason: d.name);
        expect(find.byKey(const ValueKey('home-context-pane')), findsOneWidget, reason: d.name);
      }
    });

    testWidgets('home: panes sit on either side of a vertical hinge', (tester) async {
      await _pumpAt(tester, screen('home'), device('foldhinge'));
      expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, lessThanOrEqualTo(hingeX));
      expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, greaterThanOrEqualTo(hingeX));
      expect(tester.getRect(find.byType(GlassCard).first).right, lessThanOrEqualTo(hingeX));
    });

    testWidgets('home: tabletop puts the pointing above the hinge and controls below', (tester) async {
      await _pumpAt(tester, screen('home'), device('tabletop'));
      expect(tester.getRect(find.byType(GlassCard).first).bottom, lessThanOrEqualTo(hingeY));
      expect(tester.getRect(find.byKey(const ValueKey('home-tabletop-controls'))).top, greaterThanOrEqualTo(hingeY));
      expect(tester.getRect(find.text('Next')).top, greaterThanOrEqualTo(hingeY));
    });

    testWidgets('settings: two columns on expanded, split at the hinge', (tester) async {
      await _pumpAt(tester, screen('settings'), device('foldouter'));
      expect(find.byKey(const ValueKey('settings-two-column')), findsNothing);
      await _pumpAt(tester, screen('settings'), device('foldinner'));
      expect(find.byKey(const ValueKey('settings-two-column')), findsOneWidget);
      await _pumpAt(tester, screen('settings'), device('foldhinge'));
      expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, lessThanOrEqualTo(hingeX));
      expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, greaterThanOrEqualTo(hingeX));
    });

    testWidgets('shell: bottom bar on compact, rail on medium and up, clear of the hinge', (tester) async {
      await _pumpAt(tester, screen('shell'), device('foldouter'));
      expect(find.byKey(const ValueKey('side-rail')), findsNothing);
      expect(find.bySemanticsLabel('Library tab'), findsOneWidget);
      for (final d in [medium, device('foldinner'), device('tablet')]) {
        await _pumpAt(tester, screen('shell'), d);
        expect(find.byKey(const ValueKey('side-rail')), findsOneWidget, reason: d.name);
      }
      await _pumpAt(tester, screen('shell'), device('foldhinge'));
      expect(tester.getRect(find.byKey(const ValueKey('side-rail'))).right, lessThanOrEqualTo(hingeX));
      await _pumpAt(tester, screen('shell'), device('tabletop'));
      final rail = tester.getRect(find.byKey(const ValueKey('side-rail')));
      expect(tester.getRect(find.bySemanticsLabel('Library tab')).top, greaterThanOrEqualTo(hingeY));
      expect(rail.top, greaterThanOrEqualTo(hingeY));
    });

    testWidgets('library: list and detail on expanded only', (tester) async {
      await _pumpAt(tester, screen('library'), device('foldouter'));
      expect(find.byKey(const ValueKey('library-list-detail')), findsNothing);
      await _pumpAt(tester, screen('library'), medium);
      expect(find.byKey(const ValueKey('library-list-detail')), findsNothing);
      expect(find.byType(ContentWidth), findsOneWidget);
      await _pumpAt(tester, screen('library'), device('foldinner'));
      expect(find.byKey(const ValueKey('library-list-detail')), findsOneWidget);
      expect(find.byKey(const ValueKey('library-detail-empty')), findsOneWidget);
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
        await _pumpAt(tester, screen(name), device('foldhinge'));
        expect(tester.getRect(find.byKey(const ValueKey('pane-primary'))).right, lessThanOrEqualTo(hingeX), reason: name);
        expect(tester.getRect(find.byKey(const ValueKey('pane-secondary'))).left, greaterThanOrEqualTo(hingeX), reason: name);
        expectNothingUnderHinge(tester, name);
        // Phones and unfolded tablets keep the single column.
        await _pumpAt(tester, screen(name), device('phone'));
        expect(find.byKey(const ValueKey('pane-primary')), findsNothing, reason: name);
      });
    }

    testWidgets('lineages: on a hinge, info selects the tradition in the detail pane', (tester) async {
      await _pumpAt(tester, screen('lineages'), device('foldhinge'));
      final first = traditions.keys.first;
      expect(find.byKey(ValueKey('lineages-detail-${first.name}')), findsOneWidget);
      await tester.tap(find.byIcon(AppIcons.info).at(1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byKey(ValueKey('lineages-detail-${traditions.keys.elementAt(1).name}')), findsOneWidget);
    });

    testWidgets('notificationsheet: tabletop opens below the hinge with Done reachable', (tester) async {
      final sheet = screen('notificationsheet');
      await _pumpAt(tester, sheet, device('tabletop'));
      await sheet.drive!(tester);
      final sheetRect = tester.getRect(find.byType(NotificationTimesSheet));
      expect(sheetRect.top, greaterThanOrEqualTo(hingeY));
      final done = tester.getRect(find.byKey(const ValueKey('notification-sheet-done')));
      expect(done.top, greaterThanOrEqualTo(hingeY));
      expect(done.bottom, lessThanOrEqualTo(device('tabletop').size.height));
      // The schedule overflows the lower half: a soft bottom edge marks it as scrollable.
      expect(find.byKey(const ValueKey('notification-sheet-fade')), findsOneWidget);
      await tester.tap(find.text('Done'));
      await _settleTransient(tester);
      expect(find.byType(NotificationTimesSheet), findsNothing);
    });

    testWidgets('notificationsheet: phone keeps the 70 percent sheet', (tester) async {
      final sheet = screen('notificationsheet');
      await _pumpAt(tester, sheet, device('phone'));
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
      await _settleTransient(tester);
      expect(find.byKey(const ValueKey('notification-sheet-fade')), findsNothing);
    });

    testWidgets('notificationsheet: no fade when the schedule fits', (tester) async {
      final sheet = screen('notificationsheet');
      await _pumpAt(tester, sheet, device('tablet'));
      await sheet.drive!(tester);
      expect(find.byKey(const ValueKey('notification-sheet-fade')), findsNothing);
    });

    testWidgets('tip: the card is capped on wide windows and tiles keep phone proportions', (tester) async {
      final tip = screen('tip');
      for (final name in ['tablet', 'foldinner']) {
        await _pumpAt(tester, tip, device(name));
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

/// Pumps [screen] at [device] in the dark theme for layout assertions (no golden).
Future<void> _pumpAt(WidgetTester tester, MatrixScreen screen, MatrixDevice device) async {
  final view = tester.view;
  view.physicalSize = device.size;
  view.devicePixelRatio = 1.0;
  final pad = FakeViewPadding(left: device.safeArea.left, top: device.safeArea.top, right: device.safeArea.right, bottom: device.safeArea.bottom);
  view.padding = pad;
  view.viewPadding = pad;
  view.displayFeatures = device.displayFeatures;
  addTearDown(view.reset);
  final prefs = await createMockPrefs(onboardingCompleted: screen.onboardingCompleted);
  final previous = FlutterError.onError;
  FlutterError.onError = (d) => _isLayoutOverflow(d) ? null : previous?.call(d);
  try {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(home: screen.build(), prefs: prefs, theme: MatrixTheme.dark));
    await tester.pump(const Duration(seconds: 2));
    await _settleTransient(tester);
  } finally {
    FlutterError.onError = previous;
  }
}

/// Runs a route or size transition to completion. A single long pump only
/// renders the transition's first frame, so step frames explicitly.
Future<void> _settleTransient(WidgetTester tester, {int frames = 20}) async {
  await tester.pump();
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
