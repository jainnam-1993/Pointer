# CLAUDE.md

Here Now (package `pointer`, applicationId and bundle prefix `com.dailypointer`) is a Flutter app that shows short non-dual "pointings" from contemplative traditions. It has no accounts, no backend, no analytics and no gamification. Everything is stored on the device. The only purchases are optional consumable tips.

Repo: `/workplace/jainnam/tools/Pointer` (the Mac sees it as `/Volumes/workplace/tools/Pointer` through Unison).

## Hosts and commands

Flutter 3.47.8 (Dart 3.13.7) on both hosts; 3.38.9 cannot build iOS with Xcode 27. The devdesk (Linux, aarch64) runs Flutter and is the golden host. Run analyze, tests and goldens there.

```bash
export PATH=$HOME/.local/share/flutter-sdk/3.47.8/bin:$PATH
flutter pub get
flutter analyze                       # gate: "No issues found"
flutter test --concurrency=16         # gate: all pass
flutter test test/golden/overhaul --update-goldens   # only for intended visual changes
tool/visual_diff.sh <rev-a> <rev-b|WORKTREE>         # before/after contact sheets + report.tsv
dart format --page-width=150 <files>
```

On the Mac, put `~/flutter-3.47.8/bin` first on PATH (Homebrew's `/opt/homebrew/bin/flutter` is the old 3.38.9). The Mac is used only for native builds (iOS, Xcode archives, `bundle exec fastlane android internal|production`) and on-device checks. Do not generate goldens on the Mac, because its font rasterization differs.

## Architecture

```text
lib/
  main.dart               PointerApp; AppInitializer; one text-scale clamp; SharedAmbientHost under the router
  router.dart             GoRouter singleton (read, never watch); /splash, onboarding redirect, shell tabs
  theme/app_theme.dart    Tokens: PointerColors, InkPalette, GlassMaterial/GlassLevel, AppFonts, AppType, AppTextStyles, AppSpacing, TraditionAccentColors
  theme/app_icons.dart    AppIcons: Phosphor Light (Regular for active tabs); no Material Icons in new code
  utils/                  motion.dart (Motion durations, curves, springs, reduce()), haptics.dart, typography.dart, formatting.dart
  widgets/ambient.dart    Rendering engine (below)
  widgets/shared_ambient.dart  One background for the whole app; RouteAmbient falls back where no host exists
  widgets/glass_card.dart GlassCard / GlassButton / GlassDialog on the analytic frost
  providers/              Riverpod: core (prefs, storage, notifications, widget, packageInfo), settings, content, donation, usage
  services/               app_initializer, notification_*, workmanager_service, widget_service, donation_service,
                          tip_purchase_listener, pointing_selection, affinity_service, share_service, storage_service
  data/                   Pointing, article, teacher, inquiry models and loaders over assets/data/*.json
  screens/                home, inquiry (+player), library (+library/*), lineages, article reader, settings (+settings/*),
                          share preview, onboarding, splash, main_shell
  layout/adaptive.dart    WindowSizeClass, WindowLayout (posture, hinge, rail vs bottom bar), ContentWidth, TwoPane, TabletopSplit
shaders/ambient.frag      The one fragment shader: gradient, aurora fields, dust motes, frost
android/app/src/main/kotlin/com/dailypointer/   MainActivity + self-sufficient widget
ios/Runner, ios/PointerWidget                     App delegate, privacy manifests, WidgetKit extension
```

### Rendering engine (`lib/widgets/ambient.dart`)

- `AmbientClock.instance` is one process-wide time source. It ticks from a `Timer`, never a vsync Ticker: 30 fps normally, and 15 fps in Low Power Mode or battery saver (queried over `com.dailypointer/settings` `isLowPowerMode`). Painters listen to the clock and repaint inside their own RepaintBoundary, so nothing rebuilds per frame.
- The clock runs only while all of these hold: something listens, the app is resumed, no popup route covers the shell (`AmbientRouteObserver` calls `cover`/`uncover`), and motion is not reduced. Covered page routes stop through `TickerMode`. `AmbientClock.frozen` pins time at `kAmbientStillTime` for tests.
- `AmbientShader` loads `shaders/ambient.frag`. `AmbientPalette` follows the time-of-day period (with OLED and light variants). `AmbientBackground` paints it.
- Glass is analytic frost: `AmbientFrost` / `RenderAmbientFrost` sample the same shader at the card's screen rect instead of running a live `BackdropFilter`. `FrostScope` turns frost off inside opaque sheets, which then use `GlassMaterial.onSurfaceLevels`. Live blur is reserved for dialogs and toasts (`blurSigma`) and for the tab bar, which uses `BackdropGroup` + `BackdropFilter.grouped` in `main_shell.dart` so grouped blurs share one backdrop read.
- `SharedAmbientHost` paints one `AnimatedGradient` beneath the router, so page pushes slide over one continuous background.

### Design system

The tokens live in `app_theme.dart`. Read colors through `context.colors` and glass through `GlassMaterial.of(context)`. Fonts are bundled OFL Newsreader (serif, pointings) and Inter (UI) in `assets/fonts`; there is no runtime font fetching. There is a six-size type scale (`AppType`), the motion tokens in `Motion`, haptics through `Haptics.selection/light/success`, and icons through `AppIcons`. `test/theme/contrast_test.dart` enforces at least 4.5:1 for every text color on every surface and glass fill in all four themes (dark, light, high contrast, OLED). See `DESIGN_SYSTEM.md`.

### Content and selection

- `assets/data/*.json` are parsed off the UI thread (`compute(parsePointingsJson, ...)`). There are about 2.4k pointings, 166 articles, 22 teachers and 45 teachings.
- `pointing_selection.dart` is the single answer to "which pointings are eligible and how likely is each". It combines the traditions chosen in Lineages with learned affinity (views, and saves weighted higher). Home's persisted round-robin order and the notification rotation both read it, so they cannot drift apart.

### Notifications

- `NotificationSchedule` (time window, frequency, quiet hours) has one delivery rule, `allows(time)`. Both platforms use it: Android runs a WorkManager periodic task (`workmanager_service.dart`, Android only), and iOS schedules a batch of up to 60 local notifications ahead. iOS has no background modes.
- `notification_content.dart` holds the content and action handling, written to work with no `ProviderContainer` (background isolates have only SharedPreferences, the plugin and bundled assets). Rotation is slot-aware (morning 5-11, midday 11-17, evening otherwise). Android actions "Save" and "Another" run in `notificationBackgroundHandler` (`@pragma('vm:entry-point')`).

### Home-screen widgets

- Android (Kotlin, `PointerWidgetProvider`, `WidgetRenderer`, `WidgetModel`, `PointingRepository`, `WidgetStore`, `WidgetActionReceiver`) is self-sufficient. Content comes from the APK asset and state from `WidgetStore`, so Save, Previous and Next work without the Flutter engine or without the app ever having been opened.
- There is a single favorites store. `WidgetStore` writes the app's own `FlutterSharedPreferences` file with the `flutter.` prefix, so `flutter.pointer_favorites` is exactly what `StorageService.favorites` reads. The app calls `SharedPreferences.reload()` on resume before reading favorites, and the widget writes only keys that changed.
- On iOS, WidgetKit (`ios/PointerWidget`) reads the app group `group.com.dailypointer.widget` (pointings cache, falling back to the bundled `DefaultPointings.json`). App Intents handle Previous, Next and Save. Save queues ids in `pending_saves`, and `WidgetService` merges them into favorites on resume.
- Known platform limit: on Android 15+, a force-stop disables widget interaction until the next app launch.

### Tips

`in_app_purchase` with `in_app_purchase_android` (Play Billing 8) and four consumables, `com.dailypointer.tip_{small,medium,large,generous}` (`DonationService`). `TipPurchaseListener` starts once in `AppInitializer` and finishes every purchase update, including pending, Ask to Buy and interrupted ones, even if Settings is never opened. The tip UI only subscribes to its outcomes. Tips unlock nothing.

### Adaptive layouts

`lib/layout/adaptive.dart` owns every layout decision; screens ask `WindowLayout.of(context)` instead of comparing raw widths or device models.

- Size classes follow the Android window size class breakpoints on window width: compact under 600, medium 600 to 839, expanded 840 and up.
- Navigation: compact windows keep the glass bottom bar; medium and expanded windows get the glass side rail (`kRailWidth` 96) in `main_shell.dart`.
- Panes: expanded windows, and any window split by a vertical hinge (book posture), use `TwoPane`, which keeps both panes off the hinge. Home, Library and Settings split into two panes; single columns on medium and larger windows are capped at `kContentMaxWidth` (600) by `ContentWidth`.
- Hinge and posture: `WindowLayout.separatingFeature` mirrors Android's `FoldingFeature.isSeparating`. A horizontal half-opened hinge is tabletop posture, where Home uses `TabletopSplit` (content above the fold, controls below).
- Android declares `resizeableActivity="true"` and handles size and layout config changes, so fold, unfold and multi-window resizes reflow without a restart.
- The golden matrix covers smallphone, phone, foldouter, foldinner, foldhinge, tabletop and tablet; `shell_*.png` goldens render the shell with the rail or bottom bar. `test/layout/adaptive_test.dart` covers size classes, hinges, tabletop and rail placement.

## Testing

- `test/flutter_test_config.dart` mocks home_widget and package info globally.
- `test/golden/overhaul/screens_matrix_test.dart` renders every screen in every device class and theme into `test/golden/overhaul/goldens/`, with the clock frozen and `AnimatedGradient.debugPeriodOverride = TimeOfDayPeriod.night`. Goldens must not depend on the wall clock. The legacy goldens (`test/golden/goldens/`, `setupGoldenTests`) freeze the period the same way.
- For continuous animations, use `pump(Duration)` rather than `pumpAndSettle()`, and set `AnimatedGradient.disableAnimations = true` / `AmbientClock.frozen = true`.
- `test/accessibility/` covers semantics, labels and focus order. `test/theme/contrast_test.dart` covers contrast.
- `integration_test/` and `maestro/flows/` (28 flows) run on the Mac or a device.
- After any visual change, run `tool/visual_diff.sh` and review the contact sheets before committing goldens.

## Conventions

- Doc comments use `/** */`. The formatter page width is 150.
- Conventional Commits, staged with explicit pathspecs. Do not commit `test/golden/overhaul/failures/`.
- Use `context.colors`, `AppType`, `AppSpacing`, `Motion` and `AppIcons` instead of literals. Respect `Motion.reduce(context)`.
- Do not add network code, analytics, or runtime-fetched assets. The privacy policy (`docs/PRIVACY_POLICY.md`, `docs/legal/*.html`) and the iOS `PrivacyInfo.xcprivacy` files state that there are none. Update them together if that ever changes.
- Never commit signing files or keystores.

## Docs

`DESIGN_SYSTEM.md` (tokens and rules), `docs/PRIVACY_POLICY.md`, `docs/TERMS_OF_SERVICE.md`, `docs/store_assets/SCREENSHOTS.md`, `docs/PLAY_STORE_RELEASE.md`, `fastlane/metadata/android/en-US/`.
