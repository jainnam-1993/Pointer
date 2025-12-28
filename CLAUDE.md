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
./scripts/screenshot_test.sh   # Automated screenshot test runner (optional wrapper)
flutter test --update-goldens  # Generate/update golden test baselines
flutter test test/golden/      # Run golden tests (visual regression)

# Build
flutter build apk              # Android APK
flutter build ios              # iOS build
flutter build appbundle        # Android App Bundle (Play Store)

# Utilities
flutter analyze                # Static analysis
flutter pub get                # Install dependencies

# Android Build Notes
# - Kotlin 2.3.0, Android Gradle Plugin 8.13.2
# - Kotlin configuration: kotlin.compilerOptions.jvmTarget (Gradle Plugin 2.x style)
# - android/build.gradle.kts forces compileSdk = 36 for all plugin subprojects
# - Gradle performance: caching + parallel builds enabled
# - Core library desugaring: 2.1.5 (Java 17 compatibility)
```

## Architecture

```
./
├── lib/
│   ├── main.dart              # App entry point, ProviderScope setup
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
│   │   ├── main_shell.dart    # Bottom navigation shell
│   │   ├── home_screen.dart   # Daily pointing display
│   │   ├── inquiry_screen.dart
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
│   │   ├── article_tts_player.dart     # TTS playback controls
│   │   └── audio_player_widget.dart    # Audio pointing player (guided readings)
│   ├── services/
│   │   ├── storage_service.dart            # SharedPreferences wrapper
│   │   ├── notification_service.dart       # Notification scheduling (presets, time windows, quiet hours)
│   │   ├── usage_tracking_service.dart     # Daily pointing limit (freemium)
│   │   ├── widget_service.dart             # Home widget data updates
│   │   ├── revenue_cat_service.dart        # RevenueCat integration (lifetime purchase)
│   │   ├── aws_credential_service.dart     # AWS TOTP authentication
│   │   ├── tts_service.dart                # Text-to-speech via AWS Polly
│   │   ├── affinity_service.dart           # Tradition preference tracking
│   │   ├── pointing_selector.dart          # Time-of-day aware pointing selection
│   │   └── audio_pointing_service.dart     # Audio pointing playback
│   └── data/
│       └── pointings.dart     # Curated pointings across traditions
├── android/
│   └── app/src/main/
│       ├── kotlin/com/pointer/
│       │   └── PointerWidgetProvider.kt        # Home widget provider (refresh/save actions, logging, error handling)
│       └── res/
│           ├── drawable/
│           │   ├── widget_background_modern.xml    # Modern widget white background (28dp radius)
│           │   ├── widget_nav_dot.xml              # Navigation indicator (8dp gray oval)
│           │   ├── widget_rainbow_stripes.xml      # Simple rainbow gradient (purple-cyan-pink)
│           │   └── widget_stripes_gradient.xml     # Layered rainbow gradient
│           ├── layout/
│           │   ├── pointer_widget.xml       # Widget layout dark theme (white text on dark background, refresh/save actions)
│           │   └── pointer_widget_light.xml # Widget layout light theme (dark text on white background, refresh/save actions)
│           └── raw/
│               └── bell_chime.ogg                  # Custom notification sound (OGG, 14KB)
├── test/                      # Unit tests
│   ├── providers/
│   │   └── content_providers_test.dart  # Content providers tests (CurrentPointingNotifier, FavoritesNotifier, TeachingFilterState)
│   ├── services/
│   │   └── notification_service_test.dart  # Notification service tests (Android/iOS channel config, v6 channel)
│   ├── screens/
│   │   └── onboarding_screen_test.dart  # Onboarding widget tests
│   └── golden/
│       ├── components_golden_test.dart   # Component visual regression tests
│       └── golden_test_helpers.dart      # Golden test infrastructure
├── integration_test/
│   ├── screenshot_test.dart        # IntegrationTest screenshot tests (8 testWidgets)
│   └── screenshot_helpers.dart     # Screenshot capture + UX issue tracking
├── scripts/
│   └── screenshot_test.sh          # Automated screenshot test runner
├── patrol.yaml                # Patrol CLI configuration
└── pubspec.yaml               # Dependencies
```

## Development Principles

- **Library Preference**: Strongly prefer pre-built Flutter packages over custom native code. "Think 100 times" before writing platform-specific native implementations.

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
- **Markdown**: flutter_markdown (for content rendering)
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

**PointerWidgetProvider** (`android/app/src/main/kotlin/com/pointer/PointerWidgetProvider.kt`): Android home widget provider with robust error handling. HomeWidgetPlugin.getData() wrapped in try-catch with null safety (elvis operators for fallbacks). Logging pattern: TAG "PointerWidget" with Log.d/Log.e. updateAllWidgets() companion method refreshes all widget instances. Interactive actions: ACTION_REFRESH (immediate widget update + background intent for instant feedback), ACTION_SAVE (add to favorites).

**Riverpod Providers** (`lib/providers/providers.dart`): SharedPreferences instance, router, storage service providers, TTS providers, usage tracking providers.

**Settings Providers** (`lib/providers/settings_providers.dart`): User preferences with persistence via StorageService:
- **State providers**: zenModeProvider, oledModeProvider, fontSizeMultiplierProvider, reduceMotionOverrideProvider, highContrastProvider, themeModeProvider
- **Settings notifier**: SettingsNotifier with copyWith updates (setTheme, setHighContrast, setZenMode)
- **Notification settings**: NotificationSettingsNotifier managing enabled state and notification times
- **Accessibility helpers**: shouldReduceMotion(context, appOverride), isHighContrastEnabled(context, ref)
- **Theme conversion**: AppThemeMode ↔ Flutter ThemeMode

**Content Providers** (`lib/providers/content_providers.dart`): Content state management with affinity learning and filtering:
- **Pointing navigation**: currentPointingProvider (StateNotifier) with 50-item history buffer, nextPointing()/previousPointing()/setPointing(), auto-updates home widget
- **Tradition affinity**: affinityServiceProvider tracks user preferences via view/save counts with weighted scoring (saves = 3x views)
- **Favorites**: favoritesProvider (StateNotifier) with toggle()/isFavorite(), persisted via StorageService
- **Teaching filters**: TeachingFilterNotifier with multi-dimensional filters (lineage, topics Set, moods Set, teacher, type), apply() returns filtered teachings

**Subscription Providers** (`lib/providers/subscription_providers.dart`): Subscription state and freemium enforcement:
- **SubscriptionNotifier**: Manages subscription tier (free/premium) via RevenueCat SDK, offline-first with SharedPreferences caching, mounted checks after async operations
- **DailyUsageNotifier**: Enforces 2 pointings/day limit for free users, auto-resets at midnight, premium bypasses all checks
- **State models**: SubscriptionState (tier, loading, products, error, expirationDate), SubscriptionTier enum (free/premium)
- **Premium features**: Unlimited pointings, TTS audio, audio pointing playback
- **Testing flag**: `kForcePremiumForTesting` constant for development (set to false in production)
- **Integration**: RevenueCatService singleton for purchases, UsageTrackingService for daily limits, StorageService for offline caching

**Data model**: `Pointing` has id, content, instruction, tradition (Advaita/Zen/Direct Path/Contemporary/Original), context (morning/midday/evening/stress/general), teacher, source.

**Notification Scheduling** (`lib/services/notification_service.dart`):
- **NotificationPreset**: Quick presets (Morning, All day, Evening, Minimal) for one-tap configuration
- **NotificationSchedule**: Time window + frequency model (start/end times, frequency in hours, quiet hours support)
- **Schedule calculation**: `getNotificationTimes()` generates notification times within time window
- **Quiet hours**: Supports overnight quiet periods (e.g., 22:00-07:00)
- **Channel**: Uses `pointings_v6` notification channel (Android)
- **Sound**: Custom bell_chime.ogg configured with MAX importance/priority + vibration (debugging Android audio playback)
- **Legacy support**: `NotificationTime` class kept for migration from older fixed-time model

**TTS Integration** (`lib/services/tts_service.dart` + `lib/services/aws_credential_service.dart`):
- **Setup flow**: User enters OTP → API returns TOTP secret → stored securely in keychain
- **Runtime flow**: Generate TOTP from secret → API returns AWS credentials → call Polly API
- **AWS SigV4 signing**: Manual implementation for Polly API authentication
- **Credential caching**: 1-hour cache with 5-min refresh buffer
- **Premium-gated**: TTS requires premium subscription (checked in ArticleReaderScreen)
- **Developer access**: Settings → tap version 7 times → Developer section → TTS Configuration

## Testing

**Unit tests** (`test/`): Cover services, widgets, providers. Use mocktail for mocking.

**Integration tests** (`integration_test/`): E2E flows using patrol framework.

**Screenshot tests** (`integration_test/screenshot_test.dart`): Visual regression using Flutter IntegrationTest framework.

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

## TODOs in Codebase

- Backend API (planned per EXECUTION_PLAN.md)
- Light/Dark mode toggle
- TTS Discoverability: Add visible "Audio & TTS" section in Settings (currently hidden in developer menu)

**Completed:**
- ✓ RevenueCat integration (one-time purchase) - Implemented in `lib/services/revenue_cat_service.dart`
- ✓ Premium tier gating for unlimited pointings - Implemented via `UsageTrackingService` (2 daily limit for free users)
- ✓ Text-to-speech (TTS) - AWS Polly integration for article audio playback

## TTS (Text-to-Speech) Feature

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

## Freemium Model - Daily Usage Limits

Daily pointing view limit for free users (2 per day), enforced via subscription and usage tracking system.

**Architecture:**
- **Subscription management**: `subscription_providers.dart` manages RevenueCat integration and tier state (free/premium)
- **Usage enforcement**: `UsageTrackingService` tracks daily pointing views for free users
- **Limit**: Free users: 2 pointings/day, Premium: unlimited
- **Reset**: Automatic daily reset at midnight (based on device date)
- **Storage**: SharedPreferences (query-string encoded: `viewCount=X&lastResetDate=YYYY-MM-DD`)
- **State**: Managed via `subscriptionProvider` (SubscriptionNotifier) and `dailyUsageProvider` (DailyUsageNotifier)
- **Gating**: Home screen checks `canViewPointing(isPremium)` before showing next pointing
- **Offline-first**: Subscription tier cached locally, RevenueCat syncs when online

**User Flow:**
1. Free user taps "Next" → checks `dailyUsageProvider.canViewPointing(isPremium)`
2. If under limit: Show pointing, increment counter
3. If limit reached: Show paywall with "Upgrade to Premium"
4. Premium users: Bypass all checks (always return true)

**Files:**
- `lib/providers/subscription_providers.dart` - SubscriptionNotifier, DailyUsageNotifier, SubscriptionState models
- `lib/services/revenue_cat_service.dart` - RevenueCat SDK integration, lifetime purchase flow (product: `pointer_premium_lifetime`, test API keys configured)
- `lib/services/usage_tracking_service.dart` - Counter logic, daily reset
- `lib/providers/providers.dart` - Legacy `usageTrackingServiceProvider` (deprecated, use subscription_providers.dart)

**Testing:**
- `test/services/usage_tracking_service_test.dart` - Counter increment, daily reset, limit checks

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
| **Content Providers** | `lib/providers/content_providers.dart` | Content state (pointings, favorites, affinity, teaching filters) |
| **Subscription Providers** | `lib/providers/subscription_providers.dart` | Subscription state (RevenueCat, freemium limits, testing flag kForcePremiumForTesting) |
| **GoRouter** | `lib/router.dart` | Navigation |
| **flutter_animate** | Already in pubspec | Animations |
| **AnimatedTransitions** | `lib/widgets/animated_transitions.dart` | StaggeredFadeIn (list items), AnimatedTextSwitcher (text changes), consistent animation durations/curves |
| **TTS Providers** | `lib/providers/providers.dart` | `ttsServiceProvider`, `awsCredentialServiceProvider`, `ttsConfiguredProvider`, `ttsPlaybackStateProvider` |
| **ArticleTTSPlayer** | `lib/widgets/article_tts_player.dart` | Playback controls for article audio |
| **AudioPlayerWidget** | `lib/widgets/audio_player_widget.dart` | Audio pointing player (guided readings, premium-gated) |
| **Usage Tracking** | `lib/providers/providers.dart` | `usageTrackingServiceProvider`, `dailyUsageProvider` for freemium limits |
| **PointingSelector** | `lib/services/pointing_selector.dart` | Time-of-day aware pointing selection (TimeContext enum, respects viewed-today tracking, 30% preference for time-specific pointings) |
| **AffinityService** | `lib/services/affinity_service.dart` | Tradition preference learning (view/save counts, weighted scoring 3x saves, getTraditionsByPreference()) |
| **StorageService** | `lib/services/storage_service.dart` | SharedPreferences wrapper (StorageKeys constants, AppSettings model with copyWith/toJson/fromJson, defaults: theme='system', hapticFeedback=true, autoAdvance=false) |
| **SemanticsService Announcements** | `flutter/rendering` | Screen reader announcements: `SemanticsService.sendAnnouncement(View.of(context), message, TextDirection.ltr)` - requires BuildContext for View access (modern API, replaces deprecated announce()) |
| **PointerWidgetProvider** | `android/app/src/main/kotlin/com/pointer/PointerWidgetProvider.kt` | Android home widget with error handling (try-catch, null safety), logging (TAG "PointerWidget"), updateAllWidgets() for refresh |
| **Screenshot Test Setup** | `integration_test/screenshot_test.dart` | UncontrolledProviderScope + mocked SharedPreferences + settle() helper |
| **Golden Test Helpers** | `test/golden/golden_test_helpers.dart` | setupGoldenTests(), goldenTestTheme, createGoldenTestApp(), pumpForGolden(), GoldenDevices |

### Anti-Patterns
- ❌ Don't create new files when existing ones can be extended
- ❌ Don't hardcode colors - use `context.colors` to access PointerColors theme system
- ❌ Don't skip tests
- ❌ Don't commit without verifying build

## Reference Docs

- `/DESIGN_SYSTEM.md` - Full design specifications
- `/EXECUTION_PLAN.md` - Implementation roadmap and product decisions
- `/PRFAQ.md` - Product vision and FAQ
- `${vault_path}/ROADMAP.md` - Feature roadmap with priorities
- `${vault_path}/IMPLEMENTATION_PLAYBOOK.md` - Orchestrator execution guide
