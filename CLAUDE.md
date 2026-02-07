# CLAUDE.md

Here Now: Flutter mobile app delivering daily non-dual awareness "pointings" from spiritual traditions. Anti-meditation positioning. No progress tracking or gamification.

## Current Context
<!-- Auto-synced by obsidian-vault. Full details in vault. -->

**Vault**: [[Projects/Personal/Pointer/README]]
**Status**: App Store Ready | Tests hardened, E2E flows strict
**Synced**: 2026-02-07

**Active**: App-Publishing (80%)
**Archived**: Test-Hardening, Dead-Code-Cleanup, Source-Citations, Firebase-Auth, Library-Improvements (all 100%)
**Last Session**: 2026-02-07 | Context optimization, vault cleanup, CLAUDE.md deduplication

## Commands

```bash
# Development & Testing
flutter run                            # Run on device
flutter test --concurrency=8           # Unit tests
flutter test --update-goldens          # Update golden baselines
maestro test maestro/flows/            # E2E tests (26 flows, 0 optional assertions)

# Build & Deploy
flutter build apk/ios/appbundle
bundle exec fastlane android internal/production
# Android: Kotlin 2.3.0, ProGuard enabled, google-services.json
# iOS: Manual via Xcode Archive (ExportOptions.plist)
```

## Remote Development (Dev Desktop)

This project syncs to the dev desktop via Unison. The dev desktop (32 cores, 123GB RAM) handles heavy compute; the Mac handles emulator display.

```
Dev Desktop: dev-dsk-jainnam-2a-70f1af09.us-west-2.amazon.com
Project:     /workplace/jainnam/Personal/Pointer
Sync:        Unison bidirectional (auto, ~15s cycle)
```

### Quick Commands (Dev Desktop)
```bash
pt                  # cd to Pointer project
pt-test             # flutter test --concurrency=8
pt-analyze          # flutter analyze
pt-build            # flutter build apk --debug
pt-ci               # analyze + test + build (full check)
adb-tunnel          # adb connect localhost:5555 && adb devices
```

### Testing on Dev Desktop
```bash
# Unit/widget tests (no emulator needed, uses 32 cores)
flutter test --concurrency=8

# Static analysis
flutter analyze

# Debug APK build
flutter build apk --debug
```

### Testing on Mac Emulator via ADB Tunnel

Requires the Mac user to run `./scripts/start-tunnel.sh` first (starts SSH reverse tunnel on port 5555).

```bash
# Connect to tunneled emulator
adb connect localhost:5555
flutter devices                        # Verify emulator visible

# Run on Mac emulator from dev desktop
flutter run -d localhost:5555

# E2E tests via tunnel
maestro test maestro/flows/01_navigation.yaml
maestro test maestro/flows/            # All 26 flows
```

### Golden Tests
Golden tests (`test/golden/`, 2 test files) will FAIL on Linux dev desktop — expected due to font rendering differences (FreeType vs CoreText). Only validate goldens on Mac. Use `--update-goldens` on Mac only.

### Workflow
1. Edit code on dev desktop (Claude Code / vim / VS Code Remote)
2. Run `pt-test` and `pt-analyze` immediately (fast, no emulator)
3. Unison auto-syncs changes to Mac within ~15s
4. For interactive/visual testing: `flutter run` on Mac (or via tunnel)
5. For E2E: `maestro test` on either side (Mac direct = faster, devdesk via tunnel = works)

## Architecture

