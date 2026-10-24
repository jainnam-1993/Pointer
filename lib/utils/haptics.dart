/**
 * The app's three haptic intents. Use these instead of [HapticFeedback] directly.
 *
 * Calm apps tap lightly: there is no medium or heavy impact here.
 * - [selection]: a choice changed (toggle, segment, tab, chip).
 * - [light]: a press landed (button, card, sheet open).
 * - [success]: something completed (purchase thanks, session end, saved).
 */
library;

import 'package:flutter/services.dart';

class Haptics {
  const Haptics._();

  /** A choice changed: toggles, tabs, chips, pickers. */
  static Future<void> selection() => HapticFeedback.selectionClick();

  /** A press landed: buttons, cards, opening a sheet. */
  static Future<void> light() => HapticFeedback.lightImpact();

  /** Something completed: a soft double tap (light, pause, selection). */
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.selectionClick();
  }
}
