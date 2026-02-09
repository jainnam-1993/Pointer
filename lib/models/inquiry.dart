/**
 * Inquiry data model for non-dual teaching techniques.
 *
 * Represents guided self-inquiry practices including koans, self-inquiry,
 * direct pointing, and contemplation exercises. Each inquiry has timed
 * phases rendered by [InquiryPlayerScreen].
 *
 * See also:
 * - [InquiryType] for the four categories of inquiry
 * - [Tradition] from `pointings.dart` for lineage classification
 */
library;

import '../data/pointings.dart';

/** Category of non-dual inquiry practice. */
enum InquiryType {
  /** Traditional Zen paradox designed to short-circuit conceptual thinking. */
  koan,

  /** Advaita-style "Who am I?" investigation into the nature of the self. */
  selfInquiry,

  /** A teacher's direct indication of one's true nature. */
  directPointing,

  /** Open-ended reflection on a spiritual theme. */
  contemplation,
}

/**
 * A guided non-dual inquiry with timed presentation phases.
 *
 * Inquiries are displayed in [InquiryPlayerScreen] with an optional setup,
 * the core question, a pause for contemplation, and an optional follow-up.
 */
class Inquiry {
  /** Unique identifier (e.g., `'si_001'`, `'koan_003'`). */
  final String id;

  /** The core inquiry question presented to the user. */
  final String question;

  /** Optional context or instruction shown before the question. */
  final String? setup;

  /** Optional follow-up prompt shown after the pause. */
  final String? followUp;

  /** The category of this inquiry. See [InquiryType]. */
  final InquiryType type;

  /** Source spiritual tradition. Reuses [Tradition] from `pointings.dart`. */
  final Tradition tradition;

  /** Teacher or text attribution (e.g., `'Ramana Maharshi'`). */
  final String? teacher;

  /** Duration of the contemplative pause after the question is shown. */
  final Duration pauseDuration;

  /** Whether to display an animated visual element during the pause phase. */
  final bool hasVisualElement;

  const Inquiry({
    required this.id,
    required this.question,
    this.setup,
    this.followUp,
    required this.type,
    required this.tradition,
    this.teacher,
    this.pauseDuration = const Duration(seconds: 10),
    this.hasVisualElement = false,
  });
}
