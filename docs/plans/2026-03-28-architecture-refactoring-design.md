# Architecture Refactoring Design

**Date:** 2026-03-28
**Status:** Approved
**Approach:** Risk-ordered phased refactoring (Quick Wins → Deep Changes)

## Context

Six-agent parallel audit of the Pointer codebase identified 10 major architectural issues across all layers. Additionally, user-reported bugs (widget interaction, scroll jank, splash bypass) and UX requests (Zen mode accessibility, auto-advance cadence, shimmer optimization) were investigated and incorporated.

## Findings Summary

| Metric | Value |
|--------|-------|
| Dead code (confirmed) | ~1,100 lines across 15+ symbols |
| Duplicated code (estimated) | ~1,500 lines reducible |
| Files >500 lines needing splits | 6 files, 4,400 lines total |
| Unused providers | 25+ (entire files + individual) |
| Hardcoded SharedPrefs keys | 20+ raw strings (should use constants) |
| Untested files >200 lines | 8 files, 3,700+ lines |
| GPU blur passes per scroll frame | 7-9 (budget: 1-2) |

## Top 10 Issues

1. **~880KB hard-coded data in Dart source** — pointings.dart (19,222 lines), articles.dart (10,467 lines) compiled into AOT binary
2. **~1,100 lines dead code** — disabled TTS (930 lines), unused PointingSelector (198 lines), dead providers, unused widgets
3. **Four near-identical teaching detail screens** — ~700 lines of 80-90% duplicated code
4. **Three incompatible DI patterns** — constructor injection vs static singletons vs all-static God classes
5. **SharedPreferences key fragmentation** — duplicate keys between notification/workmanager services, 5 hardcoded strings in widget_service
6. **Teacher name mismatches** — "Pema Chodron" vs "Pema Chodroen" causing silent lookup failures
7. **Theme system defined but not adopted** — AppSpacing has zero uses, 45+ hardcoded EdgeInsets
8. **Mixed GoRouter + imperative Navigator** — ArticleReaderScreen pushed via Navigator.push from 11 sites
9. **Silent error swallowing** — 37 try/catch blocks almost all just debugPrint
10. **Pervasive micro-duplication** — _calculateFontSize 3x, _formatDuration 3x, TraditionBadge 4x, switch styling 4x, scaffold boilerplate 14x

---

## Wave 1: Cleanup (Zero Risk)

**Goal:** Delete dead code, fix data bugs, centralize scattered keys. No behavioral changes.

### 1.1 Dead Code Removal (~2,000 lines)

| Target | Lines | Action |
|--------|-------|--------|
| `tts_service.dart` | 387 | Delete |
| `aws_credential_service.dart` | 230 | Delete |
| `article_tts_player.dart` | 270 | Delete |
| `tts_providers.dart` | 49 | Delete, remove from barrel |
| `pointing_selector.dart` | 198 | Delete |
| `inquiry_providers.dart` | 90 | Delete |
| `library_providers.dart` | ~210 | Delete, move test-only providers inline |
| TTS refs in screens | ~20 | Remove `_showTTSPlayer`, `_ttsConfigured`, commented imports |
| Unused in `animated_transitions.dart` | ~300 | Delete MorphingCard, OpenContainerCard, FadeThroughSwitcher, SharedAxisSwitcher, ScaleFadeTransition, PulseAnimation |
| `GlassContainer`, `GlassBottomSheet` | ~100 | Delete |
| `categoryInfoMap` | ~10 | Delete |
| `CategoryArticlesScreen` | ~100 | Delete file |
| `fontSizeMultiplierProvider` | 1 | Delete |
| `nextPointing()` unused params | 1 | Remove tradition and context params |
| 3 unused WidgetService methods | ~40 | Delete |
| `NotificationTime` legacy model | ~30 | Delete |
| `DailyUsage.toJson`/`fromJson` | ~10 | Delete |

### 1.2 Data Bug Fixes

| Bug | Fix |
|-----|-----|
| "Pema Chodroen" in teachers.dart | Rename to "Pema Chodron" |
| "Papaji (H.W.L. Poonja)" in teacher_profiles.dart | Standardize to "Papaji" |
| "Ashtavakra" vs "Ashtavakra Gita" | Standardize to "Ashtavakra Gita" everywhere |
| `checkPermissions` returns true on error | Return false (fail-safe) |

### 1.3 Key Centralization

- Move all scattered SharedPreferences keys into `StorageKeys`
- Replace 5 hardcoded `'pointer_favorites'` in widget_service.dart
- Replace hardcoded `'pointer_onboarding_completed'` in router.dart
- Add `pointer_` prefix to AffinityService keys (with migration read)

### 1.4 Housekeeping

- Rename `subscription_providers.dart` → `usage_providers.dart`
- Move `MaestroHooks` from `lib/services/` → `lib/debug/`

**Deliverable:** One PR. Verify: `flutter test` + `flutter build apk`.

---

## Wave 2: Deduplicate (Low Risk)

**Goal:** Eliminate repeated code by extracting shared abstractions. Same behavior, fewer lines.

### 2.1 Unify Teaching Detail Screens

