# Pointer - Design System

> **Theme:** "Ethereal Liquid Glass" — Blurring the boundaries between self and awareness.

---

## 1. Design Philosophy

The visual language mirrors the core teaching of the app:

- **The Background (The Absolute):** A slowly moving, deep fluid gradient represents unmanifest consciousness—always present, changing but changeless.
- **The Glass (The Apparent):** UI elements are frosted glass panes. They don't block the background but blur it, symbolizing clarity emerging from the void without separating from it.
- **Softness:** No hard edges. Deep rounded corners on everything to emphasize fluidity and non-separation.
- **Minimalism:** The design should feel almost absent. There are no gamification elements, streaks, or rewards to distract from the simple act of looking.

---

## 2. Color Tokens

The palette is dark, moody, and highly contrasted with pure white text.

### Animated Background Gradient

The background is not static; it is a slow-breathing mesh of these deep colors.

| Token | Hex Value | Description |
|:------|:----------|:------------|
| `--bg-indigo-deep` | `#0F0524` | The deepest shadow |
| `--bg-violet` | `#240046` | Mid-tone purple |
| `--bg-purple-accent` | `#5B2D8E` | Brighter highlights in the fluid |
| `--bg-teal-deep` | `#002933` | Deep cool tones |
| `--bg-cyan-muted` | `#2D8F9E` | Muted accents for depth |

### Glass Surfaces (The UI)

Glass is defined by low opacity, high blur, and subtle borders.

| Token | Value | Description |
|:------|:------|:------------|
| `--glass-fill-primary` | `rgba(255, 255, 255, 0.08)` | Main card background |
| `--glass-fill-button` | `rgba(255, 255, 255, 0.15)` | Slightly more opaque for tappables |
| `--glass-border` | `rgba(255, 255, 255, 0.15)` | 1px subtle rim |
| `--glass-blur` | `30px` | Heavy backdrop blur (frosted effect) |
| `--glass-shadow` | `0 8px 32px rgba(0, 0, 0, 0.4)` | Deep, soft shadow for lift |

### Text & Content

| Token | Hex Value | Use Case |
|:------|:----------|:---------|
| `--text-primary` | `#FFFFFF` | Main headings, pointing text (100% opacity) |
| `--text-secondary` | `#E0E0E0` | Sub-text, descriptions (~88% opacity) |
| `--text-tertiary` | `#A0A0A0` | Metadata, inactive icons (~60% opacity) |
| `--accent-color` | `#FFFFFF` | Buttons and active icons are monochrome |

---

## 3. Typography

Use the Native System Font (San Francisco on iOS, Roboto on Android) to maintain a clean, unobtrusive feel.

| Role | Size | Weight | Tracking | Usage |
|:-----|:-----|:-------|:---------|:------|
| **Display XL** | 40px | 700 (Bold) | Tight | The main pointing question on the Home screen |
| **Heading L** | 32px | 700 (Bold) | Normal | Screen titles (e.g., "Lineages") |
| **Heading M** | 24px | 600 (Semi) | Normal | Section headers, card titles |
| **Body L** | 18px | 400 (Regular) | Normal | Main instructional text |
| **Body M** | 16px | 400 (Regular) | Normal | List items, standard button text |
| **Body S** | 14px | 400 (Regular) | Normal | Sub-instructions (e.g., "Just look.") |
| **Caption** | 12px | 500 (Medium) | Loose | Labels, timestamps, metadata |

---

## 4. Iconography

Icons should be minimalist, white outline style (approx 2px stroke width).

### 4.1 Navigation Dock Icons

| Icon | Name | State |
|:-----|:-----|:------|
| 👁 | **Home** (Eye) | Active: Solid White / Inactive: 50% Opacity |
| 🌀 | **Inquiry** (Spiral) | Active: Solid White / Inactive: 50% Opacity |
| ☰ | **Lineages** (Menu) | Active: Solid White / Inactive: 50% Opacity |
| ⚙️ | **Settings** (Cog) | Active: Solid White / Inactive: 50% Opacity |

### 4.2 Tradition Lineage Icons

| Tradition | Icon Concept |
|:----------|:-------------|
| Advaita Vedanta | 🕉 (Om Symbol) |
| Zen Buddhism | ◯ (Enso Circle) |
| Dzogchen | △ or ཨ (Tibetan A) |
| Direct Path | ◇ (Diamond/Sparkle) |
| Contemporary | 👤 (Generic Person/Head) |

---

## 5. Component Library

These are the reusable building blocks of the interface.

### 5.1 The Glass Card (Container)

The fundamental container for all content.

```
Style:
  Background: --glass-fill-primary
  Border: 1px solid --glass-border
  Radius: 32px (Rounded 3XL)
  Shadow: --glass-shadow
  Backdrop Blur: 30px
  Padding: 32px
```

### 5.2 Primary Glass Button (Pill)

Used for the main call to action (e.g., "Next Pointing").

