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
  final String? commentary;
  final String? audioUrl;
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
    audioUrl: 'asset:///assets/audio/ramana_who_am_i.mp3',
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
    audioUrl: 'asset:///assets/audio/nisargadatta_world_in_you.mp3',
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
    audioUrl: 'asset:///assets/audio/spira_what_is_looking.mp3',
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
    audioUrl: 'asset:///assets/audio/tolle_present_moment.mp3',
  ),
  Pointing(
    id: 'con-3',
    content: 'You are the sky. Everything else is just the weather.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Pema Chödrön',
    audioUrl: 'asset:///assets/audio/pema_sky_weather.mp3',
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

  // === EXTRACTED FROM BOOK INDEX (61 quotes) ===
  Pointing(
    id: 'adv-101',
    content: 'You are the unchanging Awareness in which all activity takes place.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-102',
    content: 'God is not an object of any search; he remains the very subjectivity. You are not going to find him somewhere because he is everywhere.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'adv-103',
    content: 'Remember, untruth is not such a great hindrance as the belief in the truth. If you believe you stop seeking.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'adv-104',
    content: 'With me this guilt feeling has to be dropped. You are not a sinner and you are not guilty. Whatsoever you are the existence accepts you.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'adv-105',
    content: 'If you love yourself, to me you have become religious. And a person who loves himself, only he can love others.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'adv-106',
    content: 'Your life, all of your life, is your path to awakening. By resisting or not dealing with its challenges, you stay asleep to Reality.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'zen-101',
    content: 'I will teach you ignorance, unlearning, not knowledge. Only unlearning can help you.',
    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'zen-102',
    content: "Jesus says, 'Only those who are like small children will be able to enter God's kingdom.' I will try to make you like small children.",
    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'zen-103',
    content: 'Put aside knowledge, put aside seriousness, and thirdly, put aside the division of mind and body.',
    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'zen-104',
    content: 'Life is poetic, illogical. It is not like work, it is like play. Look at the trees, the animals, the birds; look at the sky: the whole existence is playful.',
    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'dir-101',
    content: 'Truth is a pathless land, and you cannot approach it by any path whatsoever, by any religion, by any sect.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'J. Krishnamurti',
  ),
  Pointing(
    id: 'dir-102',
    content: 'The observer is the observed. When one really understands this, all conflict comes to an end.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'J. Krishnamurti',
  ),
  Pointing(
    id: 'dir-103',
    content: 'Forget all you know about yourself; forget all you have ever thought about yourself; start as if you know nothing.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'J. Krishnamurti',
  ),
  Pointing(
    id: 'dir-104',
    content: 'Intelligence is the capacity to perceive the essential, what is. To awaken this capacity, in oneself and in others, is education.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'J. Krishnamurti',
  ),
  Pointing(
    id: 'dir-105',
    content: 'It is love alone that leads to right action. What brings order in the world is to love and let love do what it will.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'J. Krishnamurti',
  ),
  Pointing(
    id: 'dir-107',
    content: 'I, open, empty Awareness, am aware of thoughts, feelings, sensations and perceptions but am not made of any of these.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-108',
    content: 'When the body dies, the whirlpool dissolves. But nothing disappears, because all there is to the whirlpool is water.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-110',
    content: 'Allow your experience to appear exactly as it is from moment to moment, without trying to change it in any way.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-111',
    content: "Being aware or awareness itself is always present. It doesn't suddenly begin when it is noticed.",
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-112',
    content: 'What am I when all of these have been removed from me? Only the experience of being aware, only awareness itself.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-113',
    content: 'The direct path is really the path for our age. It requires no affiliation to any particular teacher or any tradition.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-117',
    content: "The sense of 'being myself' is our most ordinary, intimate and familiar experience. It pervades all experience.",
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-118',
    content: 'Peace and happiness are the natural condition of our essential being.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-119',
    content: 'No one becomes enlightened. Our being is simply relieved of an imaginary limitation.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-121',
    content: 'The essential discovery of all the great spiritual traditions is the identity of Consciousness and Reality.',
    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'con-101',
    content: 'The primary task of any good spiritual teaching is not to answer your questions, but to question your answers.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-102',
    content: 'Many spiritual seekers already live on a steady diet of spiritual junk food, those nice-sounding platitudes that have little or no transforming effect.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-103',
    content: 'Wake up or perish is the spiritual call of our times.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-105',
    content: "There is no such thing as an absolutely True thought. This doesn't mean that some thoughts are not truer than others.",
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-106',
    content: 'You are not your story. They are not your story about them. The world is not your story about the world.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-107',
    content: 'All true knowing arises out of the unknown and is an expression of the unknown.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'adv-107',
    content: 'God does not appear and disappear. He is reality itself. He is appearance itself.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-108',
    content: 'Find out who the seer is. Find out who you are. That does not disappear. Always it is there.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-109',
    content: 'This Freedom, this Wisdom, this Beauty, this Love is always inviting you. You only have to turn your attention within.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-110',
    content: 'What you are looking for is what is looking.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-111',
    content: 'Wake Up and Roar announces Freedom now. No postponement or delay.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'con-108',
    content: 'Yoga is pure science. No belief is needed.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'con-109',
    content: 'Yoga is not belief. It is an existential approach. You will come to the truth through your own experience.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'con-111',
    content: 'Yoga is the cessation of mind. When there is no mind, you are in yoga; when there is mind you are not in yoga.',
    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Osho',
  ),
  Pointing(
    id: 'adv-113',
    content: "The only true statement is 'I am'. All else is mere inference. By no effort can you change the 'I am' into 'I am-not'.",
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-114',
    content: "The seeker is he who is in search of himself. Give up all questions except one: 'Who am I?'",
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-115',
    content: 'Discover all that you are not -- body, feelings, thoughts, time, space. The very act of perceiving shows that you are not what you perceive.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-116',
    content: 'The clearer you understand you can be described in negative terms only, the quicker will you come to the end of your search.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-117',
    content: "The sense of being, of 'I am' is the first to emerge. Ask yourself whence it comes, or just watch it quietly.",
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-118',
    content: 'Behold, the real experiencer is not the mind, but myself, the light in which everything appears.',
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-119',
    content: "When pure awareness is attained, no need exists any more, not even for 'I am', which is but a useful pointer.",
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-120',
    content: "What you can point out as 'this' or 'that' cannot be yourself. You are nothing perceivable, or imaginable.",
    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
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
