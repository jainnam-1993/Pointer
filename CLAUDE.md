# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Pointer is a Flutter mobile app that delivers daily non-dual awareness "pointings" from various spiritual traditions. Anti-meditation positioning: direct pointing vs guided meditation. No progress tracking, no gamification.

## Commands

```bash
# Development
flutter run                    # Run on connected device/emulator
flutter run -d chrome          # Run on web (for quick testing)

# Testing
flutter test --concurrency=8   # Unit tests (8 parallel)
flutter test --coverage        # With coverage report
flutter test integration_test  # Integration tests
flutter test integration_test/screenshot_test.dart  # Screenshot tests (basic IntegrationTest)
flutter test --update-goldens  # Generate/update golden test baselines
flutter test test/golden/      # Run golden tests (visual regression)

# E2E Testing (Maestro) - Cross-platform UI automation
maestro test maestro/flows/00_smoke_test.yaml       # Quick health check (~30s)
maestro test maestro/flows/01_navigation.yaml       # Tab navigation flow
maestro test maestro/flows/02_onboarding.yaml       # First-time user flow
maestro test maestro/flows/03_freemium_paywall.yaml # Premium upgrade journey
maestro test maestro/flows/04_home_interactions.yaml # Swipes, taps, saves
maestro test maestro/flows/05_settings.yaml         # Settings & notifications
maestro test maestro/flows/06_screenshots_all.yaml  # Store screenshot capture
maestro test maestro/flows/07_accessibility_audit.yaml # Element accessibility check
maestro test maestro/flows/08_inquiry_session.yaml  # Guided inquiry session
maestro test maestro/flows/09_library_content.yaml  # Library articles & teachings
maestro test maestro/flows/10_widget_test.yaml      # Home screen widget test (requires widget on home screen)
maestro test maestro/flows/                         # Run all flows (~5 min)
# Screenshots output to: maestro/screenshots/

# Git Hooks - Pre-commit Quality Gates
# Location: scripts/hooks/pre-commit
# Runs Maestro smoke test before commits (requires Maestro installed + device/emulator)
# Currently opt-in: device detection stubbed (check_device() returns 1)
# Install: ./scripts/setup-hooks.sh (auto-detects worktrees, creates symlinks)
# Manual: Copy scripts/hooks/pre-commit to .git/hooks/pre-commit
# Blocks commit if smoke test fails (60s timeout)

# Build
flutter build apk              # Android APK
flutter build ios              # iOS build
flutter build appbundle        # Android App Bundle (Play Store)

# Utilities
flutter analyze                # Static analysis
flutter pub get                # Install dependencies

# Legacy Device Testing (DEPRECATED - use Maestro instead)
# scripts/adb_test_helper.sh - Android device testing (replaced by Maestro)
# scripts/ios_test_helper.sh - iOS simulator testing (replaced by Maestro)

# Android Build Notes
# - Kotlin 2.3.0, Android Gradle Plugin 8.13.2
# - Kotlin configuration: kotlin.compilerOptions.jvmTarget (Gradle Plugin 2.x style)
# - android/build.gradle.kts forces compileSdk = 36 for all plugin subprojects
# - Gradle performance: caching + parallel builds enabled
# - Core library desugaring: 2.1.5 (Java 17 compatibility)
# - Release signing: Loads from android/key.properties (falls back to debug if missing)
# - ProGuard: Minification + resource shrinking enabled for release builds
# - ProGuard rules: android/app/proguard-rules.pro (preserves Flutter, RevenueCat, Home Widget)

# Play Store Deployment (Fastlane)
bundle exec fastlane android internal         # Upload AAB to internal testing (skip metadata)
bundle exec fastlane android metadata         # Upload metadata/screenshots only
bundle exec fastlane android production       # Upload AAB to production track
bundle exec fastlane android deploy_internal  # Upload AAB + metadata to internal
bundle exec fastlane android validate         # Validate service account credentials
# Requires: android/play-store-credentials.json (Google Cloud service account)
# Config: fastlane/Appfile (package name: com.dailypointer)
# Metadata: fastlane/metadata/android/en-US/ (title, descriptions, screenshots)
```

## Architecture

