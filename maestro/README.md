# Maestro E2E Testing

Cross-platform UI automation for Pointer app (iOS & Android).

## Quick Start

```bash
# Install Maestro (one-time)
curl -Ls "https://get.maestro.mobile.dev" | bash

# Run all flows
maestro test maestro/flows/

# Run specific flow
maestro test maestro/flows/01_navigation.yaml
```

## Flows

### Core Flows (7)

| Flow | Purpose | Duration |
|------|---------|----------|
| `01_navigation.yaml` | Tab navigation + content verification | ~45s |
| `02_onboarding.yaml` | First-time user experience | ~60s |
| `04_home_interactions.yaml` | Swipes, taps, save, share | ~60s |
| `05_settings.yaml` | Settings & developer menu unlock | ~45s |
| `06_screenshots_all.yaml` | Store screenshot capture | ~90s |
| `09_library_content.yaml` | Library browsing & premium gating | ~60s |
| `10_widget_test.yaml` | Home screen widget verification | ~60s |

### Feature Flows (8)

| Flow | Purpose | Duration |
|------|---------|----------|
| `11_zen_mode.yaml` | Distraction-free mode (double-tap) | ~45s |
| `12_save_favorites.yaml` | Long-press save, first-save celebration | ~45s |
| `13_share_preview.yaml` | Share modal, templates, formats | ~60s |
| `14_history.yaml` | View past pointings | ~45s |
| `15_lineages.yaml` | Tradition preferences | ~45s |
| `16_widget_interactions.yaml` | Widget prev/next/save buttons | ~60s |
| `17_theme_switching.yaml` | Dark/Light/OLED theme changes | ~60s |
| `18_notification_config.yaml` | Notification presets & time windows | ~60s |

## Test Philosophy

### Maestro vs Flutter Tests

| Test Type | Maestro | Flutter Integration |
|-----------|---------|---------------------|
| Black-box E2E | ✅ Best | ❌ |
| Cross-platform parity | ✅ Best | ❌ Single platform |
| Native widget testing | ✅ Only option | ❌ Can't test |
| Store screenshots | ✅ Actual device | State-specific only |
| State-controlled testing | ❌ Can't inject state | ✅ Best (Riverpod) |
| WCAG compliance | ❌ Can't verify semantics | ✅ Best |
| Timing-sensitive flows | ❌ Unreliable | ✅ State control |

**Complementary tests in Flutter:**
- `integration_test/app_test.dart` - State-controlled E2E (929 lines, 8 groups)
- `test/accessibility/voiceover_test.dart` - WCAG compliance (369 lines)
- `test/screens/inquiry_player_test.dart` - Phase timing (531 lines)
- `test/golden/` - Visual regression tests

### What Got Removed

These flows were deleted as they duplicated Flutter test coverage:
- `00_smoke_test.yaml` - Redundant with `01_navigation.yaml`
- `03_freemium_paywall.yaml` - Flutter `app_test.dart` group 7 is superior
- `07_accessibility_audit.yaml` - Flutter `voiceover_test.dart` does real verification
- `08_inquiry_session.yaml` - Flutter `inquiry_player_test.dart` handles timing

## Widget Test Setup

The `10_widget_test.yaml` and `16_widget_interactions.yaml` flows require the Pointer widget on home screen:

1. Long-press on home screen
2. Select "Widgets"
3. Find and add the Pointer widget
4. Run: `maestro test maestro/flows/10_widget_test.yaml`

**What it catches:**
- Widget showing "Tap to load" empty state (data loading failure)
- Widget cache not being populated by the app
- RemoteViewsService/Factory errors
- Button navigation failures (prev/next/save)

## Running on Devices

### Android
```bash
# Ensure device/emulator connected
adb devices

# Install app
flutter build apk --debug && adb install build/app/outputs/flutter-apk/app-debug.apk

# Run tests
maestro test maestro/flows/
```

### iOS
```bash
# Ensure simulator booted
xcrun simctl boot "iPhone 15"

# Build and install
flutter build ios --debug --simulator
xcrun simctl install booted build/ios/iphonesimulator/Runner.app

# Run tests
maestro test maestro/flows/
```

## Screenshots

Screenshots are saved to `maestro/screenshots/` directory.

```bash
# Generate store screenshots
maestro test maestro/flows/06_screenshots_all.yaml
ls maestro/screenshots/
```

## CI/CD

GitHub Actions workflow: `.github/workflows/maestro.yml`

- Runs on push to `main` and PRs
- Tests both Android and iOS
- Uploads screenshots as artifacts

## Migration from Legacy Scripts

The `scripts/adb_test_helper.sh` and `scripts/ios_test_helper.sh` have been deprecated.

| Old Command | New Maestro Equivalent |
|-------------|------------------------|
| `./scripts/adb_test_helper.sh tap 50 50` | `- tapOn: { point: "50%,50%" }` |
| `./scripts/adb_test_helper.sh click "Home"` | `- tapOn: "Home"` |
| `./scripts/adb_test_helper.sh swipe ...` | `- swipe: { direction: UP }` |
| `./scripts/adb_test_helper.sh screenshot` | `- takeScreenshot: "name"` |
| `./scripts/adb_test_helper.sh list` | `maestro hierarchy` |
