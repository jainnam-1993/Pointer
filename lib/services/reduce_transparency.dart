/**
 * The platform's Reduce Transparency setting, live.
 *
 * iOS answers `isReduceTransparency` on `com.dailypointer/accessibility` from
 * `UIAccessibility.isReduceTransparencyEnabled` and pushes `reduceTransparencyChanged` when the user flips it.
 * Android has no public Reduce Transparency setting, so it answers false and [ReduceTransparency.of] falls back to
 * the system high-contrast flag there.
 *
 * A channel of its own, because `com.dailypointer/settings` already has its one Dart handler in the ambient clock.
 */
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ReduceTransparency extends ValueNotifier<bool> {
  static const MethodChannel channel = MethodChannel('com.dailypointer/accessibility');

  static final ReduceTransparency instance = ReduceTransparency._();

  ReduceTransparency._() : super(false) {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'reduceTransparencyChanged' && call.arguments is bool) value = call.arguments as bool;
    });
    _query();
  }

  Future<void> _query() async {
    try {
      value = await channel.invokeMethod<bool>('isReduceTransparency') ?? false;
    } on MissingPluginException {
      // Tests and platforms without the handler: keep false.
    } on PlatformException {
      // Keep false.
    }
  }

  /** Whether glass should fall back to its frosted, opaque form here: the platform setting or high contrast. */
  static bool of(BuildContext context) => instance.value || (MediaQuery.maybeHighContrastOf(context) ?? false);

  @visibleForTesting
  void debugSet(bool v) => value = v;
}