```
./
├── lib/
│   ├── main.dart              # App entry point, ProviderScope setup, notification callbacks (save/another actions), ambient sound service with global guard, WidgetsBindingObserver for widget theme sync
│   ├── router.dart            # GoRouter configuration
│   ├── theme/
│   │   └── app_theme.dart     # PointerColors (ThemeExtension), AppThemeMode, theme variants (dark/light/highContrast/oled)
│   ├── providers/
│   │   ├── core_providers.dart          # Foundation providers (SharedPreferences, storage, notifications, onboarding)
│   │   ├── settings_providers.dart      # User preferences (zen mode, OLED, accessibility, theme, notifications)
│   │   ├── content_providers.dart       # Content state (pointings, favorites, affinity, teaching filters)
│   │   ├── subscription_providers.dart  # Subscription state (RevenueCat integration, freemium daily limits)
│   │   └── providers.dart               # Riverpod providers (storage, navigation, TTS)
│   ├── screens/
│   │   ├── main_shell.dart    # Bottom navigation shell with swipe gestures, AnimatedSwitcher transitions, zen mode
│   │   ├── home_screen.dart   # Daily pointing display
│   │   ├── inquiry_screen.dart
│   │   ├── inquiry_player_screen.dart    # Guided inquiry session with timed phase transitions
│   │   ├── lineages_screen.dart
│   │   ├── library_screen.dart    # Browse articles, teachings, TTS reader
│   │   ├── settings_screen.dart   # Settings with TTS config
│   │   ├── onboarding_screen.dart
│   │   └── paywall_screen.dart    # Premium paywall (restore purchases, privacy/terms links)
│   ├── widgets/
│   │   ├── animated_gradient.dart      # Background gradient animation
│   │   ├── animated_transitions.dart   # Staggered fade-in, text switcher animations
│   │   ├── glass_card.dart             # GlassCard/GlassButton components (intensity levels, high contrast)
│   │   ├── tradition_badge.dart        # Tradition indicator badge
│   │   ├── teacher_sheet.dart          # Modal sheet with teacher bio and pointings
│   │   ├── article_tts_player.dart     # TTS playback controls
│   │   └── audio_player_widget.dart    # Audio pointing player (guided readings)
│   ├── services/
│   │   ├── storage_service.dart            # SharedPreferences wrapper
│   │   ├── notification_service.dart       # Notification scheduling (presets, time windows, quiet hours, DEBUG test notification)
│   │   ├── usage_tracking_service.dart     # Daily pointing limit (freemium)
│   │   ├── widget_service.dart             # Home widget data updates, theme sync via refreshWidget()
│   │   ├── revenue_cat_service.dart        # RevenueCat integration (lifetime purchase)
│   │   ├── aws_credential_service.dart     # AWS TOTP authentication
│   │   ├── tts_service.dart                # Text-to-speech via AWS Polly
│   │   ├── affinity_service.dart           # Tradition preference tracking
│   │   ├── pointing_selector.dart          # Time-of-day aware pointing selection
│   │   ├── audio_pointing_service.dart     # Audio pointing playback
│   │   └── ambient_sound_service.dart      # Opening sound playback (bell chime, global guard for cold start)
│   ├── models/
│   │   └── teacher.dart       # Teacher model (name, bio, dates, tradition, tags)
│   └── data/
│       ├── pointings.dart     # Curated pointings across traditions
│       └── teachers.dart      # Teacher database (9 teachers, helper functions)
├── android/
│   └── app/
│       ├── proguard-rules.pro                   # ProGuard rules (preserves Flutter, RevenueCat, Home Widget)
│       └── src/main/
│           ├── kotlin/com/dailypointer/
│           │   ├── MainActivity.kt                  # Theme change listener (BroadcastReceiver for ACTION_CONFIGURATION_CHANGED, triggers widget updates on system theme changes)
│           │   ├── PointerWidgetProvider.kt        # Home widget provider (AdapterViewFlipper navigation, prev/next actions, SharedPreferences position tracking)
│           │   └── PointerWidgetService.kt         # RemoteViewsService factory for widget data (pointings cache, dark/light theme, prefetch logic)
│           └── res/
│           ├── drawable/
│           │   ├── widget_card_dark.xml            # Enhanced glassmorphism dark card (black #0A0A12 base, diagonal shimmer gradient, radial purple glow #108B5CF6, top edge highlight, no visible borders - matches PointerColors.dark)
│           │   ├── widget_card_light.xml           # Enhanced glassmorphism light card (#F8F8FA base, frosted gradient layers, warmth/depth radial, top reflection, 1dp border - matches PointerColors.light)
│           │   ├── widget_icon_circle.xml          # App icon circle (gradient purple background)
│           │   ├── widget_rainbow_stripes.xml      # Simple rainbow gradient (purple-cyan-pink)
│           │   └── widget_stripes_gradient.xml     # Layered rainbow gradient
│           ├── layout/
│           │   ├── pointer_widget.xml              # Widget container dark theme (AdapterViewFlipper, prev/next buttons with contentDescription, refresh/save actions)
│           │   ├── pointer_widget_light.xml        # Widget container light theme (AdapterViewFlipper, prev/next buttons with contentDescription, refresh/save actions)
│           │   ├── widget_stack_item_dark.xml      # Individual pointing card dark (transparent background, 6-line content, position indicator, tradition badge, teacher attribution)
│           │   └── widget_stack_item_light.xml     # Individual pointing card light (transparent background, 6-line content, position indicator, tradition badge, teacher attribution)
│           └── raw/
│               └── bell_chime.ogg                  # Custom notification sound (OGG, 14KB)
├── test/                      # Unit tests
│   ├── dynamic_type_test.dart       # Dynamic Type accessibility tests (text scaling, font size clamping 0.8x-1.5x)
│   ├── providers/
│   │   └── content_providers_test.dart  # Content providers tests (CurrentPointingNotifier, FavoritesNotifier, TeachingFilterState)
│   ├── services/
│   │   └── notification_service_test.dart  # Notification service tests (Android/iOS channel config, v6 channel)
│   ├── screens/
│   │   ├── home_screen_test.dart        # HomeScreen widget tests (layout, content, interactions)
│   │   └── onboarding_screen_test.dart  # Onboarding widget tests (navigation, Dynamic Type)
│   ├── accessibility/
│   │   ├── accessibility_test.dart      # Semantics widget configuration tests (screen reader labels, hints, button flags)
│   │   └── voiceover_test.dart          # VoiceOver accessibility tests (semantic labels, focus order, custom actions, decorative exclusion)
│   └── golden/
│       ├── components_golden_test.dart   # Component visual regression tests
│       └── golden_test_helpers.dart      # Golden test infrastructure
├── integration_test/
│   ├── screenshot_test.dart        # IntegrationTest screenshot tests (8 testWidgets)
│   └── screenshot_helpers.dart     # Screenshot capture + UX issue tracking
├── maestro/                      # E2E testing (Maestro) - cross-platform
│   ├── README.md                 # Maestro documentation and usage guide
│   ├── config.yaml               # Maestro configuration
│   ├── flows/                    # Test flows (YAML)
│   │   ├── 00_smoke_test.yaml    # Quick health check
│   │   ├── 01_navigation.yaml    # Tab navigation
│   │   ├── 02_onboarding.yaml    # First-time user flow
│   │   ├── 03_freemium_paywall.yaml # Premium upgrade
│   │   ├── 04_home_interactions.yaml # Swipes, taps, saves
│   │   ├── 05_settings.yaml      # Settings & notifications
│   │   ├── 06_screenshots_all.yaml # Store screenshots
│   │   ├── 07_accessibility_audit.yaml # Element checks
│   │   ├── 08_inquiry_session.yaml  # Guided inquiry session
│   │   ├── 09_library_content.yaml  # Library articles & teachings
│   │   └── 10_widget_test.yaml      # Widget loading verification (requires manual widget setup on home screen)
│   └── screenshots/              # Test output
├── scripts/                      # Development scripts
│   ├── hooks/
│   │   └── pre-commit            # Git pre-commit hook (Maestro smoke test, opt-in)
│   ├── setup-hooks.sh            # Install git hooks (worktree-aware, symlink-based)
│   ├── adb_test_helper.sh        # (deprecated) Android device testing
│   ├── ios_test_helper.sh        # (deprecated) iOS simulator testing
│   └── screenshot_test.sh        # (deprecated) Screenshot runner
├── docs/
│   ├── PLAY_STORE_RELEASE.md   # Play Store release checklist
│   ├── PRIVACY_POLICY.md        # Privacy policy (markdown, effective Jan 2 2025)
│   ├── TERMS_OF_SERVICE.md      # Terms of service (markdown, effective Jan 2 2025)
│   ├── legal/                   # HTML versions for web hosting
│   │   ├── index.html           # Legal landing page
│   │   ├── privacy.html         # Privacy policy (HTML)
│   │   └── terms.html           # Terms of service (HTML)
│   └── store_assets/            # Store listing graphics
├── fastlane/
│   ├── Appfile                  # Fastlane config (package: com.dailypointer, credentials: android/play-store-credentials.json)
│   ├── Fastfile                 # Deployment lanes (internal, metadata, production, deploy_internal, validate)
│   └── metadata/android/en-US/  # Play Store listing
│       ├── title.txt            # App title: "Pointer"
│       ├── short_description.txt # 80-char tagline
│       └── full_description.txt  # 4000-char app description (features, philosophy, premium)
├── patrol.yaml                # Patrol CLI configuration
└── pubspec.yaml               # Dependencies
```

