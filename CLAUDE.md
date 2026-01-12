# CLAUDE.md

Here Now: Flutter mobile app delivering daily non-dual awareness "pointings" from spiritual traditions. Anti-meditation positioning. No progress tracking or gamification.

## Commands

```bash
# Development & Testing
flutter run                            # Run on device
flutter test --concurrency=8           # Unit tests
flutter test --update-goldens          # Update golden baselines
maestro test maestro/flows/            # E2E tests (21 flows)

# Build & Deploy
flutter build apk/ios/appbundle
bundle exec fastlane android internal/production
# Android: Kotlin 2.3.0, ProGuard enabled, google-services.json
# iOS: Manual via Xcode Archive (ExportOptions.plist)
```

## Architecture

```
lib/
├── main.dart                  # Entry point, graceful service initialization (Firebase→RevenueCat [skipped if kFreeAccessEnabled]→notifications with try-catch), notificationServiceProvider override for single initialized instance, teaching repository initialization, ambient sound guard, notification callbacks, widget theme sync
├── router.dart                # GoRouter singleton with SharedPreferences-based redirects
├── theme/app_theme.dart       # PointerColors (dark/light/highContrast/oled), AppThemeMode
├── providers/                 # Riverpod state management
│   ├── core_providers.dart    # SharedPreferences, storage, notifications
│   ├── settings_providers.dart # Zen mode, OLED, accessibility, theme, auto-advance
│   ├── content_providers.dart # Pointings, favorites, affinity, teaching filters
│   ├── subscription_providers.dart # RevenueCat, freemium, auth callbacks
│   └── auth_providers.dart    # Firebase auth state
├── screens/                   # Main UI screens
│   ├── main_shell.dart        # Bottom nav shell with swipe gestures, FloatingParticles, responsive nav bar (3-tier breakpoints), GlobalKey conflict prevention
│   ├── home_screen.dart       # Daily pointing with auto-advance timer
│   ├── inquiry_player_screen.dart # Guided inquiry with timed phases
│   ├── library_screen.dart    # Browse articles/quotes with filters (all/articles/quotes/saved), browse modes, ContentFilter integration
│   ├── settings_screen.dart   # Settings, account, developer options
│   └── paywall_screen.dart    # Premium paywall with restore purchases (prompts sign-in for cross-device sync)
├── widgets/                   # Reusable components
│   ├── glass_card.dart        # GlassCard/GlassButton (intensity levels)
│   ├── animated_gradient.dart # Background gradient animation
│   ├── teacher_sheet.dart     # Teacher bio modal
│   ├── sign_in_sheet.dart     # Google/Apple Sign-In modal
│   └── share_templates/share_card.dart # Shareable card templates
├── services/                  # Business logic
│   ├── storage_service.dart   # SharedPreferences wrapper
│   ├── notification_service.dart # Scheduling with presets, time windows
│   ├── workmanager_service.dart # Background notifications
│   ├── widget_service.dart    # Home widget data updates
│   ├── revenue_cat_service.dart # RevenueCat integration
│   ├── auth_service.dart      # Firebase Google/Apple Sign-In
│   ├── share_service.dart     # Share card generation
│   ├── tts_service.dart       # AWS Polly TTS (DISABLED)
│   ├── affinity_service.dart  # Tradition preference learning
│   └── ambient_sound_service.dart # Opening sound (bell), persisted preference
├── models/
│   ├── article.dart           # Article model with tag-based filtering
│   └── teacher.dart           # Teacher model
└── data/
    ├── pointings.dart         # Curated pointings
    ├── articles.dart          # Curated articles with topicTags/moodTags
    ├── teaching.dart          # TopicTags/MoodTags constants, TeachingType enum
    ├── teachers.dart          # Teacher database (9 teachers)
    └── teachings/             # Extended teaching content
        ├── papaji.dart        # Papaji's teachings
        └── adyashanti.dart    # Adyashanti's teachings

android/app/src/main/kotlin/com/dailypointer/
├── MainActivity.kt            # Theme change listener
├── PointerWidgetProvider.kt   # Home widget with AdapterViewFlipper
└── PointerWidgetService.kt    # RemoteViewsService for widget data

android/app/src/main/res/
├── drawable/                  # Widget glassmorphism cards (dark/light)
└── layout/                    # Widget layouts (dark/light variants)

ios/Runner/
├── Info.plist                 # App config: Google OAuth URL scheme, export compliance, permissions
├── GoogleService-Info.plist   # Firebase configuration
├── Runner.entitlements        # App capabilities (Sign in with Apple, push notifications)
└── AppDelegate.swift          # App lifecycle, AVAudioSession config (.playback, .mixWithOthers, .duckOthers), flutter_local_notifications plugin registration callback for foreground handling, UNUserNotificationCenter delegate setup (iOS 10+), background fetch (UIApplication.backgroundFetchIntervalMinimum) for WorkManager periodic notifications

test/                          # Unit tests
├── providers/                 # Provider tests
├── services/                  # Service tests
├── screens/                   # Widget tests
├── accessibility/             # Semantics & VoiceOver tests
└── golden/                    # Visual regression tests

integration_test/              # State-controlled E2E flows
maestro/flows/                 # Cross-platform E2E (21 YAML flows)
docs/                          # Legal docs, store assets
fastlane/                      # Play Store deployment
```

