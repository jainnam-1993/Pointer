# Architecture Refactoring Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Eliminate ~2,000 lines of dead code, ~1,500 lines of duplication, fix widget/performance/data bugs, unify DI/navigation/theme patterns, and migrate 880KB of inline data to JSON assets across 4 risk-ordered waves.

**Architecture:** Risk-ordered phased refactoring. Each wave is independently shippable. Wave 1 (zero risk cleanup) builds confidence before Wave 2 (deduplication), Wave 3 (pattern unification + performance + bug fixes), and Wave 4 (data migration).

**Tech Stack:** Flutter 3.x, Dart 3.10, Riverpod 2.5, GoRouter 14.x, Android Kotlin (widget), iOS Swift (widget)

**Design Doc:** `docs/plans/2026-03-28-architecture-refactoring-design.md`

---

## Wave 1: Cleanup (Zero Risk)

### Task 1.1: Delete TTS Dead Code (4 files, ~930 lines)

**Files:**
- Delete: `lib/services/tts_service.dart`
- Delete: `lib/services/aws_credential_service.dart`
- Delete: `lib/widgets/article_tts_player.dart`
- Delete: `lib/providers/tts_providers.dart`
- Modify: `lib/providers/providers.dart:24` (remove tts_providers export)
- Modify: `lib/screens/article_reader_screen.dart:37-41,76,119-120,129`
- Modify: `lib/screens/library_screen.dart:25`
- Modify: `lib/screens/settings_screen.dart:272-273,507-510`

**Step 1: Delete the 4 TTS files**

```bash
rm lib/services/tts_service.dart
rm lib/services/aws_credential_service.dart
rm lib/widgets/article_tts_player.dart
rm lib/providers/tts_providers.dart
```

**Step 2: Remove barrel export**

In `lib/providers/providers.dart`, delete line 24:
```dart
export 'tts_providers.dart';
```

**Step 3: Clean TTS references in screens**

In `lib/screens/article_reader_screen.dart`:
- Delete lines 37-41 (`_showTTSPlayer`, `_ttsConfigured` fields and comments)
- Delete line 76 (`// TTS disabled` comment)
- Delete lines 119-120 (TODO comment)
- Delete line 129 (`if (_showTTSPlayer)` conditional)

In `lib/screens/library_screen.dart`:
- Delete line 25 (commented import)

In `lib/screens/settings_screen.dart`:
- Delete lines 272-273, 507-510 (TTS config comments)