## Development Principles

- **Library Preference**: Strongly prefer pre-built Flutter packages over custom native code. "Think 100 times" before writing platform-specific native implementations.
- **Git Configuration**: The repository overrides global gitignore with `!lib/` to ensure Flutter's lib/ directory is tracked (Flutter projects require source tracking despite common global gitignore patterns).
- **Security**: Never commit app signing files - `.gitignore` excludes `android/key.properties`, `*.keystore`, `*.jks`, and `android/app/upload-keystore.jks`.

## Tech Stack

- **Framework**: Flutter 3.x + Dart 3.10
- **Routing**: GoRouter 14.x (declarative routing)
- **State Management**: Riverpod 2.5 (providers pattern)
- **Storage**: SharedPreferences, flutter_secure_storage (TTS credentials)
- **Animations**: flutter_animate, animations package, custom gradient animations
- **UI Components**: Google Fonts, flutter_svg (for Ensō icon)
- **Notifications**: flutter_local_notifications, timezone
- **Audio/TTS**: just_audio (playback), audio_service (background), AWS Polly (synthesis), otp (TOTP auth), crypto (SigV4 signing)
- **Video**: video_player
- **Home Widget**: home_widget
- **In-App Purchases**: purchases_flutter (RevenueCat)
- **URL Launching**: url_launcher (for privacy/terms links)
- **System Settings**: app_settings (notification permission deep links)
- **Markdown**: flutter_markdown_plus (for content rendering)
- **Utilities**: path_provider, share_plus
- **Haptics**: flutter/services HapticFeedback (lightImpact/mediumImpact/heavyImpact)
- **Testing**: flutter_test + mocktail (unit), patrol (integration)

## Design System

"Ethereal Liquid Glass" theme defined in `/DESIGN_SYSTEM.md`:
- **Theme variants**: 4 complete PointerColors themes (dark, light, highContrast, oled) with all Material colors
- Glass components: iOS Control Center-style blur with intensity levels (light/standard/heavy)
- Colors: Deep purples (`#0F0524`, `#1A0A3A`), accent violet (`#8B5CF6`), teal (`#06B6D4`)
- Typography: Inter font via Google Fonts
- Animations: Smooth, subtle gradient morphing

## Key Patterns

**AppTheme** (`lib/theme/app_theme.dart`): Theme system with `PointerColors` (ThemeExtension) providing theme variants (dark, light, highContrast, oled). Includes core Material theme colors (background, surface, primary, secondary), text colors (textPrimary, textSecondary, textMuted), glass morphism colors (glassBorder, glassBackground, glassBorderActive), and accent colors (gold, accent, iconColor). Access all colors via `context.colors.{colorName}`.

**GlassCard** (`lib/widgets/glass_card.dart`): iOS Control Center-style glassmorphism with `GlassIntensity` levels (light/standard/heavy). Auto-adapts blur and opacity for dark/light modes. High contrast mode uses solid backgrounds with 2px borders (AAA compliance). Supports scrolling, height constraints, tap handlers. Includes `GlassButton` for primary/secondary actions with loading states.

**AnimatedGradient** (`lib/widgets/animated_gradient.dart`): Animated background gradient for immersive feel.

**HapticFeedback**: Use `flutter/services` HapticFeedback for tactile feedback. `lightImpact()` for navigation/selection, `mediumImpact()` for actions/dialogs, `heavyImpact()` for significant events (developer unlock, subscription). Used extensively across home, library, settings, lineages, history, inquiry, paywall, onboarding screens.

**PointerWidgetProvider** (`android/app/src/main/kotlin/com/dailypointer/PointerWidgetProvider.kt`): Zero-configuration Android home widget with AdapterViewFlipper architecture for manual navigation. No WidgetConfigActivity required - widget works immediately after placement. Displays ONE pointing at a time with prev/next button controls. Actions: ACTION_PREV/ACTION_NEXT (navigate through pointings with circular wrapping, includes checkAndHandleThemeChange() on each action), ACTION_REFRESH (reload data via Flutter background intent), ACTION_SAVE (add to favorites with save button state updates). Content area click directly opens app via PendingIntent.getActivity(). SharedPreferences tracks flipper_position across updates. Auto-rotation every 30 minutes via advanceStackPosition(). Dark/light mode auto-switching via isSystemInDarkMode() with Configuration change listener (ACTION_CONFIGURATION_CHANGED) that triggers updateAllWidgets(). Theme detection on prev/next actions ensures widget theme stays in sync. Retrieves total count from pointings_cache JSON. Uses partiallyUpdateAppWidget for efficient position updates. Logging: TAG "PointerWidget" with Log.d/Log.e. Error handling: try-catch with null safety, elvis operators for fallbacks.

**PointerWidgetService** (`android/app/src/main/kotlin/com/dailypointer/PointerWidgetService.kt`): RemoteViewsService providing PointerRemoteViewsFactory for AdapterViewFlipper. Factory loads pointings from HomeWidgetPlugin.getData() (pointings_cache JSON array), creates RemoteViews for each item with tradition badges (accent colors), teacher attribution, position indicators (e.g., "3 / 40"). Dark/light theme support with separate layout files (widget_stack_item_dark/light.xml). Prefetch logic triggers at PREFETCH_THRESHOLD to request more data from Flutter. Error handling: try-catch with fallback to empty list, null-safe JSON parsing.

**Widget Glassmorphism** (`android/app/src/main/res/drawable/` + `layout/`): Widget cards match app PointerColors themes with enhanced multi-layer glassmorphism. Dark theme (widget_card_dark.xml): black #0A0A12 base with 4 gradient layers - diagonal shimmer (#10FFFFFF→#05FFFFFF→#08FFFFFF at 135°), radial purple glow (#108B5CF6 from 30%/20% center), top edge highlight (#00FFFFFF→#0AFFFFFF), no visible borders (clean glass effect). Light theme (widget_card_light.xml): #F8F8FA base with 4 gradient layers - frosted gradient (#F0FFFFFF→#D8FFFFFF→#E8FFFFFF at 135°), warmth/depth radial (#08000000 from 70%/80% center), top reflection (#00FFFFFF→#60FFFFFF), and 1dp border (#20000000). Stack item layouts (widget_stack_item_dark.xml / widget_stack_item_light.xml) use transparent 4dp padding with: header (24dp "P" icon + hidden tradition badge + position indicator e.g., "3 / 40"), 6-line ellipsized content (dark: #FFFFFF 15sp, light: #1C1C1E 15sp, 1.4 line spacing), italic teacher attribution (dark: #AAAAAA 12sp, light: #636366 12sp, hidden by default), and hidden accent stripe for code compatibility. Matches iOS Control Center glassmorphism style from app's GlassCard widget.

**Riverpod Providers** (`lib/providers/providers.dart`): SharedPreferences instance, router, storage service providers, TTS providers, usage tracking providers.