```
Style:
  Shape: Pill / Capsule (Height 56px, Radius 28px)
  Background: --glass-fill-button
  Border: 1px solid --glass-border
  Text: Body M, White, Center Aligned
  Icon: usually accompanied by an arrow (↓ or →)
```

### 5.3 Glass List Item

Used in Lineages and Settings. A horizontal strip.

```
Style:
  Height: 88px
  Background: --glass-fill-primary
  Border: 1px solid --glass-border
  Radius: 24px
  Padding: 0 24px
  Layout: Flex Row (Icon -> Text Column -> Chevron >)
```

### 5.4 Floating Nav Dock

The bottom navigation bar.

```
Style:
  Shape: Capsule (Height 72px)
  Width: ~65% of screen width
  Position: Fixed, Bottom 32px, Centered horizontally
  Background: High blur glass (similar to button)
  Content: 4 icons distributed evenly
```

### 5.5 Notification Banner

Floating overlay for arriving pointings.

```
Style:
  Position: Fixed, Top 16px, floating
  Width: ~92% of screen width
  Height: Auto (min 80px)
  Radius: 24px
  Background: High blur glass
  Animation: Slide down from top
```

---

## 6. Screen Specifications (Wireframes)

### 6.1 Home Screen (The Pointing)

Centrally focused, free of distractions.

```
[SCREEN: Animated Liquid Background]

  [STATUS BAR: Transparent]

  [CONTAINER: Centered Vertically & Horizontally]

    [GLASS CARD component]
      [TEXT: Display XL, White, Center]
      "What is aware of this moment?"

      [SPACER: 24px]

      [TEXT: Body S, Secondary Color, Center, Italic]
      "Just look. Don't answer."
    [/GLASS CARD]

  [/CONTAINER]

  [BUTTON: Primary Glass Pill, Bottom Center, Margin-bottom: 120px]
    [ICON: Arrow Down] "Next Pointing"

  [FLOATING NAV DOCK component, Bottom Center]
    [Active: Eye] [Inactive: Spiral, Menu, Cog]
```

### 6.2 Teacher Lineages Screen

A scrolling list view.

```
[SCREEN: Animated Liquid Background]

  [STATUS BAR: Transparent]

  [HEADER container, Top margin 60px, Left padding 24px]
    [TEXT: Heading L, White] "Lineages"

  [SCROLLVIEW: Padding 24px]
    [GLASS LIST ITEM component, Margin-bottom 16px]
      [Icon: Om] [Title: Advaita Vedanta] [Chevron >]

    [GLASS LIST ITEM component, Margin-bottom 16px]
      [Icon: Enso] [Title: Zen Buddhism] [Chevron >]

    [GLASS LIST ITEM component, Margin-bottom 16px]
      [Icon: Triangle] [Title: Direct Path] [Chevron >]

    [GLASS LIST ITEM component, Margin-bottom 16px]
      [Icon: Person] [Title: Contemporary] [Chevron >]
  [/SCROLLVIEW]

  [FLOATING NAV DOCK component, Bottom Center]
    [Inactive: Eye, Spiral] [Active: Menu] [Inactive: Cog]
```

### 6.3 Settings Screen

Clean structure for preferences, avoiding gamification elements.

```
[SCREEN: Animated Liquid Background]

  [HEADER: Heading L] "Settings"

  [SCROLLVIEW]
    [TEXT: Caption, Tertiary Color, Uppercase] "PREFERENCES"
    [GLASS CARD: Radius 24px, Padding 0]
      [LIST ITEM: "Daily Notifications", Right: Toggle Switch]
      [DIVIDER: subtle glass line]
      [LIST ITEM: "Frequency", Right: "3/day >"]
    [/GLASS CARD]

    [SPACER 32px]

    [TEXT: Caption, Tertiary Color, Uppercase] "HISTORY"
    [GLASS CARD: Radius 24px]
      [LIST ITEM: "View Past Pointings", Right: Chevron >]
    [/GLASS CARD]
    [TEXT: Caption, Center] "No streaks. Just recognition."

    [SPACER 32px]

    [TEXT: Caption, Tertiary Color, Uppercase] "ACCOUNT"
    [GLASS CARD: Radius 24px, Highlight Border]
      [LIST ITEM: "✨ Upgrade to Premium", Bold Title, Right: Chevron >]
    [/GLASS CARD]
  [/SCROLLVIEW]
```

### 6.4 Self-Inquiry Session Screen

Guided investigation flow.

