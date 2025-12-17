# Pointer Widget - iOS Setup Guide

The Swift source files for the PointerWidget extension are ready. To complete the setup, follow these Xcode steps.

## Quick Setup in Xcode

1. **Open Xcode Project**
   ```bash
   cd /Volumes/workplace/Personal/Pointer/ios
   open Runner.xcworkspace
   ```

2. **Add Widget Extension Target**
   - File → New → Target
   - Search "Widget Extension"
   - Name: `PointerWidget`
   - Bundle ID: `com.pointer.app.PointerWidget`
   - Uncheck "Include Configuration App Intent"
   - Click Finish

3. **Replace Generated Files**
   - Delete the auto-generated Swift files in PointerWidget group
   - Drag in the existing files:
     - `PointerWidget.swift`
     - `PointerWidgetBundle.swift`
     - `Info.plist`

4. **Configure App Groups**
   - Select Runner target → Signing & Capabilities
   - Add "App Groups" capability
   - Add group: `group.com.pointer.widget`
   - Select PointerWidget target
   - Add same "App Groups" capability with same group ID

5. **Build Settings**
   - Ensure PointerWidget deployment target matches Runner (iOS 14.0+)

6. **Build & Test**
   - Select PointerWidget scheme
   - Build and run on device/simulator
   - Add widget from home screen widget picker

## Architecture

```
┌─────────────────────────────────────────────────┐
│                 Flutter App                      │
│  ┌───────────────────────────────────────────┐  │
│  │    WidgetService (widget_service.dart)    │  │
│  │    - Saves pointing data via home_widget  │  │
│  └───────────────────────────────────────────┘  │
│                       │                          │
│           UserDefaults (App Group)               │
│        group.com.pointer.widget                  │
│                       │                          │
├───────────────────────┼──────────────────────────┤
│         iOS Native    │                          │
│  ┌───────────────────────────────────────────┐  │
│  │    PointerWidget (WidgetKit Extension)    │  │
│  │    - Reads from shared UserDefaults       │  │
│  │    - Displays pointing in small/med/large │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

## Data Keys

The widget reads these keys from shared UserDefaults:
- `pointing_content` - The pointing text
- `pointing_teacher` - Teacher attribution (optional)
- `pointing_tradition` - Tradition name
- `pointing_last_updated` - ISO8601 timestamp

## Widget Sizes

| Family | Size | Content |
|--------|------|---------|
| systemSmall | 2x2 | Tradition + truncated quote |
| systemMedium | 4x2 | Tradition + quote + teacher |
| systemLarge | 4x4 | Full quote with context |

## Troubleshooting

**Widget shows placeholder data:**
- Ensure App Group ID matches exactly
- Run app first to populate data
- Check console for shared UserDefaults errors

**Widget doesn't update:**
- Timeline refresh is set to 3 hours by default
- Force refresh: Remove and re-add widget
