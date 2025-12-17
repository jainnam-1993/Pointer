// Pointer - Curated Non-Dual Pointings
// Data models and content

import 'dart:math';

enum Tradition { advaita, zen, direct, contemporary, original }

enum PointingContext { morning, midday, evening, stress, general }

class Pointing {
  final String id;
  final String content;
  final String? instruction;
  final Tradition tradition;
  final List<PointingContext> contexts;
  final String? teacher;
  final String? source;
  /// Extended commentary for premium users - provides deeper context
  final String? commentary;
  /// Audio URL for guided reading/teaching (premium feature)
  final String? audioUrl;
  /// Video URL for video transmissions (premium feature)
  final String? videoUrl;

  const Pointing({
    required this.id,
    required this.content,
    this.instruction,
    required this.tradition,
    required this.contexts,
    this.teacher,
    this.source,
    this.commentary,
    this.audioUrl,
    this.videoUrl,
  });
}

class TraditionInfo {
  final String name;
  final String icon;
  final String description;

  const TraditionInfo({
    required this.name,
    required this.icon,
    required this.description,
  });
}

const traditions = <Tradition, TraditionInfo>{
  Tradition.advaita: TraditionInfo(
    name: 'Advaita Vedanta',
    icon: 'ॐ',
    description: 'The path of non-duality. You are already what you seek.',
  ),
  Tradition.zen: TraditionInfo(
    name: 'Zen Buddhism',
    icon: '◯',
    description: 'Direct pointing. No words, no concepts.',
  ),
  Tradition.direct: TraditionInfo(
    name: 'Direct Path',
    icon: '◇',
    description: 'Contemporary clarity. Awareness recognizing itself.',
  ),
  Tradition.contemporary: TraditionInfo(
    name: 'Contemporary',
    icon: '✦',
    description: 'Modern teachers. Ancient truth, fresh words.',
  ),
  Tradition.original: TraditionInfo(
    name: 'Original',
    icon: '∞',
    description: 'Written for now. This moment, this life.',
  ),
};

const pointings = <Pointing>[
  // === ADVAITA ===
  Pointing(
    id: 'adv-1',
    content: 'What is aware of this moment?',
    instruction: "Just look. Don't answer.",
    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    commentary: 'This is the fundamental inquiry of Advaita Vedanta. Rather than seeking an answer in thought, simply turn attention to the source of awareness itself. Notice that whatever you find—a thought, an image, a sensation—is being observed by something prior. Rest in that which is aware, before the mind formulates any response.',
    // Sample audio for guided pointing (replace with actual CDN URL in production)
    audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  ),
  Pointing(
    id: 'adv-2',
    content: 'You are not the body. The body is not yours. You are not the doer. What are you?',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-3',
    content: 'Ask yourself: "Who am I?" Don\'t answer with a thought. What remains when no answer comes?',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Ramana Maharshi',
    commentary: 'Ramana Maharshi\'s self-inquiry is not about finding an answer, but about exhausting the mind\'s habit of identification. Each time a thought arises ("I am my name," "I am my body"), trace it back to its source. What precedes the thought? Who is aware of the arising? Stay with the question until the questioner dissolves into pure awareness.',
  ),
  Pointing(
    id: 'adv-4',
    content: 'Bondage is believing you can be bound. Freedom is seeing you were never the one who could be.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-5',
    content: 'You are not in the world. The world is in you.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-6',
    content: 'The question "Who am I?" is not meant to get an answer. It is meant to dissolve the questioner.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),

  // === ZEN ===
  Pointing(
    id: 'zen-1',
    content: 'What was your face before your parents were born?',
    instruction: "Don't think. Look.",
    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'zen-2',
    content: 'If you meet the Buddha on the road, who is walking?',
    tradition: Tradition.zen,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'zen-3',
    content: 'Before thinking, what are you?',
    tradition: Tradition.zen,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'zen-4',
    content: 'The finger pointing at the moon is not the moon. What is looking at the finger?',
    tradition: Tradition.zen,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'zen-5',
    content: 'Sitting quietly, doing nothing, spring comes, and the grass grows by itself.',
    tradition: Tradition.zen,
    contexts: [PointingContext.evening, PointingContext.stress],
    teacher: 'Bashō',
  ),

  // === DIRECT PATH ===
  Pointing(
    id: 'dir-1',
    content: "Notice: you are already aware. You didn't have to do anything to become aware.",
    tradition: Tradition.direct,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'dir-2',
    content: 'Turn attention back to its source. What is looking?',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-3',
    content: 'Awareness is not an experience. It is that which experiences.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-4',
    content: 'You are not the voice in your head. You are what hears it.',
    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'dir-5',
    content: 'What you are looking for is what is looking.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Francis of Assisi / Advaita',
  ),

  // === CONTEMPORARY ===
  Pointing(
    id: 'con-1',
    content: 'Life is not happening to you. Life is happening as you.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'con-2',
    content: 'The present moment is all you ever have. There is never a time when your life is not "this moment."',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-3',
    content: 'You are the sky. Everything else is just the weather.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Pema Chödrön',
  ),

  // === ORIGINAL ===
  Pointing(
    id: 'org-1',
    content: 'Before you check your phone: What is already awake?',
    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-2',
    content: "The deadline is real. The one who's stressed about it—can you find them?",
    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-3',
    content: "Notice: you didn't start being aware. Awareness was here before the first thought.",
    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-4',
    content: 'Thoughts about the problem are arising. What are they arising in?',
    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-5',
    content: 'The day happened. But did it happen TO you, or AS you?',
    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-6',
    content: "Rest doesn't come from stopping. Notice what has never been disturbed.",
    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-7',
    content: "Before reading this, notice: you're already aware.",
    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-8',
    content: "You're scrolling for something. What if it's already here?",
    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
];

// Helper functions

final _random = Random();

Pointing getRandomPointing({Tradition? tradition, PointingContext? context}) {
  var filtered = pointings.toList();

  if (tradition != null) {
    filtered = filtered.where((p) => p.tradition == tradition).toList();
  }
  if (context != null) {
    filtered = filtered.where((p) => p.contexts.contains(context)).toList();
  }

  if (filtered.isEmpty) return pointings.first;
  return filtered[_random.nextInt(filtered.length)];
}

List<Pointing> getPointingsByTradition(Tradition tradition) {
  return pointings.where((p) => p.tradition == tradition).toList();
}

List<Pointing> getPointingsByContext(PointingContext context) {
  return pointings.where((p) => p.contexts.contains(context)).toList();
}