## Tech Stack

**Framework**: Flutter 3.x + Dart 3.10, GoRouter 14.x, Riverpod 2.5
**Key Deps**: Firebase Auth (Google/Apple Sign-In), RevenueCat (IAP), flutter_local_notifications + workmanager, just_audio, share_plus, screenshot
**Testing**: flutter_test + mocktail, Maestro (E2E)
**Design**: "Ethereal Liquid Glass" - 4 PointerColors themes, iOS Control Center glassmorphism. See `/DESIGN_SYSTEM.md`.
**Principles**: Prefer Flutter packages over native code. Never commit signing files. Always use `context.colors` for theme access.

## Key Patterns

### Providers
- **Settings** (`settings_providers.dart`): User prefs (zen mode, OLED, accessibility, theme, auto-advance 60s default). SettingsNotifier with copyWith updates
- **Content** (`content_providers.dart`): Round-robin pointing navigation (persisted shuffled order), favorites, affinity tracking, teaching filters
- **Subscription** (`subscription_providers.dart`): RevenueCat integration, freemium v2 (unlimited quotes, premium for library/notifications/widget), Firebase auth callbacks for cross-platform sync. **⚠️ kFreeAccessEnabled = TRUE** - enables free access mode for App Store release without IAP (RevenueCat disabled). Set to false when ready to enable monetization
- **Auth** (`auth_providers.dart`): Firebase auth state (Google/Apple Sign-In), AuthActionNotifier for UI loading/error states

### Services
- **Notifications** (`notification_service.dart`): Presets (Morning/All day/Evening/Minimal/Test), time windows with frequencyMinutes (30-720min), max 50 scheduled, Android 12+ exact alarm permission, pointings_v6 channel. initialize() accepts optional onNotificationResponse/onBackgroundNotificationResponse callbacks. iOS foreground presentation: alerts/banners enabled, sound disabled (silent for meditation app). Test notifications use InterruptionLevel.active for visible banner
- **Widget** (`widget_service.dart`): Premium gating (respects kFreeAccessEnabled), pointings cache population with favorite interleaving, theme sync via refreshWidget()
- **Auth** (`auth_service.dart`): Firebase singleton, Google/Apple Sign-In, RevenueCat identity sync callbacks (onSignIn/onSignOut). Apple Sign-In: ALL SignInWithAppleAuthorizationException errors return null (silent failure) to prevent error messages when users tap "Close" on system dialog (simulator/devices without Apple ID); includes SignInException for custom user-friendly errors
- **Share** (`share_service.dart`): Card generation (minimal/gradient/tradition templates), square/story formats, captureWidget/shareImage/copyToClipboard
- **AmbientSound** (`ambient_sound_service.dart`): Opening sound on cold start (bell via just_audio), persisted user preference, global guard prevents duplicate plays

### Data Models
- **Pointing**: id, content, instruction, tradition (Advaita/Zen/Direct Path/Contemporary/Original), context (morning/midday/evening/stress/general), teacher, source
- **Article** (`models/article.dart` + `data/articles.dart`): id, title, subtitle, content (markdown), excerpt, tradition, teacher, categories (ArticleCategory enum), readingTimeMinutes, isPremium, topicTags (Set<String> from TopicTags constants), moodTags (Set<String> from MoodTags constants). Helper methods: hasCategory(), isBy(), hasTopic(), hasMood()
- **Teacher** (`models/teacher.dart` + `data/teachers.dart`): 9 teachers across traditions. getTeacher(name), getPointingsByTeacher(name)

