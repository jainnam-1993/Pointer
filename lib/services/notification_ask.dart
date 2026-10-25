import 'package:shared_preferences/shared_preferences.dart';

/**
 * When the app asks for notification permission (ux-simplify.md P11).
 *
 * Not at launch: the first Save is the moment a reminder makes sense. The
 * ask happens at most once. Whatever the answer, a denial included, the
 * state becomes [asked] and the app never asks again; Settings keeps the
 * switch for anyone who changes their mind.
 */
enum NotificationAsk {
  /** A new install that finished onboarding after this change. */
  notAsked,

  /** The prompt was shown, or the user went through the old onboarding, which asked. */
  asked,
}

/** Persists [NotificationAsk] and runs the one ask. */
class NotificationAskPolicy {
  static const key = 'pointer_notification_ask';
  static const _onboardingKey = 'pointer_onboarding_completed';

  final SharedPreferences _prefs;
  final Future<bool> Function() _requestPermission;
  final Future<void> Function() _enableNotifications;

  NotificationAskPolicy(this._prefs, {required Future<bool> Function() requestPermission, required Future<void> Function() enableNotifications})
    : _requestPermission = requestPermission,
      _enableNotifications = enableNotifications;

  /**
   * The stored state. A missing value means an install from before this
   * change: if it finished onboarding, the old onboarding already asked.
   */
  NotificationAsk get state {
    final stored = _prefs.getString(key);
    if (stored == NotificationAsk.notAsked.name) return NotificationAsk.notAsked;
    if (stored == NotificationAsk.asked.name) return NotificationAsk.asked;
    return (_prefs.getBool(_onboardingKey) ?? false) ? NotificationAsk.asked : NotificationAsk.notAsked;
  }

  /** Onboarding ends without asking; the first Save asks instead. */
  Future<void> onOnboardingFinished() => _prefs.setString(key, NotificationAsk.notAsked.name);

  /** Call after any Save. Asks once, records it before the prompt so a crash or kill can't repeat it. */
  Future<void> onSaved() async {
    if (state == NotificationAsk.asked) return;
    await _prefs.setString(key, NotificationAsk.asked.name);
    if (await _requestPermission()) await _enableNotifications();
  }
}