**Settings Providers** (`lib/providers/settings_providers.dart`): User preferences with persistence via StorageService:
- **State providers**: zenModeProvider, oledModeProvider, fontSizeMultiplierProvider, reduceMotionOverrideProvider, highContrastProvider, themeModeProvider
- **Settings notifier**: SettingsNotifier with copyWith updates (setTheme, setHighContrast, setZenMode)
- **Notification settings**: NotificationSettingsNotifier managing enabled state and notification times
- **Accessibility helpers**: shouldReduceMotion(context, appOverride), isHighContrastEnabled(context, ref)
- **Theme conversion**: AppThemeMode ↔ Flutter ThemeMode

**Settings Screen** (`lib/screens/settings_screen.dart`): Settings UI with dynamic notification schedule display:
- **Dynamic schedule summary**: `_getNotificationCountSummary()` retrieves count from NotificationService schedule (e.g., "3 per day", "Disabled")
- **Time window display**: `_getScheduleTimeSummary()` formats schedule as "Every Xh/Xm, 8am - 9pm" based on frequencyMinutes and start/end hours
- **Time formatting**: `_formatHourShort()` helper converts 24h to 12h format with am/pm (8→"8am", 21→"9pm")
- **Developer options**: Version tap counter (7 taps) unlocks TTS configuration and developer settings
- **Developer testing tools**: "Grant Alarm Permission" (Android 12+ exact alarm requirement), test notification preset (1-minute intervals)
- **Test preset visibility**: _showNotificationTimesSheet() passes showTestPreset flag to notification modal when developer options enabled
- **Layout**: 8px bottom padding on settings ListView for proper spacing

**Content Providers** (`lib/providers/content_providers.dart`): Content state management with round-robin navigation and filtering:
- **Pointing navigation**: currentPointingProvider (StateNotifier) with round-robin order (shuffled once on first launch, persisted across restarts). nextPointing()/previousPointing() traverse the fixed order, setPointing() jumps to specific pointing. Guarantees seeing all pointings before any repeats. Auto-reshuffles at cycle end, persists `pointingOrder` (shuffled IDs) and `pointingIndex` via StorageService. Exposes currentIndex/totalPointings for UI.
- **Tradition affinity**: affinityServiceProvider tracks user preferences via view/save counts with weighted scoring (saves = 3x views)
- **Favorites**: favoritesProvider (StateNotifier) with toggle()/isFavorite(), persisted via StorageService
- **Teaching filters**: TeachingFilterNotifier with multi-dimensional filters (lineage, topics Set, moods Set, teacher, type), apply() returns filtered teachings

**Subscription Providers** (`lib/providers/subscription_providers.dart`): Subscription state and freemium model v2:
- **SubscriptionNotifier**: Manages subscription tier (free/premium) via RevenueCat SDK, offline-first with SharedPreferences caching, mounted checks after async operations, syncs widget premium status via WidgetService.setPremiumStatus()
- **DailyUsageNotifier**: canViewPointing() always returns true - quotes/pointings are FREE for all users (freemium v2)
- **State models**: SubscriptionState (tier, loading, products, error, expirationDate), SubscriptionTier enum (free/premium)
- **Freemium v2 model**: FREE tier gets unlimited quotes/pointings; PREMIUM unlocks full library, notifications, widget (TTS temporarily disabled)
- **Testing flag**: `kForcePremiumForTesting` constant for development (set to false in production)
- **Integration**: RevenueCatService singleton for purchases, WidgetService for premium gating, StorageService for offline caching

**Data model**: `Pointing` has id, content, instruction, tradition (Advaita/Zen/Direct Path/Contemporary/Original), context (morning/midday/evening/stress/general), teacher, source.

**Teacher Model & Database** (`lib/models/teacher.dart` + `lib/data/teachers.dart`): Teacher information system for expandable teacher bios. Teacher model includes name, bio, dates, tradition, and tags. Database contains 9 teachers across traditions (Advaita, Direct Path, Contemporary, Zen, Original). Helper functions: `getTeacher(name)` returns Teacher?, `getPointingsByTeacher(name)` returns List<Pointing>. Used by TeacherSheet widget for displaying teacher context.

**TeacherSheet** (`lib/widgets/teacher_sheet.dart`): Modal bottom sheet showing teacher biography, tradition badge, tags, and other pointings by the same teacher. Glassmorphism styling with BackdropFilter blur. Invoked via `showTeacherSheet(context, teacher)`. DraggableScrollableSheet with 0.3-0.9 size range.

**Inquiry Player** (`lib/screens/inquiry_player_screen.dart`): Guided inquiry session with timed phase transitions. Flow: Setup (3s) → Question (inquiry.pauseDuration) → FollowUp → Complete. Haptic feedback at phase transitions. `disableAutoAdvance` flag for testing. Respects accessibility settings for reduced motion.

**Notification Scheduling** (`lib/services/notification_service.dart`):
- **NotificationPreset**: Quick presets (Morning, All day, Evening, Minimal, Test) for one-tap configuration
  - Test preset: `testEveryMinute` schedules every 1 minute (0:00-23:59, quiet hours disabled) for debugging, only visible when developer options enabled
- **NotificationSchedule**: Time window + frequency model (start/end times, `frequencyMinutes` field, quiet hours support)
- **Frequency options**: `[30, 60, 120, 180, 240, 360, 480, 720]` minutes (30-minute minimum interval, up to 12 hours)
- **Schedule calculation**: `getNotificationTimes()` generates notification times within time window using `Duration(minutes: frequencyMinutes)`
- **Scheduling limits**: Max 50 notifications scheduled at once (configurable via `maxNotifications` parameter in `_scheduleFromSchedule()`) to avoid Android's alarm limit (~500)
- **Scheduling mode**: `inexactAllowWhileIdle` for better compatibility and battery efficiency (allows system batching)
- **Android 12+ requirement**: `requestExactAlarmPermission()` method requests exact alarm permission (opens system settings), `canScheduleExactNotifications()` checks permission status before scheduling
- **Permission flow**: Automatic exact alarm permission request during `requestPermission()`, manual request available via developer tools
- **Quiet hours**: Supports overnight quiet periods (e.g., 22:00-07:00)
- **Channel**: Uses `pointings_v6` notification channel (Android)
- **Sound**: Custom bell_chime.ogg configured with MAX importance/priority + vibration (debugging Android audio playback)
- **Debug logging**: Prints now time, schedule details (frequency, start/end), and notification counts for troubleshooting
- **Legacy support**: `NotificationTime` class kept for migration from older fixed-time model
- **Backward compatibility**: `fromJson()` automatically converts old `frequencyHours` to `frequencyMinutes` (hours * 60)