**Step 4: Verify build**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```
Expected: 0 errors, all tests pass.

**Step 5: Commit**

```bash
git add -A && git commit -m "chore: delete disabled TTS subsystem (930 lines dead code)"
```

---

### Task 1.2: Delete Unused Services and Providers (~500 lines)

**Files:**
- Delete: `lib/services/pointing_selector.dart`
- Delete: `lib/providers/inquiry_providers.dart`
- Delete: `lib/providers/library_providers.dart`
- Delete: `lib/screens/library/category_articles_screen.dart`
- Modify: `lib/screens/library_screen.dart` (remove category_articles_screen re-export)
- Modify: `lib/screens/library/library_models.dart` (remove categoryInfoMap)
- Modify: `lib/providers/settings_providers.dart:60` (remove fontSizeMultiplierProvider)
- Modify: `test/data/library_model_test.dart` (inline any needed providers from library_providers.dart)
- Modify: `test/screens/inquiry_player_test.dart` (inline any needed providers from inquiry_providers.dart)

**Step 1: Check which test files import the providers being deleted**

```bash
grep -r "library_providers\|inquiry_providers" test/
```

Move any providers needed by tests inline into those test files before deleting.

**Step 2: Delete files**

```bash
rm lib/services/pointing_selector.dart
rm lib/providers/inquiry_providers.dart
rm lib/providers/library_providers.dart
rm lib/screens/library/category_articles_screen.dart
```

**Step 3: Clean up references**

In `lib/screens/library_screen.dart`, remove the re-export of `category_articles_screen.dart`.

In `lib/screens/library/library_models.dart`, delete the `categoryInfoMap` constant (around line 40-46).

In `lib/providers/settings_providers.dart`, delete `fontSizeMultiplierProvider` at line 60.

**Step 4: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 5: Commit**

```bash
git add -A && git commit -m "chore: delete unused PointingSelector, inquiry/library providers, CategoryArticlesScreen"
```

---

### Task 1.3: Delete Unused Widgets (~500 lines)

**Files:**
- Modify: `lib/widgets/animated_transitions.dart` (delete 7 unused classes)
- Modify: `lib/widgets/glass_card.dart` (delete GlassContainer and GlassBottomSheet)

**Step 1: In `lib/widgets/animated_transitions.dart`, delete these classes:**

- `AnimatedTextSwitcher` (starting at line 124)
- `ScaleFadeTransition` (starting at line 175)
- `MorphingCard` (starting at line 231)
- `OpenContainerCard` (starting at line 273)
- `FadeThroughSwitcher` (starting at line 328)
- `SharedAxisSwitcher` (starting at line 356)
- `PulseAnimation` (starting at line 427)

Keep: `AnimationDurations`, `AnimationCurves`, `StaggeredFadeIn`, `CalmPageTransition`, `FadeThroughPage`, `SharedAxisPage`.

**Step 2: In `lib/widgets/glass_card.dart`, delete:**

- `GlassContainer` class (starting at line 403)
- `GlassBottomSheet` class (starting at line 449)
- Associated doc comments referencing them (lines 39-40)

**Step 3: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 4: Commit**

```bash
git add -A && git commit -m "chore: delete 9 unused widget classes (GlassContainer, GlassBottomSheet, 7 transitions)"
```

---

### Task 1.4: Delete Remaining Dead Code (~80 lines)

**Files:**
- Modify: `lib/providers/content_providers.dart:124` (remove unused params from nextPointing)
- Modify: `lib/services/widget_service.dart` (delete 3 unused methods)
- Modify: `lib/services/notification_service.dart` (delete NotificationTime legacy class and methods)
- Modify: `lib/services/usage_tracking_service.dart` (delete unused toJson/fromJson on DailyUsage)

**Step 1: In `lib/providers/content_providers.dart`, change line 124 from:**
```dart
void nextPointing({Tradition? tradition, PointingContext? context}) {
```
**to:**
```dart
void nextPointing() {
```

**Step 2: In `lib/services/widget_service.dart`, delete methods:**
- `getCurrentWidgetPointing()` (line 180)
- `syncScheduleWithNotifications()` (line 202)
- `hasActiveWidgets()` (line 220)

**Step 3: In `lib/services/notification_service.dart`, delete:**
- `NotificationTime` class (starting at line 19)
- `getNotificationTimes()` method
- `saveNotificationTimes()` method
- `_NotificationStorageKeys.notificationTimes` key

**Step 4: In `lib/services/usage_tracking_service.dart`, delete:**
- `DailyUsage.toJson()` (line 22)
- `DailyUsage.fromJson()` (line 24)

**Step 5: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 6: Commit**

```bash
git add -A && git commit -m "chore: delete unused methods, legacy NotificationTime, dead DailyUsage serialization"
```

---

### Task 1.5: Fix Teacher Name Data Bugs

**Files:**
- Modify: `lib/data/teachers.dart:65-66`
- Modify: `lib/data/pointings.dart` (60+ occurrences of "Ashtavakra" to "Ashtavakra Gita")

**Step 1: Fix Pema Chodron diacritics mismatch**

In `lib/data/teachers.dart`, change the map key from `'Pema Chödrön'` to `'Pema Chodron'` (ASCII, matching pointings.dart and teacher_profiles.dart).

**Step 2: Standardize "Ashtavakra" to "Ashtavakra Gita"**

```bash
# Preview changes first
grep -n "teacher: 'Ashtavakra'" lib/data/pointings.dart | head -5
```

In `lib/data/pointings.dart`, replace all `teacher: 'Ashtavakra'` with `teacher: 'Ashtavakra Gita'` where the teacher field is "Ashtavakra" (not already "Ashtavakra Gita").

Also update `lib/data/teachers.dart` key if it says just `'Ashtavakra'`.

**Step 3: Fix checkPermissions fail-open bug**

In `lib/services/notification_service.dart`, line 503, change:
```dart
return true;
```
to:
```dart
return false;
```

**Step 4: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 5: Commit**

```bash
git add -A && git commit -m "fix(data): standardize teacher names (Pema Chodron, Ashtavakra Gita), fail-safe permissions"
```

---

### Task 1.6: Centralize SharedPreferences Keys

**Files:**
- Modify: `lib/services/storage_service.dart:10-40` (add missing keys to StorageKeys)
- Modify: `lib/services/widget_service.dart` (5 hardcoded strings)
- Modify: `lib/router.dart:106` (1 hardcoded string)
- Modify: `lib/services/notification_service.dart:248-254` (replace private keys with StorageKeys)
- Modify: `lib/services/workmanager_service.dart:24-36` (replace duplicate keys with StorageKeys)
- Modify: `lib/services/affinity_service.dart:17-19` (add pointer_ prefix, migration read)
- Modify: `lib/services/usage_tracking_service.dart:46` (move key to StorageKeys)
- Modify: `lib/services/share_service.dart:70,101` (move keys to StorageKeys)

**Step 1: Add all missing keys to `StorageKeys` in `lib/services/storage_service.dart`**

Add these constants after the existing ones:
```dart
// Notification keys
static const notificationsEnabled = 'pointer_notifications_enabled';
static const notificationSchedule = 'pointer_notification_schedule';
static const notificationFrequency = 'pointer_notification_frequency';
static const recentNotificationIds = 'pointer_recent_notification_ids';

// Affinity keys (migrated from unprefixed)
static const affinityViewCounts = 'pointer_affinity_view_counts';
static const affinitySaveCounts = 'pointer_affinity_save_counts';
static const affinityLastUpdated = 'pointer_affinity_last_updated';

// Usage keys
static const dailyUsage = 'pointer_daily_usage';

// Share keys
static const shareTemplate = 'pointer_share_template';
static const shareFormat = 'pointer_share_format';

// Widget keys
static const widgetSkipSplash = 'widget_skip_splash';
```

**Step 2: Replace all hardcoded strings**

In `lib/services/widget_service.dart`, add `import` for storage_service.dart, then replace all 5 occurrences of `'pointer_favorites'` with `StorageKeys.favoritePointings`.

In `lib/router.dart:106`, replace `'pointer_onboarding_completed'` with `StorageKeys.onboardingCompleted`. Add import if needed.

In `lib/services/notification_service.dart`, replace `_NotificationStorageKeys` references with `StorageKeys.*`. Delete the `_NotificationStorageKeys` class.

In `lib/services/workmanager_service.dart`, replace `_NotificationKeys` references with `StorageKeys.*`. Delete the `_NotificationKeys` class.

In `lib/services/share_service.dart`, replace hardcoded key strings with `StorageKeys.shareTemplate` and `StorageKeys.shareFormat`.

In `lib/services/usage_tracking_service.dart`, replace hardcoded key with `StorageKeys.dailyUsage`.

**Step 3: AffinityService key migration**

In `lib/services/affinity_service.dart`, update keys to use `StorageKeys.*` and add migration logic to read from old unprefixed keys on first access:

```dart
Future<Map<String, int>> _loadCounts(String newKey, String oldKey) async {
  var data = _prefs.getString(newKey);
  if (data == null) {
    // Migration: read from old unprefixed key
    data = _prefs.getString(oldKey);
    if (data != null) {
      await _prefs.setString(newKey, data);
      await _prefs.remove(oldKey);
    }
  }
  // ... parse as before
}
```

**Step 4: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

Verify no remaining hardcoded SharedPreferences strings:
```bash
grep -rn "'pointer_" lib/services/ lib/providers/ lib/router.dart | grep -v StorageKeys | grep -v "import\|//"
```
Expected: 0 results (all migrated to StorageKeys).

**Step 5: Commit**

```bash
git add -A && git commit -m "refactor: centralize all SharedPreferences keys in StorageKeys, migrate affinity keys"
```

---

### Task 1.7: Housekeeping Renames

**Files:**
- Rename: `lib/providers/subscription_providers.dart` → `lib/providers/usage_providers.dart`
- Modify: `lib/providers/providers.dart` (update export)
- Move: `lib/services/maestro_hooks.dart` → `lib/debug/maestro_hooks.dart`
- Update all imports referencing these files

**Step 1: Rename subscription_providers**

```bash
mv lib/providers/subscription_providers.dart lib/providers/usage_providers.dart
```

Update `lib/providers/providers.dart` export from `subscription_providers.dart` to `usage_providers.dart`.

Search and update all imports:
```bash
grep -rn "subscription_providers" lib/ test/
```

**Step 2: Move maestro_hooks**

```bash
mkdir -p lib/debug
mv lib/services/maestro_hooks.dart lib/debug/maestro_hooks.dart
```

Update all imports:
```bash
grep -rn "maestro_hooks" lib/ test/
```

**Step 3: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 4: Commit**

```bash
git add -A && git commit -m "chore: rename subscription_providers→usage_providers, move MaestroHooks to lib/debug/"
```

---

### Task 1.8: Wave 1 Final Verification

**Step 1: Full build verification**

```bash
flutter clean && flutter pub get
flutter analyze --no-pub
flutter test --concurrency=8
flutter build apk --debug
```

**Step 2: Verify line count reduction**

```bash
find lib/ -name '*.dart' | xargs wc -l | tail -1
```

Compare to pre-wave-1 count. Expected reduction: ~2,000 lines.

**Step 3: Commit any fixups, then tag**

```bash
git tag wave-1-cleanup
```

---

## Wave 2: Deduplicate (Low Risk)

### Task 2.1: Extract Shared Utilities

**Files:**
- Create: `lib/utils/formatting.dart`
- Modify: `lib/widgets/article_tts_player.dart` (deleted in Wave 1, skip)
- Modify: `lib/widgets/audio_player_widget.dart` (replace _formatDuration)
- Modify: `lib/widgets/video_player_widget.dart` (replace _formatDuration)
- Modify: `lib/widgets/share_templates/share_card.dart` (replace 3x _calculateFontSize)
- Modify: `lib/widgets/onboarding_animations.dart` (replace 5x _shouldReduceMotion)

**Step 1: Create `lib/utils/formatting.dart`**

```dart
/// Formats a Duration as MM:SS (e.g., 3:42, 65:02).
String formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours > 0) {
    return '${duration.inHours}:$minutes:$seconds';
  }
  return '${duration.inMinutes}:$seconds';
}