```
lib/
├── main.dart                  # Entry point, graceful service initialization (Firebase→notifications with try-catch), notificationServiceProvider override for single initialized instance, teaching repository initialization, ambient sound guard, notification callbacks, widget theme sync
├── router.dart                # GoRouter singleton with SharedPreferences-based redirects, /splash route with cold-start-only video
├── theme/app_theme.dart       # PointerColors (dark/light/highContrast/oled), AppThemeMode
├── providers/                 # Riverpod state management
│   ├── core_providers.dart    # SharedPreferences, storage, notifications
│   ├── providers.dart         # Barrel file for provider exports
│   ├── settings_providers.dart # Zen mode, OLED, accessibility, theme, auto-advance, animationsEnabled
│   ├── content_providers.dart # Pointings, favorites, affinity
│   ├── subscription_providers.dart # Subscription state (all features free, no IAP)
│   └── donation_providers.dart # Tip jar via in-app purchases (consumable products)
├── screens/                   # Main UI screens
│   ├── main_shell.dart        # Bottom nav shell with swipe gestures, FloatingParticles, responsive nav bar (3-tier breakpoints), GlobalKey conflict prevention
│   ├── home_screen.dart       # Daily pointing with auto-advance timer, source citations
│   ├── inquiry_screen.dart    # Inquiry selection screen
│   ├── inquiry_player_screen.dart # Guided inquiry with timed phases
│   ├── library_screen.dart    # Browse articles/quotes with filters (all/articles/quotes/saved), browse modes, ContentFilter integration
│   ├── article_reader_screen.dart # Full article reader with markdown rendering
│   ├── lineages_screen.dart   # Lineage/tradition browser
│   ├── history_screen.dart    # Pointing history
│   ├── settings_screen.dart   # Settings, animation toggle, donation in About, developer options
│   ├── onboarding_screen.dart # First-run onboarding
│   ├── splash_screen.dart     # Video splash (theme-aware nonduality animation, cold-start only)
│   └── share_preview_screen.dart # Share card preview
├── widgets/                   # Reusable components
│   ├── glass_card.dart        # GlassCard/GlassButton (intensity levels)
│   ├── animated_gradient.dart # Background gradient animation (adaptive fps: 60/45/30 by device tier, RepaintBoundary isolated)
│   ├── animated_transitions.dart # Custom page transitions
│   ├── teacher_sheet.dart     # Teacher bio modal
│   ├── donation_button.dart   # Expandable tip jar (2x2 grid: Tea/Cushion/Incense/Retreat)
│   ├── tradition_badge.dart   # Tradition indicator badge
│   ├── notification_preview.dart # Notification preview widget
│   ├── enso_icon.dart         # Enso circle icon
│   ├── inquiry_phase_content.dart # Inquiry phase display
│   ├── inquiry_visual.dart    # Inquiry visual animation
│   ├── mini_inquiry_card.dart # Compact inquiry card
│   ├── onboarding_animations.dart # Onboarding screen animations
│   ├── save_confirmation.dart # Save/favorite confirmation
│   └── share_templates/share_card.dart # Shareable card templates (with source citations)
├── services/                  # Business logic
│   ├── storage_service.dart   # SharedPreferences wrapper
│   ├── notification_service.dart # Scheduling with presets, time windows
│   ├── widget_service.dart    # Home widget data updates
│   ├── donation_service.dart  # Tip jar via in_app_purchase (4 consumable tiers)
│   ├── share_service.dart     # Share card generation
│   ├── affinity_service.dart  # Tradition preference learning
│   └── ambient_sound_service.dart # Opening sound (bell), persisted preference
├── models/
│   ├── article.dart           # Article model with tag-based filtering
│   ├── inquiry.dart           # Inquiry session model
│   ├── teacher.dart           # Teacher model
│   └── teacher_profile.dart   # Extended teacher profile
└── data/
    ├── pointings.dart         # Curated pointings (2,434)
    ├── articles.dart          # Curated articles with topicTags/moodTags (166)
    ├── inquiries.dart         # Guided inquiry definitions
    ├── teaching.dart          # TopicTags/MoodTags constants, TeachingType enum
    ├── teachers.dart          # Teacher database (22 teachers)
    ├── teacher_profiles.dart  # Extended teacher profiles
    └── teachings/             # Extended teaching content
        ├── papaji.dart        # Papaji's teachings
        └── adyashanti.dart    # Adyashanti's teachings

android/app/src/main/kotlin/com/dailypointer/
├── MainActivity.kt            # Theme change listener
├── BootReceiver.kt            # Widget refresh on device boot
├── PointerWidgetProvider.kt   # Home widget with AdapterViewFlipper
└── PointerWidgetService.kt    # RemoteViewsService for widget data

android/app/src/main/res/
├── drawable/                  # Widget glassmorphism cards (dark/light)
└── layout/                    # Widget layouts (dark/light variants)

ios/Runner/
├── Info.plist                 # App config: Google OAuth URL scheme, export compliance, permissions
├── GoogleService-Info.plist   # Firebase configuration
├── Runner.entitlements        # App capabilities (Sign in with Apple, push notifications)
└── AppDelegate.swift          # App lifecycle, AVAudioSession config, flutter_local_notifications, UNUserNotificationCenter delegate

ios/PointerWidget/             # iOS home screen widget extension
├── PointerWidget.swift        # Widget timeline provider
├── PointerWidgetBundle.swift  # Widget bundle entry point
├── WidgetIntents.swift        # Widget configuration intents
└── PointerWidget.entitlements # Widget capabilities

test/                          # Unit tests
├── providers/                 # Provider tests
├── services/                  # Service tests
├── screens/                   # Widget tests
├── widgets/                   # Component widget tests
├── data/                      # Content validation tests
├── helpers/                   # Test setup utilities
├── accessibility/             # Semantics & VoiceOver tests
└── golden/                    # Visual regression tests

integration_test/              # State-controlled E2E flows
maestro/flows/                 # Cross-platform E2E (26 YAML flows)
docs/                          # Legal docs, store assets
fastlane/                      # Play Store deployment
```