**TTS Integration** (`lib/services/tts_service.dart` + `lib/services/aws_credential_service.dart`):
- **Setup flow**: User enters OTP → API returns TOTP secret → stored securely in keychain
- **Runtime flow**: Generate TOTP from secret → API returns AWS credentials → call Polly API
- **AWS SigV4 signing**: Manual implementation for Polly API authentication
- **Credential caching**: 1-hour cache with 5-min refresh buffer
- **Premium-gated**: TTS requires premium subscription (checked in ArticleReaderScreen)
- **Developer access**: Settings → tap version 7 times → Developer section → TTS Configuration

## Testing

**Unit tests** (`test/`): Cover services, widgets, providers. Use mocktail for mocking.

- **Animation handling**: For widgets with continuous animations (AnimatedGradient), use `pump(Duration(seconds: 2))` instead of `pumpAndSettle()` which times out on continuous animations. Disable animations in `setUpAll()` via `AnimatedGradient.disableAnimations = true`. Alternatively, pass `MediaQuery(data: MediaQueryData(disableAnimations: true))` wrapper to test helpers for fine-grained control.
- **Riverpod test setup**: Create `ProviderScope` with overrides for mocked dependencies (SharedPreferences, services, state providers). Mock SharedPreferences before provider initialization.
- **Screen size helpers**: Use `tester.view.physicalSize` and `tester.view.devicePixelRatio` for consistent test dimensions, reset in `tearDown()` via `addTearDown()`. Common sizes: iPhone 14 Pro Max (1290x2796, 3.0 DPR), standard phone (1080x1920, 2.0 DPR).
- **Dynamic Type testing**: Test text scaling with `MediaQuery.copyWith(textScaler: TextScaler.linear(scale))`. AppTextStyles automatically clamp scale factors (0.8x-1.5x range) to maintain readability.

**Integration tests** (`integration_test/`): State-controlled E2E flows using Flutter IntegrationTest (for Riverpod state injection).

**E2E tests** (`maestro/`): Cross-platform UI automation using Maestro (replaced platform-specific scripts).

- **Framework**: Maestro CLI with YAML flows
- **Coverage**: 10 flows covering smoke test, navigation, onboarding, freemium, interactions, settings, screenshots, accessibility, inquiry, library, widget
- **Cross-platform**: Same flows run on iOS and Android
- **CI/CD**: `.github/workflows/maestro.yml` for automated testing
- **Screenshots**: Output to `maestro/screenshots/` directory
- **Usage**: `maestro test maestro/flows/` to run all flows
- **Widget test setup**: Flow `10_widget_test.yaml` requires manual widget placement on home screen before running. Catches "Tap to load" empty state, cache population failures, RemoteViewsService errors.
- **Documentation**: See `maestro/README.md` for detailed flow descriptions and setup instructions
- **When to use**: Black-box E2E testing, store screenshot generation, cross-platform parity verification
- **When NOT to use**: State-controlled testing (use Flutter IntegrationTest), WCAG compliance (use Flutter accessibility tests)

**Screenshot tests** (`integration_test/screenshot_test.dart`): State-controlled visual regression using Flutter IntegrationTest framework.

- **Framework**: IntegrationTestWidgetsFlutterBinding (NOT Patrol - uses standard Flutter integration testing)
- **Coverage**: 8 testWidgets across 3 test groups
  - Core Screens: Home, Inquiry, Lineages, Library, Settings (5 tests)
  - TTS User Flow: Documents UX gap - TTS config hidden in developer menu (2 tests)
  - Daily Limit Flow: Free user usage tracking (1 test)
- **Riverpod Test Setup** (CRITICAL):
  - Must use `UncontrolledProviderScope(container: container, child: PointerApp())`
  - Mock SharedPreferences: `SharedPreferences.setMockInitialValues({})`
  - Override providers: `sharedPreferencesProvider.overrideWithValue(prefs)`
  - Create container in `setUpAll()`, dispose in `tearDownAll()`
- **Animation Handling**:
  - Custom `settle()` helper pumps for fixed 2 seconds
  - Required because app has continuous background animations (AnimatedGradient)
  - Standard `pumpAndSettle()` times out on continuous animations
- **Screenshot Capture**:
  - Android: `binding.convertFlutterSurfaceToImage()` required before capture
  - Capture: `binding.takeScreenshot(name)`
  - Shell script: Supports ADB fallback capture via `adb exec-out screencap`
- **Infrastructure**:
  - `integration_test/screenshot_helpers.dart` - ScreenshotCapture, UXIssueTracker helper classes
  - `patrol.yaml` - Patrol CLI configuration (available but not used for test execution)
  - `scripts/screenshot_test.sh` - ADB screenshot capture wrapper (optional)

**Known UX gaps (documented in tests):**
- **TTS Discoverability**: Premium users cannot find TTS configuration (hidden in developer menu via 7-tap easter egg). Test includes formatted warning recommending visible "Audio & TTS" section in Settings.

**Golden tests** (`test/golden/`): Visual regression testing for UI components.

- **Framework**: Standard Flutter golden tests (pixel-perfect comparison)
- **Test files**:
  - `components_golden_test.dart` - Component snapshots (GlassCard, GlassButton, TraditionBadge)
  - `golden_test_helpers.dart` - Test infrastructure and helpers
- **Helpers** (`golden_test_helpers.dart`):
  - `setupGoldenTests()` - Disables animations, mocks home_widget plugin (prevents MissingPluginException)
  - `goldenTestTheme` - Test theme using Roboto font (no network requests, consistent cross-platform)
  - `createGoldenTestApp()` - App wrapper with provider overrides for consistent state
  - `pumpForGolden()` - Prepares widgets with ProviderScope and size constraints
  - `GoldenDevices` - Standard sizes (iPhone 14 Pro, iPhone SE, Pixel 7, iPad Mini)
- **Usage**: `flutter test --update-goldens` to generate baselines, `flutter test test/golden/` to verify

**Accessibility tests** (`test/accessibility/`): Semantics widget configuration verification for screen readers.

- **Framework**: Standard flutter_test with Semantics node inspection
- **Test files**:
  - `accessibility_test.dart` - Semantics widget configuration (share button, navigation tabs, cards)
  - `voiceover_test.dart` - VoiceOver accessibility requirements (semantic labels, focus order, custom actions)
- **VoiceOver test coverage** (`voiceover_test.dart`):
  - Semantic Labels: TraditionBadge, GlassButton, all traditions
  - Decorative Elements Excluded: AnimatedGradient, FloatingParticles use ExcludeSemantics
  - Custom Actions: HomeScreen pointing card gesture actions
  - Focus Order: Logical top-to-bottom semantic traversal
  - Button Semantics: GlassButton tap/disabled states
  - Screen Reader Hints: Directional action hints (e.g., "Swipe up for next pointing")