```
[SCREEN: Animated Liquid Background]

  [STATUS BAR: Transparent]

  [HEADER: Row]
    [BACK BUTTON: ← icon]
    [TEXT: Heading M, Center] "Self-Inquiry"
    [SPACER]

  [CONTAINER: Centered]
    [GLASS CARD component]
      [TEXT: Caption, Tertiary] "Step 1 of 5"

      [SPACER: 16px]

      [TEXT: Heading M, White]
      "Ask yourself:"

      [SPACER: 8px]

      [TEXT: Display XL, White]
      "Who am I?"

      [SPACER: 24px]

      [TEXT: Body S, Secondary, Italic]
      "Don't answer with a thought.
       Just look for the one who's asking."
    [/GLASS CARD]
  [/CONTAINER]

  [PROGRESS: Subtle dots or thin line, not prominent]
    ● ○ ○ ○ ○

  [BUTTON: Primary Glass Pill, Bottom]
    "Continue →"
```

### 6.5 Onboarding Flow

#### Screen 1: Welcome

```
[SCREEN: Animated Liquid Background]

  [CONTAINER: Centered]
    [ICON: Eye 👁, Large, White]

    [SPACER: 24px]

    [TEXT: Heading L, White, Center]
    "Pointer"

    [SPACER: 32px]

    [GLASS CARD component]
      [TEXT: Body L, White, Center]
      "You are not the seeker.
       You are what's being sought."

      [SPACER: 16px]

      [TEXT: Body S, Secondary, Center]
      "This app won't teach you anything.
       It will only point to what you already are."
    [/GLASS CARD]
  [/CONTAINER]

  [BUTTON: Primary Glass Pill, Bottom]
    "Begin →"

  [PROGRESS DOTS: ● ○ ○ ○]
```

#### Screen 2: Choose Traditions

```
[SCREEN: Animated Liquid Background]

  [TEXT: Heading M, Center]
  "Which traditions resonate?"

  [TEXT: Body S, Secondary, Center]
  "Select any that call to you"

  [GRID: 2x2, Gap 16px, Padding 24px]
    [SELECTABLE GLASS CARD]
      [ICON: Om, Large]
      [TEXT: Body M] "Advaita"
      [CHECKMARK if selected]

    [SELECTABLE GLASS CARD]
      [ICON: Enso, Large]
      [TEXT: Body M] "Zen"

    [SELECTABLE GLASS CARD]
      [ICON: Diamond, Large]
      [TEXT: Body M] "Direct Path"

    [SELECTABLE GLASS CARD]
      [ICON: Star, Large]
      [TEXT: Body M] "Contemporary"

  [BUTTON: Text style] "All traditions"

  [BUTTON: Primary Glass Pill, Bottom]
    "Continue →"

  [PROGRESS DOTS: ● ● ○ ○]
```

#### Screen 3: Set Reminders

```
[SCREEN: Animated Liquid Background]

  [TEXT: Heading M, Center]
  "When should we point?"

  [LIST: Glass cards, selectable]
    [TIME CARD: Selected state]
      [ICON: 🌅] "Morning" [TIME: 8:00 AM]
      "Before the day takes you"

    [TIME CARD]
      [ICON: ☀️] "Midday" [TIME: 12:30 PM]
      "Interrupt the story"

    [TIME CARD]
      [ICON: 🌙] "Evening" [TIME: 9:00 PM]
      "Rest as awareness"

  [ROW: Center]
    [TEXT: Body M] "Pointings per day:"
    [STEPPER: Glass style] [−] 2 [+]

  [BUTTON: Primary Glass Pill, Bottom]
    "Continue →"

  [PROGRESS DOTS: ● ● ● ○]
```

#### Screen 4: Ready

```
[SCREEN: Animated Liquid Background]

  [CONTAINER: Centered]
    [ICON: Sparkle ✦, Large, White]

    [SPACER: 32px]

    [GLASS CARD component]
      [TEXT: Heading M, White, Center]
      "You're ready."

      [SPACER: 16px]

      [TEXT: Body L, Secondary, Center]
      "The next notification
       won't teach you anything new.

       It will only remind you
       to look."
    [/GLASS CARD]
  [/CONTAINER]

  [BUTTON: Primary Glass Pill, Bottom]
    "Start Looking"

  [PROGRESS DOTS: ● ● ● ●]
```

### 6.6 Paywall (Premium Modal)

Must feel valuable and congruent with the philosophy.

```
[MODAL SCREEN: Darkened Liquid Background]

  [GLASS CARD: Full width bottom sheet, Radius-top 40px]
    [CLOSE BUTTON: Top Right (X)]

    [ICON: Large Sparkle ✨, Center top]
    [TEXT: Heading M, Center] "Unlock Full Clarity"

    [SPACER]

    [LIST: Checkmark items, Left aligned]
      ✓ Unlimited daily pointings
      ✓ Access all 5 traditions
      ✓ Full Self-Inquiry library
      ✓ Teacher deep-dives

    [SPACER]

    [TEXT: Body S, Center, Italic]
    "The goal of this app is to become unnecessary."

    [SPACER]

    [PRICING OPTIONS: Radio selection]
      [GLASS CARD: Selectable]
        [TEXT: Body M, Bold] "$7.99 / month"
        [RADIO: ○]

      [GLASS CARD: Selectable, Highlighted border]
        [TEXT: Body M, Bold] "$59.99 / year"
        [BADGE: "Save 37%"]
        [RADIO: ●]

    [BUTTON: Primary Glass Pill, Height 64px]
      "Subscribe"

    [BUTTON: Text only, Secondary] "Restore Purchase"

    [TEXT: Caption, Center, Tertiary]
    "Terms · Privacy"
  [/GLASS CARD]
```