## Tech Stack

**Framework**: Flutter 3.x + Dart 3.10, GoRouter 14.x, Riverpod 2.5
**Key Deps**: in_app_purchase (tip jar), flutter_local_notifications, just_audio, share_plus, screenshot
**Testing**: flutter_test + mocktail, Maestro (E2E)
**Design**: "Ethereal Liquid Glass" - 4 PointerColors themes, iOS Control Center glassmorphism. See `/DESIGN_SYSTEM.md`.
**Principles**: Prefer Flutter packages over native code. Never commit signing files. Always use `context.colors` for theme access.

## Key Patterns

### Providers
- **Settings** (`settings_providers.dart`): User prefs (zen mode, OLED, accessibility, theme, auto-advance 60s default, animationsEnabled). SettingsNotifier with copyWith updates. `reduceMotionOverrideProvider` derived from `animationsEnabled` (false → reduce motion ON, true → follow system). `backgroundShimmerActiveProvider` controls GlassCard shimmer
- **Content** (`content_providers.dart`): Round-robin pointing navigation (persisted shuffled order), favorites, affinity tracking, teaching filters
- **Subscription** (`subscription_providers.dart`): RevenueCat integration, freemium v2 (unlimited quotes, premium for library/notifications/widget), Firebase auth callbacks for cross-platform sync. **⚠️ kFreeAccessEnabled = TRUE** - enables free access mode for App Store release without IAP (RevenueCat disabled). Set to false when ready to enable monetization
- **Donation** (`donation_providers.dart`): Tip jar via in_app_purchase (consumable products). DonationState with isAvailable, isLoading, products, error, lastResult. DonationNotifier manages purchase flow

### Services
- **Notifications** (`notification_service.dart`): Presets (Morning/All day/Evening/Minimal/Test), time windows with frequencyMinutes (30-720min), max 50 scheduled, Android 12+ exact alarm permission, pointings_v6 channel. initialize() accepts optional onNotificationResponse/onBackgroundNotificationResponse callbacks. iOS foreground presentation: alerts/banners enabled, sound disabled (silent for meditation app). Test notifications use InterruptionLevel.active for visible banner
- **Widget** (`widget_service.dart`): Premium gating (respects kFreeAccessEnabled), pointings cache population with favorite interleaving, theme sync via refreshWidget()
- **Share** (`share_service.dart`): Card generation (minimal/gradient/tradition templates), square/story formats, captureWidget/shareImage/copyToClipboard
- **AmbientSound** (`ambient_sound_service.dart`): Opening sound on cold start (bell via just_audio), persisted user preference, global guard prevents duplicate plays

