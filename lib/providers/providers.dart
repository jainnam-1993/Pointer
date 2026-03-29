/**
 * Providers barrel file - Re-exports all domain-specific providers.
 *
 * Import this file to access all providers:
 * ```dart
 * import 'package:pointer/providers/providers.dart';
 * ```
 *
 * Or import specific domains for smaller import footprint:
 * - `core_providers.dart`: [SharedPreferences], [StorageService], [NotificationService]
 * - `settings_providers.dart`: Zen, OLED, typography, accessibility, theme, auto-advance
 * - `usage_providers.dart`: Daily usage tracking (analytics)
 * - `content_providers.dart`: [Pointing] navigation, favorites, teaching filters
 * - `donation_providers.dart`: Tip jar IAP via [DonationNotifier]
 */
library;

export 'content_providers.dart';
export 'core_providers.dart';
export 'donation_providers.dart';
export 'settings_providers.dart';
export 'usage_providers.dart';
