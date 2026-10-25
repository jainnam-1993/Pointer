// Overhaul visual regression matrix: shared harness.
//
// Renders every key screen through the real widgets on a matrix of device
// classes (phones, Pixel 9 Pro Fold outer/inner, hinge postures, iPad) in
// dark and light themes. Time and animations are frozen so output is
// deterministic on the golden host (the Linux devdesk). Each screen has its own
// matrix_<screen>_test.dart, because flutter test runs the tests of one file
// serially and one file for all screens bounded the suite wall time.
//
// Regenerate:
//   flutter test --update-goldens --tags overhaul-golden test/golden/overhaul/
// Verify:
//   flutter test --tags overhaul-golden test/golden/overhaul/
// Before/after contact sheets:
//   tool/visual_diff.sh <rev-a> <rev-b> [out-dir]
//
// Goldens: test/golden/overhaul/goldens/<screen>_<device>_<theme>.png
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
import 'package:pointer/data/articles.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/layout/adaptive.dart';
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

import 'package:pointer/theme/contrast_level.dart';

import '../golden_test_helpers.dart' show setupGoldenTests, teardownGoldenTests, createMockPrefs, goldenTestPointing, goldenTestPointing2;

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
    displayFeatures: [DisplayFeature(bounds: Rect.fromLTWH(420, 0, 0, 884), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureHalfOpened)],
  ),
  MatrixDevice(
    'tabletop',
    _foldInner,
    2.625,
    safeArea: EdgeInsets.only(top: 24, bottom: 24),
    displayFeatures: [DisplayFeature(bounds: Rect.fromLTWH(0, 442, 841, 0), type: DisplayFeatureType.fold, state: DisplayFeatureState.postureHalfOpened)],
  ),
  // iPad: 11-inch and 13-inch in portrait and landscape, plus Split View third (compact) and half (medium) windows.
  MatrixDevice('ipad11p', Size(834, 1194), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20)),
  MatrixDevice('ipad11l', Size(1194, 834), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20)),
  MatrixDevice('ipad13p', Size(1032, 1376), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20)),
  MatrixDevice('ipad13l', Size(1376, 1032), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20)),
  MatrixDevice('ipadthird', Size(375, 1032), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20)),
  MatrixDevice('ipadhalf', Size(678, 1032), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20)),
];

/// Device used only by the layout assertions: within 1 % of ipad13p, so it has no golden cells.
const layoutOnlyDevices = <MatrixDevice>[MatrixDevice('tablet', Size(1024, 1366), 2, safeArea: EdgeInsets.only(top: 24, bottom: 20))];

MatrixDevice matrixDevice(String name) => [...matrixDevices, ...layoutOnlyDevices].firstWhere((d) => d.name == name);

/// `contrastlight` is the light theme with the system contrast setting on (ContrastLevel.increased).
enum MatrixTheme { dark, light, contrastlight }

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

Widget _app({required Widget home, required SharedPreferences prefs, required MatrixTheme theme, Pointing pointing = goldenTestPointing}) {
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
        notifier.setPointing(pointing);
        return notifier;
      }),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(theme),
      // The same contrast wiring as PointerApp in lib/main.dart: the system setting gives ContrastLevel.increased.
      builder: (context, child) => Theme(
        data: themeForContrast(Theme.of(context), resolveContrastLevel(inApp: false, system: MediaQuery.of(context).highContrast)),
        child: child!,
      ),
      home: home,
    ),
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

/// A screen in the matrix: how to build it and how to drive it into the captured state.
class MatrixScreen {
  final String name;
  final bool onboardingCompleted;
  final Widget Function() build;
  final Future<void> Function(WidgetTester tester)? drive;

  /// Hinge postures that render differently from foldinner for this screen. The others are byte-identical to
  /// foldinner, so they get no cell (checked with md5sum on 2026-10-24).
  final Set<String> postures;

  /// Extra cells beyond the standard set, as (device, theme).
  final List<(String, MatrixTheme)> extraCells;

  /// When set, the screen renders only these cells (a state variant of another screen).
  final List<(String, MatrixTheme)>? onlyCells;

  final Pointing pointing;

  const MatrixScreen(
    this.name,
    this.build, {
    this.onboardingCompleted = true,
    this.drive,
    this.postures = const {'foldhinge'},
    this.extraCells = const [],
    this.onlyCells,
    this.pointing = goldenTestPointing,
  });
}