### Data Models
- **Pointing**: id, content, instruction, tradition (Advaita/Zen/Direct Path/Contemporary/Original), context (morning/midday/evening/stress/general), teacher, source
- **Article** (`models/article.dart` + `data/articles.dart`): id, title, subtitle, content (markdown), excerpt, tradition, teacher, categories (ArticleCategory enum), readingTimeMinutes, isPremium, topicTags (Set<String> from TopicTags constants), moodTags (Set<String> from MoodTags constants). Helper methods: hasCategory(), isBy(), hasTopic(), hasMood()
- **Teacher** (`models/teacher.dart` + `data/teachers.dart`): 22 teachers across traditions (expanded from teachings-db). getTeacher(name), getPointingsByTeacher(name)

## Testing

### Quality Bar (NON-NEGOTIABLE)

**Every test must catch its feature being broken.** If a test passes when the screen is blank or the feature is missing, it's not a test — it's a liability.

**Rules:**
1. **Zero optional assertions** — `optional: true` is banned in Maestro flows and try-catch suppression on assertions is banned in widget tests. Every step passes or the flow fails. No exceptions
2. **Given-When-Then naming** — `'Given [state], When [action], Then [expected outcome]'`
3. **Assert actual content, not just structure** — verifying "Library" header exists doesn't prove articles render. Verify article titles, counts, or specific data
4. **Widget tests must init dependencies** — if the screen depends on `TeachingRepository.initialize()`, the test must call it. If providers need overrides, provide them
5. **Every screen test must verify its primary content** — HomeScreen: pointing text visible. LibraryScreen: featured articles + category cards visible. SettingsScreen: settings items visible
6. **Failure is signal** — a failing test surfaces a real bug. Never suppress, skip, or weaken assertions to make tests pass. Fix the code or fix the test setup

**Skill**: Use `flutter-tester` skill for patterns (layer testing, Riverpod, widget testing guides)

### Unit Tests (`test/`)
- **Setup**: ProviderScope with mocked deps, SharedPreferences mocking, mocktail for services
- **TeachingRepository**: Must call `TeachingRepository.initialize(pointings: pointings)` in `setUpAll()` and `TeachingRepository.reset()` in `tearDownAll()` for any test that depends on teaching data
- **Animations**: Use `pump(Duration(seconds: 2))` not `pumpAndSettle()` for continuous animations. Set `AnimatedGradient.disableAnimations = true` in `setUpAll()`
- **Subscription mocking**: `_TestSubscriptionNotifier` pattern extends SubscriptionNotifier with fixed state. See `library_screen_test.dart`
- **Donation mocking**: `MockDonationService` extends DonationService (not Mock), `TestDonationNotifier` with setTestState() for controlled donation state. See `settings_screen_test.dart`
- **Content validation**: Verify actual data values (article titles, pointing content, teacher names), not just widget types or empty/non-empty checks
- **Screen sizes**: iPhone 14 Pro Max (1290x2796, 3.0 DPR), iPad Pro (2048x2732, 2.0 DPR), standard phone (1080x1920, 2.0 DPR)
- **Golden tests** (`test/golden/`): setupGoldenTests(), goldenTestTheme (Roboto), pumpForGolden(), GoldenDevices. Linux devdesk will fail (font rendering) — only update goldens on Mac
- **Accessibility** (`test/accessibility/`): VoiceOver semantics, labels, focus order, custom actions, screen reader hints

### Integration Tests (`integration_test/`)
- State-controlled E2E using IntegrationTestWidgetsFlutterBinding (Riverpod state injection)
- UncontrolledProviderScope pattern, custom settle() helper for animations
- Screenshot capture: binding.convertFlutterSurfaceToImage() → binding.takeScreenshot()