/// Calculates font size for share cards based on content length.
double calculateShareFontSize(int charCount) {
  if (charCount < 100) return 24;
  if (charCount < 200) return 20;
  if (charCount < 400) return 16;
  return 14;
}
```

**Step 2: Replace all usages**

In `lib/widgets/audio_player_widget.dart` and `lib/widgets/video_player_widget.dart`:
- Add `import '../utils/formatting.dart';`
- Delete private `_formatDuration` methods
- Replace calls with `formatDuration(duration)`

In `lib/widgets/share_templates/share_card.dart`:
- Add `import '../../utils/formatting.dart';`
- Delete all three `_calculateFontSize` methods
- Replace calls with `calculateShareFontSize(text.length)`

In `lib/widgets/onboarding_animations.dart`:
- Replace 5 private `_shouldReduceMotion` getters with the centralized `shouldReduceMotion(context)` from `lib/providers/settings_providers.dart`
- This also picks up the app-level animation override that the private getters were ignoring

**Step 3: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 4: Commit**

```bash
git add -A && git commit -m "refactor: extract shared formatDuration, calculateShareFontSize, unify shouldReduceMotion"
```

---

### Task 2.2: Extract PointerScaffold and PointerBackAppBar

**Files:**
- Create: `lib/widgets/pointer_scaffold.dart`
- Modify: All 14 screen files that use `Scaffold > Stack > AnimatedGradient` pattern

**Step 1: Create `lib/widgets/pointer_scaffold.dart`**

```dart
import 'package:flutter/material.dart';
import 'animated_gradient.dart';

class PointerScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  const PointerScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedGradient()),
          SafeArea(child: body),
        ],
      ),
    );
  }
}
```

**Step 2: Create `PointerBackAppBar` SliverAppBar wrapper**

Add to the same file or a new `lib/widgets/pointer_app_bar.dart`:

```dart
class PointerBackAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const PointerBackAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: colors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: colors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          if (subtitle != null)
            Text(subtitle!, style: TextStyle(color: colors.textSecondary, fontSize: 14)),
        ],
      ),
      actions: actions,
    );
  }
}
```

**Step 3: Replace boilerplate in all 14 screens**

Replace the `Scaffold > Stack > [Positioned.fill(AnimatedGradient()), SafeArea > ...]` pattern with `PointerScaffold(body: ...)`. Replace hand-built back-button app bars with `PointerBackAppBar(title: ...)`.

Work through each screen one at a time. Verify after each:
```bash
flutter analyze --no-pub
```

**Step 4: Verify all tests + update goldens**

```bash
flutter test --concurrency=8
flutter test --update-goldens
```

**Step 5: Commit**

```bash
git add -A && git commit -m "refactor: extract PointerScaffold and PointerBackAppBar, replace 14 screen boilerplate"
```

---

### Task 2.3: Extract Shared Widgets (PointerSwitch, TraditionBadge, DragHandle, EmptyState, showSharePreview)

**Files:**
- Create: `lib/widgets/pointer_switch.dart`
- Modify: `lib/widgets/tradition_badge.dart` (add variant parameter)
- Create: `lib/widgets/drag_handle.dart`
- Create: `lib/widgets/empty_state.dart`
- Create or modify: `lib/widgets/share_preview_helper.dart` (showSharePreview function)
- Modify: 4 settings files (switch), 4 tradition badge sites, 3 drag handle sites, 4+ empty states, 4 share preview sites

This task is large. Work through each widget one at a time, following TDD: write a simple widget test if one does not exist, extract the widget, replace all call sites, verify.

**Step 1-5: Extract each widget, replace call sites, verify after each.**

**Step 6: Commit**

```bash
git add -A && git commit -m "refactor: extract PointerSwitch, TraditionBadge variants, DragHandle, EmptyState, showSharePreview"
```

---

### Task 2.4: Unify Teaching Detail Screens

**Files:**
- Create: `lib/screens/library/teaching_detail_screen.dart`
- Modify: `lib/screens/library/teacher_teachings_screen.dart` (thin wrapper)
- Modify: `lib/screens/library/lineage_teachings_screen.dart` (thin wrapper)
- Modify: `lib/screens/library/mood_teachings_screen.dart` (thin wrapper)
- Modify: `lib/screens/library/topic_teachings_screen.dart` (thin wrapper)

**Step 1: Create the unified `TeachingDetailScreen`**

Extract the common pattern from all 4 screens into one screen that accepts:
```dart
class TeachingDetailScreen extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? descriptionWidget;
  final List<Article> articles;
  final List<Teaching> teachings;
  final ContentFilter filter;
  // ...
}
```

The build method contains: CustomScrollView with PointerBackAppBar, articles SliverList, quotes SliverList with StaggeredFadeIn, viewed-status tracking, share sheet invocation.

**Step 2: Convert each existing screen to a thin wrapper**

Each screen file shrinks to ~20-30 lines: a StatelessWidget that gathers its data and delegates to `TeachingDetailScreen`.

**Step 3: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 4: Commit**

```bash
git add -A && git commit -m "refactor: unify 4 teaching detail screens into parameterized TeachingDetailScreen"
```

---

### Task 2.5: Consolidate FavoritesNotifier, Share Card Templates, Home Screen Handlers

**Files:**
- Modify: `lib/providers/content_providers.dart` (generic FavoritesNotifier)
- Modify: `lib/widgets/share_templates/share_card.dart` (single parameterized template)
- Modify: `lib/screens/home_screen.dart` (extract _advancePointing)

**Step 1: Replace `FavoritesNotifier` + `ArticleFavoritesNotifier` with generic**

```dart
class FavoritesNotifier extends StateNotifier<List<String>> {
  final List<String> Function() _load;
  final Future<void> Function(String) _add;
  final Future<void> Function(String) _remove;