MatrixScreen matrixScreen(String name) => matrixScreens.firstWhere((s) => s.name == name);

const _postures = {'foldhinge', 'tabletop'};

/// Devices that get a light cell for every screen; the others get one only for [_wideLightScreens].
const _lightDevices = {'smallphone', 'phone', 'foldouter', 'foldinner'};
const _wideLightScreens = {'home', 'settings'};

/// The golden cells of [screen], as (device, theme). Dark renders on every device; light on the phone and fold
/// classes, and on the wide classes only for home and settings, which keeps the matrix under 10 MB.
List<(MatrixDevice, MatrixTheme)> matrixCells(MatrixScreen screen) {
  if (screen.onlyCells case final only?) return [for (final (d, t) in only) (matrixDevice(d), t)];
  return [
    for (final device in matrixDevices)
      if (!_postures.contains(device.name) || screen.postures.contains(device.name))
        for (final theme in const [MatrixTheme.dark, MatrixTheme.light])
          if (theme == MatrixTheme.dark || _lightDevices.contains(device.name) || _wideLightScreens.contains(screen.name)) (device, theme),
    for (final (d, t) in screen.extraCells) (matrixDevice(d), t),
  ];
}

final matrixScreens = <MatrixScreen>[
  MatrixScreen(
    'onboarding',
    () => const OnboardingScreen(),
    onboardingCompleted: false,
    // First page reveals word by word after a 1.5 s delay; capture the fully revealed page.
    drive: (tester) => settleTransient(tester, frames: 80),
  ),
  MatrixScreen(
    'home',
    () => const HomeScreen(),
    postures: {'foldhinge', 'tabletop'},
    // Stark borders under the system contrast setting (Android contrast_level 1.0) were a user-found bug.
    extraCells: [('phone', MatrixTheme.contrastlight)],
  ),
  // A pointing with no teacher: the attribution line is absent (moved from the legacy screens_golden_test).
  MatrixScreen('homeminimal', () => const HomeScreen(), pointing: goldenTestPointing2, onlyCells: [('phone', MatrixTheme.dark)]),
  // The real MainShell (bottom bar on compact, side rail on medium and up) around Home.
  MatrixScreen('shell', () => const _ShellHost(), postures: {'foldhinge', 'tabletop'}, extraCells: [('phone', MatrixTheme.contrastlight)]),
  MatrixScreen('library', () => const Scaffold(body: LibraryScreen())),
  MatrixScreen('settings', () => const SettingsScreen()),
  // Saved with nothing saved: the empty state's heart icon and copy (restructure2 moved Saved to its own tab).
  MatrixScreen(
    'savedempty',
    () => const Scaffold(body: SavedScreen()),
    onlyCells: [('phone', MatrixTheme.light), ('phone', MatrixTheme.dark), ('foldinner', MatrixTheme.light), ('foldinner', MatrixTheme.dark)],
  ),
  MatrixScreen('lineages', () => const LineagesScreen()),
  MatrixScreen('article', () => const ArticleReaderScreen(articleId: _readerArticleId)),
  MatrixScreen(
    'notificationsheet',
    () => const _HostPage(),
    postures: {'foldhinge', 'tabletop'},
    drive: (tester) async {
      // Same call as SettingsScreen._showNotificationTimesSheet.
      showAdaptiveSheet<void>(
        context: tester.element(find.byType(_HostPage)),
        anchorPoint: sheetAnchorPoint(tester.element(find.byType(_HostPage))),
        isScrollControlled: true,
        builder: (context) => const NotificationTimesSheet(),
      );
      await settleTransient(tester);
    },
  ),
  MatrixScreen('sharepreview', () => const SharePreviewScreen(pointing: goldenTestPointing), postures: {}),
  MatrixScreen(
    'tip',
    () => const _HostPage(body: SingleChildScrollView(child: DonationButton())),
    postures: {},
    drive: (tester) async {
      await tester.tap(find.text('Support Development'), warnIfMissed: false);
      await settleTransient(tester);
    },
  ),
];

/// Overflow is part of the documented current state on some devices; record it
/// in the log instead of failing, since the golden shows the overflow stripes.
bool _isLayoutOverflow(FlutterErrorDetails d) => d.exceptionAsString().contains('overflowed');

