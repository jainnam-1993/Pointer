# Here Now 1.3.0 (17) release kit

Nothing here has been uploaded. Every step under "Upload steps" needs the user's explicit approval first.

## Version

`1.3.0+17` (`pubspec.yaml:5`). Play already holds build 16 on the alpha and internal tracks (read-only `google_play_track_version_codes`, 2026-10-24: alpha `[16]`, internal `[16]`; production and beta have no releases). The highest is 16, so the release is 17.

## Text

| Item | File | Length |
|---|---|---|
| Play release notes | `fastlane/metadata/android/en-US/changelogs/17.txt` | 432 of 500 |
| Play short description | `fastlane/metadata/android/en-US/short_description.txt` | 78 of 80 |
| Play full description | `fastlane/metadata/android/en-US/full_description.txt` | 1470 of 4000 |
| App Store "What's New" | `fastlane/metadata/ios/en-US/release_notes.txt` | 435 |
| App Store description, name, subtitle, keywords | `fastlane/metadata/ios/en-US/{description,name,subtitle,keywords}.txt` | subtitle 22 of 30, keywords 96 of 100 |
| Data safety and App Privacy answers | `store/1.3.0/privacy-answers.md` | |

## Assets

| Store slot | On hand | State |
|---|---|---|
| Play icon 512x512, feature graphic 1024x500 | `fastlane/metadata/android/en-US/images/` | present |
| Play phone screenshots | `phoneScreenshots/` 1080x2424, 5 | pre-overhaul look; recapture |
| Play 7-inch and 10-inch tablet | `sevenInchScreenshots/`, `tenInchScreenshots/` 1080x1920, 5 each | pre-overhaul look; recapture on a tablet |
| iPhone 6.5-inch | `fastlane/metadata/ios/en-US/iphone65/` 1284x2778, 7 | pre-overhaul look |
| iPhone 6.9-inch (1320x2868 or 1290x2796) | none | **missing**; App Store Connect requires 6.9-inch or 6.5-inch |
| iPad 13-inch (2064x2752 or 2048x2732) | none; `screenshots/ipad_11/` is 1640x2360 | **missing**, required because the app supports iPad (`TARGETED_DEVICE_FAMILY = "1,2"`) |

New-look captures exist only as test evidence under `/workplace/jainnam/AgentResearch/PointerOptimize/visual/`: `studio/` (iPhone 17 Pro 1206x2622, iPad 1668x2420, Fold 2076x2152, phone 1080x2424) and `uiscene/uiscene_ios27_*` (1206x2622). They are home-screen shots at sizes the stores do not accept for iOS, so they are references for a recapture.

## Builds (checks only)

| Output | Where | Size | Signing |
|---|---|---|---|
| AAB 1.3.0 (17) | Mac `~/PointerRelease/1.3.0+17/app-release.aab` | 60,558,132 B | upload key, cert SHA-256 `A1:12:CD:ED:...:93:80:C4`, `jarsigner -verify` passes |
| AAB, temporary key | Mac `~/PointerRelease/1.3.0+17/NOT-FOR-UPLOAD-tempkey-app-release.aab` | 60,548,908 B | temporary key `10:A8:C4:5A:...` |
| iOS archive 1.3.0 (17) | Studio `~/PointerStudio-release/build/ios/archive/Runner.xcarchive` | 193 MB | unsigned (`--no-codesign`) |

The AAB was built on the Studio with Flutter 3.47.8 and re-signed on the Mac with the upload key, so the key never leaves the Mac. The signed IPA did not build over ssh, because codesign cannot reach the Studio's locked login keychain ("User interaction is not allowed"). The Studio has the identity "Apple Distribution: Naman Jain (29DPLC9929)" and App Store profiles for `com.dailypointer` and `com.dailypointer.PointerWidget` (valid to 2027-01-05).

## Upload steps (each needs approval; none run)

1. Play internal testing, as a draft, from the Mac:
   `cd <Pointer checkout at ovh/release-1.3.0> && cp ~/PointerRelease/1.3.0+17/app-release.aab build/app/outputs/bundle/release/ && fastlane android internal` (service-account JSON at `android/play-store-credentials.json`; the Studio's copy validated read-only).
2. TestFlight: on the Studio, unlock the login keychain in a GUI session (or run `security unlock-keychain ~/Library/Keychains/login.keychain-db`), then `flutter build ipa --release` and `fastlane ios beta`.
3. Listing text, as a separate approval: `fastlane android metadata` and `fastlane ios metadata` (`submit_for_review: false`).
4. Production rollout and App Review: separate later approval.