### 6.7 Notification States

#### Lock Screen Notification

```
[iOS/ANDROID LOCK SCREEN]

  [NOTIFICATION CARD: System style with app icon]
    [APP ICON: Eye]
    [APP NAME: "Pointer"]
    [TIME: "now"]

    [CONTENT:]
    "Notice: You are not the voice in your head."
```

#### In-App Banner

```
[FLOATING BANNER: Top of screen]
  [GLASS CARD: High blur, Height 80px, Radius 24px]
    [ROW]
      [ICON: Eye, Small]
      [COLUMN]
        [TEXT: Caption, Bold] "Pointer"
        [TEXT: Body S] "Notice: You are not the voice in your head."
```

---

## 7. Animation & Interaction

### Background Animation

```javascript
// The background gradient mesh slowly morphs (60s loop)
animation: {
  duration: 60000,
  easing: 'ease-in-out',
  loop: true,
  // Colors shift between defined tokens
  keyframes: [
    { colors: ['#0F0524', '#240046', '#5B2D8E'] },
    { colors: ['#240046', '#002933', '#2D8F9E'] },
    { colors: ['#5B2D8E', '#0F0524', '#002933'] },
  ]
}
```

### Screen Transitions

| Transition | Duration | Easing | Style |
|:-----------|:---------|:-------|:------|
| Tab switch | 200ms | ease-out | Fade |
| Push screen | 300ms | ease-in-out | Slide from right |
| Modal open | 250ms | spring | Slide from bottom + backdrop fade |
| Modal close | 200ms | ease-in | Slide down + backdrop fade |

### Micro-interactions

| Element | Interaction | Feedback |
|:--------|:------------|:---------|
| Button press | Touch down | Scale to 0.96, 100ms |
| Button release | Touch up | Scale to 1.0, 100ms spring |
| Card press | Touch down | Border glow increase |
| Toggle | State change | Slide 200ms, light haptic |
| Next Pointing | Tap | Light haptic, card fade transition |

### Haptic Feedback

- **Light impact:** Button taps, navigation
- **None:** Scrolling, passive interactions
- **Medium impact:** Completing inquiry step, subscribing

---

## 8. Accessibility

| Requirement | Implementation |
|:------------|:---------------|
| Color contrast | All text meets WCAG AA (4.5:1 minimum) |
| Touch targets | Minimum 44x44px for all interactive elements |
| Reduce motion | Respect system setting, disable gradient animation |
| Screen reader | All icons labeled, pointings announced |
| Dynamic type | Support up to 200% system font scaling |
| Focus states | Visible focus rings on all interactive elements |

---

## 9. Asset Checklist

### Required for MVP

- [ ] App Icon (1024x1024 master)
- [ ] Splash Screen
- [ ] Tradition Icons (Om, Enso, Diamond, Triangle, Star) - SVG
- [ ] Navigation Icons (Eye, Spiral, Menu, Cog) - SVG
- [ ] UI Icons (Arrow, Chevron, Check, Close, Plus, Minus) - SVG

### App Store Assets

