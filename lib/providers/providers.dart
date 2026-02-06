/// Providers barrel file - Re-exports all domain-specific providers
///
/// Import this file to access all providers:
/// ```dart
/// import 'package:pointer/providers/providers.dart';
/// ```
///
/// Or import specific domains for smaller import footprint:
/// - core_providers.dart: SharedPreferences, storage, notifications
/// - settings_providers.dart: Zen, OLED, typography, accessibility, theme
/// - subscription_providers.dart: Premium, freemium
/// - content_providers.dart: Pointings, favorites, teaching filter
library;

export 'content_providers.dart';
export 'core_providers.dart';
export 'donation_providers.dart';
export 'settings_providers.dart';
export 'subscription_providers.dart';
