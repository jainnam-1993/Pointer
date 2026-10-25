# Here Now 1.3.0 (17) release kit

Nothing here has been uploaded. Every step under "Upload steps" needs the user's explicit approval first.

## Version

`1.3.0+17` (`pubspec.yaml:5`), on `ovh/release-1.3.0-rc2` (base `overhaul/2026-10` at `2c024ff`). Read-only checks, 2026-10-24 20:38: Play alpha `[16]`, internal `[16]`, production and beta empty; App Store Connect builds top out at 1.2.1 (16), live version 1.2.1 READY_FOR_SALE. 17 is free on both stores.

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

## Release builds (signed, not uploaded)

| Output | Where | Size | SHA-256 | Signing |
|---|---|---|---|---|
| Play AAB 1.3.0 (17) | Mac `~/PointerRelease/1.3.0+17-rc2/HereNow-1.3.0-17-release.aab` | 59,861,788 B | `c2211e62bed6b08827a2f7b3a407a4142f74f359984a27502771b95ace4edfad` | upload key `A1:12:CD:ED:...:93:80:C4`, `jarsigner -verify` passes |
| App Store IPA 1.3.0 (17) | Studio `~/PointerRelease/1.3.0+17-rc2/HereNow-1.3.0-17-release.ipa` | 27,161,752 B | `dc4e0151c4de500a0b1f365331600edeb5d4812437ae1bce29fa5f77cdaa7ca2` | Apple Distribution: Naman Jain (29DPLC9929) on app and widget extension; profiles "Pointer AppStore 2026-10" and "PointerWidget AppStore 2026-10", cert SHA-1 `6DF2208B`; `codesign --verify --strict` passes |

Routes: the AAB is built on the Studio and re-signed on the Mac with jarsigner, so the upload key stays on the Mac. The IPA is built with `flutter build ipa --export-options-plist` (manual signing, the two profiles above) inside the Studio's `hermes-relay` tmux server, the only session with an unlocked keychain.

## Upload steps (each needs approval; none run)

1. Play internal testing, as a draft (Studio, `~/Projects/Pointer` holds `android/play-store-credentials.json`):
   `scp` the AAB to `build/app/outputs/bundle/release/app-release.aab` in a checkout of `ovh/release-1.3.0-rc2`, then `fastlane android internal`.
2. TestFlight (Studio): `fastlane ios beta` with `build/ios/ipa/` holding the IPA above; the lane uses API key J72393HTF4 and does not submit for review.
3. Listing text, separate approval: `fastlane android metadata`, `fastlane ios metadata` (`submit_for_review: false`).
4. Production rollout and App Review: a later, separate approval.
