// Inquiry Seed Data
// Traditional non-dual teaching techniques: koans, self-inquiry, direct pointing

import 'dart:math';
import '../models/inquiry.dart';
import 'pointings.dart'; // For Tradition enum

const inquiries = <Inquiry>[
  // === SELF-INQUIRY (Advaita) - 7 inquiries ===

  Inquiry(
    id: 'si_001',
    question: 'Who is aware of this thought?',
    setup: 'Notice your next thought.',
    followUp: 'Look for the one who noticed.',
    type: InquiryType.selfInquiry,
    tradition: Tradition.advaita,
    teacher: 'Ramana Maharshi',
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'si_002',
    question: 'To whom does this arise?',
    type: InquiryType.selfInquiry,
    tradition: Tradition.advaita,
    teacher: 'Ramana Maharshi',
    pauseDuration: Duration(seconds: 8),
  ),

  Inquiry(
    id: 'si_003',
    question: 'Who am I?',
    setup: 'Not "what am I" or "what should I be." Who am I right now?',
    followUp: 'Can you find the one asking?',
    type: InquiryType.selfInquiry,
    tradition: Tradition.advaita,
    teacher: 'Ramana Maharshi',
    pauseDuration: Duration(seconds: 12),
  ),

  Inquiry(
    id: 'si_004',
    question: 'What remains when all thoughts cease?',
    setup: 'Watch your thoughts arise and pass.',
    type: InquiryType.selfInquiry,
    tradition: Tradition.advaita,
    teacher: 'Nisargadatta Maharaj',
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'si_005',
    question: 'Am I the body or that which witnesses the body?',
    type: InquiryType.selfInquiry,
    tradition: Tradition.advaita,
    teacher: 'Ashtavakra Gita',
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'si_006',
    question: 'Who knows that I am?',
    setup: 'You know that you exist. You have the sense "I am."',
    followUp: 'Who is it that knows this "I am"?',
    type: InquiryType.selfInquiry,
    tradition: Tradition.advaita,
    teacher: 'Nisargadatta Maharaj',
    pauseDuration: Duration(seconds: 12),
  ),

  Inquiry(
    id: 'si_007',
    question: 'Where am I?',
    setup: 'Not where is your body. Where is the "I" that seems to be looking through these eyes?',
    type: InquiryType.selfInquiry,
    tradition: Tradition.advaita,
    pauseDuration: Duration(seconds: 10),
  ),

  // === KOANS (Zen) - 7 inquiries ===

  Inquiry(
    id: 'koan_001',
    question: 'What was your face before your parents were born?',
    type: InquiryType.koan,
    tradition: Tradition.zen,
    pauseDuration: Duration(seconds: 15),
    hasVisualElement: true,
  ),

  Inquiry(
    id: 'koan_002',
    question: 'What is the sound of one hand clapping?',
    type: InquiryType.koan,
    tradition: Tradition.zen,
    teacher: 'Hakuin Ekaku',
    pauseDuration: Duration(seconds: 12),
    hasVisualElement: true,
  ),

  Inquiry(
    id: 'koan_003',
    question: 'Does a dog have Buddha nature?',
    setup: 'A monk asked Zhaozhou, "Does a dog have Buddha nature?" Zhaozhou said, "Mu."',
    followUp: 'What is Mu?',
    type: InquiryType.koan,
    tradition: Tradition.zen,
    teacher: 'Zhaozhou',
    pauseDuration: Duration(seconds: 12),
  ),

  Inquiry(
    id: 'koan_004',
    question: 'Who is it that hears?',
    setup: 'Listen to any sound right now.',
    type: InquiryType.koan,
    tradition: Tradition.zen,
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'koan_005',
    question: 'If you meet the Buddha on the road, what do you do?',
    setup: 'The teaching says: kill him.',
    followUp: 'But who would do the killing?',
    type: InquiryType.koan,
    tradition: Tradition.zen,
    teacher: 'Linji Yixuan',
    pauseDuration: Duration(seconds: 12),
    hasVisualElement: true,
  ),

  Inquiry(
    id: 'koan_006',
    question: 'Where do you go when you die?',
    type: InquiryType.koan,
    tradition: Tradition.zen,
    pauseDuration: Duration(seconds: 15),
  ),

  Inquiry(
    id: 'koan_007',
    question: 'Show me your original face.',
    setup: 'Not the face in the mirror. Not the face you show others.',
    followUp: 'The face that was never born.',
    type: InquiryType.koan,
    tradition: Tradition.zen,
    pauseDuration: Duration(seconds: 12),
    hasVisualElement: true,
  ),

  // === DIRECT POINTING (Direct Path) - 7 inquiries ===

  Inquiry(
    id: 'dp_001',
    setup: 'Close your eyes for a moment.',
    question: 'What is aware of the darkness?',
    followUp: 'Is that awareness dark or light?',
    type: InquiryType.directPointing,
    tradition: Tradition.direct,
    teacher: 'Rupert Spira',
    pauseDuration: Duration(seconds: 12),
  ),

  Inquiry(
    id: 'dp_002',
    setup: 'Look at any object.',
    question: 'Can you find where seeing ends and the object begins?',
    type: InquiryType.directPointing,
    tradition: Tradition.direct,
    teacher: 'Francis Lucille',
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'dp_003',
    question: 'Are you aware?',
    followUp: 'Notice: you didn\'t have to do anything to become aware.',
    type: InquiryType.directPointing,
    tradition: Tradition.direct,
    teacher: 'Rupert Spira',
    pauseDuration: Duration(seconds: 8),
  ),

  Inquiry(
    id: 'dp_004',
    setup: 'Notice the sense of being present right now.',
    question: 'Is this presence located in time or space?',
    type: InquiryType.directPointing,
    tradition: Tradition.direct,
    teacher: 'Jean Klein',
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'dp_005',
    question: 'Are you aware of being aware?',
    setup: 'Don\'t think about it. Simply notice.',
    followUp: 'Awareness is aware of itself.',
    type: InquiryType.directPointing,
    tradition: Tradition.direct,
    teacher: 'Rupert Spira',
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'dp_006',
    setup: 'Think of a past memory.',
    question: 'Where is that memory appearing?',
    followUp: 'Is the space in which it appears made of the past or the present?',
    type: InquiryType.directPointing,
    tradition: Tradition.direct,
    teacher: 'Francis Lucille',
    pauseDuration: Duration(seconds: 12),
  ),

  Inquiry(
    id: 'dp_007',
    question: 'Is awareness separate from what it is aware of?',
    setup: 'Look at your current experience.',
    type: InquiryType.directPointing,
    tradition: Tradition.direct,
    teacher: 'Rupert Spira',
    pauseDuration: Duration(seconds: 10),
  ),

  // === CONTEMPORARY CONTEMPLATION - 6 inquiries ===

  Inquiry(
    id: 'cont_001',
    question: 'Can you find the boundary between you and your experience?',
    setup: 'Look at any object in your visual field.',
    type: InquiryType.contemplation,
    tradition: Tradition.contemporary,
    pauseDuration: Duration(seconds: 8),
  ),

  Inquiry(
    id: 'cont_002',
    question: 'What is it like to be you right now?',
    setup: 'Not what are you thinking or feeling. What is the nature of experiencing itself?',
    type: InquiryType.contemplation,
    tradition: Tradition.contemporary,
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'cont_003',
    question: 'Is there a you separate from awareness?',
    followUp: 'Or are you the awareness in which everything appears?',
    type: InquiryType.contemplation,
    tradition: Tradition.contemporary,
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'cont_004',
    setup: 'Notice that you are aware.',
    question: 'Has this awareness ever not been present?',
    type: InquiryType.contemplation,
    tradition: Tradition.contemporary,
    pauseDuration: Duration(seconds: 10),
  ),

  Inquiry(
    id: 'cont_005',
    question: 'What is the distance between you and this moment?',
    setup: 'Can there be any separation between awareness and now?',
    type: InquiryType.contemplation,
    tradition: Tradition.contemporary,
    pauseDuration: Duration(seconds: 8),
  ),

  Inquiry(
    id: 'cont_006',
    question: 'Are thoughts happening to you or as you?',
    setup: 'Watch a thought arise.',
    followUp: 'Where does it come from? Where does it go?',
    type: InquiryType.contemplation,
    tradition: Tradition.contemporary,
    pauseDuration: Duration(seconds: 12),
  ),
];

// Helper functions

final _random = Random();

/// Get a random inquiry, optionally filtered by type or tradition
Inquiry getRandomInquiry({InquiryType? type, Tradition? tradition}) {
  var filtered = inquiries.toList();

  if (type != null) {
    filtered = filtered.where((i) => i.type == type).toList();
  }
  if (tradition != null) {
    filtered = filtered.where((i) => i.tradition == tradition).toList();
  }

  if (filtered.isEmpty) return inquiries.first;
  return filtered[_random.nextInt(filtered.length)];
}

/// Get all inquiries of a specific type
List<Inquiry> getInquiriesByType(InquiryType type) {
  return inquiries.where((i) => i.type == type).toList();
}

/// Get all inquiries from a specific tradition
List<Inquiry> getInquiriesByTradition(Tradition tradition) {
  return inquiries.where((i) => i.tradition == tradition).toList();
}
