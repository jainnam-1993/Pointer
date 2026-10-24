# Here Now 1.3.0 (17): Play Data safety and Apple App Privacy answers

Drafted from the code on `ovh/release-1.3.0` (base `0169231`). The user enters these in Play Console and App Store Connect by hand. Line references are to that commit.

## What the code does with data

| Area | Finding | Evidence |
|---|---|---|
| Network | No HTTP client, analytics, crash reporting or ads SDK. No `http`, `dio`, Firebase, Crashlytics, Sentry or AdMob dependency. | `pubspec.yaml:15-58` (full dependency list); grep of `lib/` for `HttpClient`, `package:http/`, `dio`, `firebase`, `crashlytics`, `sentry`, `admob` finds nothing |
| Android permissions | Notifications, boot-completed (to restore schedules), vibrate. No `INTERNET` in the release manifest. | `android/app/src/main/AndroidManifest.xml:4-6`; `INTERNET` is only in `android/app/src/profile/AndroidManifest.xml:6` (profile builds) |
| Usage counts | Daily view counts kept in SharedPreferences on the device only. | `lib/services/usage_tracking_service.dart:51`, `:89` |
| Tips (billing) | Optional consumable tips through Google Play Billing or StoreKit. The app sends nothing to its own server; Google and Apple process the payment. | `lib/services/donation_service.dart:41`, `:95` |
| Notifications | Local scheduled notifications only; no push service, no `aps-environment` entitlement. | `lib/services/notification_service.dart:335`, `:340`, `:509`; `ios/Runner/Runner.entitlements` has only the App Group |
| Widget App Group | `group.com.dailypointer.widget` shares the current pointing between app and widget on the device. | `lib/services/widget_service.dart:37`, `:62`; `ios/Runner/Runner.entitlements:7`; `ios/PointerWidget/PointerWidget.entitlements:7` |
| Sharing | User-initiated share sheet (text or an image card) and Day One export via URL scheme. | `lib/services/share_service.dart:151`, `:171`, `:205`, `:211` |
| Links | Privacy policy and terms open in the external browser. | `lib/screens/settings_screen.dart:441`, `:447` |
| iOS privacy manifest | Tracking false, no collected data types; required-reason API is UserDefaults only. | `ios/Runner/PrivacyInfo.xcprivacy:5-6`, `:9-10`, `:15`; `ios/PointerWidget/PrivacyInfo.xcprivacy:5-15` |

## Google Play: Data safety

| Question | Answer | Why |
|---|---|---|
| Does your app collect or share any of the required user data types? | **No** | Nothing leaves the device (Network, Usage counts rows). |
| Is all user data encrypted in transit? | Not asked once the answer above is No | |
| Do you provide a way for users to request that their data is deleted? | Not asked once the answer above is No. Data lives on the device; uninstalling or clearing app data removes it. | |
| Purchases | Not declared | Play Billing processes tips; the app keeps no purchase record off device (Tips row). Google's guidance excludes data handled by Play's own billing. |
| User-initiated sharing | Not "sharing" | Play excludes transfers the user starts through the system share sheet (Sharing row). |

Other App content answers: Ads **No** (no ads SDK); App access **all functionality available without login**; Account creation **none**, so the account deletion URL does not apply.

## Apple: App Privacy

| Question | Answer | Why |
|---|---|---|
| Do you or your third-party partners collect data from this app? | **No, we do not collect data from this app** ("Data Not Collected") | Same evidence as above; Apple defines "collect" as transmitting off the device. |
| Tracking | **No** | `NSPrivacyTracking` false and no tracking domains (`ios/Runner/PrivacyInfo.xcprivacy:5-8`). |
| Purchases | Not declared | StoreKit handles the purchase; the app does not store or send purchase history. |

## Re-check before submitting

Answers change if any future build adds a network call, an SDK with telemetry, push notifications, or an account. Re-run the grep in the Network row on the exact commit being uploaded.
