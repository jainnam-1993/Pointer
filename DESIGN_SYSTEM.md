# Here Now design system

The code is the source of truth. Tokens live in `lib/theme/app_theme.dart`, icons in `lib/theme/app_icons.dart`, motion in `lib/utils/motion.dart`, haptics in `lib/utils/haptics.dart`, and the ambient renderer in `lib/widgets/ambient.dart` with `shaders/ambient.frag`. When this file and the code disagree, fix this file.

## 1. Principles

- **The background is the absolute.** One slow ambient field (gradient, aurora, dust motes) lies under the whole app and follows the time of day.
- **Glass is the apparent.** Surfaces are frosted panes cut from that same field. They clarify the background without hiding it.
- **Almost absent.** There are no streaks, scores, badges or paywall. A screen should hold one thing to look at.
- **Ink, not neon.** The accent is enso ink (indigo and lavender). Gold appears only as a small tradition highlight.
- **Calm by default.** Motion is slow and settles without bounce, and every effect has a reduced-motion form.

## 2. Color

Read colors with `context.colors` (`PointerColors`). Never write a hex value in a widget.

| Token | Dark | Light | High contrast | OLED |
| --- | --- | --- | --- | --- |
| background | #000000 | #F6F4F1 | black | black |
| surface | #0B0A10 | #FFFFFF | #1A1A1A | black |
| textPrimary | #F5F3FA | #1A1622 | white | #F5F3FA |
| textSecondary | #C9C5D3 | #45404F | white | #C9C5D3 |
| textMuted | #A8A3B3 | #69636F | #CCCCCC | #A8A3B3 |
| accent / primary | inkLavender #A597E0 | inkDeep #4B3D8F / ink #2A2238 | #D4CBF5 | inkLavender |
| gold | #D9B26F | #8A6420 | | |

- `InkPalette`: `ink` #2A2238, `inkDeep` #4B3D8F (9:1 on white), `inkLavender` #A597E0 (7:1 on black), `inkDusk` #8E7CC3 (gradients).
- `TraditionAccentColors`: advaita #D4A574, zen #4DD0E1, direct inkLavender, contemporary #06B6D4, original #E0E0E0. Use them only for badges and small marks, never for body text.
- The contrast rules are enforced by `test/theme/contrast_test.dart` in all four themes. Every text color must reach at least 4.5:1 on every surface and glass fill, and button labels at least 4.5:1 on their button fill. Gold must reach 3:1, and primary, secondary and muted must keep their order.

### Ambient palette

`AmbientPalette` defines top, mid and bottom gradient stops, three aurora field colors (`fieldA`, `fieldB`, `fieldC`), aurora strength and mote strength. The dark palette follows `TimeOfDayPeriod`: dawn 5-7, morning 7-12, midday 12-14, afternoon 14-17, dusk 17-20, evening 20-22, and night otherwise. Light mode uses soft lavender and peach over warm off-white. OLED is pure black with no aurora and no motes.

## 3. Typography

Two bundled OFL families, with no runtime fetching (`AppFonts`):

- **Newsreader** (serif) for pointings, quotes and instructions.
- **Inter** (sans) for all UI.

The six-size scale is `AppType`. Every shared style uses one of these sizes, and the user's text scale is applied once at the app root (clamped).

| Size | Value | Use |
| --- | --- | --- |
| display | 28 | Pointings (serif) |
| title | 22 | Screen titles, headings |
| headline | 18 | Card titles, quotes, instructions |
| body | 16 | Body copy, button labels |
| callout | 14 | Supporting text, attributions |
| caption | 12 | Captions, section labels, footers |

`AppTextStyles`:

| Style | Definition |
| --- | --- |
| `pointingText` | serif display, height 1.36, -0.2 tracking |
| `quoteText` / `instructionText` | serif headline italic, height 1.5 |
| `teacherText` | sans callout w500, height 1.45 |
| `heading` | sans title, height 1.3, -0.3 tracking |
| `bodyText` | sans body, height 1.5, textSecondary |
| `buttonLabel` | sans body w600 |
| `sectionHeader` | sans caption w600, letter-spaced, upper case |
| `footerText` | sans caption, height 1.4 |

## 4. Spacing and shape

`AppSpacing` is on an 8 pt grid: xs 4, sm 8, md 12, lg 16, xl 24, xxl 32.

