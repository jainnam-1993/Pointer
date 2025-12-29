# Play Store Release Checklist

Step-by-step guide to publish Pointer on Google Play Store.

## Current Status

| Item | Status | Notes |
|------|--------|-------|
| Package Name | ✅ | `com.pointer` |
| Version | ✅ | 1.0.0+1 |
| App Icons | ✅ | flutter_launcher_icons configured |
| Adaptive Icons | ✅ | White background + enso foreground |
| Release Signing | ❌ | Using debug keys |
| Privacy Policy | ❌ | Placeholder URL `pointer.app/privacy` |
| Terms of Service | ❌ | Placeholder URL `pointer.app/terms` |
| Store Assets | ❌ | Need feature graphic, screenshots |

---

## Phase 1: Google Play Developer Account

**Dependency: None | Can start immediately**

- [ ] **1.1** Create Google Play Developer account
  - Go to: https://play.google.com/console/signup
  - Cost: $25 one-time fee
  - Use a Google account you'll maintain long-term

- [ ] **1.2** Complete identity verification
  - Provide government ID
  - Wait for approval (~48 hours)

- [ ] **1.3** Set up developer profile
  - Developer name (shown on store): e.g., "Pointer Apps" or your name
  - Contact email (public)
  - Website (optional but recommended)

---

## Phase 2: App Signing Setup

**Dependency: None | Can run parallel with Phase 1**

> **CRITICAL**: Signing config cannot be changed after first upload. Back up your keystore!

- [ ] **2.1** Generate upload keystore
  ```bash
  # Run from project root
  keytool -genkey -v -keystore android/app/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias upload \
    -storepass <YOUR_STORE_PASSWORD> \
    -keypass <YOUR_KEY_PASSWORD>
  ```

- [ ] **2.2** Create `android/key.properties` (DO NOT COMMIT)
  ```properties
  storePassword=<YOUR_STORE_PASSWORD>
  keyPassword=<YOUR_KEY_PASSWORD>
  keyAlias=upload
  storeFile=upload-keystore.jks
  ```

- [ ] **2.3** Add to `.gitignore`
  ```
  android/key.properties
  android/app/upload-keystore.jks
  *.keystore
  *.jks
  ```

- [ ] **2.4** Update `android/app/build.gradle.kts` for release signing

- [ ] **2.5** Create `android/app/proguard-rules.pro`

- [ ] **2.6** Backup keystore securely
  - Store in password manager or encrypted cloud storage
  - **CRITICAL**: If you lose this, you cannot update your app

- [ ] **2.7** Test release build
  ```bash
  flutter build appbundle --release
  ```

---

## Phase 3: Legal Documents

**Dependency: None | Can run parallel with Phase 1-2**

### 3.1 Privacy Policy

- [ ] **3.1.1** Create privacy policy document

  **Data Collected (local only):**
  - App preferences (SharedPreferences)
  - Notification settings
  - Favorites and reading history
  - Usage data (daily pointing views)
  - TTS credentials (device keychain)

  **Data Shared with Third Parties:**
  - RevenueCat: Device ID, purchase history
  - AWS Polly: Text content for TTS (premium only)

  **Data NOT Collected:**
  - Personal info (name, email)
  - Location, contacts, photos

- [ ] **3.1.2** Host privacy policy at accessible URL
  - Options: GitHub Pages, Notion, dedicated site
  - Must be publicly accessible (no login)

- [ ] **3.1.3** Update `lib/screens/paywall_screen.dart` line 368 with real URL

### 3.2 Terms of Service

- [ ] **3.2.1** Create terms document covering:
  - App usage terms
  - Lifetime purchase policy (one-time, no refunds)
  - Content disclaimer
  - Limitation of liability

- [ ] **3.2.2** Host at accessible URL

- [ ] **3.2.3** Update `lib/screens/paywall_screen.dart` line 382 with real URL

---

## Phase 4: Store Listing Assets

**Dependency: None | Can run parallel with Phase 1-3**

### 4.1 Required Graphics

- [ ] **4.1.1** Verify App Icon (512x512 PNG, no transparency)
  ```bash
  sips -g pixelWidth -g pixelHeight assets/icons/enso_icon.png
  ```

- [ ] **4.1.2** Create Feature Graphic (1024x500 PNG)
  - Save to: `docs/store_assets/feature_graphic.png`
  - Design: Ensō symbol + "Pointer" + tagline

- [ ] **4.1.3** Capture Phone Screenshots (min 2, recommend 6)
  - Dimensions: 1080px minimum width
  - Save to: `docs/store_assets/screenshots/`
  - Screens to capture:
    1. Home - daily pointing
    2. Pointing detail with teacher
    3. Lineages view
    4. Library
    5. Settings
    6. Home widget