  FavoritesNotifier({
    required List<String> Function() load,
    required Future<void> Function(String) add,
    required Future<void> Function(String) remove,
  }) : _load = load, _add = add, _remove = remove, super(load());

  bool isFavorite(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    if (state.contains(id)) {
      state = state.where((e) => e != id).toList();
      await _remove(id);
    } else {
      state = [...state, id];
      await _add(id);
    }
  }
}
```

Update `favoritesProvider` and `articleFavoritesProvider` to use this single class with different storage callbacks.

**Step 2: Consolidate 3 share card templates into parameterized `_ShareTemplate`**

**Step 3: Extract `_advancePointing({bool withHaptic})` in home_screen.dart**

**Step 4: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
```

**Step 5: Commit**

```bash
git add -A && git commit -m "refactor: generic FavoritesNotifier, parameterized share templates, deduplicate advance handlers"
```

---

### Task 2.6: Split Overgrown Files and Consolidate Library Browse Lists

**Files:**
- Modify: `lib/screens/library_screen.dart` (extract widgets, shared browse list builder)
- Create: `lib/screens/library/library_browse_card.dart`
- Create: `lib/screens/library/library_featured_card.dart`
- Split: `lib/widgets/onboarding_animations.dart` → `lib/widgets/onboarding/` (5 files)
- Modify: `lib/screens/home_screen.dart` (extract _SourceCitation)

**Step 1: Extract browse list builder and cards from library_screen.dart**

Create shared `_buildBrowseList(List<BrowseItem> items, ...)` method. Extract `_BrowseCard` and `_FeaturedArticleCard` to separate files.

**Step 2: Split onboarding_animations.dart**

```bash
mkdir -p lib/widgets/onboarding
```

Create one file per widget:
- `lib/widgets/onboarding/typewriter_text.dart`
- `lib/widgets/onboarding/dissolve_transition.dart`
- `lib/widgets/onboarding/strike_through_reveal.dart`
- `lib/widgets/onboarding/notification_simulation.dart`
- `lib/widgets/onboarding/breathing_glow.dart`

Create barrel: `lib/widgets/onboarding/onboarding_animations.dart` re-exporting all.

**Step 3: Extract _SourceCitation from home_screen.dart**

Move `_SourceCitation`, `_SourceMatch` sealed class hierarchy to `lib/widgets/source_citation.dart`.

**Step 4: Verify**

```bash
flutter analyze --no-pub
flutter test --concurrency=8
flutter test --update-goldens
```

**Step 5: Commit**

```bash
git add -A && git commit -m "refactor: split library_screen (1003→~400 lines), onboarding_animations, home_screen"
```

---

### Task 2.7: Wave 2 Final Verification

```bash
flutter clean && flutter pub get
flutter analyze --no-pub
flutter test --concurrency=8
flutter build apk --debug
git tag wave-2-deduplicate
```

---

## Wave 3: Unify Patterns + Performance + Bug Fixes (Medium Risk)

### Task 3.1: Standardize DI (WidgetService, WorkManagerService, AmbientSoundService, AudioPointingService)

Convert static/singleton services to instance-based with Riverpod providers. Follow the `DonationService` pattern: constructor injection, no static state, expose via provider.

**For each service:**
1. Convert static methods to instance methods
2. Inject dependencies via constructor
3. Create Riverpod provider
4. Update all call sites to use `ref.read(provider)` instead of `ClassName.staticMethod()`
5. Keep top-level background callbacks (widgetBackgroundCallback, callbackDispatcher) as standalone functions that create their own SharedPreferences (they run in isolates without Riverpod)

**Verify after each service conversion:**
```bash
flutter analyze --no-pub && flutter test --concurrency=8
```

**Commit after each service:**
```bash
git commit -m "refactor(di): convert {ServiceName} from static/singleton to injectable"
```

---

### Task 3.2: Fix Derived Provider Correctness

**Files:**
- Modify: `lib/providers/settings_providers.dart` (zenMode, oledMode, highContrast)
- Modify: `lib/providers/core_providers.dart` (onboardingCompleted)
- Modify: all call sites that set these providers directly

Change `StateProvider<bool>` to read-only `Provider<bool>`:
```dart
final zenModeProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).zenMode;
});
```

Find and update all call sites that do `ref.read(zenModeProvider.notifier).state = X` to use `ref.read(settingsProvider.notifier).setZenMode(X)` instead.

```bash
grep -rn "zenModeProvider.notifier\|oledModeProvider.notifier\|highContrastProvider.notifier\|onboardingCompletedProvider.notifier" lib/
```

