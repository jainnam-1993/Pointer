# Design panel findings in the app's own UI (store screenshots, 1.3.0 rc2)

Source: DesignPanel runs on 2026-10-24. Round 1 is in `/workplace/jainnam/AgentResearch/PointerOptimize/store-1.3.0-panel/`; round 2 (retakes, current Today screen as the brand reference) is in `.../store-1.3.0-panel2/<device>/verdict.md`. Screenshots are in `/workplace/jainnam/AgentResearch/PointerOptimize/store-1.3.0/`. All 5 sets came back REVISE in both rounds. The items below are app UI, not capture, so the screenshots cannot pass the panel until the owners fix them.

| # | Item | Screens (example file) | Panel reason | Flagged by |
|---|---|---|---|---|
| 1 | Dark tab bar is a near-black opaque slab with a flat grey selected pill | all dark sheets (`iphone69_dark_1_today.png`) | Stark against the purple sky; does not read as glass; ignores the lavender accent | HIG, adversarial, brand, every device |
| 2 | Light tab bar: the selected pill is white on cream | `iphone69_light_1_today.png` | The active tab barely shows | HIG |
| 3 | Secondary text is too small and too low contrast: row subtitles, "1 min", "Contemporary" tag, "Swipe for another invitation to look", tab labels, the tradition chip in dark | all (`play_phone_dark_2_library.png`) | Below about 12pt and likely below 4.5:1, worst in dark | all three, every device |
| 4 | Library "Who Am I?" row is lighter than its siblings | `*_light_2_library.png` | Reads as a stuck pressed or disabled state | HIG, adversarial |
| 5 | Section headers mix styles: "Guided Inquiry" in sentence case, "POINTINGS" and "FEATURED" in tracked caps | Library, Saved | Inconsistent typography | adversarial, HIG |
| 6 | Saved sets pointings in sans; Today uses the Newsreader serif | `*_3_saved.png` | The same content looks like two products | brand, HIG |
| 7 | Saved cards have a fixed height; short quotes float, with the actions stranded at bottom right | `*_3_saved.png` | Dead space | adversarial, HIG |
| 8 | Today quote leaves "you." alone on the last line | `*_1_today.png` | Widow on the hero line | adversarial, HIG |
| 9 | Attributions use "- Name" instead of "— Name" | inquiry and Today cards | Typography | all three |
| 10 | Copy mismatch: Library says "Who Am I?", the inquiry card says "Who am I?" | `*_2_library.png`, `*_4_inquiry.png` | Inconsistent copy | adversarial |
| 11 | Guided Inquiry: the bottom ring animates, so a still catches a partial arc that reads as a loading spinner; the centre orb is unlabeled; the elements float in empty space | `*_4_inquiry.png` | Unfinished-looking state; unclear affordance | all three |
| 12 | Dark cards let the starfield show through (a star inside a Saved card) | `iphone69_dark_3_saved.png` | Muddy glass | HIG, adversarial |
| 13 | Notification banner is a muddy brown-orange fill in dark and a loud amber fill in light | Settings (dropped from the store set) | Clashes with the palette; reads as an error | all three |
| 14 | Settings: theme tiles nest inside a card inside a section; the selected "System" tile is faint; large title sits lower than on other screens | Settings | Nested containers; weak selection; title jumps | HIG, adversarial |
| 15 | Notification Times value truncates ("Every 3h, 8am - ...") on the phone | `play_phone_light_5_settings` (round 1) | Truncation | HIG |
| 16 | Hit areas: Saved share and heart, inquiry close X, "Next", the tradition pill look smaller than 44pt / 48dp | Saved, inquiry | Target size | HIG |
| 17 | iPad and tablets get phone layouts: 50-80% of the canvas is empty, Saved is one narrow column, Library leaves the right half blank, the Featured grid is ragged | all `ipad13_*`, `play_tablet7_*`, `play_tablet10_*` | Not adapted to regular width | all three |
| 18 | iPad and tablet navigation is a small floating vertical pill at mid-left; on iPad Today it crowds the card | `ipad13_light_1_today.png` | Neither the iPadOS top tab bar or sidebar nor a Material 3 rail | HIG, adversarial |
| 19 | iPad Library subtitles truncate ("Explore awareness teach...") despite free width; the Presence row shows an empty icon tile | `ipad13_*_2_library.png` | Truncation; missing glyph | adversarial |
| 20 | Today has a large empty zone above the card at store-thumbnail scale | `*_1_today.png` | Underfilled hero | HIG |
| 21 | On Android the floating capsule tab bar and glass pills are iOS idioms | `play_phone_*` | Non-native next to Material 3 | adversarial |

Capture-side findings that I own, and their state (scripts: `store/1.3.0/ios_shots.sh`, `store/1.3.0/play_shots.sh`, `store/1.3.0/render_captions.py`):
- Guided Inquiry: the retake uses the fixed "Who Am I?" inquiry. The ring still animates (item 11).
- Settings banner: Settings was dropped from the store set.
- Android "3G": hidden with demo mode `network -e mobile hide`.
- iOS charging bolt: accepted. `--batteryState charged --batteryLevel 100` still draws a green battery with a bolt on the iOS 27 simulator, and `discharged` is ignored. Cropping is not an option, because App Store sizes are exact.
- Dynamic Island: on the iOS 27 simulator it appears after about 10 s without input and hides on the next tap (measured: absent at 3 s and 8 s after launch, present at 15 s and 25 s, gone again after a tap). Every shot is now taken within 8 s of the last tap or launch, so no frame shows it.
- iPad windowed chrome: fixed. The Store iPad 13 simulator is set to Settings > Multitasking & Gestures > Full Screen Apps, which persists on the device. Settings is terminated before the app launches, so no "Settings" back link shows.
- Library ending on a clipped "FEATURED" header: on iPhone the shot scrolls about 140 pt first, so it ends on the Featured cards. iOS then minimizes the tab bar, which is native behaviour.
- iPad status-bar date: `simctl status_bar --time` rejects ISO dates on this Xcode, so the real date shows next to 9:41 AM.
- Captions: drafted in `captions.md` and rendered by `render_captions.py`. The dark background is the app's night ambient (indigo to plum with soft fields), and dark frames get a hairline device edge. The final render waits for the app fixes.