### E2E Tests (Maestro)
- 26 YAML flows: `maestro/flows/` with shared helpers in `maestro/shared/`
- Cross-platform (iOS/Android), outputs to `maestro/screenshots/`
- **Assertion rules**:
  - `assertVisible` WITHOUT `optional: true` for ALL content that must exist (articles, pointings, categories, settings items)
  - `optional: true` is BANNED — zero instances allowed. Every assertion and tap must pass or the flow fails
  - Regex matching is fine (`".*Next.*"`) but the assertion itself must be required
  - All flows use `clearState: true` to ensure deterministic onboarding via `shared/skip_onboarding.yaml`
- **Interaction patterns**: Swipe gestures (direction: UP/DOWN, duration), long press (longPressOn), coordinate-based taps (point: "50%,40%")
- **Timing**: `waitForAnimationToEnd` after navigation. Use `timeout` param if animation may not end
- **Shared flows**: `maestro/shared/skip_onboarding.yaml` — requires `appId` in calling flow's config header
- **Use for**: Black-box E2E, store screenshots, native widget testing
- **Don't use for**: State-controlled tests (use Flutter), WCAG compliance (use Flutter accessibility tests), timing-sensitive flows

## TODOs

- Backend API (planned per EXECUTION_PLAN.md)
- Light/Dark mode toggle
- iOS: Enable "Sign in with Apple" capability in Xcode signing settings (Google Sign-In already configured via Info.plist URL scheme)

## Features

**Freemium V2**: FREE = unlimited pointings/quotes. PREMIUM (lifetime purchase via RevenueCat) = library, audio, notifications, widget. Firebase auth callbacks sync purchases cross-device. `kFreeAccessEnabled` flag in `subscription_providers.dart` (**⚠️ currently TRUE** - all features unlocked, RevenueCat disabled for App Store release without IAP).

## Execution Protocol

**Git**: Commit after each task (`fix/feat(scope): description`), verify tests pass before next task
**Worktrees**: Use `git worktree add ../Pointer-feature-{name}` for parallel isolation (max 8 concurrent)
**Vault**: Mark checkboxes complete, update ROADMAP.md status after waves, log blockers in playbook

## Implementation Patterns

**Theme** (`app_theme.dart`): PointerColors (4 variants), access via `context.colors.{property}` | GlassCard/Button (intensity levels, high contrast) | AnimatedGradient | HapticFeedback (light/medium/heavy)

**Providers** (`providers/`): Settings (zen, OLED, accessibility, theme, auto-advance) | Content (round-robin persisted order, favorites, affinity, teaching filters) | Subscription (RevenueCat, freemium v2, **⚠️ kFreeAccessEnabled=TRUE** - free access mode for App Store release) | Donation (tip jar, in_app_purchase consumables, DonationState)
**Services** (`services/`): StorageService (SharedPreferences wrapper, AppSettings) | AffinityService (tradition learning, 3x weight for saves) | NotificationService (initialize() with optional onNotificationResponse/onBackgroundNotificationResponse callbacks, iOS foreground presentation: defaultPresentAlert/defaultPresentBanner=true, defaultPresentSound=false for silent meditation experience, scheduling via flutter_local_notifications) | DonationService (tip jar, DonationProductIds, isAvailable/loadProducts/purchaseDonation/completePurchase, graceful degradation) | ShareService (card templates, formats) | AmbientSound (opening sound on cold start, global guard)
**Android Widget** (`*.kt`): PointerWidgetProvider (zero-config AdapterViewFlipper, prev/next, auto-rotation, theme sync) | PointerWidgetService (RemoteViewsFactory) | Widget glassmorphism cards (multi-layer, matches app themes)

**Screens**: InquiryPlayer (timed phases, haptic feedback) | LibraryScreen (LibraryFilter: all/articles/quotes/saved; browse modes: topics/teachers/lineages/moods; ContentFilter integration with filter propagation to detail screens; peek indicator with LayoutBuilder at 70% card width for horizontal scroll reveal; topics source switches to TeachingRepository.topicCounts when quotes filter active; premium gating) | Detail screens (TeacherTeachingsScreen, LineageTeachingsScreen, MoodTeachingsScreen) accept ContentFilter parameter from parent, show filtered articles/quotes sections, premium gating with _ArticleListItem | Settings helpers (_getNotificationCountSummary, _getScheduleTimeSummary, _formatHourShort, _AccountSection)