**Verify and commit:**
```bash
flutter analyze --no-pub && flutter test --concurrency=8
git commit -m "fix: make derived providers read-only, mutations go through SettingsNotifier only"
```

---

### Task 3.3: Consolidate Navigation to GoRouter

**Files:**
- Modify: `lib/router.dart` (add /article/:id route)
- Modify: `lib/screens/article_reader_screen.dart` (accept articleId, look up)
- Modify: 11 call sites using Navigator.push for articles

**Step 1: Add route to router.dart**

```dart
GoRoute(
  path: '/article/:id',
  pageBuilder: (context, state) {
    final articleId = state.pathParameters['id']!;
    return CalmPageTransition(
      key: state.pageKey,
      child: ArticleReaderScreen(articleId: articleId),
    );
  },
),
```

**Step 2: Update ArticleReaderScreen to accept articleId and look up article**

**Step 3: Replace all 11 Navigator.push sites**

```bash
grep -rn "Navigator.*ArticleReaderScreen\|Navigator.of.*push.*ArticleReader" lib/
```

Replace each with `context.push('/article/${article.id}')`.

**Step 4: Verify**

```bash
flutter analyze --no-pub && flutter test --concurrency=8
```

**Step 5: Commit**

```bash
git commit -m "refactor(nav): consolidate ArticleReaderScreen to GoRouter, replace 11 Navigator.push sites"
```

---

### Task 3.4: Adopt AppSpacing Theme System

Mechanical find-and-replace across all widgets and screens. Replace hardcoded `EdgeInsets` values with `AppSpacing` constants. Replace hardcoded `BorderRadius.circular(24)` with `AppSpacing.radiusCard`.

Merge `TraditionColors` (share_card.dart) with `TraditionAccentColors` (app_theme.dart). Replace hardcoded colors in notification_preview.dart with PointerColors semantics.

**Verify and commit:**
```bash
flutter test --update-goldens
git commit -m "refactor(theme): adopt AppSpacing constants, merge TraditionColors, semantic notification colors"
```

---

### Task 3.5: Standardize Error Handling

Audit all 37 try/catch blocks. Replace `catch (e) { debugPrint(e); }` with proper error propagation or state-based error reporting (the DonationNotifier pattern).

Create `lib/utils/error_helpers.dart`:
```dart
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );
}
```

**Commit:**
```bash
git commit -m "refactor: standardize error handling, add showErrorSnackBar, propagate service errors"
```

---

### Task 3.6: Move Misplaced Code

Move models, enums, and helper functions to their correct locations per the design doc. Update all imports.

| What | From | To |
|------|------|-----|
| Tradition, PointingContext, TraditionInfo | pointings.dart | models/tradition.dart |
| AppSettings | storage_service.dart | models/app_settings.dart |
| InquirySession + data | inquiry_screen.dart | models/ + data/ |
| shouldReduceMotion, isHighContrastEnabled | settings_providers.dart | theme/accessibility_helpers.dart |
| TopicTags, MoodTags | teaching.dart | data/tags.dart |

**Commit after each move:**
```bash
git commit -m "refactor: move {what} from {from} to {to}"
```

---

### Task 3.7: Consolidate Audio Player

Extract shared `AudioPlayerService` base class. `AudioPointingService` extends it.

**Commit:**
```bash
git commit -m "refactor: extract AudioPlayerService base class, AudioPointingService extends"
```

---

### Task 3.8: Performance: 120Hz Scroll

**Step 1: Enable input resampling (1 line)**

In `lib/main.dart`, after `WidgetsFlutterBinding.ensureInitialized()`:
```dart
GestureBinding.instance.resamplingEnabled = true;
```

**Step 2: Add GlassCardVariant.solid for scrollable lists**

In `lib/widgets/glass_card.dart`, add a `variant` parameter. When `GlassCardVariant.solid`, skip BackdropFilter entirely and use a semi-transparent Container with subtle border instead.

Update all scrollable list items (library browse cards, saved pointings, teaching lists) to use `.solid`.

**Step 3: Pause off-screen AnimatedGradient shimmers**

In `PointerScaffold`, wrap AnimatedGradient in `TickerMode(enabled: isActiveTab)` where `isActiveTab` is passed down from `MainShell`.

**Step 4: Move SystemChrome out of build**

In `lib/main.dart`, move `SystemChrome.setSystemUIOverlayStyle` from the `builder` callback to `initState` and theme-change listener.

**Step 5: Verify on device with Flutter DevTools**

```bash
flutter run --profile
```
Open DevTools, check GPU frame times during library scroll. Target: <8.33ms per frame.

**Commit:**
```bash
git commit -m "perf: GlassCardVariant.solid for scroll lists, 120Hz resampling, pause off-screen shimmers"
```

---

### Task 3.9: Shimmer Lightweight Alternative

Replace `flutter_animate` `.shimmer()` with `ColorTween` gradient animation.

