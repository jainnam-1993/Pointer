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
├── main.dart                  # Entry point, delegates to AppInitializer, retains notification callback (@pragma vm:entry-point) and PointerApp widget
├── router.dart                # GoRouter singleton with SharedPreferences-based redirects, /splash route with cold-start-only video
├── theme/app_theme.dart       # PointerColors (dark/light/highContrast/oled), AppThemeMode
├── providers/                 # Riverpod state management
│   ├── core_providers.dart    # SharedPreferences, storage, notifications
│   ├── settings_providers.dart # Zen mode, OLED, accessibility, theme, auto-advance, animationsEnabled
│   ├── content_providers.dart # Pointings, favorites, affinity, teaching filters
│   ├── subscription_providers.dart # RevenueCat, freemium, auth callbacks
│   ├── donation_providers.dart # Tip jar via in-app purchases (consumable products)
│   └── auth_providers.dart    # Firebase auth state
├── screens/                   # Main UI screens
│   ├── main_shell.dart        # Bottom nav shell with swipe gestures, FloatingParticles, responsive nav bar (3-tier breakpoints), GlobalKey conflict prevention
│   ├── home_screen.dart       # Daily pointing with auto-advance timer, source citations
│   ├── inquiry_player_screen.dart # Guided inquiry with timed phases
│   ├── library_screen.dart    # Main library screen + re-exports library/* subfiles
│   ├── library/               # Library subfiles (extracted from library_screen.dart)
│   │   ├── library_models.dart          # ContentFilter, CategoryInfo, LibraryBrowseMode, TeachingListSorting
│   │   ├── library_widgets.dart         # SectionHeader, ArticleListItem, TeachingCard, FilterSheet, LibraryPremiumUpgrade
│   │   ├── category_articles_screen.dart # Articles by category
│   │   ├── teacher_teachings_screen.dart  # Quotes/articles by teacher
│   │   ├── lineage_teachings_screen.dart  # Quotes/articles by lineage
│   │   ├── mood_teachings_screen.dart     # Quotes/articles by mood
│   │   └── topic_teachings_screen.dart    # Quotes/articles by topic
│   ├── settings_screen.dart   # Main settings screen + re-exports settings/* subfiles
│   ├── settings/              # Settings subfiles (extracted from settings_screen.dart)
│   │   ├── settings_widgets.dart        # SettingsSectionHeader, SettingsRow, SettingsDivider
│   │   ├── settings_banners.dart        # NotificationPermissionBanner, PremiumFeatureBanner
│   │   ├── appearance_section.dart      # AppearanceSelector, ThemeOption, ZenModeToggle, AnimationToggle
│   │   ├── experience_section.dart      # AutoAdvanceToggle, AmbientSoundPicker
│   │   └── notification_times_sheet.dart # NotificationTimesSheet (schedule management)
│   ├── splash_screen.dart     # Video splash (theme-aware nonduality animation, cold-start only)
│   └── paywall_screen.dart    # Premium paywall with restore purchases (prompts sign-in for cross-device sync)
├── widgets/                   # Reusable components
│   ├── glass_card.dart        # GlassCard/GlassButton (intensity levels)
│   ├── animated_gradient.dart # Background gradient animation (adaptive fps: 60/45/30 by device tier, RepaintBoundary isolated)
│   ├── teacher_sheet.dart     # Teacher bio modal
│   ├── sign_in_sheet.dart     # Google/Apple Sign-In modal
│   ├── donation_button.dart   # Expandable tip jar (2x2 grid: Tea/Cushion/Incense/Retreat)
│   └── share_templates/share_card.dart # Shareable card templates (with source citations)
├── services/                  # Business logic
│   ├── app_initializer.dart   # Phased startup: platform→core→services→container→content
│   ├── storage_service.dart   # SharedPreferences wrapper
│   ├── notification_service.dart # Scheduling with presets, time windows
│   ├── workmanager_service.dart # Background notifications
│   ├── widget_service.dart    # Home widget data updates
│   ├── revenue_cat_service.dart # RevenueCat integration
│   ├── donation_service.dart  # Tip jar via in_app_purchase (4 consumable tiers)
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
    ├── teachers.dart          # Teacher database (22 teachers)
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
├── providers/                 # Provider tests (high contrast, OLED mode)
├── services/                  # Service tests (time of day)
├── screens/                   # Widget tests (dynamic type, long press, zen mode)
├── data/                      # Data model tests (inquiry, library, pointings)
├── widgets/                   # Widget tests (reduced motion)
├── accessibility/             # Semantics & VoiceOver tests
└── golden/                    # Visual regression tests