Replace 4 files (~700 lines) with one `TeachingDetailScreen(title, subtitle, description, articles, teachings, filter)`. Existing screens become thin constructors.

### 2.2 Extract Shared Scaffold and App Bar

- `PointerScaffold` — wraps `Scaffold > Stack > [AnimatedGradient, SafeArea > child]` boilerplate (14 screens)
- `PointerBackAppBar` — custom SliverAppBar with consistent back button and title (7 copies)

### 2.3 Extract Shared Widgets

| Widget | Replaces | Instances |
|--------|----------|-----------|
| `PointerSwitch` | Duplicated switch color computation | 4 |
| `TraditionBadge` with `TraditionBadgeVariant` | 4 separate implementations | 4 |
| `DragHandle` | Manual drag handle pill | 3 |
| `showSharePreview()` | Duplicated showModalBottomSheet | 4 |
| `EmptyStateWidget` | Ad-hoc empty state columns | 4+ |

### 2.4 Extract Shared Utilities

| Function | Replaces |
|----------|----------|
| `formatDuration(Duration)` → `lib/utils/formatting.dart` | 3 inconsistent copies |
| `calculateShareFontSize(int)` | 3 identical copies in share_card.dart |
| `shouldReduceMotion(BuildContext)` — use existing | 5 duplicates in onboarding_animations.dart |

### 2.5 Consolidate Share Card Templates

Refactor 3 templates into single `_ShareTemplate` with `ShareCardStyle` config. ~120 lines reduced.

### 2.6 Deduplicate Home Screen Handlers

Extract `_handleAutoAdvance` + `_handleNext` shared logic into `_advancePointing({bool withHaptic})`.

### 2.7 Consolidate FavoritesNotifier

Single generic `FavoritesNotifier<T>` parameterized with storage callbacks replaces two structural clones.

### 2.8 Consolidate Library Browse Lists

Shared `_buildBrowseList(List<BrowseItem>)` replaces 4 identical `_build*List` methods.

### 2.9 Split Overgrown Files

| File | Lines | Action |
|------|-------|--------|
| `library_screen.dart` | 1,003 | Extract _BrowseCard, _FeaturedArticleCard, dropdowns, filter sheet |
| `onboarding_animations.dart` | 829 | Split into `widgets/onboarding/` per animation |
| `home_screen.dart` | 758 | Extract _SourceCitation hierarchy |
| `notification_service.dart` | 716 | Extract cache serialization and notification building |

**Deliverable:** 1-3 PRs. Update golden baselines.

---

## Wave 3: Unify Patterns + Performance + Bug Fixes (Medium Risk)

**Goal:** Standardize DI, navigation, error handling, theme adoption. Fix widget bugs. Achieve 120Hz scroll. Make Zen mode accessible.

### 3.1 Standardize DI

All services use constructor injection via Riverpod (the DonationService pattern).

| Service | Current | Target |
|---------|---------|--------|
| WidgetService | All-static | Instance, inject SharedPreferences |
| WorkManagerService | All-static | Instance, inject SharedPreferences + NotificationService |
| AmbientSoundService | Static singleton | Remove singleton, provider-only access |
| AudioPointingService | Static singleton | Remove singleton, create provider |
| AppInitializer | All-static | Keep static (runs before Riverpod) |

### 3.2 Fix Derived Provider Correctness

- `zenModeProvider`, `oledModeProvider`, `highContrastProvider`: change from `StateProvider<bool>` → read-only `Provider<bool>` derived from `settingsProvider`
- `onboardingCompletedProvider`: derive from storage, mutate through StorageService only

### 3.3 Consolidate Navigation to GoRouter

- Add `/article/:id` and `/share/:pointingId` routes
- Replace 11 `Navigator.push` call sites with `context.push('/article/${article.id}')`
- ArticleReaderScreen takes `articleId`, looks up via `_articlesById` map (O(1))

### 3.4 Adopt Theme System

- Replace 45+ hardcoded `EdgeInsets` with `AppSpacing` constants
- Merge `TraditionColors` into `TraditionAccentColors` (single source)
- Replace hardcoded colors in `notification_preview.dart` with `PointerColors` semantics
- `TeacherSheet` composes `GlassBottomSheet` instead of reimplementing

### 3.5 Standardize Error Handling

- Services return typed exceptions (no bare `catch (e) { debugPrint }`)
- Providers expose `error` field (like DonationNotifier)
- Shared `showErrorSnackBar(context, message)` for UI errors
- WidgetService propagates errors instead of swallowing

### 3.6 Move Misplaced Code

| What | From | To |
|------|------|-----|
| `Tradition`, `PointingContext`, `TraditionInfo` | pointings.dart | models/tradition.dart |
| `AppSettings` | storage_service.dart | models/app_settings.dart |
| `InquirySession` + data | inquiry_screen.dart | models/ + data/ |
| `shouldReduceMotion()`, `isHighContrastEnabled()` | settings_providers.dart | theme/accessibility_helpers.dart |
| `TopicTags`, `MoodTags` | teaching.dart | data/tags.dart |

### 3.7 Consolidate Audio Player