- **Test helper**: `createTestApp()` function with ProviderScope overrides for consistent test setup
- **Animation handling**: Uses `pump(Duration(seconds: 2))` for continuous animations instead of `pumpAndSettle()`
- **Verification**: Tests validate SemanticsFlag properties (isButton, isSelected), accessibility labels, and directional hints
- **Theme testing**: Validates color contrast in dark/light PointerColors themes
- **Manual testing**: Use `scripts/adb_test_helper.sh` for device-agnostic Android testing via percentage-based coordinates and UIAutomator element finding

## TODOs in Codebase

- Backend API (planned per EXECUTION_PLAN.md)
- Light/Dark mode toggle

**Completed:**
- ✓ RevenueCat integration (one-time purchase) - Implemented in `lib/services/revenue_cat_service.dart`
- ✓ Freemium model v2 - Unlimited pointings for all users, premium features: library, notifications, widget

## TTS (Text-to-Speech) Feature

**⚠️ STATUS: DISABLED** - Feature temporarily disabled. Code remains in place for future re-enablement.

Article audio playback using AWS Polly neural voices.

**Architecture:**
- **Auth**: TOTP-based credential exchange (OTP setup → TOTP secret → AWS credentials)
  - Setup endpoint: `https://l35p6w7qe7.execute-api.us-east-1.amazonaws.com/prod/setup`
  - Auth endpoint: `https://l35p6w7qe7.execute-api.us-east-1.amazonaws.com/prod/auth`
  - TOTP: SHA1, 30-second window, 6 digits
- **Security**: TOTP secret stored in keychain via `flutter_secure_storage` (iOS: first_unlock, Android: encryptedSharedPreferences)
- **Credential lifecycle**: 1-hour TTL with 5-min refresh buffer, cached in-memory + secure storage
- **API signing**: Manual AWS SigV4 implementation for Polly `SynthesizeSpeech` API (HMAC-SHA256)
- **Content preparation**: Markdown stripping (headers, bold/italic, links, images, code blocks, blockquotes, lists, horizontal rules)
- **Audio**: MP3 synthesis → temp file → just_audio playback
- **Voices**: Joanna (US English, Female - default), Matthew (US English, Male), Amy (British English, Female), Brian (British English, Male)
- **Playback**: Streams for state/position/duration/errors, seek (10s forward/backward), scrubbing via slider
- **Premium-gated**: Requires subscription (free users see paywall)

**User Flow:**
1. Premium user → Article → Tap headphones icon
2. If not configured: Shows "TTS not configured" → Settings → Developer
3. Developer section: Tap version 7 times → TTS Configuration appears
4. Enter 6-digit OTP → Stored as TOTP secret
5. Future requests: Auto-generate TOTP → fetch credentials → play audio

**Files:**
- `lib/services/aws_credential_service.dart` - TOTP auth, credential caching, secure storage (AWSCredentials model, isConfigured/setupWithOTP/getCredentials/clearConfiguration)
- `lib/services/tts_service.dart` - Polly API, SigV4 signing, markdown stripping, audio playback (TTSPlaybackState enum, PollyVoice enum, singleton, streams)
- `lib/widgets/article_tts_player.dart` - Playback UI (play/pause, 10s seek forward/backward, slider scrubbing, voice selector, error display, glass card styling)
- `lib/screens/library_screen.dart` - Article reader with TTS button (premium check, headphones icon)
- `lib/screens/settings_screen.dart` - Developer options (tap version 7 times), TTS config dialog (OTP entry, status check, clear config)
- `lib/providers/providers.dart` - TTS providers (`awsCredentialServiceProvider`, `ttsServiceProvider`, `ttsConfiguredProvider`, `ttsPlaybackStateProvider`)

**Testing:**
- `test/services/aws_credential_service_test.dart` - Credential lifecycle, TOTP generation, caching, expiry, API mocking
- `test/services/tts_service_test.dart` - Singleton, initial state, voice selection, playback state enum, Polly voice enum
- `test/services/tts_markdown_stripping_test.dart` - Markdown removal (headers, bold, italic, links, images, code blocks, lists, blockquotes, horizontal rules, multiple newlines)
- `test/widgets/article_tts_player_test.dart` - Playback controls (play/pause, seek, scrubbing), progress display, voice selection, error display
- `test/screens/article_reader_tts_test.dart` - Article reader TTS integration (button visibility, premium gating)
- `test/screens/settings_tts_test.dart` - Developer options unlock (7 taps), TTS config dialog (OTP entry, status check, clear config)

## Audio Pointings Feature

Pre-recorded guided readings and teachings (distinct from TTS synthesis).

**Key Difference from TTS:**
- **TTS**: Synthesized article reading using AWS Polly (text → audio generation)
- **Audio Pointings**: Pre-recorded audio files (guided readings by teachers)

**Architecture:**
- **Playback**: `AudioPointingService` singleton using just_audio for cross-platform playback
- **State management**: Stream-based (playback state, position, duration)
- **Playback states**: idle, loading, playing, paused, completed, error
- **Controls**: Play/pause, seek forward/backward (10s), slider scrubbing
- **Premium-gated**: Requires subscription (free users see upgrade prompt)

**User Flow:**
1. Pointing with audio URL → AudioPlayerWidget appears
2. Free user taps play → Modal bottom sheet: "Upgrade to Premium"
3. Premium user → Full playback controls available

**Files:**
- `lib/services/audio_pointing_service.dart` - Singleton service for audio playback with just_audio backend
- `lib/widgets/audio_player_widget.dart` - Compact player UI (glass-morphism styling, premium gating)

## Freemium Model V2 - Premium Feature Gating

Freemium model with unlimited pointings for all users. Premium unlocks advanced features.

**Architecture:**
- **Subscription management**: `subscription_providers.dart` manages RevenueCat integration and tier state (free/premium)
- **Feature gating**: Premium features (full library, audio/TTS, notifications, widget) require subscription
- **Free tier**: Unlimited quotes/pointings - `canViewPointing()` always returns true
- **Premium tier**: Full library access, audio pointings, TTS, notifications, home widget
- **Storage**: SharedPreferences (query-string encoded for usage tracking)
- **State**: Managed via `subscriptionProvider` (SubscriptionNotifier) and `dailyUsageProvider` (DailyUsageNotifier)
- **Widget gating**: `WidgetService.setPremiumStatus()` controls widget availability, respects `kForcePremiumForTesting` flag
- **Offline-first**: Subscription tier cached locally, RevenueCat syncs when online

**User Flow:**
1. Free user: Unlimited pointings on home screen, paywalls appear when accessing premium features
2. Premium features locked: Library articles, TTS audio, audio pointings, notifications, widget
3. Premium purchase: One-time lifetime purchase unlocks all features
4. Widget behavior: Free users see empty state, premium users see full pointings carousel