- [ ] iOS Screenshots (6.7", 6.5", 5.5") - 6 images each
- [ ] Android Screenshots (Phone, 7" Tablet) - 6 images each
- [ ] Feature Graphic (1024x500) - Android
- [ ] App Preview Video (optional)

---

## 10. Implementation Notes

### React Native / Expo

```javascript
// Glassmorphism in React Native
const glassStyle = {
  backgroundColor: 'rgba(255, 255, 255, 0.08)',
  borderWidth: 1,
  borderColor: 'rgba(255, 255, 255, 0.15)',
  borderRadius: 32,
  // Use expo-blur for backdrop blur
  overflow: 'hidden',
};

// Animated gradient: use react-native-reanimated +
// expo-linear-gradient or react-native-skia for mesh gradients
```

### Key Libraries

| Purpose | Library |
|:--------|:--------|
| Blur effects | `expo-blur` |
| Animations | `react-native-reanimated` |
| Gradients | `expo-linear-gradient` or `react-native-skia` |
| Haptics | `expo-haptics` |
| Icons | Custom SVG or `react-native-svg` |

---

---

## 11. Additional Screens

### 11.1 Pointing Detail View

When tapping a pointing from history or browsing a lineage.

```
[SCREEN: Animated Liquid Background]

  [HEADER: Row]
    [BACK BUTTON: ← icon]
    [SPACER]
    [SHARE BUTTON: Share icon]

  [CONTAINER: Centered]
    [GLASS CARD component, Large]
      [BADGE: Glass pill, top]
        [ICON: Om] "Advaita Vedanta"

      [SPACER: 24px]

      [TEXT: Display XL, White, Center]
      "You are not the body.
       The body is not yours.
       You are not the doer.

       What are you?"

      [SPACER: 24px]

      [DIVIDER: Subtle glass line]

      [SPACER: 16px]

      [TEXT: Body S, Tertiary, Center]
      "— Ashtavakra Gita"

      [SPACER: 8px]

      [TEXT: Caption, Tertiary]
      "Shown: Nov 27, 2024 • 8:12 AM"
    [/GLASS CARD]
  [/CONTAINER]

  [BOTTOM ACTIONS: Row, Space-between]
    [BUTTON: Glass Outline, Icon Only]
      [ICON: Heart] "Save"

    [BUTTON: Primary Glass Pill]
      "Another from this tradition →"
```

### 11.2 Lineage Detail View (e.g., Advaita Vedanta)

Drilling into a specific tradition.

```
[SCREEN: Animated Liquid Background]

  [HEADER]
    [BACK BUTTON: ←]
    [TEXT: Heading L] "Advaita Vedanta"

  [HERO SECTION: Glass Card, Horizontal]
    [ICON: Om, Large, 60px]
    [TEXT COLUMN]
      [TEXT: Body L, White]
      "The path of non-duality.
       You are already what you seek."
      [TEXT: Caption, Tertiary]
      "42 pointings • 3 teachers"

  [SECTION: Teachers]
    [TEXT: Caption, Uppercase, Tertiary] "TEACHERS"

    [HORIZONTAL SCROLL: Glass Cards]
      [TEACHER CARD: Width 140px]
        [AVATAR: Circle, placeholder or icon]
        [TEXT: Body M, Center] "Ramana Maharshi"
        [TEXT: Caption] "12 pointings"

      [TEACHER CARD]
        [AVATAR]
        [TEXT: Body M] "Nisargadatta"
        [TEXT: Caption] "15 pointings"

      [TEACHER CARD]
        [AVATAR]
        [TEXT: Body M] "Ashtavakra"
        [TEXT: Caption] "15 pointings"

  [SECTION: Pointings]
    [TEXT: Caption, Uppercase, Tertiary] "SAMPLE POINTINGS"

    [GLASS LIST ITEM]
      "You are not the body..."
      [ICON: Play or Arrow]

    [GLASS LIST ITEM]
      "The question 'Who am I?'..."
      [ICON: Play or Arrow]

    [GLASS LIST ITEM]
      "Bondage is believing..."
      [ICON: Play or Arrow]

  [BUTTON: Full Width, Glass]
    "Explore All Advaita Pointings"

  [FLOATING NAV DOCK]
```

### 11.3 Past Pointings (History Log)

Simple, non-gamified log.

```
[SCREEN: Animated Liquid Background]

  [HEADER]
    [BACK BUTTON: ←]
    [TEXT: Heading L] "Past Pointings"

  [SUBHEADER: Glass Card, Subtle]
    [TEXT: Body S, Secondary, Center]
    "No streaks. No scores.
     Just a record of invitations to look."

  [LIST: Grouped by date]

    [DATE HEADER]
      [TEXT: Caption, Tertiary] "TODAY"

    [GLASS LIST ITEM: Compact]
      [TIME: "8:12 AM"]
      [TEXT: Body M, Truncated]
      "What is aware of this moment?"
      [BADGE: "Advaita"]

    [GLASS LIST ITEM: Compact]
      [TIME: "12:30 PM"]
      [TEXT: Body M, Truncated]
      "Before this thought, what are you?"
      [BADGE: "Zen"]

    [DATE HEADER]
      [TEXT: Caption, Tertiary] "YESTERDAY"

    [GLASS LIST ITEM: Compact]
      [TIME: "8:05 AM"]
      [TEXT: Body M, Truncated]
      "Notice: you didn't start being aware..."
      [BADGE: "Direct Path"]

    [... more items ...]

  [FLOATING NAV DOCK]
```

### 11.4 Self-Inquiry Library

List of available guided inquiry sessions.

```
[SCREEN: Animated Liquid Background]

  [HEADER]
    [BACK BUTTON: ←]
    [TEXT: Heading L] "Self-Inquiry"

  [INTRO CARD: Glass]
    [TEXT: Body L, White]
    "These sessions guide you through
     the ancient practice of self-investigation."

    [TEXT: Body S, Secondary]
    "Each session is 5-15 minutes.
     No experience required."

  [SECTION: Sessions]
    [TEXT: Caption, Uppercase, Tertiary] "AVAILABLE SESSIONS"

    [SESSION CARD: Glass, Height 100px]
      [ROW]
        [ICON: Circle with "1"]
        [COLUMN]
          [TEXT: Body M, Bold] "Who Am I?"
          [TEXT: Caption, Secondary] "The fundamental inquiry"
          [TEXT: Caption, Tertiary] "5 min • Beginner"
        [PREMIUM BADGE if locked: "✨"]

    [SESSION CARD: Glass]
      [ROW]
        [ICON: Circle with "2"]
        [COLUMN]
          [TEXT: Body M, Bold] "Finding the Looker"
          [TEXT: Caption, Secondary] "Turn attention to its source"
          [TEXT: Caption, Tertiary] "7 min • Beginner"

    [SESSION CARD: Glass]
      [ROW]
        [ICON: Circle with "3"]
        [COLUMN]
          [TEXT: Body M, Bold] "The Space of Awareness"
          [TEXT: Caption, Secondary] "Recognizing what doesn't change"
          [TEXT: Caption, Tertiary] "10 min • Intermediate"
        [PREMIUM BADGE: "✨"]

    [SESSION CARD: Glass]
      [ROW]
        [ICON: Circle with "4"]
        [COLUMN]
          [TEXT: Body M, Bold] "Investigating Thoughts"
          [TEXT: Caption, Secondary] "What are thoughts made of?"
          [TEXT: Caption, Tertiary] "8 min • Intermediate"
        [PREMIUM BADGE: "✨"]

    [SESSION CARD: Glass]
      [ROW]
        [ICON: Circle with "5"]
        [COLUMN]
          [TEXT: Body M, Bold] "Resting as Awareness"
          [TEXT: Caption, Secondary] "Beyond the practice"
          [TEXT: Caption, Tertiary] "12 min • Advanced"
        [PREMIUM BADGE: "✨"]

  [FLOATING NAV DOCK]
```

### 11.5 Splash / Loading Screen

Initial app load.

```
[SCREEN: Static Deep Gradient (not animated yet)]
  Background: #0F0524 → #240046

  [CONTAINER: Centered]
    [ICON: Eye 👁, Large 80px, White]

    [SPACER: 16px]

    [TEXT: Heading L, White]
    "Pointer"

    [SPACER: 48px]

    [LOADING INDICATOR: Subtle]
      Three dots pulsing OR
      Thin circular progress OR
      Simple "breathing" opacity animation on icon

  [/CONTAINER]

  [BOTTOM: Padding 48px]
    [TEXT: Caption, Tertiary, Center]
    "Awareness is already here."
```

### 11.6 Notification Permission Request

Contextual prompt before system dialog.

```
[SCREEN: Animated Liquid Background]

  [CONTAINER: Centered]
    [ICON: Bell 🔔, Large, White]

    [SPACER: 24px]

    [GLASS CARD component]
      [TEXT: Heading M, White, Center]
      "Allow Notifications?"

      [SPACER: 16px]

      [TEXT: Body L, Secondary, Center]
      "Pointer works through interruption.

       A notification arrives.
       You pause for 10 seconds.
       You look.

       That's the entire practice."

      [SPACER: 24px]

      [TEXT: Body S, Tertiary, Center, Italic]
      "You can adjust timing in Settings."
    [/GLASS CARD]

  [/CONTAINER]

  [BOTTOM BUTTONS: Stacked]
    [BUTTON: Primary Glass Pill]
      "Enable Notifications"

    [BUTTON: Text only, Secondary]
      "Maybe Later"
```

### 11.7 Empty States

#### No Pointings Yet (New User)

```
[EMPTY STATE: Centered in content area]

  [ICON: Eye with sparkle, 64px, 50% opacity]

  [SPACER: 16px]

  [TEXT: Heading M, White]
  "Your first pointing awaits"

  [TEXT: Body S, Secondary, Center]
  "It will arrive at your scheduled time.
   Until then, notice: you're already aware."
```

#### No History Yet

```
[EMPTY STATE: Centered]

  [ICON: Clock, 64px, 50% opacity]

  [SPACER: 16px]

  [TEXT: Heading M, White]
  "No past pointings yet"

  [TEXT: Body S, Secondary, Center]
  "Your history will appear here.
   Not as progress—just as a record."
```

#### Offline State

```
[EMPTY STATE: Centered]

  [ICON: Cloud with X, 64px, 50% opacity]

  [SPACER: 16px]

  [TEXT: Heading M, White]
  "You're offline"

  [TEXT: Body S, Secondary, Center]
  "But awareness doesn't need WiFi.
   Your saved pointings are still available."

  [BUTTON: Glass Outline]
    "View Saved Pointings"
```

### 11.8 Time Picker Modal

For setting notification times.

```
[MODAL: Bottom Sheet, Glass]

  [HANDLE: Drag indicator, centered]

  [HEADER]
    [TEXT: Heading M] "Set Time"
    [CLOSE BUTTON: X]

  [TIME PICKER: Native iOS/Android style, but glass-themed]
    [SCROLL WHEELS or DIGITAL INPUT]
      Hour: [8]
      Minute: [00]
      Period: [AM]

  [PRESET SUGGESTIONS: Horizontal pills]
    [PILL: Glass] "6:00 AM"
    [PILL: Glass] "8:00 AM"
    [PILL: Glass, Selected] "9:00 AM"
    [PILL: Glass] "12:00 PM"

  [CONTEXT TEXT]
    [TEXT: Body S, Secondary, Center]
    "Morning pointings arrive before
     the day's stories take hold."

  [BUTTON: Primary Glass Pill, Full Width]
    "Save Time"
```

### 11.9 Share Modal

When sharing a pointing.

```
[MODAL: Bottom Sheet, Glass, Short]

  [HANDLE: Drag indicator]

  [PREVIEW CARD: Glass, showing pointing]
    [TEXT: Body M, Italic]
    "What is aware of this moment?"
    [TEXT: Caption] "— Pointer App"

  [SHARE OPTIONS: Grid 4-across]
    [ICON BUTTON: Messages]
    [ICON BUTTON: Instagram Stories]
    [ICON BUTTON: Twitter/X]
    [ICON BUTTON: Copy Link]

  [BUTTON: Glass Outline, Full Width]
    "More Options..."
```

### 11.10 Account Screen

For signed-in users.

```
[SCREEN: Animated Liquid Background]

  [HEADER]
    [BACK BUTTON: ←]
    [TEXT: Heading L] "Account"

  [PROFILE SECTION: Glass Card]
    [AVATAR: Circle, initials or icon]
    [TEXT: Body L, Bold] "name@email.com"
    [BADGE: Premium status]
      "✨ Premium Member"
      OR
      "Free Plan"

  [SECTION: Subscription]
    [TEXT: Caption, Uppercase, Tertiary] "SUBSCRIPTION"

    [GLASS CARD]
      [If Premium:]
        [TEXT: Body M] "Premium Yearly"
        [TEXT: Caption, Secondary] "Renews Dec 27, 2025"
        [BUTTON: Text] "Manage Subscription"

      [If Free:]
        [TEXT: Body M] "Free Plan"
        [TEXT: Caption, Secondary] "2 pointings per day"
        [BUTTON: Glass] "✨ Upgrade to Premium"

  [SECTION: Data]
    [TEXT: Caption, Uppercase, Tertiary] "YOUR DATA"

    [GLASS LIST ITEM]
      "Export Pointing History"
      [ICON: Download]

    [GLASS LIST ITEM]
      "Delete Account"
      [ICON: Trash, Red tint]

  [SECTION: Sign Out]
    [BUTTON: Glass Outline, Full Width]
      "Sign Out"
```

### 11.11 Widget Designs (iOS/Android)

#### Small Widget (2x2)

```
┌─────────────────────┐
│ [Gradient BG]       │
│                     │
│  "What is aware     │
│   right now?"       │
│                     │
│        👁 Pointer   │
└─────────────────────┘

Size: 155x155 pt (iOS)
Tap action: Opens app to this pointing
```

#### Medium Widget (4x2)

```
┌─────────────────────────────────────────┐
│ [Gradient BG]                           │
│                                         │
│  "The question 'Who am I?' doesn't      │
│   need an answer. Just look."           │
│                                         │
│  ॐ Advaita              👁 Pointer     │
└─────────────────────────────────────────┘

Size: 329x155 pt (iOS)
Shows: Current/last pointing with tradition badge
```

#### Large Widget (4x4)

```
┌─────────────────────────────────────────┐
│ [Gradient BG]                           │
│                                         │
│         👁                              │
│                                         │
│  "Before you check your phone:          │
│   What is already awake?"               │
│                                         │
│  ────────────────────────               │
│                                         │
│  Next pointing in: 2h 34m               │
│                                         │
│  [Tap for new pointing]                 │
│                                         │
│  ॐ Advaita Vedanta                      │
└─────────────────────────────────────────┘

Size: 329x345 pt (iOS)
Interactive: Tap button for immediate pointing
```

### 11.12 Error States

#### Generic Error

```
[ERROR STATE: Centered]

  [ICON: Warning triangle, 64px, 50% opacity]

  [SPACER: 16px]

  [TEXT: Heading M, White]
  "Something went wrong"

  [TEXT: Body S, Secondary, Center]
  "Even errors arise in awareness.
   Let's try again."

  [BUTTON: Glass Pill]
    "Retry"
```

#### Subscription Error

```
[ERROR STATE: In paywall context]

  [ICON: Card with X, 48px]

  [TEXT: Body M, White]
  "Payment couldn't be processed"

  [TEXT: Body S, Secondary]
  "Please check your payment method
   and try again."

  [BUTTON: Glass Pill]
    "Try Again"

  [BUTTON: Text] "Contact Support"
```

### 11.13 Success States

#### Subscription Success

```
[MODAL: Centered, Glass]

  [ICON: Checkmark in circle, 80px, White]

  [SPACER: 24px]

  [TEXT: Heading M, White, Center]
  "Welcome to Premium"

  [TEXT: Body L, Secondary, Center]
  "All traditions unlocked.
   All sessions available.

   Remember: the app's goal is
   to become unnecessary."

  [BUTTON: Primary Glass Pill]
    "Start Exploring"
```

#### Onboarding Complete

```
[CELEBRATION: Subtle, not over-the-top]

  [ICON: Sparkles animation, brief]

  [TEXT: Heading M, White]
  "You're all set"

  [TEXT: Body S, Secondary]
  "Your first pointing arrives at 8:00 AM"
```

### 11.14 Search / Explore Screen

For browsing all content.

```
[SCREEN: Animated Liquid Background]

  [HEADER]
    [TEXT: Heading L] "Explore"

  [SEARCH BAR: Glass style]
    [ICON: Search]
    [PLACEHOLDER: "Search pointings..."]

  [SECTION: Quick Filters - Horizontal scroll]
    [FILTER PILL: Glass, Selected] "All"
    [FILTER PILL: Glass] "Advaita"
    [FILTER PILL: Glass] "Zen"
    [FILTER PILL: Glass] "Direct Path"
    [FILTER PILL: Glass] "Morning"
    [FILTER PILL: Glass] "Work Stress"

  [SECTION: Featured]
    [TEXT: Caption, Uppercase, Tertiary] "POPULAR THIS WEEK"

    [POINTING CARD: Glass, Compact]
      "What was your face before your parents were born?"
      [BADGE: Zen] [SAVES: "234 saves"]

    [POINTING CARD: Glass, Compact]
      "The deadline is real. The one who's stressed—can you find them?"
      [BADGE: Original] [SAVES: "189 saves"]

  [SECTION: By Context]
    [TEXT: Caption, Uppercase, Tertiary] "BY MOMENT"

    [GRID: 2x2]
      [CONTEXT CARD: Glass]
        [ICON: 🌅]
        "Morning"
        "23 pointings"

      [CONTEXT CARD: Glass]
        [ICON: 💼]
        "Work Stress"
        "18 pointings"

      [CONTEXT CARD: Glass]
        [ICON: 🌙]
        "Evening"
        "15 pointings"

      [CONTEXT CARD: Glass]
        [ICON: 😰]
        "Anxiety"
        "21 pointings"

  [FLOATING NAV DOCK]
```

### 11.15 About / Credits Screen

Attribution and philosophy.

```
[SCREEN: Animated Liquid Background]

  [HEADER]
    [BACK BUTTON: ←]
    [TEXT: Heading L] "About"

  [LOGO SECTION: Centered]
    [ICON: Eye, 64px]
    [TEXT: Heading M] "Pointer"
    [TEXT: Caption, Tertiary] "Version 1.0.0"

  [PHILOSOPHY CARD: Glass]
    [TEXT: Body L, White, Italic]
    "This app exists to remind you
     of what you already are.

     It points. You look.
     That's all."

  [SECTION: Gratitude]
    [TEXT: Caption, Uppercase, Tertiary] "WITH GRATITUDE TO"

    [TEXT: Body S, Secondary]
    "The teachers whose words we share:
     Ramana Maharshi, Nisargadatta Maharaj,
     Ashtavakra, Huang Po, Bankei,
     Rupert Spira, Francis Lucille,
     and countless others who point
     to what cannot be taught."

  [SECTION: Links]
    [GLASS LIST ITEM]
      "Terms of Service" [ICON: External link]

    [GLASS LIST ITEM]
      "Privacy Policy" [ICON: External link]

    [GLASS LIST ITEM]
      "Contact Support" [ICON: Mail]

    [GLASS LIST ITEM]
      "Rate on App Store" [ICON: Star]

  [FOOTER]
    [TEXT: Caption, Tertiary, Center]
    "Made with 🤍 for seekers everywhere"
```

---

## 12. Interaction Patterns

### Pull to Refresh (Home)

```
[PULL DOWN GESTURE]
  - Resistance: Slight elastic feel
  - Trigger point: 80px pull
  - Animation: Card fades out, new card fades in
  - Haptic: Light impact on new pointing load
  - Text while pulling: "Pull for new pointing..."
  - Text on release: "Looking..."
```

### Swipe Gestures

```
[HOME SCREEN]
  - Swipe Left: Next pointing (same as button)
  - Swipe Right: Previous pointing (if in session)

[LIST ITEMS]
  - Swipe Left: Reveal "Save" action
  - Long Press: Context menu (Share, Save, Report)
```

### Keyboard Shortcuts (iPad)

```
Space: Next pointing
Cmd+1-4: Switch tabs
Cmd+S: Save current pointing
Cmd+Shift+S: Share
Escape: Dismiss modals
```

---

*"The design should disappear. Only the pointing remains."*
