// Inquiry - Non-dual teaching techniques
// Koans, self-inquiry, direct pointing, and contemplations

import '../data/pointings.dart';

enum InquiryType {
  koan,
  selfInquiry,
  directPointing,
  contemplation,
}

class Inquiry {
  final String id;
  final String question; // The inquiry itself
  final String? setup; // Optional context before question
  final String? followUp; // Optional follow-up after pause
  final InquiryType type; // koan, selfInquiry, directPointing, contemplation
  final Tradition tradition; // Source tradition (reuse from pointings)
  final String? teacher; // Attribution
  final Duration pauseDuration; // How long to pause after question
  final bool hasVisualElement; // Whether to show animation

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