**Files:**
- `lib/providers/subscription_providers.dart` - SubscriptionNotifier, DailyUsageNotifier, SubscriptionState models, `kForcePremiumForTesting` flag
- `lib/services/revenue_cat_service.dart` - RevenueCat SDK integration with lifetime purchase model (product: `pointer_premium_lifetime`), test API keys configured, debug logging enabled for development/testing
- `lib/services/widget_service.dart` - Widget premium gating (`setPremiumStatus`, `isPremiumEnabled`, `clearWidgetData`, `populatePointingsCache`)
- `lib/services/usage_tracking_service.dart` - Legacy counter logic (quotes no longer limited)
- `lib/providers/providers.dart` - Legacy `usageTrackingServiceProvider` (deprecated, use subscription_providers.dart)

**Testing:**
- `test/services/usage_tracking_service_test.dart` - Counter increment, daily reset (legacy tests, quotes now unlimited)

## Orchestration Settings

```yaml
# Parallel Implementation Configuration
subagent_concurrency: 8          # Max parallel subagents for feature implementation
worktree_strategy: true          # Use git worktrees for isolation
vault_path: /Volumes/workplace/tools/Obsidian/Projects/Personal/Pointer/Active
playbook_path: ${vault_path}/IMPLEMENTATION_PLAYBOOK.md
roadmap_path: ${vault_path}/ROADMAP.md
```

### Wave Strategy
- Analyze file conflicts before spawning
- Group features by shared files to avoid merge conflicts
- Max 8 concurrent subagents per wave
- Merge sequentially after wave completes

### Git Worktrees for Parallel Execution
Use git worktrees to parallelize tasks and subagents - each subagent operates in an isolated worktree to avoid file conflicts:
```bash
git worktree add ../Pointer-feature-{name} -b feature/{name}  # Create isolated worktree
# Subagent works in worktree independently
git worktree remove ../Pointer-feature-{name}                  # Cleanup after merge
```

## Execution Protocol

### Git Discipline
- **Commit after each task** - atomic commits for easy rollback
- **Commit message format**: `fix/feat(scope): description`
- **Before moving to next task**: verify `flutter test` passes

### Vault Updates
- **Mark checkboxes** as tasks complete: `- [ ]` → `- [x]`
- **Update status** in ROADMAP.md after each wave
- **Log blockers/discoveries** in playbook Implementation Notes

### Reusable Patterns

