# Bug Fixes + Premium Cleanup Sprint

## Task 1: Visible Save/Like Button
- [x] Add heart icon to home screen card header (next to share icon)
- [x] Fix widget heart button: layout_height collapse (0dp→48dp), add clickable/focusable
- [x] Fix widget save→app sync: Kotlin writes save_pending_id, Dart reads it
- [x] Validate: heart visible on home screen, toggles on tap, share still works

## Task 2: Bell Sound Respects Setting
- [x] Convert SplashScreen to ConsumerStatefulWidget
- [x] Mute video when ambient sound is "none"
- [x] Validate: Opening Sound None/Bell visible in Settings, splash video respects setting

## Task 3: Fix Notifications
- [x] Re-enable WorkManager on Android only
- [x] Add iOS zonedSchedule batch fallback (batch local notifications when WorkManager is Android-only)
- [x] Add "Send Test Notification" button in settings
- [x] Remove testEveryMinute preset (not useful — WorkManager minimum is 15min)
- [x] Validate: WorkManager initialized in logs, test notification button visible

## Task 4: Remove Premium Gating (complete)
- [x] Remove kFreeAccessEnabled, SubscriptionTier, SubscriptionState, SubscriptionNotifier
- [x] Remove /paywall route
- [x] Clean premium conditionals from all screens
- [x] Clean premium from widgets (audio, video, commentary)
- [x] Clean widget_service.dart premium checks (setPremiumStatus, clearWidgetData, isPremium key)
- [x] Clean Kotlin widget premium check
- [x] Remove isPremium from Article model + all 160 article entries
- [x] Remove isLocked from ArticleListItem + all library detail screens
- [x] Remove isPremium from InquirySession + inquiry providers
- [x] Remove premiumArticlesProvider, getFeaturedArticles filter, subscriptionTier storage key
- [x] Clean tests
- [x] Validate: flutter analyze clean, zero premium references in lib/

## Task 5: Verify Lineages Coverage
- [x] Confirm 5 lineages visible: Advaita (581), Zen (522), Direct Path (162), Contemporary (637), Original (702)
- [x] No code change needed (verification only)

## Task 6: Donation Button Prominence
- [x] Move donation button up in settings (after appearance section)
- [x] Validate: positioned correctly (hidden on debug build — no IAP, shows on production)

## Task 7: Send Test Notification Button
- [x] Add visible "Send Test Notification" row in notifications section
- [x] Validate: button visible in settings with bell icon

## Task 8: Implementation Tracker
- [x] Create this file
- [x] Add reference to CLAUDE.md

## Additional Cleanups
- [x] Remove first-save celebration animation (confetti package, isFirstSave logic, hasEverSaved storage)
- [x] Remove showTestPreset parameter from NotificationTimesSheet
- [x] Remove dead PremiumFeatureBanner code from settings_banners.dart