## Testing

### Unit Tests (`test/`)
- **Setup**: ProviderScope with mocked deps, SharedPreferences mocking, mocktail for services
- **Animations**: Use `pump(Duration(seconds: 2))` not `pumpAndSettle()` for continuous animations. Set `AnimatedGradient.disableAnimations = true` in `setUpAll()`
- **Subscription mocking**: `_TestSubscriptionNotifier` pattern extends SubscriptionNotifier with fixed state. See `library_screen_test.dart`
- **Screen sizes**: iPhone 14 Pro Max (1290x2796, 3.0 DPR), iPad Pro (2048x2732, 2.0 DPR), standard phone (1080x1920, 2.0 DPR)
- **Golden tests** (`test/golden/`): setupGoldenTests(), goldenTestTheme (Roboto), pumpForGolden(), GoldenDevices
- **Accessibility** (`test/accessibility/`): VoiceOver semantics, labels, focus order, custom actions, screen reader hints

### Integration Tests (`integration_test/`)
- State-controlled E2E using IntegrationTestWidgetsFlutterBinding (Riverpod state injection)
- UncontrolledProviderScope pattern, custom settle() helper for animations
- Screenshot capture: binding.convertFlutterSurfaceToImage() → binding.takeScreenshot()

### E2E Tests (Maestro)
- 21 YAML flows (7 core + 14 feature): navigation, onboarding, widget, settings, library, Apple Sign-In (6 flows: basic, full, close, iPad, navbar spacing, full test), etc.
- Cross-platform (iOS/Android), outputs to `maestro/screenshots/`
- **Assertion patterns**: Use regex for flexible matching (`".*Next.*"` vs `"Next Pointing"`), mark optional for responsive layouts (landscape/portrait), verify content loaded (not just navigation)
- **Interaction patterns**: Swipe gestures (direction: UP/DOWN, duration), long press (longPressOn), coordinate-based taps (point: "50%,40%")
- **Timing**: Add `waitForAnimationToEnd` after navigation to prevent flaky assertions
- **Use for**: Black-box E2E, store screenshots, native widget testing
- **Don't use for**: State-controlled tests (use Flutter), WCAG compliance (use Flutter accessibility tests), timing-sensitive flows

## TODOs

- Backend API (planned per EXECUTION_PLAN.md)
- Light/Dark mode toggle
- iOS: Enable "Sign in with Apple" capability in Xcode signing settings (Google Sign-In already configured via Info.plist URL scheme)

## Features

**TTS** (`tts_service.dart` + `aws_credential_service.dart`): AWS Polly article synthesis. **STATUS: DISABLED** - code remains for future re-enablement.

**Audio Pointings** (`audio_pointing_service.dart` + `audio_player_widget.dart`): Pre-recorded guided readings via just_audio. Premium-gated.

**Freemium V2**: FREE = unlimited pointings/quotes. PREMIUM (lifetime purchase via RevenueCat) = library, audio, notifications, widget. Firebase auth callbacks sync purchases cross-device. `kFreeAccessEnabled` flag in `subscription_providers.dart` (**⚠️ currently TRUE** - all features unlocked, RevenueCat disabled for App Store release without IAP).

## Execution Protocol

**Git**: Commit after each task (`fix/feat(scope): description`), verify tests pass before next task
**Worktrees**: Use `git worktree add ../Pointer-feature-{name}` for parallel isolation (max 8 concurrent)
**Vault**: Mark checkboxes complete, update ROADMAP.md status after waves, log blockers in playbook

## Implementation Patterns

**Theme** (`app_theme.dart`): PointerColors (4 variants), access via `context.colors.{property}` | GlassCard/Button (intensity levels, high contrast) | AnimatedGradient | HapticFeedback (light/medium/heavy)