**In `lib/widgets/animated_gradient.dart`:**
- Replace the `.animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(...)` chain
- Use a single `AnimationController(duration: Duration(seconds: 8))` with `CurvedAnimation`
- Interpolate 2-3 gradient color stops via `ColorTween`
- Repaint gradient `CustomPainter` with interpolated colors
- Add scroll pause: `NotificationListener<ScrollNotification>` pauses the controller during scroll
- Add Zen mode pause: check `zenModeProvider` and pause if active

**Verify on device:** Shimmer should be a subtle, slow color shift. GPU time for the gradient should be <1ms/frame.

**Commit:**
```bash
git commit -m "perf: replace shader shimmer with ColorTween gradient animation, add scroll/zen pause"
```

---

### Task 3.10: Widget Launch Splash Race Condition Fix

**Files:**
- Modify: `lib/main.dart:121-165` (buffer deep-links until init complete)
- Modify: `lib/router.dart:125-130` (remove widget_skip_splash)
- Modify: `lib/screens/splash_screen.dart` (navigate to buffered destination)
- Modify: `android/.../MainActivity.kt:72-75` (remove flag write)

**Step 1: Buffer widget deep-links in main.dart**

In `_setupWidgetDeepLink()`, store the incoming URI in a `Completer` or `ValueNotifier` instead of immediately calling `router.go('/')`. Only navigate after `AppInitializer` signals completion.

**Step 2: Remove `widget_skip_splash` flag**

Delete the flag write in `MainActivity.kt:72-75`. Delete the flag read in `router.dart:125-130`.

**Step 3: Splash navigates to buffered destination**

`SplashScreen.onComplete` reads the buffered deep-link and navigates there, or defaults to `/`.

**Step 4: Build and test on device**

```bash
flutter build apk --debug && adb install build/app/outputs/flutter-apk/app-debug.apk
```

Kill app, tap widget, verify splash plays then lands on correct pointing.

**Commit:**
```bash
git commit -m "fix: widget launch shows splash, buffer deep-links until init complete"
```

---

### Task 3.11: Widget Interaction Bug Fixes

**Files:**
- Modify: `android/.../pointer_widget.xml` and `pointer_widget_light.xml` (remove autoStart)
- Modify: `android/.../PointerWidgetProvider.kt` (debounce, single auto-advance)
- Modify: `lib/screens/home_screen.dart` (fix _isAnimating race)
- Modify: `ios/PointerWidget/WidgetIntents.swift` (debounce index increment)

**Step 1: Remove dual auto-advance**

In both widget XML layouts, change `android:autoStart="true"` to `android:autoStart="false"`.

**Step 2: Add debounce to Android widget**

In `PointerWidgetProvider.kt` `onReceive`, add timestamp-based debounce (500ms) for ACTION_PREV/ACTION_NEXT.

**Step 3: Fix Flutter _isAnimating race**

In `home_screen.dart`, move `setState(() => _isAnimating = true)` to the first line of `_handleNext()`, before `nextPointing()` call.

**Step 4: Add iOS debounce**

In `WidgetIntents.swift`, add UserDefaults timestamp guard on index increment.

**Step 5: Build and test on device**

Research official Android docs for AdapterViewFlipper touch handling before attempting code-level workarounds for Bug 1 (inconsistent taps).

**Commit:**
```bash
git commit -m "fix(widget): remove dual auto-advance, add debounce, fix isAnimating race"
```

---

### Task 3.12: Zen Mode Everywhere + Reading Focus

**Files:**
- Modify: `lib/widgets/pointer_scaffold.dart` (add Zen toggle)
- Modify: `lib/screens/article_reader_screen.dart` (reading focus in Zen mode)
- Modify: `lib/widgets/animated_gradient.dart` (respect Zen mode)

**Step 1: Add Zen toggle to PointerScaffold**

Small icon button in top-right corner. Tapping toggles `settingsProvider.notifier.setZenMode()`. Icon: subtle moon/circle.

**Step 2: Article reader Zen mode**

When `zenModeProvider` is true: AnimatedGradient pauses (static), FloatingParticles hidden, no breathing animations.

**Step 3: Verify**

```bash
flutter test --concurrency=8
```

**Commit:**
```bash
git commit -m "feat: Zen mode toggle on every screen, reading focus mode on article reader"
```

---

### Task 3.13: Configurable Auto-Advance Cadence

**Files:**
- Modify: `lib/models/app_settings.dart` (add autoAdvanceInterval field)
- Modify: `lib/providers/settings_providers.dart` (expose interval)
- Modify: `lib/screens/settings/experience_section.dart` (add picker)
- Modify: `lib/screens/home_screen.dart` (read interval from settings)

**Step 1: Add `autoAdvanceSeconds` to AppSettings**

Default: 90. Options: 30, 60, 90, 120, 300.

**Step 2: Add picker in Experience section of Settings**

**Step 3: Home screen reads from settings instead of hardcoded Duration**

**Step 4: Verify**

```bash
flutter test --concurrency=8
```

**Commit:**
```bash
git commit -m "feat: configurable auto-advance cadence (30s/60s/90s/2m/5m), default 90s"
```

---