integration_test/              # State-controlled E2E flows
maestro/flows/                 # Cross-platform E2E (21 YAML flows)
docs/                          # Legal docs, store assets
fastlane/                      # Play Store deployment
```

## Tech Stack

**Framework**: Flutter 3.x + Dart 3.10, GoRouter 14.x, Riverpod 2.5
**Key Deps**: Firebase Auth (Google/Apple Sign-In), RevenueCat (IAP), in_app_purchase (tip jar), flutter_local_notifications + workmanager, just_audio, share_plus, screenshot
**Testing**: flutter_test + mocktail, Maestro (E2E)
**Design**: "Ethereal Liquid Glass" - 4 PointerColors themes, iOS Control Center glassmorphism. See `/DESIGN_SYSTEM.md`.
**Principles**: Prefer Flutter packages over native code. Never commit signing files. Always use `context.colors` for theme access.

## Key Patterns

**Providers**: Settings (zen, OLED, accessibility, theme, auto-advance 60s, animationsEnabled with reduceMotionOverrideProvider derived) | Content (round-robin persisted order, favorites, affinity, teaching filters) | Subscription (analytics-only DailyUsageNotifier, no premium gating) | Donation (tip jar, consumable products, DonationState) | Auth (Firebase Google/Apple Sign-In)

**Services**: Notifications (presets: Morning/All day/Evening/Minimal/Test, 30-720min freq, 50 max, iOS silent) | Widget (premium gating, favorite interleaving, theme sync) | Auth (Firebase singleton, RevenueCat sync, Apple Sign-In silent failures) | Share (minimal/gradient/tradition templates, square/story) | AmbientSound (opening bell, global guard)

**Data Models**: Pointing (id, content, instruction, tradition, context, teacher, source) | Article (id, title, subtitle, content, excerpt, tradition, teacher, categories, readingTimeMinutes, isPremium, topicTags, moodTags) | Teacher (22 across traditions, getTeacher, getPointingsByTeacher)

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

## Release Status

**Current version**: 1.2.0+15 (pubspec), App Store version 1.1
**iOS**: v1.2.0 (build 13) — Submitted to App Review with 4 IAPs (Waiting for Review, auto-release on approval)
**Android**: v1.2.0 (build 15) — Live on Play Store internal testing. Production blocked by Google's new developer account policy (requires 20+ testers × 14 days closed testing)
**IAPs (both stores)**: 4 consumable tip jar products configured and active
  - `com.dailypointer.tip_small` — Buy Me a Tea ($0.99)
  - `com.dailypointer.tip_medium` — Buy Me a Cushion ($4.99)
  - `com.dailypointer.tip_large` — Buy Me Incense ($9.99)
  - `com.dailypointer.tip_generous` — Fund a Retreat ($24.99)

## Next Actions

- **When Apple approves**: Post Reddit update from `docs/REDDIT_V1.2_UPDATE.md` to r/nonduality thread
- **Android production**: Promote internal → closed testing (Alpha), recruit 20+ testers, wait 14 days, then apply for production access
- **App Store IAP prices**: Verify tip_medium ($4.99), tip_large ($9.99), tip_generous ($24.99) were applied correctly after review approval
- **Version alignment**: iOS has build 13, Android has build 15 — cosmetic mismatch, same code. Align on next release

## TODOs

- Backend API (planned per EXECUTION_PLAN.md)
- Light/Dark mode toggle
- iOS: Enable "Sign in with Apple" capability in Xcode signing settings (Google Sign-In already configured via Info.plist URL scheme)

## Features

**TTS** (`tts_service.dart` + `aws_credential_service.dart`): AWS Polly article synthesis. **STATUS: DISABLED** - code remains for future re-enablement.

**Audio Pointings** (`audio_pointing_service.dart` + `audio_player_widget.dart`): Pre-recorded guided readings via just_audio. Premium-gated.

**Fully Free**: All features unlocked. No premium gating, no paywall, no RevenueCat. Revenue via optional tip jar donations (in_app_purchase consumables).

## Implementation Patterns

**Theme**: PointerColors (4 variants, access via context.colors), GlassCard/Button (intensity levels, high contrast), AnimatedGradient, HapticFeedback

**Services**: AppInitializer (phased startup: platform→core→services→container→content) | StorageService (SharedPreferences wrapper) | AffinityService (3x weight for saves) | NotificationService (presets, iOS silent) | WorkManager (Android only; iOS uses backgroundFetchIntervalMinimum) | DonationService (graceful degradation) | ShareService (templates) | AmbientSound (global guard) | Auth (silent failures)

**Screens**: InquiryPlayer (timed phases) | LibraryScreen (browse by topics/teachers/lineages/moods, peek indicators) | Settings

**Widgets**: TeacherSheet, SignInSheet, NotificationPreview, ShareCardTemplates

**Data**: 2,434 pointings, 166 articles (22 teachers, 18 topics, 8 moods)

**Navigation**: GoRouter singleton (ref.read not ref.watch), SharedPreferences redirects, /splash cold-start-only, tab-specific keys, FadeThrough/SharedAxis/Calm transitions

**Testing**: pump(Duration) for animations, _TestSubscriptionNotifier pattern, screen sizes (iPhone 14 Pro Max, iPad Pro)

**Performance**: AnimatedGradient adaptive FPS (_DeviceTier), RepaintBoundary isolation, particle scaling (6/3/2), consolidate animation controllers

**Special**: Auto-Advance 60s | AppInitializer phased | Ambient Sound Guard | Video Splash (4.3s, bell +5s delay)

_Anti-patterns in `.claude/rules/pointer-rules.md`_

## Reference

**Docs**: DESIGN_SYSTEM.md | EXECUTION_PLAN.md | PRFAQ.md | ROADMAP.md | IMPLEMENTATION_PLAYBOOK.md
**Git**: Commit per task (`fix/feat(scope): desc`), verify tests | Worktrees: `git worktree add ../Pointer-feature-{name}` (max 8)
