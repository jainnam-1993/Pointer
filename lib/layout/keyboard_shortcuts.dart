import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/**
 * Hardware keyboard shortcuts for iPad and tablet keyboards.
 *
 * Every command binds both Cmd (meta, iPadOS) and Ctrl (Android, ChromeOS), so
 * the same keys work on any keyboard. The shell maps [tabShortcuts]; Home maps
 * [homeShortcuts] around its own autofocused node, so the keys reach Home only
 * while Home is on screen. Escape closing a sheet or dialog comes from the
 * modal routes' own DismissIntent and needs nothing here.
 */
class SelectTabIntent extends Intent {
  final int index;

  const SelectTabIntent(this.index);
}

/** Show the next pointing on Home. */
class NextPointingIntent extends Intent {
  const NextPointingIntent();
}

/** Show the previous pointing on Home. */
class PreviousPointingIntent extends Intent {
  const PreviousPointingIntent();
}

/** Save the current pointing on Home. */
class SavePointingIntent extends Intent {
  const SavePointingIntent();
}

/** Leave focus (zen) mode on Home. */
class ExitFocusModeIntent extends Intent {
  const ExitFocusModeIntent();
}

/** One digit per tab: Today, Library, Saved (main_shell.dart shellTabs). */
const _tabDigits = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3];

/** Cmd+1 to Cmd+4 (and Ctrl+1 to Ctrl+4) select the four tabs. */
final Map<ShortcutActivator, Intent> tabShortcuts = {
  for (var i = 0; i < _tabDigits.length; i++) ...{
    SingleActivator(_tabDigits[i], meta: true): SelectTabIntent(i),
    SingleActivator(_tabDigits[i], control: true): SelectTabIntent(i),
  },
};

/**
 * Home keys: the right or down arrow for the next pointing, the left or up
 * arrow for the previous one, Cmd+S (Ctrl+S) to save. Space also shows the next
 * pointing, but only while Home's own node has focus (see [isNextPointingKey]),
 * so Space still activates a focused button.
 */
const Map<ShortcutActivator, Intent> homeShortcuts = {
  SingleActivator(LogicalKeyboardKey.arrowRight): NextPointingIntent(),
  SingleActivator(LogicalKeyboardKey.arrowDown): NextPointingIntent(),
  SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousPointingIntent(),
  SingleActivator(LogicalKeyboardKey.arrowUp): PreviousPointingIntent(),
  SingleActivator(LogicalKeyboardKey.keyS, meta: true): SavePointingIntent(),
  SingleActivator(LogicalKeyboardKey.keyS, control: true): SavePointingIntent(),
};

/** Escape leaves focus mode; mapped only while focus mode is on. */
const Map<ShortcutActivator, Intent> focusModeShortcuts = {SingleActivator(LogicalKeyboardKey.escape): ExitFocusModeIntent()};

/** Whether [event] is the bare Space key press that shows the next pointing. */
bool isNextPointingKey(KeyEvent event) =>
    event is KeyDownEvent &&
    event.logicalKey == LogicalKeyboardKey.space &&
    !HardwareKeyboard.instance.isMetaPressed &&
    !HardwareKeyboard.instance.isControlPressed;
