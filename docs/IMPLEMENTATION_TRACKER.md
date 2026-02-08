# Bug Fixes + Premium Cleanup Sprint

## Task 1: Visible Save/Like Button
- [x] Add heart icon to home screen card header (next to share icon)
- [ ] Investigate widget heart button visibility (deferred — needs device testing)
- [x] Validate: heart toggles on tap, share still works

## Task 2: Bell Sound Respects Setting
- [x] Convert SplashScreen to ConsumerStatefulWidget
- [x] Mute video when ambient sound is "none"
- [ ] Validate: silent with "None", audio with "Bell" (needs device testing)

## Task 3: Fix Notifications + iOS Fallback
- [x] Re-enable WorkManager on Android only
- [ ] Add iOS zonedSchedule batch fallback (deferred — iOS WorkManager disabled)
- [x] Add "Send Test Notification" button in settings
- [ ] Validate: immediate test notification, periodic on Android (needs device testing)

## Task 4: Remove Premium Gating
- [x] Remove kFreeAccessEnabled, SubscriptionTier, SubscriptionState, SubscriptionNotifier
- [x] Remove /paywall route
- [x] Clean premium conditionals from all screens
- [x] Clean premium from widgets (audio, video, commentary)
- [x] Clean widget_service.dart premium checks
- [x] Clean tests
- [x] Validate: flutter analyze clean, all tests pass (978/979, 1 pre-existing golden failure)

## Task 5: Verify Lineages Coverage
- [ ] Confirm 5 lineages visible in "All" view (needs device testing)
- [ ] Confirm Original absent in "Articles" filter (0 articles)
- [x] No code change needed (verification only)

## Task 6: Donation Button Prominence
- [x] Move donation button up in settings (after appearance section)
- [ ] Validate: visible and prominent, 4 tip options render (needs device testing)

## Task 7: Send Test Notification Button
- [x] Add visible "Send Test Notification" row in notifications section
- [ ] Validate: immediate notification on tap (needs device testing)

## Task 8: Implementation Tracker
- [x] Create this file
- [x] Add reference to CLAUDE.md