| Pattern | Location | Use For |
|---------|----------|---------|
| **PointerColors** | `lib/theme/app_theme.dart` | Theme-aware color system (dark/light/highContrast/oled variants) |
| **context.colors** | Extension in app_theme.dart | Access PointerColors from context (e.g., `context.colors.background`, `context.colors.textPrimary`, `context.colors.primary`) |
| **GlassCard** | `lib/widgets/glass_card.dart` | iOS-style glassmorphism cards with intensity levels (light/standard/heavy), high contrast support |
| **GlassButton** | `lib/widgets/glass_card.dart` | Glass buttons (primary/secondary variants, loading states) |
| **GlassIntensity** | `lib/widgets/glass_card.dart` | Enum for glass blur intensity (light/standard/heavy) |
| **AppTextStyles** | `lib/theme/app_theme.dart` | Typography |
| **Riverpod Providers** | `lib/providers/providers.dart` | State management |
| **Settings Providers** | `lib/providers/settings_providers.dart` | User preferences (zen mode, OLED, accessibility, theme) |
| **Content Providers** | `lib/providers/content_providers.dart` | Content state (round-robin pointings with persisted order/index, favorites, affinity, teaching filters) |
| **Subscription Providers** | `lib/providers/subscription_providers.dart` | Subscription state (RevenueCat, freemium v2 model with unlimited quotes, testing flag kForcePremiumForTesting, widget premium gating) |
| **WidgetService** | `lib/services/widget_service.dart` | Widget premium gating (setPremiumStatus, isPremiumEnabled with kForcePremiumForTesting support, populatePointingsCache with favorite interleaving, clearWidgetData for free users, syncs favorites from SharedPreferences) |
| **GoRouter** | `lib/router.dart` | Navigation |
| **flutter_animate** | Already in pubspec | Animations |
| **AnimatedTransitions** | `lib/widgets/animated_transitions.dart` | StaggeredFadeIn (list items), AnimatedTextSwitcher (text changes), consistent animation durations/curves |
| **TTS Providers** | `lib/providers/providers.dart` | `ttsServiceProvider`, `awsCredentialServiceProvider`, `ttsConfiguredProvider`, `ttsPlaybackStateProvider` |
| **ArticleTTSPlayer** | `lib/widgets/article_tts_player.dart` | Playback controls for article audio |
| **AudioPlayerWidget** | `lib/widgets/audio_player_widget.dart` | Audio pointing player (guided readings, premium-gated) |
| **Usage Tracking** | `lib/providers/providers.dart` | `usageTrackingServiceProvider`, `dailyUsageProvider` for freemium limits |
| **Round-Robin Navigation** | `lib/providers/content_providers.dart` | CurrentPointingNotifier with persisted shuffled order. First launch shuffles all pointing IDs, persists `pointingOrder` + `pointingIndex`. next/previous traverse fixed order with wrap-around. Reshuffles at cycle end (keeps current at index 0 to avoid back-to-back repeat). Guarantees all pointings seen before any repeats. StorageKeys: `pointer_pointing_order`, `pointer_pointing_index`. |
| **PointingSelector** | `lib/services/pointing_selector.dart` | Time-of-day aware pointing selection (TimeContext enum, respects viewed-today tracking, 30% preference for time-specific pointings) - NOTE: Currently unused, replaced by round-robin |
| **AffinityService** | `lib/services/affinity_service.dart` | Tradition preference learning (view/save counts, weighted scoring 3x saves, getTraditionsByPreference()) |
| **StorageService** | `lib/services/storage_service.dart` | SharedPreferences wrapper (StorageKeys constants, AppSettings model with copyWith/toJson/fromJson, pointingOrder/pointingIndex for round-robin, defaults: theme='system', hapticFeedback=true, autoAdvance=false) |
| **SemanticsService Announcements** | `flutter/rendering` | Screen reader announcements: `SemanticsService.sendAnnouncement(View.of(context), message, TextDirection.ltr)` - requires BuildContext for View access (modern API, replaces deprecated announce()) |
| **Accessibility Labels** | Android layouts + Flutter widgets | Android: All interactive widgets require `android:contentDescription` attributes (e.g., "Refresh pointings", "Previous pointing", "Next pointing", "Save to favorites"). Flutter: Semantics widgets should have clear directional hints (e.g., "Swipe up for next pointing, down for previous" not vague "swipe up or down for actions"). Ensures screen reader users understand widget purpose and gesture directions. |
| **Teacher Model & Database** | `lib/models/teacher.dart` + `lib/data/teachers.dart` | Teacher info system (name, bio, dates, tradition, tags), 9 teachers database, getTeacher(name), getPointingsByTeacher(name) |
| **TeacherSheet** | `lib/widgets/teacher_sheet.dart` | Modal bottom sheet for teacher bio (showTeacherSheet(context, teacher), glassmorphism, DraggableScrollableSheet) |
| **InquiryPlayer** | `lib/screens/inquiry_player_screen.dart` | Timed inquiry phases (Setup → Question → FollowUp → Complete), haptic feedback, disableAutoAdvance flag for testing |
| **PointerWidgetProvider** | `android/app/src/main/kotlin/com/dailypointer/PointerWidgetProvider.kt` | Zero-config AdapterViewFlipper widget with prev/next navigation (includes checkAndHandleThemeChange() on each action), 30-min auto-rotation, SharedPreferences position tracking, save button state updates based on favorites, dark/light mode switching via isSystemInDarkMode() and ACTION_CONFIGURATION_CHANGED, theme detection on prev/next ensures widget stays in sync |
| **PointerWidgetService** | `android/app/src/main/kotlin/com/dailypointer/PointerWidgetService.kt` | RemoteViewsFactory for widget data (pointings cache, tradition badges, position indicators, prefetch logic) |
| **Widget Glassmorphism** | `android/app/src/main/res/drawable/widget_card_*.xml` + `layout/widget_stack_item_*.xml` | Enhanced multi-layer glassmorphism cards matching app PointerColors themes (dark: 4 gradient layers #10→#05→#08 FFFFFF diagonal shimmer + #108B5CF6 purple glow + top edge highlight, no visible borders for clean glass effect; light: 4 gradient layers with frosted + warmth radial + reflection, 1dp border), stack item layouts with header/content/teacher attribution |
| **Widget Theme Sync** | `lib/main.dart` + `lib/services/widget_service.dart` + `android/app/src/main/kotlin/com/dailypointer/MainActivity.kt` | Multi-layer theme sync: (1) Flutter-side: PointerApp implements WidgetsBindingObserver to detect app lifecycle (didChangeAppLifecycleState) and system theme changes (didChangePlatformBrightness), calls WidgetService.refreshWidget() on changes. (2) Native-side: MainActivity registers BroadcastReceiver for ACTION_CONFIGURATION_CHANGED, tracks currentNightMode (UI_MODE_NIGHT_MASK), calls PointerWidgetProvider.updateAllWidgets() when system theme changes. Ensures widget theme updates even when app is in background. |
| **Settings Screen Helpers** | `lib/screens/settings_screen.dart` | `_getNotificationCountSummary()`, `_getScheduleTimeSummary()`, `_formatHourShort()` for dynamic notification schedule display |
| **Screenshot Test Setup** | `integration_test/screenshot_test.dart` | UncontrolledProviderScope + mocked SharedPreferences + settle() helper |
| **Golden Test Helpers** | `test/golden/golden_test_helpers.dart` | setupGoldenTests(), goldenTestTheme, createGoldenTestApp(), pumpForGolden(), GoldenDevices |
| **Unit Test Animation Handling** | `test/screens/onboarding_screen_test.dart` | pump(Duration) for continuous animations instead of pumpAndSettle(), AnimatedGradient.disableAnimations flag, ProviderScope overrides, screen size helpers (iPhone 14 Pro Max: 1290x2796, 3.0 DPR to avoid overflow) |
| **Accessibility Testing** | `test/accessibility/voiceover_test.dart` + `accessibility_test.dart` + `scripts/adb_test_helper.sh` | VoiceOver tests: 6 test groups (semantic labels, decorative exclusion, custom actions, focus order, button semantics, screen reader hints), createTestApp() helper with ProviderScope overrides, pump(Duration) for continuous animations. Unit tests verify Semantics widget configuration (SemanticsFlag.isButton, labels, hints). ADB helper provides device-agnostic manual testing via percentage-based coordinates (tap_percent(), swipe_percent(), tap_element("content-desc"), list_elements(), analyze_layout()). UIAutomator integration finds elements by content-desc for reliable interaction. |
| **iOS Simulator Testing** | `scripts/ios_test_helper.sh` | Cross-platform testing parity for iOS: percentage-based coordinates (tap/swipe), accessibility element finding via idb (Facebook's iOS Device Bridge), auto-detects booted simulator UDID, supports common device sizes (iPhone 15/14/SE, iPad Pro variants). Commands: tap_percent(), swipe_percent(), tap_element("label"), find_element("label"), list_elements(), screenshot(), launch_app(), analyze_layout(). Python3 JSON parsing for simctl output and accessibility tree. Requires `brew install idb-companion` for UI interaction. |
| **Responsive Layout (Foldables)** | `lib/screens/home_screen.dart` | Aspect ratio detection for foldables/tablets: `aspectRatio = screenHeight / screenWidth`, `isSquareAspect = aspectRatio < 1.3`. Dynamic spacing: nav bar space 80px for foldables vs 8% of screen height (80-120px) for phones. Card constraints: foldables use 25-40% screen height vs 65% for phones. Use `Expanded` for better vertical space on large screens. Pattern generalizable to other screens requiring responsive layout. |
| **Notification Action Callbacks** | `lib/main.dart` | Global container pattern for notification callbacks: `_globalContainer` stores ProviderContainer reference for `notificationActionCallback()` entry point. Handler supports 'save' (toggle favorites via favoritesProvider) and 'another' (send new notification) actions. Annotated with `@pragma('vm:entry-point')` for background execution. Initialize with `onDidReceiveNotificationResponse` and `onDidReceiveBackgroundNotificationResponse` in FlutterLocalNotificationsPlugin. |
| **Ambient Sound Global Guard** | `lib/main.dart` | Prevent duplicate audio playback during hot reloads: `_globalAmbientSoundPlayed` static flag guards `_playAmbientSound()`. Set to true on first play, persists across widget rebuilds. 500ms delay ensures providers are ready. Check `mounted` before accessing ref. Pattern prevents audio stacking during development and app lifecycle transitions. |

### Anti-Patterns
- ❌ Don't create new files when existing ones can be extended
- ❌ Don't hardcode colors - use `context.colors` to access PointerColors theme system
- ❌ Don't skip tests
- ❌ Don't commit without verifying build

## Reference Docs

- `/DESIGN_SYSTEM.md` - Full design specifications
- `/EXECUTION_PLAN.md` - Implementation roadmap and product decisions
- `/PRFAQ.md` - Product vision and FAQ
- `/docs/PLAY_STORE_RELEASE.md` - Play Store release checklist (signing, legal docs, store assets, Play Console setup)
- `/docs/PRIVACY_POLICY.md` - Privacy policy (local-first, RevenueCat/AWS Polly data sharing, effective Jan 2 2025)
- `/docs/TERMS_OF_SERVICE.md` - Terms of service (lifetime purchase, content disclaimer, CA law, effective Jan 2 2025)
- `${vault_path}/ROADMAP.md` - Feature roadmap with priorities
- `${vault_path}/IMPLEMENTATION_PLAYBOOK.md` - Orchestrator execution guide