### Task 3.14: Wave 3 Final Verification

```bash
flutter clean && flutter pub get
flutter analyze --no-pub
flutter test --concurrency=8
flutter test --update-goldens
flutter build apk --debug
```

Test on device: scroll library, verify smooth 120Hz. Tap widget, verify splash. Test Zen mode on every screen. Test auto-advance cadence change.

```bash
git tag wave-3-unify-perform-fix
```

---

## Wave 4: Data Migration (Medium-High Risk)

### Task 4.1: Create Migration Script and Extract Pointings to JSON

**Files:**
- Create: `tools/export_pointings.dart` (one-time migration script)
- Create: `assets/data/pointings.json`
- Modify: `lib/data/pointings.dart` (shrink to model + loader + query helpers)
- Modify: `pubspec.yaml` (register assets)

**Step 1: Write migration script**

A Dart script that imports the current const list and writes it as JSON:
```bash
dart run tools/export_pointings.dart
```

**Step 2: Update pointings.dart**

Replace the const list with a loader:
```dart
late List<Pointing> allPointings;
late Map<String, Pointing> _byId;
late Map<Tradition, List<Pointing>> _byTradition;
// etc.

Future<void> loadPointings() async {
  final json = await rootBundle.loadString('assets/data/pointings.json');
  final list = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  allPointings = list.map((e) => Pointing.fromJson(e)).toList();
  _byId = {for (final p in allPointings) p.id: p};
  _byTradition = groupBy(allPointings, (p) => p.tradition);
  // etc.
}
```

**Step 3: Update AppInitializer Phase 5 to call `loadPointings()`**

**Step 4: Register assets in pubspec.yaml**

**Step 5: Update tests** (use `TestWidgetsFlutterBinding` to load assets)

**Step 6: Verify**

```bash
flutter test --concurrency=8
flutter build apk --debug
```

**Commit:**
```bash
git commit -m "refactor(data): migrate pointings to JSON asset with pre-built indexes"
```

---

### Task 4.2: Extract Articles to JSON + Markdown

**Files:**
- Create: `tools/export_articles.dart`
- Create: `assets/data/articles.json` (metadata)
- Create: `assets/articles/{id}.md` (166 files)
- Modify: `lib/data/articles.dart`

Same pattern as 4.1 but with lazy-loading for article body content:
```dart
Future<String> loadArticleContent(String articleId) async {
  return rootBundle.loadString('assets/articles/$articleId.md');
}
```

**Commit:**
```bash
git commit -m "refactor(data): migrate articles to JSON metadata + lazy-loaded Markdown assets"
```

---

### Task 4.3: Extract Teachings, Unify Teachers, Tag Validation

**Files:**
- Create: `assets/data/teachings.json`
- Create: `assets/data/teachers.json` (unified, all 22)
- Modify: `lib/data/teaching.dart` (loader, remove static singleton)
- Modify: `lib/data/teachers.dart` (loader from JSON)
- Delete: `lib/data/teacher_profiles.dart`
- Delete: `lib/models/teacher_profile.dart`
- Modify: `lib/models/teacher.dart` (add optional fields from TeacherProfile)

**Step 1: Merge TeacherProfile fields into Teacher model**

Add optional fields: `imageAsset`, `keyTeachings`, `quote`, `location`, `articleIds`, `pointingIds`.

**Step 2: Create unified teachers.json**

**Step 3: Create teachings.json, convert TeachingRepository to provider-injected**

**Step 4: Add tag validation at article load time**

**Step 5: Delete TeacherProfile model and data file**

**Step 6: Verify**

```bash
flutter test --concurrency=8
flutter build apk --debug
```

**Commit:**
```bash
git commit -m "refactor(data): unify Teacher model, migrate teachings to JSON, add tag validation"
```

---

### Task 4.4: Pre-Built Search Index

**Files:**
- Modify: `lib/data/articles.dart` (replace brute-force searchArticles)

Build inverted index at load time. Replace `searchArticles` with index-based lookup.

**Commit:**
```bash
git commit -m "perf: pre-built inverted search index for articles (title/tags/excerpt)"
```

---

### Task 4.5: Wave 4 Final Verification

```bash
flutter clean && flutter pub get
flutter analyze --no-pub
flutter test --concurrency=8
flutter build apk --release
```

Compare binary size before/after. Run Maestro E2E suite. Manual spot-check: random pointings, articles, teacher lookups.

```bash
git tag wave-4-data-migration
```

---

## Execution Notes

- Each wave can be a separate branch/PR
- Wave 1 tasks can run in parallel (dead code deletion is independent per file group)
- Wave 2 tasks 2.1-2.3 are independent and parallelizable
- Wave 3 tasks have dependencies: 3.1 before 3.5, 3.2 before 3.12, 3.8 before 3.9
- Wave 4 tasks are sequential (each builds on the previous data migration)
- Always run `flutter analyze --no-pub && flutter test --concurrency=8` after each task
- Update golden baselines when UI widgets change (Waves 2, 3)
- Device testing required for Wave 3 tasks 3.8-3.11