- Aliases: `screenPadding` 24, `cardPadding` 24, `sectionGap` 16, `itemGap` 12, `iconGap` 8, `navBarOffset` 120.
- Radii: `radiusSm` 8, `radiusMd` 12, `radiusLg` 16, `radiusXl` 24, `radiusCard` 24.
- Insets: `screenH`, `screenAll`, `cardAll`, `listItem`.

## 5. Glass material

There is one material, `GlassMaterial` (a ThemeExtension, read with `GlassMaterial.of(context)`). It powers `GlassCard`, `GlassButton` and `GlassDialog`.

- **Levels** (`GlassLevel(frost, topAlpha, bottomAlpha)`) for light, standard and heavy. In dark these are (0.6, .07, .03), (0.8, .10, .04) and (1.0, .16, .07); in light, (0.6, .16, .08), (0.8, .22, .12) and (1.0, .34, .20). The fill is white, as a top-left to bottom-right gradient.
- **Buttons:** `buttonPrimary` and `buttonSecondary` levels.
- **Rim:** a lit `rimTop` fading to `rimBottom` (1.5 px in dark, 1 px elsewhere). **Highlight:** a top sheen over 35% of the height. **Shadow:** 24 blur (20 in light).
- **Frost is analytic.** `AmbientFrost` samples the ambient shader at the card's screen rect, so cards cost no backdrop read. Inside opaque sheets, `FrostScope` disables frost, and cards fall back to `onSurfaceLevels` (plain fills).
- **Live blur** (`blurSigma` 30) is used only for dialogs, toasts and the tab bar. The tab bar uses `BackdropGroup` with `BackdropFilter.grouped`, so every grouped blur in the shell shares one backdrop read.
- **High contrast** is `opaque: true`: a solid #1A1A1A fill with no frost and no blur.

## 6. Icons

There is one icon set: Phosphor (MIT), through `AppIcons` semantic names. Light weight is the default because its thin even line matches the enso stroke; active tabs use Regular weight. Rules:

- Do not use Material `Icons` in new code. Do not use lotus or seated-figure motifs: the app points at what is already here and does not depict practice.
- Icons that carry meaning get a semantic label. Decorative icons are excluded from semantics.

## 7. Motion

`Motion` tokens:

| Token | Value | Use |
| --- | --- | --- |
| instant | 120 ms | Press feedback, toggles |
| quick | 200 ms | Fades, color changes |
| standard | 320 ms | Sheets, toasts, expanding cards |
| slow | 600 ms | Screen reveals |
| calm | 1200 ms | Pointing text, enso draw |
| breath | 4 s | Ambient loops |

- **Curves:** `enter` easeOutCubic, `exit` easeInCubic, `inOut` easeInOutCubic.
- **Springs:** `settle` (critically damped, for sheets and drags) and `gentle` (damping 0.82, for press release and toggles).
- **Press feedback** is `PressScale` to `Motion.pressScale` (0.97). There are no ink ripples on glass.
- **Reduced motion:** `Motion.reduce(context)` is true when either the system setting or the app's Animations toggle asks for it. Under reduced motion, the ambient clock stops at a still frame and transitions skip their movement.
- **Ambient field:** a 30 fps Timer (15 fps in power-saving modes) that pauses when backgrounded, under sheets and dialogs, and on covered routes. Never drive ambient motion from a vsync Ticker.

## 8. Haptics

Use `Haptics` only:

- `selection()` when a choice changes (toggles, tabs, chips, pickers).
- `light()` when a press lands (buttons, cards, opening a sheet).
- `success()` when something completes (a soft double tap).

Use nothing heavier.

## 9. Accessibility

- Contrast is covered by `contrast_test.dart` (section 2). High-contrast and OLED themes are user options.
- Text scales with the system setting through the one root clamp. Layouts must not clip at the clamp maximum.
- Semantics, focus order and labels are covered by `test/accessibility/`. Tap targets are at least 44x44 (iOS) / 48x48 (Android).

## 10. Home-screen widgets

The Android (Kotlin) and iOS (WidgetKit) widgets follow the app's ink-on-calm look: a serif pointing, the teacher in small sans, and Save, Previous and Next actions. Both render without the app running; see `WidgetRenderer.kt` and `PointerWidget.swift` for the exact styling.

## 11. Layout

Device classes in the golden matrix are smallphone, phone, foldouter, foldinner, foldhinge, tabletop and tablet. Adaptive rules (size classes, hinge avoidance, two-pane tablet layouts) live in `lib/layout/`, which is being built on the adaptive-layout stream. Screens ask `lib/layout/` for their layout instead of testing raw widths.
