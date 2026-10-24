# Store screenshots after the 2026-10 overhaul

Every existing store screenshot predates the overhaul. The v1.1 set in `docs/store_assets/ios_screenshots_v1.1/` and `ios_screenshots/` shows the old purple glass UI, and some frames show audio controls that no longer ship. `fastlane/metadata/android/en-US/images/phoneScreenshots/` is empty. Replace all of them.

## Proposed set

Compositions come from the overhaul goldens in `test/golden/overhaul/goldens/`. Those goldens render at 390x844 logical pixels and 1x, which is too small for the stores. Use them as the shot list and capture the finals on a device or simulator at native resolution.

| # | Screen | Reference golden | Caption idea |
| --- | --- | --- | --- |
| 1 | Home, pointing shown | `home_phone_dark.png` | One pointing a day. Look now. |
| 2 | Home, light theme | `home_phone_light.png` | Calm in light or dark |
| 3 | Library | `library_phone_dark.png` | Teachings from Advaita, Zen and the Direct Path |
| 4 | Article reader | `article_phone_light.png` | Short reads, no noise |
| 5 | Lineages | `lineages_phone_dark.png` | Meet the teachers |
| 6 | Reminder times sheet | `notificationsheet_phone_dark.png` | Gentle reminders, when you choose |
| 7 | Home-screen widget | none (capture on device) | Presence on your home screen |
| 8 | Settings or Tip sheet | `settings_phone_dark.png` / `tip_phone_dark.png` | Free. Private. Optional tips. |

Tablet sets: use the `*_tablet_*` goldens for Play 7-inch and 10-inch and for the iPad 13-inch set. The adaptive tablet layouts are still being built in a parallel stream, so capture tablets only after that stream lands.

## Required sizes

- Google Play phone: 2 to 8 images, 16:9 or 9:16, sides 320 to 3840 px. Use 1080x2400.
- Google Play 7-inch and 10-inch tablet: optional, but needed for tablet featuring.
- App Store iPhone 6.9-inch: 1290x2796 (or 1320x2868). Smaller iPhone sizes scale down from this one.
- App Store iPad 13-inch: 2064x2752, required because the app supports iPad.
- Feature graphic (Play): 1024x500. Recheck `featureGraphic.png` against the new palette.

Do not show tips as unlocking anything, and do not show Premium, audio, or text-to-speech.