Extract shared `AudioPlayerService` base class (stream controllers, transport controls, lifecycle). `AudioPointingService` extends it with URL-based loading.

### 3.8 Performance: 120Hz Scroll

Root cause: 7-9 Gaussian blur passes per frame during scroll (budget 8.33ms at 120Hz).

**(a)** `GlassCardVariant.solid` for scrollable list items — semi-transparent fill instead of BackdropFilter. Keep `.frosted` for static/hero cards only. Eliminates 4-6 blur passes per frame.

**(b)** Enable 120Hz input resampling: `GestureBinding.instance.resamplingEnabled = true`

**(c)** Pause off-screen AnimatedGradient shimmers via `TickerMode(enabled: isActiveTab)`

**(d)** Cache/reduce bottom nav bar blur during scroll (sigma 35 → 15, or solid during scroll)

**(e)** Wrap individual FloatingParticles in RepaintBoundary. Pause during scroll.

**(f)** Move `SystemChrome.setSystemUIOverlayStyle` out of build method.

### 3.9 Widget Launch: Splash Race Condition

- Queue widget deep-links until AppInitializer Phase 5 completes
- Show splash during widget cold-start too (remove `widget_skip_splash` flag)
- Splash navigates to buffered destination on complete

### 3.10 Widget Interaction Bug Fixes

- **Inconsistent taps:** Replace AdapterViewFlipper touch handling (research official docs first) or overlay transparent clickable View
- **Card shifts mid-tap:** Remove `android:autoStart="true"`, use only code-level `onUpdate()` advance
- **Loading delay:** Parallelize sequential awaits in `processPendingWidgetActions`, incremental cache updates
- **Ghost taps:** 500ms timestamp debounce in `onReceive`; move `_isAnimating = true` above async work in Flutter; UserDefaults timestamp guard on iOS

### 3.11 Zen Mode Everywhere + Reading Focus

- Persistent Zen toggle in `PointerScaffold` (top-right, subtle icon, every screen)
- Article reader in Zen mode: pause AnimatedGradient shimmer, hide particles, clean reading surface
- No breathing animations on GlassCard in Zen mode

### 3.12 Configurable Auto-Advance Cadence

- Add `autoAdvanceInterval` to AppSettings (persisted)
- Options: 30s / 60s / 90s / 2min / 5min (picker in Settings > Experience)
- Default: 90s
- Timer resets on cadence change

### 3.13 Shimmer: Lightweight Alternative

Replace `flutter_animate` `.shimmer()` shader with `ColorTween` gradient animation:
- Single AnimationController (duration: 8s) interpolating 2-3 color stops
- No shader pass, no compositing layer — just gradient CustomPainter repaint
- Frame skip on `_DeviceTier.low` (15fps)
- Pause during scroll (NotificationListener<ScrollNotification>)
- Pause on article reader in Zen mode

**Deliverable:** Multiple PRs (DI, navigation, theme, performance, widget fixes, Zen mode, settings). Device testing required for 3.8-3.10.

---

## Wave 4: Data Migration (Medium-High Risk)

**Goal:** Move 880KB of hard-coded Dart data to JSON assets. Lazy loading, pre-built indexes, maintainable files.

### 4.1 Pointings → JSON

- `assets/data/pointings.json` — 537 pointings
- `pointings.dart` shrinks to model + loader + query helpers
- Pre-build indexes at load time: `_byTradition`, `_byTeacher`, `_byContext`, `_byId`
- Query helpers become O(1) map lookups

### 4.2 Articles → JSON + Markdown

- `assets/data/articles.json` — metadata only (166 articles)
- `assets/articles/{id}.md` — individual Markdown files, lazy-loaded on demand
- Peak memory drops: 1-2 articles in memory vs all 166

### 4.3 Teachings → JSON

- `assets/data/teachings.json`
- TeachingRepository becomes provider-injected service
- Remove static mutable singleton

### 4.4 Tag Validation at Load Time

- Validate article tags against `TopicTags.all` / `MoodTags.all` on parse
- Debug-only warning for unrecognized tags

### 4.5 Unify Teacher Data

- Single `assets/data/teachers.json` (all 22 teachers)
- Single `Teacher` model (merge TeacherProfile optional fields)
- Delete TeacherProfile and teacher_profiles.dart

### 4.6 Pre-Built Search Index

- Inverted index: `word → Set<articleId>` built at load time
- Index title, subtitle, excerpt, tags (not full body)
- Fall back to body scan only if <3 results

### 4.7 Asset Registration

```yaml
flutter:
  assets:
    - assets/data/
    - assets/articles/
```

**Deliverable:** One large PR. Verify: test suite (with TestWidgetsFlutterBinding asset loading), binary size comparison, Maestro E2E, manual spot-checks.

---

## Known Limitations (Not Code Bugs)

- **Android billing error ("not configured for billing through Google Play"):** Expected behavior on internal testing track. Resolves when app is promoted to closed testing (20+ testers × 14 days).

## Out of Scope

- Backend API (per EXECUTION_PLAN.md roadmap)
- New feature development
- Test coverage expansion (except where refactoring requires test updates)