- [ ] **4.1.4** Capture Tablet Screenshots (optional but recommended)

### 4.2 Store Listing Text

- [ ] **4.2.1** Short Description (80 chars)
  ```
  Daily non-dual pointings from wisdom traditions. Direct path to presence.
  ```

- [ ] **4.2.2** Full Description (4000 chars) - see template below

- [ ] **4.2.3** Select Category: Lifestyle or Health & Fitness

---

## Phase 5: Play Console Configuration

**Dependency: Phase 1 complete (developer account verified)**

### 5.1 Create App

- [ ] **5.1.1** Play Console → Create app
  - Name: Pointer
  - Language: English (US)
  - Type: App (not game)
  - Pricing: Free (with in-app purchases)

### 5.2 Content Rating

- [ ] **5.2.1** Complete IARC questionnaire
  - Expected rating: Everyone (E)

### 5.3 Data Safety Form

- [ ] **5.3.1** Declare data collection:

  | Data Type | Collected | Shared | Purpose |
  |-----------|-----------|--------|---------|
  | Purchase history | Yes | RevenueCat | Functionality |
  | Device identifiers | Yes | RevenueCat | Analytics |
  | App interactions | Yes | No | Functionality |

- [ ] **5.3.2** Confirm: Data encrypted in transit

### 5.4 App Content Declarations

- [ ] **5.4.1** Ads: None
- [ ] **5.4.2** Target audience: General (not for children)
- [ ] **5.4.3** App access: No login required

### 5.5 Store Listing

- [ ] **5.5.1** Upload all assets from Phase 4
- [ ] **5.5.2** Enter descriptions
- [ ] **5.5.3** Link privacy policy URL

---

## Phase 6: Release

**Dependency: Phases 2-5 complete**

### 6.1 Internal Testing (Recommended)

- [ ] **6.1.1** Create internal testing track
- [ ] **6.1.2** Build and upload bundle
  ```bash
  flutter build appbundle --release
  # Output: build/app/outputs/bundle/release/app-release.aab
  ```
- [ ] **6.1.3** Add test emails
- [ ] **6.1.4** Verify install and purchase flow

### 6.2 Production Release

- [ ] **6.2.1** Verify all console sections show green checkmarks
- [ ] **6.2.2** Select release countries (start US, expand later)
- [ ] **6.2.3** Create production release
- [ ] **6.2.4** Upload app bundle
- [ ] **6.2.5** Add release notes
- [ ] **6.2.6** Submit for review (1-3 days typical)

---

## Phase 7: Post-Release

- [ ] **7.1** Monitor review status
- [ ] **7.2** Switch RevenueCat to production mode
- [ ] **7.3** Verify live purchase flow
- [ ] **7.4** Monitor crash reports and reviews

---

## Quick Reference

### Key Files
| Purpose | Location |
|---------|----------|
| Version | `pubspec.yaml:5` |
| Package name | `android/app/build.gradle.kts:22` |
| Signing | `android/key.properties` (create) |
| Privacy URL | `lib/screens/paywall_screen.dart:368` |
| Terms URL | `lib/screens/paywall_screen.dart:382` |

### Commands
```bash
# Build release bundle
flutter build appbundle --release

# Build APK for testing
flutter build apk --release

# Install on device
flutter install --release

# Increment version (edit pubspec.yaml)
# Format: major.minor.patch+buildNumber
```

---

## Full Description Template

```
Pointer delivers daily non-dual awareness pointings from diverse wisdom traditions.

Unlike meditation apps that guide you through practices, Pointer offers direct pointings—immediate invitations to recognize your true nature, right now.

FEATURES
• Daily Pointings: Fresh wisdom each day from Advaita, Zen, Direct Path, and contemporary teachers
• Multiple Traditions: Explore pointings from Nisargadatta Maharaj, Ramana Maharshi, Rupert Spira, and more
• Audio Readings: Listen to guided readings (Premium)
• Text-to-Speech: Have any article read aloud (Premium)
• Home Widget: Quick daily pointer on your home screen
• Favorites: Save pointings that resonate
• No Gamification: No streaks, no progress tracking—just presence

PHILOSOPHY
Pointer takes an anti-meditation stance. Rather than building a practice over time, each pointing is a direct invitation to recognize what you already are.

PREMIUM
• Unlimited daily pointings
• Audio guided readings
• Text-to-speech for all content
• One-time lifetime purchase (no subscription)

Free users receive 2 pointings per day.

Privacy-focused: All preferences stored locally. No accounts required.
```

---

## Common Rejection Reasons

1. **Broken privacy policy link** - Test URL works before submission
2. **Missing data safety info** - Be thorough and accurate
3. **Crashes on startup** - Test release build on real device
4. **Purchase flow broken** - Test with sandbox accounts
5. **Screenshots don't match app** - Use actual app screenshots