**Providers** (`providers/`): Settings (zen, OLED, accessibility, theme, auto-advance) | Content (round-robin persisted order, favorites, affinity, teaching filters) | Subscription (RevenueCat, freemium v2, **⚠️ kFreeAccessEnabled=TRUE** - free access mode for App Store release) | Auth (Firebase, Google/Apple Sign-In, RevenueCat callbacks)

**Services** (`services/`): StorageService (SharedPreferences wrapper, AppSettings) | AffinityService (tradition learning, 3x weight for saves) | NotificationService (initialize() with optional onNotificationResponse/onBackgroundNotificationResponse callbacks, iOS foreground presentation: defaultPresentAlert/defaultPresentBanner=true, defaultPresentSound=false for silent meditation experience) | WorkManager (**TEMP DISABLED** for iOS 26 beta crash diagnosis; normally: background notifications surviving termination; iOS uses UIApplication.backgroundFetchIntervalMinimum in AppDelegate, Flutter plugin auto-registers BGTaskScheduler handlers) | ShareService (card templates, formats) | AmbientSound (opening sound on cold start, global guard) | Auth (Apple Sign-In silent failures: catch ALL SignInWithAppleAuthorizationException, return null instead of rethrowing to avoid error messages on simulator/devices without Apple ID)

**Android Widget** (`*.kt`): PointerWidgetProvider (zero-config AdapterViewFlipper, prev/next, auto-rotation, theme sync) | PointerWidgetService (RemoteViewsFactory) | Widget glassmorphism cards (multi-layer, matches app themes)

**Screens**: InquiryPlayer (timed phases, haptic feedback) | LibraryScreen (LibraryFilter: all/articles/quotes/saved; browse modes: topics/teachers/lineages/moods; ContentFilter integration with filter propagation to detail screens; peek indicator with LayoutBuilder at 70% card width for horizontal scroll reveal; topics source switches to TeachingRepository.topicCounts when quotes filter active; premium gating) | Detail screens (TeacherTeachingsScreen, LineageTeachingsScreen, MoodTeachingsScreen) accept ContentFilter parameter from parent, show filtered articles/quotes sections, premium gating with _ArticleListItem | PaywallScreen (_handleRestore flow: prompts sign-in before restore for cross-device sync, falls back to same-device restore if cancelled) | Settings helpers (_getNotificationCountSummary, _getScheduleTimeSummary, _formatHourShort, _AccountSection)

**Widgets**: TeacherSheet/SignInSheet (modals, DraggableScrollableSheet) | NotificationPreview (matches BigTextStyleInformation) | Share Card Templates (minimal/gradient/tradition)

**Data**: Article (topicTags/moodTags, hasTopic/hasMood, ArticleCategory, isPremium) | TopicTags/MoodTags constants (18 topics, 8 moods) | Teacher (9 teachers, getTeacher/getPointingsByTeacher)

**Navigation**: GoRouter (singleton pattern with _appRouter/_getOrCreateRouter() to prevent GlobalKey conflicts, use ref.read not ref.watch for router to prevent MaterialApp.router rebuilds, SharedPreferences direct access via setRouterSharedPreferences() for redirects, tab-specific navigator keys, route transitions: FadeThrough/SharedAxis/Calm, redirect function for onboarding logic) | MainShell (don't wrap navigationShell in AnimatedSwitcher/KeyedSubtree - has internal GlobalKeys that conflict when widget tree changes; 8px top margin + 16px bottom margin for content separation and visible gap, navbar's rounded corners provide visual separation) | Round-Robin (persisted shuffled order, wrap-around)

**Testing**: Animation handling (pump(Duration), disableAnimations flag) | Subscription mocking (_TestSubscriptionNotifier) | Screen sizes (iPhone 14 Pro Max, iPad Pro) | Golden helpers (setupGoldenTests, pumpForGolden) | Accessibility (VoiceOver semantics, screen reader hints)

**Special**: Auto-Advance Timer (60s default, smart pausing) | Responsive Layout (aspect ratio <1.3 for foldables) | Notification Callbacks (global container, @pragma entry-point) | Graceful Service Init (Firebase/RevenueCat/notifications wrapped in try-catch with fallback modes, non-fatal failures) | NotificationService Provider Override (single initialized instance via container override prevents uninitialized FlutterLocalNotificationsPlugin on iOS) | Ambient Sound Guard (_globalAmbientSoundPlayed flag prevents duplicate plays on cold start)

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
