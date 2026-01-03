# Maestro E2E Testing

Cross-platform UI automation for Pointer app (iOS & Android).

## Quick Start

```bash
# Install Maestro (one-time)
curl -Ls "https://get.maestro.mobile.dev" | bash

# Run all flows
maestro test maestro/flows/

# Run specific flow
maestro test maestro/flows/00_smoke_test.yaml
```

## Flows

| Flow | Purpose | Duration |
|------|---------|----------|
| `00_smoke_test.yaml` | Quick health check | ~30s |
| `01_navigation.yaml` | Tab navigation | ~45s |
| `02_onboarding.yaml` | First-time user experience | ~60s |
| `03_freemium_paywall.yaml` | Premium upgrade journey | ~45s |
| `04_home_interactions.yaml` | Swipes, taps, saves | ~45s |
| `05_settings.yaml` | Settings & notifications | ~45s |
| `06_screenshots_all.yaml` | Store screenshot capture | ~90s |
| `07_accessibility_audit.yaml` | Element accessibility check | ~45s |
| `10_widget_test.yaml` | Home screen widget verification | ~60s |

### Widget Test Setup

The `10_widget_test.yaml` flow requires the Pointer widget to be added to the home screen before running:

1. Long-press on home screen
2. Select "Widgets"
3. Find and add the Pointer widget
4. Run the test: `maestro test maestro/flows/10_widget_test.yaml`

**What it catches:**
- Widget showing "Tap to load" empty state (data loading failure)
- Widget cache not being populated by the app
- RemoteViewsService/Factory errors

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

## When to Use

| Scenario | Use |
|----------|-----|
| Black-box E2E testing | ✅ Maestro |
| Cross-platform parity | ✅ Maestro |
| Store screenshot generation | ✅ Maestro |
| State-controlled testing | ❌ Flutter IntegrationTest |
| WCAG compliance verification | ❌ Flutter accessibility tests |
| Visual regression (pixel-perfect) | ❌ Flutter golden tests |

## Migration from Legacy Scripts

The `scripts/adb_test_helper.sh` and `scripts/ios_test_helper.sh` have been deprecated.

| Old Command | New Maestro Equivalent |
|-------------|------------------------|
| `./scripts/adb_test_helper.sh tap 50 50` | `- tapOn: { point: "50%,50%" }` |
| `./scripts/adb_test_helper.sh click "Home"` | `- tapOn: "Home"` |
| `./scripts/adb_test_helper.sh swipe ...` | `- swipe: { direction: UP }` |
| `./scripts/adb_test_helper.sh screenshot` | `- takeScreenshot: "name"` |
| `./scripts/adb_test_helper.sh list` | `maestro hierarchy` |
