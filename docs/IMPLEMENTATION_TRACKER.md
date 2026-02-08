# Bug Fixes + Premium Cleanup Sprint

## Task 1: Visible Save/Like Button
- [ ] Add heart icon to home screen card header (next to share icon)
- [ ] Investigate widget heart button visibility
- [ ] Validate: heart toggles on tap, share still works

## Task 2: Bell Sound Respects Setting
- [ ] Convert SplashScreen to ConsumerStatefulWidget
- [ ] Mute video when ambient sound is "none"
- [ ] Validate: silent with "None", audio with "Bell"

## Task 3: Fix Notifications + iOS Fallback
- [ ] Re-enable WorkManager on Android only
- [ ] Add iOS zonedSchedule batch fallback
- [ ] Add "Send Test Notification" button in settings
- [ ] Validate: immediate test notification, periodic on Android

## Task 4: Remove Premium Gating
- [ ] Remove kFreeAccessEnabled, SubscriptionTier, SubscriptionState, SubscriptionNotifier
- [ ] Remove /paywall route
- [ ] Clean premium conditionals from all screens
- [ ] Clean premium from widgets (audio, video, commentary)
- [ ] Clean widget_service.dart premium checks
- [ ] Clean tests
- [ ] Validate: flutter analyze clean, all tests pass

## Task 5: Verify Lineages Coverage
- [ ] Confirm 5 lineages visible in "All" view
- [ ] Confirm Original absent in "Articles" filter (0 articles)
- [ ] No code change needed (verification only)

## Task 6: Donation Button Prominence
- [ ] Move donation button up in settings (after appearance section)
- [ ] Validate: visible and prominent, 4 tip options render

## Task 7: Send Test Notification Button
- [ ] Add visible "Send Test Notification" row in notifications section
- [ ] Validate: immediate notification on tap

## Task 8: Implementation Tracker
- [x] Create this file
- [ ] Add reference to CLAUDE.md