**Widgets**: TeacherSheet/SignInSheet (modals, DraggableScrollableSheet) | NotificationPreview (matches BigTextStyleInformation) | Share Card Templates (minimal/gradient/tradition)

**Data**: Article (topicTags/moodTags, hasTopic/hasMood, ArticleCategory, isPremium) | TopicTags/MoodTags constants (18 topics, 8 moods) | Teacher (22 teachers, getTeacher/getPointingsByTeacher) | Pointing.source (populated from teachings-db, rendered on home + share cards) | 2,434 pointings, 166 articles

**Navigation**: GoRouter (singleton pattern with _appRouter/_getOrCreateRouter() to prevent GlobalKey conflicts, use ref.read not ref.watch for router to prevent MaterialApp.router rebuilds, SharedPreferences direct access via setRouterSharedPreferences() for redirects, tab-specific navigator keys, route transitions: FadeThrough/SharedAxis/Calm, redirect function for onboarding logic, /splash route with ?dest= param and in-memory _hasShownSplash flag for cold-start-only video) | MainShell (don't wrap navigationShell in AnimatedSwitcher/KeyedSubtree - has internal GlobalKeys that conflict when widget tree changes; 8px top margin + 16px bottom margin for content separation and visible gap, navbar's rounded corners provide visual separation) | Round-Robin (persisted shuffled order, wrap-around)

**Testing**: Animation handling (pump(Duration), disableAnimations flag) | Subscription mocking (_TestSubscriptionNotifier) | Screen sizes (iPhone 14 Pro Max, iPad Pro) | Golden helpers (setupGoldenTests, pumpForGolden) | Accessibility (VoiceOver semantics, screen reader hints)

**Performance**: AnimatedGradient adaptive frame rate (_DeviceTier: high 60fps/mid 45fps/low 30fps based on screen height + DPR), RepaintBoundary isolation on FloatingParticles/shimmer/GlassCard, particle count scales with tier (6/3/2), consolidated animation controllers (12→3 via Tween composition). `animationsEnabled` toggle persisted in AppSettings, bridges to reduceMotionOverrideProvider

**Special**: Auto-Advance Timer (60s default, smart pausing) | Responsive Layout (aspect ratio <1.3 for foldables) | Notification Callbacks (global container, @pragma entry-point) | Graceful Service Init (Firebase/RevenueCat/notifications wrapped in try-catch with fallback modes, non-fatal failures) | NotificationService Provider Override (single initialized instance via container override prevents uninitialized FlutterLocalNotificationsPlugin on iOS) | Ambient Sound Guard (_globalAmbientSoundPlayed flag prevents duplicate plays on cold start) | Video Splash Screen (3.5s trimmed nonduality animation, theme-aware black/white, skips if reduceMotion or animationsEnabled=false)

**Anti-Patterns**: ❌ New files vs extending | ❌ Hardcode colors | ❌ Skip tests | ❌ Commit without build verification

## Reference Docs

- `/DESIGN_SYSTEM.md` - Full design specifications
- `/EXECUTION_PLAN.md` - Implementation roadmap and product decisions
- `/PRFAQ.md` - Product vision and FAQ
- `/docs/PLAY_STORE_RELEASE.md` - Play Store release checklist (signing, legal docs, store assets, Play Console setup)
- `/docs/PRIVACY_POLICY.md` - Privacy policy (local-first, RevenueCat/AWS Polly data sharing, effective Jan 2 2025)
- `/docs/TERMS_OF_SERVICE.md` - Terms of service (lifetime purchase, content disclaimer, CA law, effective Jan 2 2025)
- `${vault_path}/ROADMAP.md` - Feature roadmap with priorities
- `${vault_path}/IMPLEMENTATION_PLAYBOOK.md` - Orchestrator execution guide