/// Goldens render at DPR 1.0 to keep the matrix small (under 10 MB). Layout depends only on
/// logical size, so [MatrixDevice.dpr] documents the real device and is not used for capture.
const _goldenDpr = 1.0;

Future<void> _capture(WidgetTester tester, MatrixScreen screen, MatrixDevice device, MatrixTheme theme, {double textScale = 1.0}) async {
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
  if (theme == MatrixTheme.contrastlight) {
    tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(highContrast: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  if (textScale != 1.0) {
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }
  final cell = '${screen.name}_${device.name}_${theme.name}${_textScaleSuffix(textScale)}';

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
    await tester.pumpWidget(_app(home: screen.build(), prefs: prefs, theme: theme, pointing: screen.pointing));
    await tester.pump(const Duration(seconds: 2));
    // A single long pump renders only the first frame of entrance animations (the
    // Library featured row stayed at opacity 0); step frames so they finish.
    await settleTransient(tester);
    if (screen.drive != null) await screen.drive!(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$cell.png'));
    // Unmount so pending timers and repeating animations are disposed.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  } finally {
    FlutterError.onError = previous;
  }
  if (overflows.isNotEmpty) {
    // ignore: avoid_print
    print('[overhaul-golden] $cell: ${overflows.length} overflow(s): ${overflows.toSet().join('; ')}');
  }
}

/// Shared setup for every matrix file: fonts, shaders, articles and the notification mock.
void setUpMatrixSuite() {
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
}

/// Golden cells for the named screens; call from a `matrix_<screen>_test.dart` main().
void runMatrixScreens(List<String> names) {
  setUpMatrixSuite();
  for (final name in names) {
    final screen = matrixScreen(name);
    group(screen.name, () {
      for (final (device, theme) in matrixCells(screen)) {
        testWidgets('${screen.name} ${device.name} ${theme.name}', (tester) => _capture(tester, screen, device, theme));
      }
      for (final (device, theme) in extraCells[screen.name] ?? const <(MatrixDevice, MatrixTheme)>[]) {
        testWidgets('${screen.name} ${device.name} ${theme.name}', (tester) => _capture(tester, screen, device, theme));
      }
      for (final (device, theme, scale) in largeTextCells[screen.name] ?? const <(MatrixDevice, MatrixTheme, double)>[]) {
        testWidgets('${screen.name} ${device.name} ${theme.name} text $scale', (tester) => _capture(tester, screen, device, theme, textScale: scale));
      }
    });
  }
}

/// The user's vivo V2330 unfolded at its 432 dpi display size: medium width,
/// two panes from its near-square shape.
const userFoldDevice = MatrixDevice('userfold', Size(815, 918), 2.7, safeArea: EdgeInsets.only(top: 24, bottom: 24));

/// Cells beyond the shared device matrix, per screen. Library's Featured strip
/// ends at the list pane's edge on the user's fold, so it must fade, not cut into a box.
final extraCells = <String, List<(MatrixDevice, MatrixTheme)>>{
  'library': [for (final theme in MatrixTheme.values) (userFoldDevice, theme)],
};

/// Cells at a large system text scale, as (device, theme, scale). The shell's tab labels must fit
/// at 2.0 in both layouts: the bottom bar (phone) and the side rail (ipad11p).
final largeTextCells = <String, List<(MatrixDevice, MatrixTheme, double)>>{
  'shell': [
    for (final device in ['phone', 'ipad11p'])
      for (final theme in [MatrixTheme.light, MatrixTheme.dark]) (matrixDevice(device), theme, 2.0),
  ],
};

/// Golden name suffix for a text scale: none at 1.0, `_text2` at 2.0, `_text1.3` at 1.3.
String _textScaleSuffix(double scale) => scale == 1.0 ? '' : '_text${scale == scale.roundToDouble() ? scale.toInt() : scale}';

/// Pumps [screen] at [device] in the dark theme for layout assertions (no golden).
Future<void> pumpAt(WidgetTester tester, MatrixScreen screen, MatrixDevice device) async {
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
    await settleTransient(tester);
  } finally {
    FlutterError.onError = previous;
  }
}

/// Runs a route or size transition to completion. A single long pump only
/// renders the transition's first frame, so step frames explicitly.
Future<void> settleTransient(WidgetTester tester, {int frames = 20}) async {
  await tester.pump();
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
