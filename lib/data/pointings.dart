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
    content: "Notice: you are already aware. You didn\'t have to do anything to become aware.",
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
    content: "The deadline is real. The one who\'s stressed about it—can you find them?",
    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-3',
    content: "Notice: you didn\'t start being aware. Awareness was here before the first thought.",
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
    content: "Rest doesn\'t come from stopping. Notice what has never been disturbed.",
    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-7',
    content: "Before reading this, notice: you\'re already aware.",
    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-8',
    content: "You're scrolling for something. What if it\'s already here?",
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
    content: "Being aware or awareness itself is always present. It doesn\'t suddenly begin when it is noticed.",
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
    content: "There is no such thing as an absolutely True thought. This doesn\'t mean that some thoughts are not truer than others.",
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

  // === MERGED CONTENT ===

  // --- advaita_quotes.dart ---
  Pointing(
    id: 'adv-121',
    content: 'The question "Who am I?" is not really meant to get an answer. It is meant to dissolve the questioner.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-122',
    content: 'You are not what you take yourself to be. Find out what you are. Watch the sense "I am", find your real Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-123',
    content: 'The Self is not something to be gained. You are already That. Just stop imagining yourself to be something else.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-124',
    content: 'Brahman alone is real, the world is illusory, and the individual soul is non-different from Brahman.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-125',
    content: 'You are pure consciousness, free and unchanging. All else is mere appearance.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-126',
    content: 'The self-effulgent Self is the witness of all. Rest in That which needs no support.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-127',
    content: 'If you make the least effort to attain the Self, it will show that you are ignorant of its nature.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-128',
    content: 'You are the unchanging seer of all that changes. Recognize this and be free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-129',
    content: 'There is nothing to practice. All practices are in consciousness. You are prior to consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-130',
    content: 'The one who seeks liberation is the obstacle to liberation. Give up seeking and you are free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-131',
    content: 'Your own Self-Realization is the greatest service you can render the world.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-132',
    content: 'Wisdom tells me I am nothing. Love tells me I am everything. Between the two my life flows.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-133',
    content: 'Wake up from the dream of being a person. You are the infinite ocean, not the wave.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-134',
    content: 'Through discrimination between the eternal and the non-eternal, the wise attain liberation.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-135',
    content: 'The knower of the Self transcends sorrow. This is the highest truth.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-136',
    content: 'Be still and know that you are That. All seeking is in ignorance of what already is.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-137',
    content: 'The Self is ever realized. There is no such thing as a new realization.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-138',
    content: 'Let everything be as it is. You are the space in which it all appears.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-139',
    content: 'When you realize you are nothing, that is wisdom. When you realize you are everything, that is love.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-140',
    content: 'All effort to become something is bondage. Simply be what you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-141',
    content: 'The thought "I am the body" is the thread on which all other thoughts are strung.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-142',
    content: 'The real is that which does not change. Find that and rest there.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-143',
    content: 'There is no path to freedom. Freedom is the absence of the one who seeks a path.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-144',
    content: 'The Self shines by its own light. It needs no proof of its existence.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-145',
    content: 'You are not bound. You are free. You are awareness itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-146',
    content: 'The witness is never touched by what it witnesses. You are That witness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-147',
    content: 'The Self is always present. You cannot attain what is already yours.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-148',
    content: 'Stop trying to become. You already are. Just discover it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-149',
    content: 'The world is a dream. Wake up and see that you are the dreamer.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-150',
    content: 'Surrender is not giving up. It is the recognition that there is no one to give up anything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-151',
    content: 'Find out who is having this experience. That is the direct path to Self-realization.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-152',
    content: 'The mind creates the world. When the mind is still, the world disappears.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-153',
    content: 'Stop waiting for enlightenment. It is not an event in time. You are already That.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-154',
    content: 'The ignorant person identifies with the body. The wise one knows "I am Brahman."',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-155',
    content: 'Liberation is seeing that there was never any bondage. The chains were always imaginary.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-156',
    content: 'The Self is not hidden. You are looking through it, not at it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-157',
    content: 'All efforts are in the realm of the mind. The Self is prior to effort.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-158',
    content: 'You are the silence in which all sounds appear and disappear.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-159',
    content: 'The body is in you, not you in the body. The world is in you, not you in the world.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-160',
    content: 'Non-doership is not about stopping action. It is recognizing that actions happen by themselves.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-161',
    content: 'Be what you are. That is the sum and substance of all spiritual teaching.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-162',
    content: 'Once you realize that the road is the goal and that you are always on the road, there is nothing to reach.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-163',
    content: 'The ego is just a thought. When you stop giving it attention, it dissolves.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-164',
    content: 'Ignorance is mistaking the non-Self for the Self. Knowledge is the recognition of the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-165',
    content: 'You are not the doer of actions. Actions happen in you, but you remain untouched.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-166',
    content: 'The witness consciousness is the eternal observer, never observed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-167',
    content: 'The Self is not something that can be lost. You only forgot what you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-168',
    content: 'Peace is your nature. You need not search for it elsewhere.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-169',
    content: 'All suffering comes from identification with the false. Know yourself as the true, and suffering ends.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-170',
    content: 'The separate self is an illusion. See through it and be free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-171',
    content: 'Self-inquiry is not a mental practice. It is the dissolution of the mind itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-172',
    content: 'You are beyond birth and death. How can you be born or die?',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-173',
    content: 'The truth is simple: You are not the person. You are the awareness in which the person appears.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-174',
    content: 'The Self is self-evident. It does not require proof from scriptures or sages.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-175',
    content: 'Freedom is recognizing that you were never bound. Bondage was only a belief.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-176',
    content: 'Rest in your own being. That is the highest meditation.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-177',
    content: 'The Self does not come and go. Only the thoughts come and go.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-178',
    content: 'Everything is appearing in you. You are not appearing in anything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-179',
    content: 'There is no path to the Self because you are already That. Drop the idea of becoming.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-180',
    content: 'The sense of separation is the root of all suffering. See its falseness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-181',
    content: 'Keep the attention on the "I" feeling until it dissolves into the source.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-182',
    content: 'The moment you know yourself as you are, all problems dissolve.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-183',
    content: 'Do not identify with passing states. You are what remains when all states disappear.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-184',
    content: 'The world appears and disappears, but the Self remains constant.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-185',
    content: 'The enlightened one sees no difference between action and inaction.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-186',
    content: 'You are the unchanging background of all experience.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-187',
    content: 'All states are temporary. The Self alone is permanent.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-188',
    content: 'Let the world be. Just discover who you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-189',
    content: 'Consciousness is all there is. The world is just a play of consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-190',
    content: 'True surrender is the recognition that there is no one to surrender.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-191',
    content: 'Silence is the true teaching. Words only point to it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-192',
    content: 'The seeker is the sought. When this is seen, seeking ends.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-193',
    content: 'This moment, right now, is the only reality. Everything else is memory or imagination.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-194',
    content: 'That which perceives change cannot itself be changing. You are That.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-195',
    content: 'The Self needs no enlightenment. It is already perfect and complete.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-196',
    content: 'Be aware of being aware. That is all.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-197',
    content: 'The Self is not an object of knowledge. It is the knower itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-198',
    content: 'Nothing you think you are is true. Find out what remains when all ideas are dropped.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-199',
    content: 'Peace is not something to be attained. It is what you are when the mind is quiet.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-200',
    content: 'The person you think you are is just a collection of thoughts. Let them go.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-201',
    content: 'When the "I-thought" arises, inquire within: To whom does this arise?',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-202',
    content: 'Give up all questions except one: Who am I? Eventually this question will destroy itself and the questioner.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-203',
    content: 'Freedom is not somewhere else. It is here, when the mind stops creating a future.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-204',
    content: 'The world is neither real nor unreal. It is an appearance in consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-205',
    content: 'In deep sleep, there is no world, no body, no mind. Yet you exist. You are That.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-206',
    content: 'The witness watches everything but is touched by nothing.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-207',
    content: 'Do not try to become the Self. Give up trying to be what you are not.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-208',
    content: 'The mind cannot grasp the Self. It can only disappear into it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-209',
    content: 'You are not in the world. The world is in you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-210',
    content: 'All spiritual practices are meant to quiet the mind. The Self needs no practice.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-211',
    content: 'There is no inside or outside. These are concepts of the mind.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-212',
    content: 'The moment you stop wanting anything, you have everything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-213',
    content: 'Keep quiet. All will be revealed in that quietness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-214',
    content: 'The Self is the light by which everything else is known.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-215',
    content: 'You are the infinite ocean pretending to be a wave.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-216',
    content: 'Awareness is always present. It is the constant factor in all experience.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-217',
    content: 'You cannot reach the Self because you are it already.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-218',
    content: 'Let thoughts come and go. You remain as you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-219',
    content: 'The only problem is the belief that you are a separate individual.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-220',
    content: 'Stop seeking. Start being.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-221',
    content: 'The "I" that you seek is the "I" that is seeking.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-222',
    content: 'All your problems exist in time. When you are in the timeless now, there are no problems.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-223',
    content: 'The present moment is the doorway to eternity.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-224',
    content: 'You are not the experiencer. You are the pure experience itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-225',
    content: 'Give up the idea that you are a person bound by time and space.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-226',
    content: 'The witness is your true nature. Everything else is observed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-227',
    content: 'The Self is complete in itself. It needs nothing.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-228',
    content: 'All seeking is in duality. When duality collapses, you are home.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-229',
    content: 'The world is a thought. When the thought goes, the world goes.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-230',
    content: 'Liberation is not a future event. It is the recognition of what is always true.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-231',
    content: 'Thoughts are like visitors. Let them come and go without holding on.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-232',
    content: 'You are the awareness that is aware of the lack of awareness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-233',
    content: 'All suffering is a case of mistaken identity.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-234',
    content: 'The Self is not something to be attained. Remove ignorance and it shines by itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-235',
    content: 'The one who realizes the Self has nothing to do and nowhere to go.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-236',
    content: 'Rest as the witness and watch the drama of life unfold.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-237',
    content: 'You are already free. You only need to stop believing you are bound.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-238',
    content: 'Everything that can be observed is not you. You are the observer.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-239',
    content: 'The world appears real only because you have not investigated it deeply enough.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-240',
    content: 'Give up becoming. Simply be.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-241',
    content: 'The heart is the seat of the Self. Sink into the heart and be still.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-242',
    content: 'The past is a memory. The future is a thought. Reality is now.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-243',
    content: 'The greatest obstacle is the belief that there is an obstacle.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-244',
    content: 'Consciousness is not personal. It is universal.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-245',
    content: 'When you see that you do nothing, you have arrived.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-246',
    content: 'The Self is like the sky. Clouds come and go, but the sky remains.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-247',
    content: 'There is no one to realize anything. Realization is the absence of the illusion of a separate person.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-248',
    content: 'Stay as awareness. That is the simplest and most direct path.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-249',
    content: 'The universe is a projection of consciousness, like a dream.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-250',
    content: 'Enlightenment is not an achievement. It is the understanding that there is nothing to achieve.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-251',
    content: 'The one who asks "Am I realized?" is not realized. When you are That, there is no question.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-252',
    content: 'To know that you are is enough. All else is distraction.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-253',
    content: 'No practice will give you what you already are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-254',
    content: 'Brahman is not an object of thought. It is the subject that thinks.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-255',
    content: 'Joy and sorrow are states of mind. You are beyond both.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-256',
    content: 'The witness consciousness is untouched by anything it witnesses.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-257',
    content: 'Meditation is not something the Self does. The Self is meditation itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-258',
    content: 'Do not try to control the mind. Simply step back and watch it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-259',
    content: 'If there is a problem, know that it exists only in the mind.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-260',
    content: 'The guru is not a person. The guru is the Self itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-261',
    content: 'Surrender the ego and the Self will shine forth naturally.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-262',
    content: 'Stop imagining yourself to be this or that. You are the infinite.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-263',
    content: 'The now has no duration. It is timeless.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-264',
    content: 'You cannot find the Self by searching. It is closer than close.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-265',
    content: 'The realized one knows that nothing ever happens.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-266',
    content: 'You are the pure witness, untouched by the dance of existence.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-267',
    content: 'Do not use the mind to find the Self. The mind is an obstacle.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-268',
    content: 'True freedom is to have no position at all.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-269',
    content: 'If you think you are the body, you will suffer. Know yourself as consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-270',
    content: 'The thought "I am the doer" is the root of bondage.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-271',
    content: 'Abide as the Self, which is the witness of all.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-272',
    content: 'The sense "I am" is the bridge between the Self and the world. Stay with "I am" and go beyond it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-273',
    content: 'When you stop chasing enlightenment, it reveals itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-274',
    content: 'The appearance of multiplicity is due to ignorance. In truth, there is only one.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-275',
    content: 'The mind is a restless monkey. Do not follow it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-276',
    content: 'Remain as you are. That is the highest teaching.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-277',
    content: 'The Self is ever-present. It is the ignorance of it that needs to be removed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-278',
    content: 'You are the screen on which all experience appears.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-279',
    content: 'Nothing touches you. You are the untouched witness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-280',
    content: 'Actions happen through the body, but the Self remains uninvolved.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-281',
    content: 'The scriptures all point to one truth: You are That.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-282',
    content: 'All experiences come and go. You are what remains.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-283',
    content: 'The final understanding is that there is no one to understand anything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-284',
    content: 'The Self is self-luminous. It does not depend on anything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-285',
    content: 'When the mind is quiet, the Self is obvious.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-286',
    content: 'The witness never participates. It only observes.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-287',
    content: 'All efforts imply someone who efforts. The Self is effortless.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-288',
    content: 'Do not believe your thoughts. You are not what you think.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-289',
    content: 'The entire universe exists in your consciousness, not the other way around.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-290',
    content: 'Surrender is not an action. It is the cessation of the illusion of being a doer.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-291',
    content: 'The ego is just a false notion. See its falseness and it vanishes.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-292',
    content: 'The highest state is the natural state. Just be.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-293',
    content: 'Time is a concept. The eternal now is what is real.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-294',
    content: 'The ignorant see many. The wise see only the one Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-295',
    content: 'You are the infinite masquerading as the finite.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-296',
    content: 'Be the witness and all problems dissolve.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-297',
    content: 'The Self is not attained. Ignorance is removed, and it shines.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-298',
    content: 'Let everything be. Nothing needs fixing.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-299',
    content: 'The world is a mirage. Only consciousness is real.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-300',
    content: 'Liberation is not a state. It is the absence of bondage.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-301',
    content: 'Do not look for the Self. Be the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-302',
    content: 'The only mistake you make is to think you are a person.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-303',
    content: 'Realization is not about gaining something. It is about losing the illusion.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-304',
    content: 'The Self is beyond all attributes. It is pure being.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-305',
    content: 'The universe arises and subsides in you. You are the eternal.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-306',
    content: 'Stand as the witness. Everything else is drama.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-307',
    content: 'There is no becoming the Self. There is only being the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-308',
    content: 'You are not limited by the body or the mind. You are the limitless awareness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-309',
    content: 'The world is consciousness appearing as form.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-310',
    content: 'To surrender is to understand there is no one to surrender.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-311',
    content: 'The inquiry "Who am I?" should be continuous until the ego dissolves.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-312',
    content: 'You are complete as you are. Nothing is lacking.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-313',
    content: 'Be here now. That is the only place you can be free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-314',
    content: 'The Self is never not known. It is the ever-present reality.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-315',
    content: 'All phenomena are passing. The Self alone is permanent.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-316',
    content: 'Witnessing is not an action. It is your very nature.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-317',
    content: 'You do not have to become aware. You are awareness itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-318',
    content: 'Let go of all ideas about yourself. What remains is what you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-319',
    content: 'There is no distance between you and the Self. You are it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-320',
    content: 'Non-doership is not passivity. It is understanding that all action happens spontaneously.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-321',
    content: 'The world is like a dream that appears in the waking state.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-322',
    content: 'Give up all identifications. You are none of them.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-323',
    content: 'The mind seeks freedom. The Self is freedom.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-324',
    content: 'Consciousness is one. The appearance of many is illusion.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-325',
    content: 'You are the source from which all experience arises.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-326',
    content: 'The witness is the silent presence behind all activity.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-327',
    content: 'The Self cannot be realized through effort. Effort is in the realm of the ego.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-328',
    content: 'All suffering is based on misidentification. Know yourself truly.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-329',
    content: 'The sense of separation is the only illusion. See through it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-330',
    content: 'When you understand there is no doer, peace arises naturally.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-331',
    content: 'Trace every thought back to its source. That source is the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-332',
    content: 'The "I am" is the first ignorance. Go beyond it to the absolute.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-333',
    content: 'The present moment is the only teacher you need.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-334',
    content: 'The Self is not bound by causality. It is free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-335',
    content: 'All that is seen is temporary. The seer is eternal.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-336',
    content: 'Rest in the witness and let life unfold.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-337',
    content: 'You are already enlightened. You just do not know it yet.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-338',
    content: 'Every appearance is in consciousness. You are that consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-339',
    content: 'The world is not outside you. It is a projection within you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-340',
    content: 'True surrender happens when you see there is no one to surrender.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-341',
    content: 'Give up seeking and you will find what you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-342',
    content: 'All desires keep you in bondage. Be desireless.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-343',
    content: 'The ego cannot survive in the light of awareness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-344',
    content: 'The Self is the light of all lights.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-345',
    content: 'Freedom is not in doing or not doing. It is in being.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-346',
    content: 'The witness never changes. Everything else is change.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-347',
    content: 'The Self is realized when ignorance is destroyed, not by acquiring something new.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-348',
    content: 'You are the eternal subject, never an object.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-349',
    content: 'When the mind becomes still, the Self is revealed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-350',
    content: 'Non-doership is the understanding that life lives itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-351',
    content: 'The Self is the substratum of all experience.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-352',
    content: 'You are not in time. Time is in you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-353',
    content: 'Nothing has to be done. Everything is already complete.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-354',
    content: 'The wise one sees no difference between waking and dreaming.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-355',
    content: 'You are not the experiencer. You are the experiencing itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-356',
    content: 'The witness consciousness is your true identity.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-357',
    content: 'The Self is not a state to be attained. It is what remains when all states disappear.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-358',
    content: 'All problems are created by the mind. The Self has no problems.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-359',
    content: 'Consciousness is the only reality. Everything else is appearance.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-360',
    content: 'Liberation is the end of the illusion of bondage.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-361',
    content: 'Do not waste time seeking. You are already what you seek.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-362',
    content: 'The ultimate understanding is that you never existed as a separate entity.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-363',
    content: 'Stop postponing freedom. It is available right now.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-364',
    content: 'The Self is the cause of everything, yet itself has no cause.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-365',
    content: 'In truth, nothing ever happens. All is the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-366',
    content: 'The witness is the door to liberation.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-367',
    content: 'You cannot practice being the Self. You can only stop pretending to be something else.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-368',
    content: 'When you give up the idea of being a person, freedom dawns.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-369',
    content: 'The world is a reflection of consciousness, not separate from it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-370',
    content: 'To be free is to recognize that you were never bound.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-371',
    content: 'The Self is the eternal now, unchanging and ever-present.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-372',
    content: 'All that you perceive is yourself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-373',
    content: 'The eternal present is the only time there is.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-374',
    content: 'Brahman alone exists. Nothing else has independent reality.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-375',
    content: 'The realized one lives in the world but is not of it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-376',
    content: 'Witnessing is not something you do. It is what you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-377',
    content: 'The Self is never not here. Only attention shifts.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-378',
    content: 'Rest as you are, without any movement toward or away.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-379',
    content: 'The entire universe is your own Self appearing as many.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-380',
    content: 'See that there is no doer, and peace will prevail.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-381',
    content: 'Remain as pure awareness. That is your natural state.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-382',
    content: 'The knowingness "I am" is the doorway. Pass through it to the absolute.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-383',
    content: 'You are always already liberated. Drop the search.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-384',
    content: 'The Self is beyond all concepts and descriptions.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-385',
    content: 'Be still. In that stillness, the Self is obvious.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-386',
    content: 'The witness remains untouched by all that is witnessed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-387',
    content: 'All effort to realize the Self is misguided. The Self is always realized.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-388',
    content: 'You are the awareness in which all states appear and disappear.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-389',
    content: 'The world is like a movie projected on the screen of consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-390',
    content: 'Liberation is seeing that all actions happen by themselves, without a doer.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-391',
    content: 'The "I" is the root of all illusion. Inquire into it until it disappears.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-392',
    content: 'Be aware that you are aware. That is enough.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-393',
    content: 'Freedom is not a future event. It is the recognition of what is always true.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-394',
    content: 'The Self is the witness of the three states: waking, dreaming, and deep sleep.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-395',
    content: 'You are not in the body. The body is in you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-396',
    content: 'The witness is the silent backdrop of all experience.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-397',
    content: 'The Self does not need enlightenment. Only the ego thinks it does.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-398',
    content: 'You are the peace that surpasses understanding.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-399',
    content: 'There is only consciousness. All else is a play within it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-400',
    content: 'When you see that nothing is ever done by you, freedom is immediate.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-401',
    content: 'The Self is the silence between thoughts.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-402',
    content: 'Awareness is your only treasure. All else is borrowed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-403',
    content: 'The now is eternal. Past and future are concepts.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-404',
    content: 'The Self illuminates the mind but is not touched by it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-405',
    content: 'Separation is an illusion. Unity is the truth.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-406',
    content: 'Stand as the witness and the world loses its grip.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-407',
    content: 'The Self is always shining. Only ignorance obscures it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-408',
    content: 'When you realize you are nothing, you become everything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-409',
    content: 'Consciousness alone is. The rest is imagination.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-410',
    content: 'Surrender the illusion of personal doership and be free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-411',
    content: 'All questions arise from the false notion of being a person.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-412',
    content: 'The greatest discovery is that you do not exist as a separate entity.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-413',
    content: 'Be still and see that you are the stillness itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-414',
    content: 'The Self is the eternal subject, never an object of knowledge.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-415',
    content: 'You are the infinite space in which everything appears.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-416',
    content: 'Witnessing is your eternal nature. It requires no effort.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-417',
    content: 'You need do nothing to be the Self. You need only stop pretending.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-418',
    content: 'Everything appears in you, changes in you, and disappears in you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-419',
    content: 'The world is consciousness dreaming itself as many.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-420',
    content: 'True freedom is the absence of the belief in a separate self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-421',
    content: 'Let the mind be. Do not fight it. You are beyond it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-422',
    content: 'You are before all, during all, and after all.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-423',
    content: 'The eternal present is all there is. Everything else is mind.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-424',
    content: 'That which knows all experiences is itself never experienced.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-425',
    content: 'The waves are not different from the ocean. You are not different from the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-426',
    content: 'The witness is ever-free. Identify with it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-427',
    content: 'There is no path to the Self because you never left it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-428',
    content: 'You are the unchanging in the midst of all change.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-429',
    content: 'All forms are temporary manifestations of the one consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-430',
    content: 'When non-doership is understood, spontaneous action arises naturally.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-431',
    content: 'All spiritual effort is aimed at destroying the ego. Once it is gone, the Self shines.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-432',
    content: 'Give up the sense of being the body and realize your infinity.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-433',
    content: 'Stay in the now. The past is memory, the future is imagination.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-434',
    content: 'The Self is the substratum on which all else appears.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-435',
    content: 'You are free. You only believe you are bound.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-436',
    content: 'The witness is the eternal constant. Everything else changes.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-437',
    content: 'The Self is effortlessly present. Let go of effort.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-438',
    content: 'All that is perceived is within consciousness. You are that consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-439',
    content: 'The world is consciousness taking form.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-440',
    content: 'Surrender is recognizing that you are not the author of your actions.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-441',
    content: 'Do not follow thoughts. Return to the source.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-442',
    content: 'The sense "I am" is the gateway to the absolute truth.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-443',
    content: 'Freedom is here now. Stop searching for it in time.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-444',
    content: 'Consciousness needs no proof. It is self-evident.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-445',
    content: 'Let go of all identities. You are none of them.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-446',
    content: 'Stand as the witness and liberation is instant.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-447',
    content: 'You are already the Self. Stop believing otherwise.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-448',
    content: 'All phenomena are passing clouds. You are the sky.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-449',
    content: 'There is no world outside consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-450',
    content: 'The doer is an illusion. See through it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-451',
    content: 'In deep sleep you exist without the world. That existence is your true nature.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-452',
    content: 'Everything you know is within you, including the entire universe.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-453',
    content: 'This moment is complete. Nothing is missing.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-454',
    content: 'The Self is the light that illuminates all knowledge.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-455',
    content: 'You are the unchanging reality behind all appearances.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-456',
    content: 'The witness is always here. Never was it absent.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-457',
    content: 'Enlightenment is not a special state. It is freedom from all states.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-458',
    content: 'You are the source from which all arises and to which all returns.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-459',
    content: 'The universe is an imagination within consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-460',
    content: 'To realize non-doership is to realize freedom.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-461',
    content: 'The "I" thought is the root. Cut it and the tree of suffering falls.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-462',
    content: 'All troubles arise from the belief "I am the body." Drop it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-463',
    content: 'You are the present moment itself, not in it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-464',
    content: 'The Self knows itself by its own light.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-465',
    content: 'All bondage is imaginary. You are already free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-466',
    content: 'Rest in pure witnessing and all conflict ends.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-467',
    content: 'The Self is not something to be gained. It is always present.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-468',
    content: 'The space of awareness is your true home.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-469',
    content: 'Consciousness is the only substance. All forms are its expressions.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-470',
    content: 'When you see you are not the doer, true peace arises.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-471',
    content: 'Be still and know. That is the entire teaching.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-472',
    content: 'You are the timeless witness of time.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-473',
    content: 'The eternal now is the only reality. Everything else is illusion.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-474',
    content: 'The Self is never absent. Only attention wanders.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-475',
    content: 'You are the infinite. Do not limit yourself with concepts.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-476',
    content: 'The witness consciousness is ever-free and ever-present.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-477',
    content: 'Nothing needs to be done. Just stop doing the wrong thing.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-478',
    content: 'When the mind becomes quiet, what remains is the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-479',
    content: 'Everything is consciousness playing hide and seek with itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-480',
    content: 'True surrender is the end of the sense of personal doership.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-481',
    content: 'The ego is just a thought. Do not give it power.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-482',
    content: 'You are beyond all experience. You are the experiencer.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-483',
    content: 'Now is all there is. Be fully present.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-484',
    content: 'Brahman is the only reality. The world is its appearance.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-485',
    content: 'All suffering is due to identification with the false. Let it go.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-486',
    content: 'Be the witness. That is liberation.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-487',
    content: 'You do not have to realize the Self. You have to stop unrealizing it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-488',
    content: 'All that appears is within you. You are not within anything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-489',
    content: 'The world is like a dream occurring in the one consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-490',
    content: 'Liberation is the understanding that actions happen without a personal doer.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),
  Pointing(
    id: 'adv-491',
    content: 'Self-inquiry removes ignorance. The Self is always there.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-492',
    content: 'The sense "I am" is the beginning. Go beyond it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-493',
    content: 'The present moment is eternal. There is no other time.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-494',
    content: 'The Self is the unchanging witness of the mind and body.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Adi Shankara',
  ),
  Pointing(
    id: 'adv-495',
    content: 'All states are temporary. The Self is permanent.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra',
  ),
  Pointing(
    id: 'adv-496',
    content: 'Witness everything and be attached to nothing.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Dattatreya',
  ),
  Pointing(
    id: 'adv-497',
    content: 'You are already enlightened. You need only recognize it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Annamalai Swami',
  ),
  Pointing(
    id: 'adv-498',
    content: 'Rest in your being. That is all that is needed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-499',
    content: 'Consciousness is the only reality. Everything else is appearance.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Robert Adams',
  ),
  Pointing(
    id: 'adv-520',
    content: 'When the illusion of doership ends, freedom begins.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Lakshmana Swamy',
  ),

  // --- zen_quotes.dart ---
  Pointing(
    id: 'zen-108',
    content: 'The moon is the same old moon, the flowers exactly as they were, yet I\'ve become the thingness of things.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-109',
    content: 'To study the way is to study the self. To study the self is to forget the self.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-110',
    content: 'When you paint spring, do not paint willows, plums, peaches, or apricots. Just paint spring.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-111',
    content: 'If you cannot find the truth right where you are, where else do you expect to find it?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-112',
    content: 'Do not follow in the footsteps of the wise. Seek what they sought.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-113',
    content: 'A flower falls, even though we love it; and a weed grows, even though we do not love it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-114',
    content: 'The way of Buddha is to know yourself. To know yourself is to forget yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-115',
    content: 'Time is being, being is time.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-116',
    content: 'Mountains and rivers, the whole earth, all manifest the essential body of being.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-117',
    content: 'Practice and realization are not two things.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-118',
    content: 'Spring comes with flowers, autumn with the moon, summer with breezes, winter with snow. When idle concerns don\'t fill your thoughts, that\'s your best season.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-119',
    content: 'To be enlightened by all things is to remove the barrier between self and other.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-120',
    content: 'Birth and death are the great matter. All things pass quickly away. Wake up, wake up! Do not waste this life.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-121',
    content: 'When we discover that the truth is already in us, we are all at once our original self.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-122',
    content: 'Just sitting, without any complication, is the most important thing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-123',
    content: 'In truth, there is nothing to cut off. The waters are boundless; the mountains are endless.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-124',
    content: 'Life and death are of supreme importance. Time swiftly passes by and opportunity is lost.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-125',
    content: 'As all things are Buddha-dharma, there is delusion and realization, practice, birth and death.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-126',
    content: 'The whole moon and entire sky are reflected in one dewdrop on the grass.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-127',
    content: 'When you find your place where you are, practice occurs, actualizing the fundamental point.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-128',
    content: 'That which is before you is it, in all its fullness, utterly complete.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-129',
    content: 'Let there be a silent understanding and no more.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-130',
    content: 'The ignorant eschew phenomena but not thought; the wise eschew thought but not phenomena.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-131',
    content: 'Mind is Buddha, and Buddha is Mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-132',
    content: 'When no discriminating thoughts arise, the old mind ceases to exist.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-133',
    content: 'Not thinking about anything is Zen. Once you know this, walking, standing, sitting, or lying down, everything you do is Zen.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-134',
    content: 'If you would spend all your time walking, standing, sitting or lying down learning to halt the concept-forming activities of your own mind, you could be sure of ultimately attaining the goal.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-135',
    content: 'The arising and the elimination of illusion are both illusory.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-136',
    content: 'If you use your mind to study reality, you won\'t understand either your mind or reality. If you study reality without using your mind, you\'ll understand both.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-137',
    content: 'Do not seek from the Buddha, nor from the Dharma, nor from the Sangha. Do not seek at all.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-138',
    content: 'When you hear that there is nothing to attain, do not make of this nothing another attainment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-139',
    content: 'The ordinary and the wise are equal; there is no distinction.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-140',
    content: 'Bodhi is no state. The Buddha did not attain to it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-141',
    content: 'The foolish reject what they see, not what they think; the wise reject what they think, not what they see.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-142',
    content: 'All the Buddhas and all sentient beings are nothing but the One Mind, beside which nothing exists.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-143',
    content: 'Throughout this life, you can never be certain of living long enough to take another breath.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-144',
    content: 'To practice the Way singleheartedly is, in itself, enlightenment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-145',
    content: 'If you stop and think, you will miss it; if you strain your intellect, you will go against it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-146',
    content: 'There is nothing to take hold of in the dharma of the Buddha. There is only this void empty space.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-147',
    content: 'The Mind is no mind of conceptual thought, and it is completely detached from form.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-148',
    content: 'If you students of the Way do not awake to this Mind substance, you will overlay Mind with conceptual thought.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-149',
    content: 'Wherever you are, be there totally.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-150',
    content: 'If you meet the Buddha, kill the Buddha. If you meet the patriarchs, kill the patriarchs.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-151',
    content: 'There is no place you can run to. There is nothing you can rely upon.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-152',
    content: 'Be master of your surroundings, and wherever you are, the place itself is real.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-153',
    content: 'The true person of no rank comes in and out of your face right now.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-154',
    content: 'Do not seek from the Buddha. Buddha is a name, an empty sound.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-155',
    content: 'If you want to get the plain truth, be not concerned with right and wrong. The conflict between right and wrong is the sickness of the mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-156',
    content: 'What concerns me is that students do not have enough faith in themselves.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-157',
    content: 'Just be ordinary. Don\'t put on airs. Be yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-158',
    content: 'The one who seeks is the one who is sought.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-159',
    content: 'Do not chase after the past or long for the future. The past is gone, the future not yet here.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-160',
    content: 'There is no Buddha to attain, no Way to practice, no enlightenment to realize.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-161',
    content: 'Your true nature is right before you - do not search elsewhere.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-162',
    content: 'Simply let experience take place very freely, so that your open heart is suffused with the tenderness of true compassion.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-163',
    content: 'Do not depend on anything. When you meet circumstances, make no discriminations.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-164',
    content: 'If you know that your own light is unborn, then there is no necessity to seek the Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-165',
    content: 'Outside the mind, there is no separate dharma; inside the mind there is no other dharma either.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-166',
    content: 'The person of the Way has nothing to do, nothing to cultivate, nothing to realize.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-167',
    content: 'In the beginner\'s mind there are many possibilities, in the expert\'s mind there are few.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-168',
    content: 'When you do something, you should burn yourself completely, like a good bonfire, leaving no trace of yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-169',
    content: 'The most important thing is to find out what is the most important thing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-170',
    content: 'To live in the realm of Buddha nature means to die as a small being, moment after moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-171',
    content: 'When we have our body and mind in order, everything else will exist in the right place, in the right way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-172',
    content: 'If your mind is empty, it is always ready for anything; it is open to everything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-173',
    content: 'Each of you is perfect the way you are, and you can use a little improvement.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-174',
    content: 'The way of practice is just to concentrate on your breathing with the right posture and with great, pure effort.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-175',
    content: 'Without accepting the fact that everything changes, we cannot find perfect composure.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-176',
    content: 'Renunciation is not giving up the things of this world, but accepting that they go away.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-177',
    content: 'Treat every moment as your last. It is not preparation for something else.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-178',
    content: 'Everything is perfect, but there is a lot of room for improvement.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-179',
    content: 'Zazen practice is the direct expression of our true nature.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-180',
    content: 'The true purpose of Zen is to see things as they are, to observe things as they are, and to let everything go as it goes.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-181',
    content: 'Calmness of mind does not mean you should stop your activity. Real calmness should be found in activity itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-182',
    content: 'What we call "I" is just a swinging door which moves when we inhale and when we exhale.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-183',
    content: 'When you are just you, you see things as they are, and you become one with your surroundings.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-184',
    content: 'The seed has no idea of being some particular plant, but it has its own form and is in perfect harmony with the ground.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-185',
    content: 'Life is like stepping onto a boat which is about to sail out to sea and sink.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-186',
    content: 'To give your sheep or cow a large, spacious meadow is the way to control him.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-187',
    content: 'Walk as if you are kissing the Earth with your feet.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-188',
    content: 'Breathing in, I calm body and mind. Breathing out, I smile.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-189',
    content: 'The present moment is filled with joy and happiness. If you are attentive, you will see it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-190',
    content: 'Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-191',
    content: 'The most precious gift we can offer anyone is our attention.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-192',
    content: 'Drink your tea slowly and reverently, as if it is the axis on which the world earth revolves.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-193',
    content: 'There is no way to happiness - happiness is the way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-194',
    content: 'Peace is every step. It turns the endless path to joy.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-195',
    content: 'To be beautiful means to be yourself. You don\'t need to be accepted by others. You need to accept yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-196',
    content: 'When we are mindful, deeply in touch with the present moment, our understanding of what is going on deepens.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-197',
    content: 'Life is available only in the present moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-198',
    content: 'Smile, breathe, and go slowly.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-199',
    content: 'Breathing in, I am aware that I am breathing in. Breathing out, I am aware that I am breathing out.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-200',
    content: 'The miracle is not to walk on water. The miracle is to walk on the green earth, dwelling deeply in the present moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-201',
    content: 'If we are not fully ourselves, truly in the present moment, we miss everything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-202',
    content: 'People have a hard time letting go of their suffering. Out of a fear of the unknown, they prefer suffering that is familiar.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-203',
    content: 'Many people are alive but don\'t touch the miracle of being alive.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-204',
    content: 'Enlightenment is when a wave realizes it is the ocean.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-205',
    content: 'Awareness is like the sun. When it shines on things, they are transformed.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-206',
    content: 'Guarding knowledge is not a good way to understand. Understanding means to throw away your knowledge.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-207',
    content: 'The only way to make sense out of change is to plunge into it, move with it, and join the dance.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-208',
    content: 'Trying to define yourself is like trying to bite your own teeth.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-209',
    content: 'You are the universe experiencing itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-210',
    content: 'The meaning of life is just to be alive. It is so plain and so obvious and so simple.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-211',
    content: 'Man suffers only because he takes seriously what the gods made for fun.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-212',
    content: 'We cannot be more sensitive to pleasure without being more sensitive to pain.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-213',
    content: 'Muddy water is best cleared by leaving it alone.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-214',
    content: 'The more a thing tends to be permanent, the more it tends to be lifeless.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-215',
    content: 'What we have to discover is that there is no safety, that seeking is painful, and that when we imagine that we have found it, we don\'t like it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-216',
    content: 'This is the real secret of life - to be completely engaged with what you are doing in the here and now.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-217',
    content: 'You don\'t look out there for God, something in the sky, you look in you.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-218',
    content: 'Things are as they are. Looking out into the universe at night, we make no comparisons between right and wrong stars.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-219',
    content: 'To have faith is to trust yourself to the water. When you swim you don\'t grab hold of the water, because if you do you will sink.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-220',
    content: 'The art of living... is neither careless drifting on the one hand nor fearful clinging to the past on the other.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-221',
    content: 'To be free from convention is not to spurn it but not to be deceived by it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-222',
    content: 'You are an aperture through which the universe is looking at and exploring itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-223',
    content: 'Waking up to who you are requires letting go of who you imagine yourself to be.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-224',
    content: 'A person who thinks all the time has nothing to think about except thoughts. So he loses touch with reality.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-225',
    content: 'No valid plans for the future can be made by those who have no capacity for living now.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-226',
    content: 'Through our eyes, the universe is perceiving itself. Through our ears, the universe is listening to its harmonies.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-227',
    content: 'Attention is the rarest and purest form of generosity.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-228',
    content: 'Practice is about learning to live this moment. That\'s all.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-229',
    content: 'We have to face the pain we have been running from. In fact, we need to learn to rest in it and let its searing power transform us.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-230',
    content: 'Enlightenment is not something you achieve. It is the absence of something.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-231',
    content: 'Our practice should be based on the ideal of selflessness. Selflessness is very difficult to understand.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-232',
    content: 'Problems arise when we act out of our emotional reactions rather than experiencing them.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-233',
    content: 'Real love is never possessive or demanding. It is simply a state of being.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-234',
    content: 'Experience is the only teacher. All we can do is expose ourselves to experiences.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-235',
    content: 'When we sit, we just sit. When we walk, we just walk. And when life falls apart, we just let it fall apart.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-236',
    content: 'Zen is not about blissing out or going into an alpha brain-wave trance. It\'s about seeing things as they are.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-237',
    content: 'If we don\'t observe our thoughts, we become our thoughts.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-238',
    content: 'The goal is not to substitute one thought for another. The goal is to see the arising of thought itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-239',
    content: 'True practice is direct response to the present moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-240',
    content: 'Suffering is just suffering. It\'s not good or bad. It\'s just what\'s here.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-241',
    content: 'We don\'t sit to become enlightened. We sit to express enlightenment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-242',
    content: 'There is no self to be realized. Just awareness, unfolding moment by moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-243',
    content: 'Life itself is the teacher, and we are in a state of constant learning.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-244',
    content: 'The only way out is through. We have to go through the difficulty, not around it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-245',
    content: 'We are not trying to get rid of anything. We\'re trying to understand it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-246',
    content: 'Realization doesn\'t mean arriving somewhere. It means finally seeing what has always been.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-247',
    content: 'Chan is not about seeking enlightenment or trying to become a Buddha. It is about seeing your true nature.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-248',
    content: 'Our fundamental problem is that the self wants to preserve and protect itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-249',
    content: 'When you are not thinking about anything, you are in accord with the Dharma.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-250',
    content: 'Don\'t try to be holy. Just be ordinary.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-251',
    content: 'When you sit in meditation, allow thoughts to come and go. Don\'t attach to them.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-252',
    content: 'Emptiness doesn\'t mean nothing exists. It means nothing exists independently.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-253',
    content: 'The practice of Chan is to experience every moment fully, with clarity and awareness.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-254',
    content: 'When the mind has no obstruction, it mirrors all things clearly.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-255',
    content: 'Vexation arises from the attachment to self. Without self, where is vexation?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-256',
    content: 'Wisdom is not something to be acquired. It is always present when delusion is absent.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-257',
    content: 'Silent illumination is letting go of everything and resting in natural awareness.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-258',
    content: 'See your original nature directly. Don\'t seek for it through concepts.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-259',
    content: 'Whatever you encounter, just meet it directly. Don\'t add or subtract anything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-260',
    content: 'Practice is not a means to an end. Practice itself is enlightenment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-261',
    content: 'The method is no method. Just be present with whatever arises.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-262',
    content: 'Let go of the past, don\'t anticipate the future. Rest in the present moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-263',
    content: 'In meditation, don\'t follow thoughts and don\'t suppress them. Just watch them.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-264',
    content: 'Buddha nature is not something to be attained. It is your original face.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-265',
    content: 'Suffering comes from grasping. Liberation comes from letting go.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-266',
    content: 'True emptiness is not blank nothingness. It is the boundless openness of mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-267',
    content: 'All dharmas return to the One. Where does the One return to?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-268',
    content: 'The Unborn is the origin of all and the end of all. Live in the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-269',
    content: 'All your mental wandering and agitation comes from not staying in the Unborn Buddha Mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-270',
    content: 'If you simply have faith in the Unborn, you will already be living in it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-271',
    content: 'Nothing is born, nothing dies. This is the Buddha Mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-272',
    content: 'Don\'t try to become a Buddha. You are already complete from the start.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-273',
    content: 'Whatever you do, don\'t leave the Unborn Buddha Mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-274',
    content: 'Stop transforming the Buddha Mind into something else. Just let it be as it is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-275',
    content: 'When you abide in the Unborn, there is no coming, no going, no appearance, no disappearance.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-276',
    content: 'Illusion begins when you wander from the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-277',
    content: 'Everyone is endowed with the Buddha Mind from the start. There is nothing to practice.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-278',
    content: 'Your Buddha Mind is unborn and marvelously illuminating. This is all you need to know.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-279',
    content: 'Don\'t try to stop your thoughts. Just don\'t cling to them.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-280',
    content: 'The Unborn has no shape, no form, no color. It is not being, not non-being.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-281',
    content: 'If you know the Unborn, you will be free of birth and death right where you stand.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-282',
    content: 'The Unborn is originally pure and clear, without any stain.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-283',
    content: 'If you chase after thoughts, you lose the Unborn. If you suppress thoughts, you also lose it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-284',
    content: 'Live without dividing things into good and bad. This is the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-285',
    content: 'The great way has no gate. Thousands of roads enter it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-286',
    content: 'Your treasure house is within. It contains all you need.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-287',
    content: 'Does a dog have Buddha nature?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-288',
    content: 'When you have finished drinking your tea, wash your bowl.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-289',
    content: 'What is the meaning of Bodhidharma coming from the West? The cypress tree in the courtyard.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-290',
    content: 'If you meet the Buddha, kill him. If you meet the patriarchs, kill the patriarchs.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-291',
    content: 'Have a cup of tea.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-292',
    content: 'The Great Way is not difficult for those who have no preferences.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-293',
    content: 'Before I studied Zen, mountains were mountains and rivers were rivers. When I studied Zen, mountains were not mountains and rivers were not rivers. Now I understand Zen, and mountains are mountains and rivers are rivers.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-294',
    content: 'If you cannot find it in yourself, where will you go for it?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-295',
    content: 'Seeing into one\'s nature is the most direct path.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-296',
    content: 'Your everyday mind is the Way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-297',
    content: 'A teacher can open the door, but you must enter by yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-298',
    content: 'All dualities are falsely imagined.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-299',
    content: 'The ultimate truth is beyond words. Doctrines are words. They are not the Way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-300',
    content: 'When it is time to get dressed, put on your clothes. When you must walk, then walk. When you must sit, then sit.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-301',
    content: 'Before enlightenment, chop wood, carry water. After enlightenment, chop wood, carry water.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-302',
    content: 'One moment of total awareness is one moment of perfect freedom.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-303',
    content: 'If you understand, things are just as they are. If you do not understand, things are just as they are.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-304',
    content: 'It is not that there is no answer. It is that the question is wrong.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-305',
    content: 'What is Buddha? Three pounds of flax.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-306',
    content: 'When you seek, you move away from it. When you don\'t seek, you are naturally there.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-307',
    content: 'Firewood becomes ash. Ash cannot become firewood again.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-308',
    content: 'Those who see worldly life as an obstacle to practice see no true path. Those who see it as the path itself enlighten the way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-309',
    content: 'To be enlightened by myriad things is to recognize the unity of the self with all things.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-310',
    content: 'Zazen is the dharma gate of great ease and joy.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-311',
    content: 'The whole world is medicine. What is the self?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-312',
    content: 'Enlightenment is like the moon reflected on the water. The moon does not get wet, nor is the water broken.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-313',
    content: 'You should not have a favorite way of doing things. You should make the best way your way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-314',
    content: 'Continuous practice, day after day, is the most appropriate way of expressing gratitude.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-315',
    content: 'The colour of the mountains is Buddha\'s body; the sound of running water is his great speech.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-316',
    content: 'The whole universe is enlightenment activity.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-317',
    content: 'Flowers fall amid our longing and weeds spring up amid our antipathy.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-318',
    content: 'To carry yourself forward and experience myriad things is delusion. That myriad things come forth and experience themselves is awakening.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-319',
    content: 'Impermanence is Buddha-nature.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-320',
    content: 'Zazen is not meditation. It is simply the dharma gate of joyful ease.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-321',
    content: 'All sentient beings are Buddha-nature.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-322',
    content: 'The Buddha Way is leaping clear of the many and the one.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-323',
    content: 'Realization is not the same as understanding with the mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-324',
    content: 'If you wish to see the truth, then hold no opinions for or against anything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-325',
    content: 'The fundamental delusion of humanity is to suppose that I am here and you are out there.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-326',
    content: 'There is only the One Mind and not a particle of anything else on which to lay hold.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-327',
    content: 'To seek is to suffer. To seek nothing is bliss.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-328',
    content: 'Ordinary people look outside; the sage looks within.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-329',
    content: 'Make no distinctions and you will be in accord with the Tao.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-330',
    content: 'Only when you have no thing in your mind and no mind in things are you vacant and spiritual, empty and marvelous.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-331',
    content: 'People are scared to empty their minds fearing that they will be engulfed by the void.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-332',
    content: 'If your mind is not contriving, it will of itself be enlightened.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-333',
    content: 'The Way is perfect like vast space where nothing is lacking and nothing in excess.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-334',
    content: 'Let go over a cliff, die completely, and then come back to life - after that you cannot be deceived.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-335',
    content: 'The Way is not a matter of knowing or not knowing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-336',
    content: 'Put an end to seeking, and then there will be nothing you cannot do.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-337',
    content: 'There is no reality other than what is right here before your eyes.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-338',
    content: 'Do not be deceived by others. Inwardly or outwardly, if you encounter any obstacles, slay them at once.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-339',
    content: 'The true person is without form - you have to see it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-340',
    content: 'What you are depends on you alone.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-341',
    content: 'Students of the Way, the Dharma of the buddhas requires no special undertakings.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-342',
    content: 'In one particle of dust, the whole earth is contained.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-343',
    content: 'When hungry, eat. When tired, sleep.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-344',
    content: 'In Zen we have nothing to explain, nothing to teach, that will add to your knowledge.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-345',
    content: 'The important thing in our practice is to have right or perfect effort.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-346',
    content: 'To accept something as it is means to acknowledge the truth as it is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-347',
    content: 'True zazen is just to be concentrated on your breathing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-348',
    content: 'Moment after moment, completely devote yourself to listening to your inner voice.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-349',
    content: 'Water which is too pure has no fish.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-350',
    content: 'You are you. You are not a projection of something else.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-351',
    content: 'When you bow, you should just bow; when you sit, you should just sit.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-352',
    content: 'Usually, we think of our body and mind as two things, but they are not two; they are one.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-353',
    content: 'Just being there, being completely present, is enough.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-354',
    content: 'Do not try to stop your mind, but leave everything as it is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-355',
    content: 'Right practice is to express your true self in your activity.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-356',
    content: 'Practice does not mean trying to get something. It means being completely present.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-357',
    content: 'When you have one dharma, you have all dharmas. When you have no dharma, you have no dharmas.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-358',
    content: 'Nothing outside yourself can cause any trouble. You yourself make the waves in your mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-359',
    content: 'Sometimes we think that to practice is to figure something out, but actually, it\'s to let everything be as it is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-360',
    content: 'Around us, life bursts with miracles - a glass of water, a ray of sunshine, a leaf, a caterpillar, a flower, laughter, raindrops.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-361',
    content: 'Our appointment with life is in the present moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-362',
    content: 'Every breath we take, every step we make, can be filled with peace, joy, and serenity.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-363',
    content: 'When we are mindful, touching deeply the present moment, we can see and listen deeply.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-364',
    content: 'The seed of suffering in you may be strong, but don\'t wait until you have no more suffering before allowing yourself to be happy.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-365',
    content: 'Because you are alive, everything is possible.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-366',
    content: 'When we recognize the virtues, the talent, the beauty of Mother Earth, something is born in us, some kind of connection, love is born.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-367',
    content: 'Meditation is not to escape from society, but to come back to ourselves and see what is going on.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-368',
    content: 'To love without knowing how to love wounds the person we love.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-369',
    content: 'We will be more successful in all our endeavors if we can let go of the habit of running all the time.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-370',
    content: 'To think in terms of either pessimism or optimism oversimplifies the truth. The problem is to see reality as it is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-371',
    content: 'Silence is something more than just a pause; it is that enchanted place where space is cleared and time is stayed.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-372',
    content: 'My actions are my only true belongings.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-373',
    content: 'Understanding is the fruit of meditation. Understanding is the basis of everything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-374',
    content: 'At any moment, you have a choice, that either leads you closer to your spirit or further away from it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-375',
    content: 'Hope is important because it can make the present moment less difficult to bear.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-376',
    content: 'Fear keeps us focused on the past or worried about the future.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-377',
    content: 'The present moment is the only moment available to us, and it is the door to all moments.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-378',
    content: 'Letting go gives us freedom, and freedom is the only condition for happiness.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-379',
    content: 'True love always brings joy to ourselves and the one we love.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-380',
    content: 'The way out is via the door. Why is it that no one will use this method?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-381',
    content: 'Zen does not confuse spirituality with thinking about God while one is peeling potatoes.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-382',
    content: 'No work or love will flourish out of guilt, fear, or hollowness of heart.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-383',
    content: 'The more we try to catch hold of the present moment, the more elusive it becomes.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-384',
    content: 'A person who thinks all the time has nothing to think about except thoughts.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-385',
    content: 'The menu is not the meal.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-386',
    content: 'Life is not a problem to be solved but a reality to be experienced.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-387',
    content: 'You are under no obligation to be the same person you were five minutes ago.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-388',
    content: 'Reality is only a Rorschach ink-blot.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-389',
    content: 'We do not come into this world; we come out of it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-390',
    content: 'Better to have a short life that is full of what you like doing than a long life spent in a miserable way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-391',
    content: 'We are living in a culture entirely hypnotized by the illusion of time.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-392',
    content: 'Zen is a way of liberation, concerned not with discovering what is good or bad or advantageous, but what is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-393',
    content: 'The past and future are real illusions, that they exist in the present, which is what there is and all there is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-394',
    content: 'If you say that getting the money is the most important thing, you\'ll spend your life completely wasting your time.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-395',
    content: 'Technology is destructive only in the hands of people who do not realize that they are one and the same process as the universe.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-396',
    content: 'You and I are all as much continuous with the physical universe as a wave is continuous with the ocean.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-397',
    content: 'The more we think about it, the less there is to think about. Finally, we might give up thinking altogether.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-398',
    content: 'There is no coming toward it or going away from it; it is, and you are it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-399',
    content: 'The real you is not a puppet which life pushes around. The real deep down you is the whole universe.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Alan Watts',
  ),
  Pointing(
    id: 'zen-400',
    content: 'When I\'m hungry, I eat. When I\'m tired, I sleep. Fools laugh at me. The wise understand.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-401',
    content: 'We have to open to the experience of what we\'ve spent our life running away from.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-402',
    content: 'Sitting is essentially a simplified space. Our daily life is in constant movement.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-403',
    content: 'The more we can be with what is, the less we need fantasies.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-404',
    content: 'If we\'re honest about what we\'re experiencing, the practice takes care of itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-405',
    content: 'Practice has to be the absolute, final authority in your life.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-406',
    content: 'There\'s no security in anything. There\'s only security in reality itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-407',
    content: 'What we call self is a composite. It\'s not anything real or solid.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-408',
    content: 'Practice is simple: pay attention to what\'s happening.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-409',
    content: 'Life always gives us exactly the teacher we need at every moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-410',
    content: 'Until we stop clinging to the thought of something better, we can\'t experience what is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-411',
    content: 'We learn through the body, not through the intellect.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-412',
    content: 'Simply stay with the body sensations, and they will dissolve.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-413',
    content: 'There\'s no place to go, no special state to attain.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-414',
    content: 'In zazen, we do nothing. We just sit. And through this nothing, everything is revealed.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-415',
    content: 'We have to be willing to experience our life exactly as it is, not as we wish it to be.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-416',
    content: 'What takes us away from practice is our attachment to having life be a certain way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-417',
    content: 'Our practice is simply to stay with what is.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-418',
    content: 'In my Zen practice, thoughts, perceptions, and emotions are all the same.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-419',
    content: 'There is no place to stand outside of the flow.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Charlotte Joko Beck',
  ),
  Pointing(
    id: 'zen-420',
    content: 'No one is born a Buddha. Practice is the way we approach this.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-421',
    content: 'A clear mind is one that doesn\'t dwell on anything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-422',
    content: 'The mind that has no thought is the mind of Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-423',
    content: 'Enlightenment is sudden; practice is gradual.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-424',
    content: 'The greatest illusion is the illusion of separation.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-425',
    content: 'When you find yourself fighting or resisting, that is the time to practice letting go.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-426',
    content: 'All phenomena are empty of self-nature. This is the wisdom of emptiness.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-427',
    content: 'When the mind is not discriminating, it is at peace.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-428',
    content: 'True practice is just to sit with no gaining idea.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-429',
    content: 'Buddhism does not ask you to believe in anything. It asks you to investigate.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-430',
    content: 'The person who understands emptiness has nothing to fear.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-431',
    content: 'Where there is grasping, there is suffering.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-432',
    content: 'Meditation is not about becoming a better person. It\'s about being who you truly are.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-433',
    content: 'When mind and body are unified, there is no self-consciousness.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-434',
    content: 'Form is emptiness, emptiness is form.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-435',
    content: 'The practice of Chan is not to escape difficulties, but to face them with equanimity.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-436',
    content: 'In stillness, wisdom arises.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-437',
    content: 'Suffering is created when we believe in our own thoughts.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-438',
    content: 'Let things be as they are. Don\'t try to change them.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-439',
    content: 'The source of all phenomena is the Buddha Mind. There is nothing outside it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Sheng Yen',
  ),
  Pointing(
    id: 'zen-440',
    content: 'Live from the Unborn, and all things will be as they are.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-441',
    content: 'When you abide in the Unborn Buddha Mind, nothing troubles you.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-442',
    content: 'From the start, you\'re in the Buddha Mind. Don\'t look for it elsewhere.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-443',
    content: 'Whatever you see and hear right now - that itself is the proof of the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-444',
    content: 'The Unborn is your original face, the face before your parents were born.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-445',
    content: 'Stop turning the Buddha Mind into something else.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-446',
    content: 'Before thought arises, you are in the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-447',
    content: 'There is no practice to do. Just stay in the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-448',
    content: 'The Unborn has never been born and will never die.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-449',
    content: 'At the moment of hearing, before you label the sound, that is the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-450',
    content: 'All dharma teachings point back to the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-451',
    content: 'Don\'t think you need to attain something. You already have it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-452',
    content: 'In the Unborn, there is no delusion, no enlightenment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-453',
    content: 'The Unborn is not a thing. It is not emptiness either.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-454',
    content: 'When you know the Unborn, you are free from life and death.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-455',
    content: 'Abiding in the Unborn is the ultimate meditation.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-456',
    content: 'Everything you need, you already possess in the Unborn Buddha Mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-457',
    content: 'Stop searching. You are already what you seek.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-458',
    content: 'Don\'t get caught up in thoughts. Return to the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-459',
    content: 'The Unborn is everywhere and nowhere. It is what you truly are.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-460',
    content: 'A cup of tea is all you need right now.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-461',
    content: 'If you meet a master, do not speak; if you do not speak, how will you know?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-462',
    content: 'Does a dog have Buddha nature? Mu.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-463',
    content: 'When you walk, just walk. When you eat, just eat.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-464',
    content: 'The way is not something you can understand. If you understand it, you are already off the path.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-465',
    content: 'Enlightenment is as common as everyday life.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-466',
    content: 'If you grasp it, you lose it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-467',
    content: 'The oak tree in the garden.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-468',
    content: 'Stop seeking and it will be given.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-469',
    content: 'Don\'t cling to words. Words are not reality.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-470',
    content: 'When you are hungry, food appears. When tired, sleep comes.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-471',
    content: 'Do not seek from the Buddha; the Buddha seeks nothing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-472',
    content: 'Form is emptiness, emptiness is form. Can you see it?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-473',
    content: 'Wash your bowl. That is the teaching.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-474',
    content: 'Simplicity is the ultimate sophistication.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-475',
    content: 'Not knowing is the most intimate.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-476',
    content: 'Buddha is a dried shit-stick.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-477',
    content: 'To ask is to err. To not ask is also to err.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-478',
    content: 'The truth is right where you stand.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-479',
    content: 'No thought, no problem.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Joshu',
  ),
  Pointing(
    id: 'zen-480',
    content: 'Sit like a mountain. Breathe like the wind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-481',
    content: 'The entire world is the gate to liberation.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-482',
    content: 'Not knowing how near the truth is, we seek it far away.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-483',
    content: 'To master the way is to be a master of every moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-484',
    content: 'When the ten thousand things are viewed in their oneness, we return to the origin.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-485',
    content: 'One inch of sitting, one inch of Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-486',
    content: 'Seeing forms with the whole body and mind, hearing sounds with the whole body and mind, one understands them intimately.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-487',
    content: 'Dropping body-mind is zazen.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-488',
    content: 'The moon in the water; broken and unbroken.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-489',
    content: 'Nothing in the entire universe is hidden.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-490',
    content: 'When you walk in the mist, you get wet without realizing it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-491',
    content: 'Practice is not a step toward enlightenment. It is enlightenment itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-492',
    content: 'The mind cannot be grasped. It is vast as the sky.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-493',
    content: 'Speech and silence are one.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-494',
    content: 'The Buddha and sentient beings are not different.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-495',
    content: 'Do not use the mind to seek the mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-496',
    content: 'The Way is not built. It is walked.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-497',
    content: 'Nothing is added in enlightenment; nothing is lost in delusion.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-498',
    content: 'When no mind arises, all things are without fault.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-499',
    content: 'Seeking mind is delusion; the enlightened mind does not seek.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-500',
    content: 'The nature of mind is emptiness. Emptiness is the nature of all things.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-501',
    content: 'Don\'t remain in dualism. Avoid such pursuits carefully.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-502',
    content: 'All phenomena are dreams, illusions, bubbles, shadows.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-503',
    content: 'Stop all thought and see the mind directly.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-504',
    content: 'The true dharma has no form. It is found right here.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-505',
    content: 'Wherever you stand, be a lamp unto yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-506',
    content: 'The true person has no form, yet appears in form.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),
  Pointing(
    id: 'zen-507',
    content: 'Stop seeking, and rest in the unborn mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Linji',
  ),

  // --- contemporary_quotes.dart ---
  Pointing(
    id: 'con-113',
    content: 'The moment you stop seeking is the moment you find what has always been here.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-114',
    content: 'Presence is not something you achieve. It is what remains when you stop trying to be someone.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-115',
    content: 'Question your thoughts and watch your suffering dissolve like morning mist.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-116',
    content: 'You are already free. You are simply believing thoughts that say otherwise.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-117',
    content: 'Be here now, for here is where love lives and now is when it speaks.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-118',
    content: 'Compassion is not a relationship between the healer and the wounded. It is a relationship between equals.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-119',
    content: 'Mindfulness is not about fixing yourself. It is about befriending who you already are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-120',
    content: 'True refuge is not a place outside yourself. It is the tender meeting with your own heart.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-121',
    content: 'Your inner growth is not about accumulating experiences. It is about surrendering to the flow of life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-122',
    content: 'Truth is what remains when all beliefs have been burned away.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-123',
    content: 'Awakening is not an achievement. It is a recognition of what has never left.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-124',
    content: 'The present moment is the only doorway out of the prison of time.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-125',
    content: 'When you believe your thoughts, you suffer. When you question them, you are free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-126',
    content: 'Stop trying to find yourself. You are what is looking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-127',
    content: 'The quieter you become, the more you can hear the heart speaking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-128',
    content: 'The path is not about becoming better. It is about becoming more fully who you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-129',
    content: 'Meditation is not about stopping thoughts. It is about stopping the identification with them.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-130',
    content: 'Healing happens when we turn toward our pain with presence and care.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-131',
    content: 'Let go of who you think you should be and embrace who you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-132',
    content: 'Enlightenment is the death of the belief that you are separate.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-133',
    content: 'True meditation has no technique. It is simply resting as what you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-134',
    content: 'Time is the disease. Presence is the cure.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-135',
    content: 'Reality is always kinder than the stories we tell ourselves about it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-136',
    content: 'You have been looking for yourself everywhere except where you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-137',
    content: 'Love is not a state to achieve. It is what you are when fear dissolves.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-138',
    content: 'Our resistance to change is the source of our suffering.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-139',
    content: 'Wisdom is the natural result of an open heart meeting life as it is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-140',
    content: 'Belonging to yourself is the greatest belonging there is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-141',
    content: 'Freedom comes when you no longer need life to be different than it is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-142',
    content: 'Spiritual awakening is the collapse of the dream character you thought you were.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-143',
    content: 'The ego is not your enemy. It is simply a case of mistaken identity.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-144',
    content: 'Awareness is the silent witness that has been watching all along.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-145',
    content: 'Who would you be without your story? Free, awake, and kind.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-146',
    content: 'Peace is not something you find. It is what you are when you stop searching.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-147',
    content: 'The spiritual journey is about unlearning everything that is not true.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-148',
    content: 'When we stop avoiding our experience, we discover the path forward.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-149',
    content: 'Your capacity for presence is infinite. Your capacity for suffering is learned.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-150',
    content: 'When we meet ourselves with compassion, transformation happens naturally.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-151',
    content: 'The highest spiritual practice is to allow life to be as it is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-152',
    content: 'You cannot awaken from a dream by modifying the dream.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-153',
    content: 'True freedom is found in the complete acceptance of this moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-154',
    content: 'The Now is not a moment in time. It is the timeless space where life unfolds.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-155',
    content: 'Every thought is innocent until we believe it to be true.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-156',
    content: 'Stillness is not empty. It is full of you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-157',
    content: 'When you are truly present, everything becomes a teacher.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-158',
    content: 'Fear is not the obstacle. Running from fear is the obstacle.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-159',
    content: 'Peace comes not from changing the world, but from changing how we meet it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-160',
    content: 'The embrace of imperfection is the gateway to freedom.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-161',
    content: 'Surrender is not giving up. It is letting go of control and trusting life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-162',
    content: 'Liberation is seeing through the illusion of a separate self.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-163',
    content: 'Grace arrives when you stop trying to earn it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-164',
    content: 'The dimension of depth opens up when you become present.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-165',
    content: 'What if the worst thing that could happen is also the best thing?',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-166',
    content: 'The silence within you is vast enough to hold everything.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-167',
    content: 'Every soul is on the journey home to itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-168',
    content: 'The willingness to feel is the foundation of awakening.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-169',
    content: 'In the end, only kindness matters. And it is never the end.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-170',
    content: 'Radical acceptance means loving what is, even when it hurts.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-171',
    content: 'Every moment is an opportunity to let go and be free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-172',
    content: 'The seeker is what stands between you and what you seek.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-173',
    content: 'Awakening reveals that there is no one to awaken.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-174',
    content: 'Stillness speaks louder than a thousand thoughts.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-175',
    content: 'Love what is and suffering ends. Fight what is and suffering continues.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-176',
    content: 'You are not the waves. You are the ocean.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-177',
    content: 'The only true journey is from the head to the heart.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-178',
    content: 'When we learn to stay, transformation happens by itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-179',
    content: 'Suffering is optional. Pain is inevitable.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-180',
    content: 'Your true nature is already whole, already loved, already enough.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-181',
    content: 'The universe is not happening to you. It is happening through you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-182',
    content: 'Truth does not care about your feelings. It simply is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-183',
    content: 'The spiritual path is a path of subtraction, not addition.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-184',
    content: 'Life is the dancer and you are the dance.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-185',
    content: 'Your suffering is the doorway to your freedom.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-186',
    content: 'Nothing real can be threatened. Nothing unreal exists. Herein lies the peace.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-187',
    content: 'We are all just walking each other home.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-188',
    content: 'The only way out is through. The only way through is with.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-189',
    content: 'Forgiveness is giving up all hope of a better past.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-190',
    content: 'The boundary of self is where suffering begins.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-191',
    content: 'Your true power is found in letting go, not holding on.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-192',
    content: 'The only thing standing between you and truth is the belief that there is something standing between you and truth.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-193',
    content: 'Enlightenment is intimacy with all things.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-194',
    content: 'You are the awareness in which all experience arises.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-195',
    content: 'Defense is the first act of war. Inquiry is the first act of peace.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-196',
    content: 'The ground of being is always here, waiting for recognition.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-197',
    content: 'The heart knows what the mind can never understand.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-198',
    content: 'Groundlessness is actually the path itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-199',
    content: 'Attention is the most basic form of love.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-200',
    content: 'What if who you are is already exactly who you need to be?',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-201',
    content: 'Life will give you whatever experience is most helpful for your evolution.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-202',
    content: 'Spiritual awakening is not a journey to somewhere else. It is a journey to here.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-203',
    content: 'The deepest teaching is found in the space between words.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-204',
    content: 'Presence is the answer to every question you have ever asked.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-205',
    content: 'Until you can find the gift in what you are experiencing, you will suffer.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-206',
    content: 'Stop waiting for enlightenment. You are already That.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-207',
    content: 'The spiritual path is simply coming home to who you have always been.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-208',
    content: 'Compassion for ourselves is the foundation for compassion for others.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-209',
    content: 'The measure of spiritual growth is how quickly you return to love.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-210',
    content: 'You cannot hate your way into loving yourself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-211',
    content: 'When you let go of wanting life to be different, you are free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-212',
    content: 'The dream is not what happens. The dream is the belief that you are separate from what happens.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-213',
    content: 'You do not need to be better to be free. You only need to see clearly.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-214',
    content: 'The pain-body loves drama. Presence dissolves it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-215',
    content: 'Stress is caused by believing thoughts that argue with reality.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-216',
    content: 'Rest in the silence that has never been disturbed.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-217',
    content: 'Your obstacles are your practice. Your practice is your life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-218',
    content: 'Lean into the sharp points. That is where the tenderness lies.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-219',
    content: 'What we resist persists. What we meet with awareness transforms.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-220',
    content: 'The trance of unworthiness keeps us from claiming our true nature.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-221',
    content: 'True growth is letting go of that which you are not.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-222',
    content: 'The character you play in the dream will never wake up. Only you can.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-223',
    content: 'Surrender is not weakness. It is the highest form of courage.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-224',
    content: 'The Now is where joy lives, waiting to be discovered.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-225',
    content: 'When you argue with reality, you lose. But only every time.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-226',
    content: 'The recognition of your true self is instant and complete.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-227',
    content: 'The most important relationship is the one you have with yourself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-228',
    content: 'Start where you are. Use what you have. Do what you can.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-229',
    content: 'Peace is not the absence of conflict. It is the presence of love.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-230',
    content: 'The permission to be yourself is the greatest gift you can give.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-231',
    content: 'Your heart is the most powerful transformative tool you possess.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-232',
    content: 'Awakening is the end of seeking and the beginning of being.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-233',
    content: 'True meditation is beyond practice. It is the natural state of open awareness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-234',
    content: 'You are not in the universe. The universe is in you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-235',
    content: 'Loving what is does not mean you cannot work for change.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-236',
    content: 'The treasure you seek is hidden in plain sight.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-237',
    content: 'Suffering is grace calling you to awakening.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-238',
    content: 'The wisdom of insecurity is trusting the groundlessness of life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-239',
    content: 'The way out of suffering is through the door of kindness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-240',
    content: 'True meditation is allowing everything to be as it already is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-241',
    content: 'Every experience is an invitation to open your heart wider.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-242',
    content: 'The separate self is an optical illusion of consciousness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-243',
    content: 'Liberation is recognizing that you have never been bound.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-244',
    content: 'The eternal Now is the only thing that is real.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-245',
    content: 'Your pain is the breaking of the shell that encloses understanding.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-246',
    content: 'Being is not a state you achieve. It is what you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-247',
    content: 'Let go or be dragged. The choice is always yours.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-248',
    content: 'The path of awakening is the path of falling awake.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-249',
    content: 'Love is what we are born with. Fear is what we learn.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-250',
    content: 'When we pause and turn toward ourselves, we find what we have been seeking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-251',
    content: 'The door to liberation swings open the moment you let go.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-252',
    content: 'The guru cannot give you truth. The guru can only take away your lies.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-253',
    content: 'Awakening is falling out of the story and into presence.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-254',
    content: 'Being is your deepest self. It is who you are beneath the noise.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-255',
    content: 'Every uncomfortable feeling is a sweet gift leading you home to yourself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-256',
    content: 'What you are looking for is what is looking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-257',
    content: 'The next message you need is always right where you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-258',
    content: 'Things falling apart is a kind of testing and also a kind of healing.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-259',
    content: 'The spiritual path is not a journey of perfection but of wholeness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-260',
    content: 'Self-compassion is the courage to turn toward your suffering.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-261',
    content: 'The moment you say yes to life, life says yes to you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-262',
    content: 'All fear is fear of death. All death is the death of ego.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-263',
    content: 'The gateless gate opens when you stop trying to find it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-264',
    content: 'Acceptance means you allow this moment to be as it is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-265',
    content: 'If you want lasting change, stop trying to change yourself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-266',
    content: 'The seeking ends when you discover there is no seeker.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-267',
    content: 'Your suffering is your teacher asking you to pay attention.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-268',
    content: 'Hope and fear come from feeling that we lack something.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-269',
    content: 'The quieter the mind, the louder the soul.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-270',
    content: 'Our deepest fear is not that we are inadequate but that we have forgotten who we are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-271',
    content: 'Spiritual evolution is about becoming more of who you already are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-272',
    content: 'Truth requires nothing. Lies require everything.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-273',
    content: 'Awareness does not judge what arises. It simply sees.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-274',
    content: 'Your inner space is where peace lives and always has.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-275',
    content: 'Suffering is an alarm clock that wakes you up to your true nature.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-276',
    content: 'Stop searching for who you are and simply be.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-277',
    content: 'The spiritual path begins when you decide to tell yourself the truth.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-278',
    content: 'Nothing ever goes away until it has taught us what we need to know.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-279',
    content: 'Wisdom is knowing what you do not need to carry.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-280',
    content: 'The universe is not punishing you or blessing you. It is responding to you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-281',
    content: 'When you resist, life pushes back. When you surrender, life supports you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-282',
    content: 'Enlightenment is discovering there is no one to become enlightened.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-283',
    content: 'The most profound truths are always the simplest.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-284',
    content: 'To be free of time is to be free of the psychological need of past and future.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-285',
    content: 'Happiness is a thought you have when you are thinking clearly.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-286',
    content: 'True freedom is discovering you are already free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-287',
    content: 'Attachment is the source of all suffering. Love is free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-288',
    content: 'We do not sit in meditation to become good meditators. We sit to become awake.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-289',
    content: 'You will not be punished for your anger. You will be punished by your anger.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-290',
    content: 'The curious paradox is that when I accept myself just as I am, then I can change.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-291',
    content: 'The secret to happiness is to let every situation be what it is instead of what you think it should be.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-292',
    content: 'The truth is that which requires no belief.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-293',
    content: 'Awakening is about losing your mind and coming to your senses.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-294',
    content: 'Life will give you whatever experience is most helpful for your awakening.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-295',
    content: 'Suffering is optional. It is what happens when we argue with what is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-296',
    content: 'You are the sky. Everything else is just the weather.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-297',
    content: 'Everything changes once we identify with being the witness to the story.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-298',
    content: 'The mind is always seeking to escape the present moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-299',
    content: 'The near enemy of love is attachment. The near enemy of compassion is pity.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-300',
    content: 'There is something wonderfully bold and liberating about saying yes to our entire imperfect lives.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-301',
    content: 'Your inner state is the only thing you can control. Everything else is a gift.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-302',
    content: 'Awakening is the end of confusion about who you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-303',
    content: 'Let everything happen to you. Beauty and terror. Just keep going.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-304',
    content: 'The primary cause of unhappiness is never the situation but your thoughts about it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-305',
    content: 'If you want to know the truth of who you are, question everything you believe.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-306',
    content: 'Peace is your true nature. Disturbance is learned.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-307',
    content: 'Your imperfections are doorways to your divinity.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-308',
    content: 'Letting there be room for not knowing is the most important thing of all.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-309',
    content: 'The heart of all spiritual practice is to learn to love ourselves and others without condition.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-310',
    content: 'Presence is not some exotic state that we need to search for. It is here, now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-311',
    content: 'The highest spiritual practice is self-observation without judgment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-312',
    content: 'You are not becoming something. You are unbecoming everything that is not you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-313',
    content: 'The light that shines through your eyes is the light of consciousness itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-314',
    content: 'Wherever you are, be there totally.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-315',
    content: 'I discovered that when I believed my thoughts, I suffered. When I did not believe them, I did not suffer.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-316',
    content: 'The invitation is to stop postponing and simply be here now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-317',
    content: 'The most exquisite paradox is that as soon as you give it all up, you can have it all.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-318',
    content: 'The most difficult times for many of us are the ones we give ourselves.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-319',
    content: 'True freedom is living as if you had completely chosen whatever you feel or experience at this moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-320',
    content: 'With mindfulness, we are learning to see the transience of all phenomena.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-321',
    content: 'Life is a succession of events. When you learn to experience each one, the door opens.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-322',
    content: 'The dream is not the problem. The problem is believing the dream is real.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-323',
    content: 'Your nature is already perfect. It just needs to be discovered.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-324',
    content: 'The moment you realize you are not present, you are present.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-325',
    content: 'All I have is all I need and all I need is all I have in this moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-326',
    content: 'Enlightenment is simple. It is just being yourself without apology.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-327',
    content: 'Treat everyone you meet like God in drag.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-328',
    content: 'To be fully alive, fully human, and completely awake is to be continually thrown out of the nest.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-329',
    content: 'In the end, just three things matter: how well we have lived, how well we have loved, how well we have learned to let go.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-330',
    content: 'Perhaps the biggest tragedy of our lives is that freedom is possible, yet we pass our years trapped in the same old patterns.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-331',
    content: 'The day you decide that you are more interested in being aware than in being in control, your life will begin to unfold.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-332',
    content: 'The only thing you ever lose is your identification with it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-333',
    content: 'True spirituality is a mental attitude you can practice at any time.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-334',
    content: 'Anything that you resent and strongly react to in another is also in you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-335',
    content: 'What is the worst that can happen? This thought. And you are questioning it now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-336',
    content: 'Silence is the language of God. Everything else is a poor translation.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-337',
    content: 'Your problem is you are too busy holding onto your unworthiness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-338',
    content: 'Only to the extent that we expose ourselves over and over to annihilation can that which is indestructible be found in us.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-339',
    content: 'Whatever you truly understand, you begin to love.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-340',
    content: 'The intimacy that arises in listening and speaking truth is only possible if we can open to the vulnerability of our own hearts.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-341',
    content: 'Do not let anything that happens in life be important enough that you are willing to close your heart over it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-342',
    content: 'Ego is the single greatest cause of suffering there is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-343',
    content: 'The truth is that you already are what you are seeking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-344',
    content: 'You do not become good by trying to be good, but by finding the goodness that is already within you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-345',
    content: 'Peace does not come from thinking. It comes from questioning what you think.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-346',
    content: 'You are not limited by your thoughts. You are limited by the belief that you are your thoughts.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-347',
    content: 'The resistance to the unpleasant situation is the root of suffering.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-348',
    content: 'The root of suffering is resisting the certainty that no matter what the circumstances, uncertainty is all we truly have.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-349',
    content: 'Compassion grows from the understanding that we are all doing the best we can with the resources we have.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-350',
    content: 'When we relax the sense of self, we discover our true nature.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-351',
    content: 'The only thing you should be addicted to is a sense of inner peace and well-being.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-352',
    content: 'Everything you know about yourself is just a story. Who would you be without it?',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-353',
    content: 'Freedom is found when you realize you are not the doer.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-354',
    content: 'All negativity is caused by an accumulation of psychological time and denial of the present.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-355',
    content: 'Nothing outside you can ever give you what you are looking for.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-356',
    content: 'The freedom you long for is already present, already fulfilled.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-357',
    content: 'The game is not about becoming somebody. It is about becoming nobody.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-358',
    content: 'Meditation practice is not about trying to throw ourselves away and become something better.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-359',
    content: 'True happiness is always available, simply through shifting what we pay attention to.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-360',
    content: 'The recognition that who we are is not limited by our body or personality opens us to a mysterious universe.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-361',
    content: 'The only permanent thing in the universe is the part of you that is watching it all happen.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-362',
    content: 'Seeking enlightenment is the denial of enlightenment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-363',
    content: 'The end of seeking is the beginning of finding.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-364',
    content: 'Ego is no more than this: identification with form, which primarily means thought forms.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-365',
    content: 'The Work is meditation. It is about awareness, not about trying to change your mind.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-366',
    content: 'True meditation has no direction or goal. It is pure wordless surrender.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-367',
    content: 'You are loved just for being who you are, just for existing.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-368',
    content: 'The spiritual journey involves going beyond hope and fear, stepping into unknown territory.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-369',
    content: 'When we get too caught up in the busyness of the world, we lose connection with one another and ourselves.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-370',
    content: 'Suffering is not wrong, but it is a powerful wake-up call.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-371',
    content: 'The only way to be always happy is to learn how to experience each moment as it comes.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-372',
    content: 'The search for truth is the search for that which cannot be found.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-373',
    content: 'Presence is when you are no longer waiting for the next moment, believing it will be better than this one.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-374',
    content: 'Realize deeply that the present moment is all you have. Make the Now the primary focus of your life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-375',
    content: 'Your story is always changing. Who you are never does.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-376',
    content: 'The peace you seek is found in the direct realization of what you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-377',
    content: 'If you think you are enlightened, go spend a week with your family.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-378',
    content: 'True refuge is not a safe place where we do not have to practice. It is a place where we can practice.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-379',
    content: 'When we learn to be present, life becomes the meditation.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-380',
    content: 'The longing to be loved is so powerful, we will suffer greatly before we realize we are already love itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-381',
    content: 'Freedom is the realization that you are not bound by your past or by what happens to you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-382',
    content: 'There is no self to know. There is only knowing.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-383',
    content: 'When the mind is absolutely still, reality reveals itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-384',
    content: 'The split second you abandon the illusion of control, you gain true power.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-385',
    content: 'Once you realize that the road is the goal and that you are always on the road, not to reach a goal but to enjoy its beauty and wisdom, life ceases to be a task.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-386',
    content: 'The treasure you seek cannot be found in time. It can only be found now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-387',
    content: 'Compassion is the key that unlocks the door of your heart.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-388',
    content: 'What keeps us from being awake is just our habits and our fear.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-389',
    content: 'Peace comes when our hearts are open like the sky, vast as the ocean.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-390',
    content: 'Life becomes workable when we stop trying to make it work our way.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-391',
    content: 'When you are no longer compelled to defend your point of view, you experience the freedom of clarity.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-392',
    content: 'The only real failure is the failure to keep going.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-393',
    content: 'When the belief in separation falls away, love remains.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-394',
    content: 'The power of Now can only be experienced now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-395',
    content: 'No one can hurt you. That is your job.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-396',
    content: 'The answer to every question is already here in the silence.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-397',
    content: 'Your work is to discover your work and then with all your heart give yourself to it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-398',
    content: 'All situations teach you, and often it is the tough ones that teach you best.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-399',
    content: 'If your compassion does not include yourself, it is incomplete.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-400',
    content: 'In any moment, no matter how lost we feel, we can take refuge in beginning again.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-401',
    content: 'Spiritual growth is not about learning new things. It is about unlearning old things.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-402',
    content: 'The truth is simple. It is the lies that are complicated.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-403',
    content: 'The truth is not something you can grasp with your mind. It must be lived.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-404',
    content: 'Most humans are never fully present in the now, because unconsciously they believe that the next moment must be more important than this one.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-405',
    content: 'The way to find out about happiness is to keep your mind on those moments when you feel most happy.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-406',
    content: 'Rest in what is here. Let go of the search.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-407',
    content: 'The soul is here for its own joy.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-408',
    content: 'To stay with that shakiness is to stay present to the moment without trying to escape.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-409',
    content: 'Compassion is our deepest nature. It arises from our interconnection with all things.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-410',
    content: 'The way out of our cage begins with accepting absolutely everything about ourselves and our lives.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-411',
    content: 'If you want to be happy, you have to let go of the part of you that wants to create drama.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-412',
    content: 'The obstacle is not the obstacle. The obstacle is your refusal to face the obstacle.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-413',
    content: 'True intelligence operates silently. Stillness is where creativity and solutions are found.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-414',
    content: 'The moment that judgment stops through acceptance of what is, you are free of the mind.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-415',
    content: 'You move totally away from reality when you believe there is a legitimate reason to suffer.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-416',
    content: 'The fullness of who you are has never left you, even for a moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-417',
    content: 'The journey into consciousness is learning to be with what is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-418',
    content: 'The most fundamental aggression to ourselves is remaining ignorant by not having the courage to look at ourselves.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-419',
    content: 'The Buddha taught that suffering has an end. That end is available right now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-420',
    content: 'When we let go of the constant monitoring of our own adequacy, awareness naturally opens.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-421',
    content: 'Pain is physical. Suffering is mental. Beyond the mind, there is no suffering.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-422',
    content: 'Truth is not a destination. Truth is what you are when you stop pretending.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-423',
    content: 'In the stillness of being, you find who you are and what you always have been.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-424',
    content: 'As soon as you honor the present moment, all unhappiness and struggle dissolve.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-425',
    content: 'When you realize where you are, you will know that this is exactly where you need to be.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-426',
    content: 'In this moment, without seeking, without efforting, you can discover what has always been here.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-427',
    content: 'The quieter the mind, the more powerful, the worthier, the deeper, the more telling and perfect our instinct.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-428',
    content: 'Compassion is not a relationship between the healer and the wounded. It is the recognition that we are all in this together.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-429',
    content: 'We suffer because we are caught in wanting things to be different than they are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-430',
    content: 'When we offer ourselves kindness in the midst of suffering, our pain begins to transform.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-431',
    content: 'There is nothing you can do to make the universe give you what you want, but you can let go of resisting what comes.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-432',
    content: 'The dream of enlightenment is the last and greatest obstacle to enlightenment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-433',
    content: 'When the search stops, you fall into what you always were.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-434',
    content: 'Every addiction arises from an unconscious refusal to face and move through your own pain.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-435',
    content: 'Peace comes not from hoping for better circumstances but from knowing that you can handle whatever comes.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-436',
    content: 'The invitation is always the same: to be completely here now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-437',
    content: 'In stillness, the world resets.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-438',
    content: 'We can always start our day again.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-439',
    content: 'The heart that breaks open can contain the whole universe.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-440',
    content: 'Our fears are paper tigers. They dissolve in the light of clear seeing.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-441',
    content: 'Anytime you are feeling disturbed, it is because you are refusing to let go.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-442',
    content: 'The illusion of separation is what keeps suffering alive.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-443',
    content: 'Let life unfold without resistance. That is the ultimate trust.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-444',
    content: 'Awakening is the shift from thinking you are the waves to knowing you are the ocean.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-445',
    content: 'Whatever we try to control does have control over us and our life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-446',
    content: 'In the recognition of pure being, everything falls into place.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-447',
    content: 'The spiritual journey is about becoming more intimate with yourself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-448',
    content: 'What you practice grows stronger.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-449',
    content: 'Love says, I am everything. Wisdom says, I am nothing. Between the two, my life flows.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-450',
    content: 'When we bow to our vulnerability, we discover our deepest strength.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-451',
    content: 'When the energy is unable to pass through you, it disturbs you. When you can let it pass through, you are free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-452',
    content: 'Awakening is not an event. It is the collapse of a belief structure.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-453',
    content: 'Your true nature is revealed in the absence of effort.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-454',
    content: 'What a liberation to realize that the voice in my head is not who I am.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-455',
    content: 'When you become a lover of what is, the war is over.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-456',
    content: 'Stillness is the key to unlocking the mystery of who you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-457',
    content: 'The highest form of renunciation is to renounce that which never existed.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-458',
    content: 'Without giving up hope that there is somewhere better to be, that there is someone better to be, we will never relax.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-459',
    content: 'Wherever you go, there you are. Wherever you are, be fully there.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-460',
    content: 'The sacred is found in the acceptance of our whole selves.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-461',
    content: 'You are not your thoughts. You are the one who hears them.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-462',
    content: 'The only way to win the game is to see that there is no game.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-463',
    content: 'Spiritual awakening is the difficult process of letting go of our cherished illusions.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-464',
    content: 'Boredom, anger, sadness, or fear are not yours. They are conditions of the human mind.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-465',
    content: 'The work is simple: question your stressful thoughts.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-466',
    content: 'When you stop trying to become something, you discover what you already are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-467',
    content: 'The universe respects you only when you respect yourself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-468',
    content: 'True fearlessness is not the reduction of fear, but going beyond fear.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-469',
    content: 'The way out of the trance of unworthiness is self-compassion.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-470',
    content: 'True happiness is uncaused. It does not depend on any outer circumstances.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-471',
    content: 'Letting go is the path to real freedom.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-472',
    content: 'You are not in the darkness. You are the light looking at darkness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-473',
    content: 'Liberation is found in the absence of the need for liberation.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-474',
    content: 'Life is the dancer and you are the dance. Dance is not separate from dancer.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-475',
    content: 'My happiness is not dependent on what happens outside me.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-476',
    content: 'This moment is the doorway to eternity.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-477',
    content: 'Suffering is grace in disguise.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-478',
    content: 'What we avoid, we empower.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-479',
    content: 'The mind creates the abyss. The heart crosses it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-480',
    content: 'Awakening is the remembering of who we have always been.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-481',
    content: 'When you are happy for no reason, you are free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-482',
    content: 'The only way out of the maze is to stop believing in the maze.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-483',
    content: 'The truth is always simple, always obvious, and always here.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-484',
    content: 'Whatever the present moment contains, accept it as if you had chosen it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-485',
    content: 'Everything happens for me, not to me.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-486',
    content: 'Being is the alpha and omega. There is nothing beyond it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-487',
    content: 'The only time you have is now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-488',
    content: 'To live fully is to let go of all points of reference.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-489',
    content: 'When we let go of our battles, we find peace.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-490',
    content: 'The gateway to freedom is not through perfection. It is through presence.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-491',
    content: 'You have the freedom to choose to be disturbed or to be at peace.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-492',
    content: 'Truth is not complicated. It is the lies that are complex.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-493',
    content: 'Freedom is not a place you arrive at. It is the absence of the one trying to get there.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-494',
    content: 'All true artists, whether they know it or not, create from a place of no-mind.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-495',
    content: 'Suffering is always optional. Pain happens. Suffering is the story we tell about pain.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-496',
    content: 'Truth is not hidden. It is overlooked.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-497',
    content: 'As you dissolve, your world dissolves with you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-498',
    content: 'Abandon hope that things will be different. Then you can relax with how they actually are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-499',
    content: 'Healing does not mean going back to the way things were. Healing means embracing what is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-500',
    content: 'You are not flawed. You are a process unfolding.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-501',
    content: 'Enlightenment means taking full responsibility for your life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-502',
    content: 'The belief that you need to do something is what prevents you from being who you already are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),
  Pointing(
    id: 'con-503',
    content: 'In the end, nothing matters. In the beginning, everything is sacred.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-504',
    content: 'Life is the dancer and you are the dance.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-505',
    content: 'You cannot hurt me with your love. You cannot hurt me with your hate. Only my thoughts can hurt me.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-506',
    content: 'What you are looking for is the looking itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Gangaji',
  ),
  Pointing(
    id: 'con-507',
    content: 'Your life is your guru.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-508',
    content: 'The wisdom that emerges from the silence is far greater than the wisdom of words.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Pema Chodron',
  ),
  Pointing(
    id: 'con-509',
    content: 'The things we refuse to feel become the walls of our prison.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jack Kornfield',
  ),
  Pointing(
    id: 'con-510',
    content: 'The moment we say yes to who we are, we step out of suffering.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Tara Brach',
  ),
  Pointing(
    id: 'con-511',
    content: 'When you are not attached to anything, you have everything.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Michael Singer',
  ),
  Pointing(
    id: 'con-512',
    content: 'The final truth is that there is no final truth.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Jed McKenna',
  ),

  // --- original_quotes.dart ---
  Pointing(
    id: 'ori-1',
    content: 'Before the thought of searching arose, what were you already?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-2',
    content: 'The silence between breaths is not empty—it is the fullness you have been seeking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-3',
    content: 'Notice: everything appears in this. Even the one who notices.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-4',
    content: 'What if home is not a place you arrive at, but the ground you never left?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-5',
    content: 'The story of becoming dissolves when you see you already are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-6',
    content: 'Right now, before any adjustment, this is enough.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-7',
    content: 'The ordinary breath is an extraordinary miracle when seen without the lens of time.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-8',
    content: 'You are the space in which all experiences dawn and fade.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-9',
    content: 'What remains when you stop trying to be something?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-10',
    content: 'The present moment is not a moment in time—it is the timeless witnessing all moments.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-11',
    content: 'Before you name this as meditation, notice what is already still.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-12',
    content: 'The person you think you are is a story told to awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-13',
    content: 'Rest is not something you do. It is what you are when doing stops.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-14',
    content: 'Every sound arises in an infinite silence that never becomes noisy.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-15',
    content: 'What you are looking for is what is looking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-16',
    content: 'The light of awareness needs no lamp to see itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-17',
    content: 'Beneath the rush of thought, there is an untouched stillness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-18',
    content: 'When you stop reaching for tomorrow, today reveals its infinite depth.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-19',
    content: 'The one who tries to meditate is the only thing standing in the way.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-20',
    content: 'You are not in the world. The world appears in you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-21',
    content: 'This simple awareness, reading these words—have you ever not been this?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-22',
    content: 'Peace is not found in perfect conditions. It is the space holding all conditions.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-23',
    content: 'The flower does not try to bloom. Neither need you try to be.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-24',
    content: 'Behind every question about who you are is the quiet knowing that already knows.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-25',
    content: 'The next moment is imaginary. This one is all there is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-26',
    content: 'What if nothing is missing and never has been?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-27',
    content: 'The waves forget they are ocean. You need not forget.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-28',
    content: 'Effortlessness is not a state to achieve. It is what remains when effort ends.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-29',
    content: 'The sky does not resist the clouds. Be as the sky.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-30',
    content: 'Every experience is temporary. What experiences them is not.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-31',
    content: 'You cannot step into presence—you are always already standing in it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-32',
    content: 'The miracle is not that life appears, but that you are here to witness it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-33',
    content: 'Before the first thought of morning, what are you?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-34',
    content: 'The separate self is like a drawing of a cage—it cannot actually hold you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-35',
    content: 'In the gap between thoughts, notice the one who remains.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-36',
    content: 'Awareness is not a flashlight you point at things. It is the light in which all things appear.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-37',
    content: 'The search for yourself is the only thing delaying the discovery.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-38',
    content: 'When you see that you are the seeing, all seeking ends.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-39',
    content: 'This moment does not owe you anything. Yet it gives you everything.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-40',
    content: 'The body breathes itself. The heart beats itself. What are you doing?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-41',
    content: 'Silence is not the absence of sound. It is the presence that hears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-42',
    content: 'The path home is zero steps long.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-43',
    content: 'What is here when you stop adding to this moment?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-44',
    content: 'The story of your life unfolds in you, not to you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-45',
    content: 'Being is so simple that the mind overlooks it while searching for something complex.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-46',
    content: 'The present is not a slice of time. It is the timeless meeting all time.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-47',
    content: 'You are not the content of consciousness. You are the consciousness containing it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-48',
    content: 'Let the day unfold without your narration.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-49',
    content: 'The candle does not chase the darkness. It simply is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-50',
    content: 'Before you were a person with problems, what were you?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-51',
    content: 'The screen is never damaged by the movie playing on it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-52',
    content: 'What you truly are cannot be threatened by anything that appears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-53',
    content: 'The deepest rest is available right now, beneath the surface of doing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-54',
    content: 'Stop. Notice. This is it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-55',
    content: 'The me is a thought appearing to you. Who are you?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-56',
    content: 'In this very breath, a thousand philosophers are silenced.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-57',
    content: 'The space between these words is the same space that holds galaxies.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-58',
    content: 'You are the unchanging witness to all change.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-59',
    content: 'Freedom is not earned. It is remembered.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-60',
    content: 'The ordinary cup of tea contains the entire teaching when you are fully here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-61',
    content: 'Behind the mask of personality, an infinite presence smiles.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-62',
    content: 'The future is a ghost. The past is a memory. Now is alive.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-63',
    content: 'What if the answer to every question is simply this: here?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-64',
    content: 'The river does not wonder if it is flowing correctly.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-65',
    content: 'Awareness is closer than your own breath and more distant than the furthest star.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-66',
    content: 'The wisdom you seek is in the silence between your questions.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-67',
    content: 'When effort collapses, grace appears—not as something new, but as what was always here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-68',
    content: 'The mind builds a prison of time. Step out. You are already free.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-69',
    content: 'Notice how effortlessly you are aware of these words.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-70',
    content: 'This simple being needs no improvement.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-71',
    content: 'The universe is not happening to you. It is happening as you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-72',
    content: 'Before memory names this as familiar, there is raw presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-73',
    content: 'The door to now has no lock—it was never closed.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-74',
    content: 'What remains when the story of me falls silent?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-75',
    content: 'Life is not a problem to solve but a presence to recognize.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-76',
    content: 'The ground of being is ordinary as breath, profound as infinity.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-77',
    content: 'In the space before naming, everything is intimate and alive.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-78',
    content: 'You are the still point around which all movement dances.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-79',
    content: 'The search ends where it began: here, now, as this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-80',
    content: 'Before enlightenment: breath. After enlightenment: breath.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-81',
    content: 'The morning light does not arrive—it reveals what was always here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-82',
    content: 'In the mirror of awareness, all things appear without leaving a trace.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-83',
    content: 'The thought "I am not there yet" appears in the already arrived.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-84',
    content: 'What is reading this sentence requires no name.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-85',
    content: 'Between the breaths, between the thoughts—vast openness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-86',
    content: 'The one trying to be present is itself a thought in presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-87',
    content: 'Home is not a destination. It is the absence of distance.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-88',
    content: 'Nothing needs to happen for you to be what you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-89',
    content: 'The knowing of this moment requires no knower.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-90',
    content: 'Like space making room for all things, you are the allowing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-91',
    content: 'The bird does not practice flying. The heart does not practice beating.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-92',
    content: 'What you are searching for cannot be found because it is doing the searching.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-93',
    content: 'The simplicity of being is too obvious to be seen by the complicated mind.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-94',
    content: 'Every moment is the first moment when you drop the past.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-95',
    content: 'Beneath every sensation, there is a sensitivity that is never touched.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-96',
    content: 'The present moment is the only place where life can be met.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-97',
    content: 'You are not a wave trying to become the ocean—you are already the ocean.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-98',
    content: 'The next moment is postponed forever. This one is here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-99',
    content: 'What is aware of the breath is not breathing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-100',
    content: 'The eternal is not somewhere beyond time. It is what time appears in.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-101',
    content: 'Let this moment be exactly as it is, and discover what you truly are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-102',
    content: 'The rose does not carry yesterday\'s blooms or tomorrow\'s fears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-103',
    content: 'In the absence of becoming, there is only being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-104',
    content: 'Awareness is the room in which all experience is a guest.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-105',
    content: 'The question "who am I?" dissolves in the answer that is already here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-106',
    content: 'Stillness is not the opposite of movement. It is what remains unmoved.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-107',
    content: 'The thoughts come and go. Have you ever come or gone?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-108',
    content: 'This awareness is so intimate that it is overlooked as too simple.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-109',
    content: 'The miracle is not that you exist, but that you know you exist.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-110',
    content: 'In the ordinary, the extraordinary hides in plain sight.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-111',
    content: 'The space that holds your life is made of the same substance as your true nature.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-112',
    content: 'Before the word "peace," there is peace.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-113',
    content: 'The sunset does not ask permission to be beautiful.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-114',
    content: 'When you stop defending yourself, who remains to be attacked?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-115',
    content: 'The watcher of dreams is never dreaming.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-116',
    content: 'This simple knowing—have you earned it or struggled for it?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-117',
    content: 'The journey ends when you notice you never left home.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-118',
    content: 'In the pause between doing and being, the truth whispers.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-119',
    content: 'The world is not outside you, looking in. It is inside you, looking out.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-120',
    content: 'What you are has never had a beginning and will never have an end.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-121',
    content: 'The cup is held by the hand, but both are held by awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-122',
    content: 'Stop seeking and notice what is already seeking through you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-123',
    content: 'The light does not struggle to illuminate. Neither need you struggle to be.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-124',
    content: 'What is here before the first inhale of the day?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-125',
    content: 'The story of separation is a tale told to that which is never separate.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-126',
    content: 'In this moment, nothing is incomplete.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-127',
    content: 'The moon reflects in ten thousand lakes, yet remains one moon.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-128',
    content: 'Before you label this moment as good or bad, it simply is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-129',
    content: 'The silence of being speaks louder than any word.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-130',
    content: 'You are the context in which all content appears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-131',
    content: 'The past is a drawing on water. Watch it disappear.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-132',
    content: 'In the midst of change, unchanging awareness remains.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-133',
    content: 'The teacher you need is the stillness already within.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-134',
    content: 'What if this ordinary moment is the sacred you have been seeking?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-135',
    content: 'The ocean does not cling to any wave.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-136',
    content: 'You are not limited by the body. The body appears within your limitless nature.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-137',
    content: 'The effort to be present keeps you from noticing you already are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-138',
    content: 'Like the sun behind clouds, your true nature is never obscured.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-139',
    content: 'The gap between thoughts is not empty—it is full of what you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-140',
    content: 'Right here, before understanding, there is simple knowing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-141',
    content: 'The journey of ten thousand miles begins and ends in this step.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-142',
    content: 'What remains when the seeker disappears?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-143',
    content: 'The stars shine without announcing their light.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-144',
    content: 'This breath is the first breath. This moment is the only moment.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-145',
    content: 'The separate me is a thin story written on the infinite page of being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-146',
    content: 'Awareness needs no practice to be aware.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-147',
    content: 'In the center of the storm, there is perfect stillness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-148',
    content: 'The fragrance does not seek the flower. It simply is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-149',
    content: 'Before the label "spiritual," there is only this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-150',
    content: 'What you truly are is too close to be seen as an object.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-151',
    content: 'The dance of life requires no dancer.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-152',
    content: 'In the absence of time, there is only presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-153',
    content: 'The eye cannot see itself, yet never doubts it exists.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-154',
    content: 'What remains when all techniques are abandoned?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-155',
    content: 'The grass grows without consulting manuals.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-156',
    content: 'You are the peaceful background to every restless thought.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-157',
    content: 'The now is not a point in time—it is the disappearance of time.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-158',
    content: 'Like water taking any shape, yet remaining water, you adapt while unchanging.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-159',
    content: 'The boundary between inner and outer is imaginary.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-160',
    content: 'Before the first "I" thought, what is awake?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-161',
    content: 'The weight of the world belongs to the world, not to awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-162',
    content: 'Effortless being is your natural state, not an achievement.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-163',
    content: 'The canvas is never troubled by the painting.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-164',
    content: 'What you seek seeks you through the seeking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-165',
    content: 'In the rawness of this moment, before interpretation, is truth.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-166',
    content: 'The river arrives at the ocean by never leaving water.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-167',
    content: 'You are not the weather passing through. You are the sky.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-168',
    content: 'The present moment is not narrow—it contains infinity.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-169',
    content: 'Like the mirror reflecting all yet holding nothing, you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-170',
    content: 'The truth is not found in becoming still. It is the stillness itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-171',
    content: 'What is here when you let the world be as it is?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-172',
    content: 'The seed knows nothing of becoming a tree. It simply opens.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-173',
    content: 'In the space of not-knowing, wisdom flowers.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-174',
    content: 'The separate self is the only thing standing between you and everything.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-175',
    content: 'What is looking through your eyes has never been born.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-176',
    content: 'The mountain does not climb itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-177',
    content: 'Before the concept of time, there is timeless being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-178',
    content: 'The ordinary hum of existence is the ultimate mantra.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-179',
    content: 'You are not in relationship with awareness. You are awareness relating.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-180',
    content: 'Like sunlight needing no permission to shine, you simply are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-181',
    content: 'The answer is in the silence after the question fades.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-182',
    content: 'What you are cannot be practiced or improved—only recognized.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-183',
    content: 'The emptiness is not empty. It is pregnant with all possibility.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-184',
    content: 'In the surrender of the seeker, the sought is revealed to have never been lost.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-185',
    content: 'The fire does not try to be warm.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-186',
    content: 'You are the eternal yes to whatever appears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-187',
    content: 'The world is the dream, and you are the dreaming.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-188',
    content: 'In this very instant, everything is already complete.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-189',
    content: 'The bird sings not to reach a destination, but because it is a bird.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-190',
    content: 'What remains when you stop trying to control your experience?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-191',
    content: 'The truth does not need to be believed. It simply is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-192',
    content: 'You are the space in which the question "who am I?" appears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-193',
    content: 'The shadow proves the light.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-194',
    content: 'Before memory tells you who you were, notice who you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-195',
    content: 'The miracle is not that you can think, but that you know you are thinking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-196',
    content: 'Like the ocean allowing waves, you allow all experience.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-197',
    content: 'The now is not a small moment. It is the only moment there is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-198',
    content: 'What you are seeking is what is aware of the seeking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-199',
    content: 'The waterfall does not wonder if it is falling correctly.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-200',
    content: 'In the absence of resistance, life flows effortlessly.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-201',
    content: 'The screen of awareness is never damaged by the drama playing upon it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-202',
    content: 'You are not the footnote. You are the page.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-203',
    content: 'Before you name this as breath, there is breathing itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-204',
    content: 'The lotus blooms in mud yet remains unstained.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-205',
    content: 'What is here when the need to understand disappears?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-206',
    content: 'The journey inward leads to the discovery that you never moved.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-207',
    content: 'Like the sun giving light without effort, you are without trying.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-208',
    content: 'The thought "I don\'t understand" appears to one who needs no understanding.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-209',
    content: 'In the wordless space before language, truth speaks.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-210',
    content: 'The rain does not apologize for falling.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-211',
    content: 'You are the witnessing that remains when all witnessing ceases.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-212',
    content: 'The still pond reflects the moon perfectly without trying.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-213',
    content: 'What if you have always been what you are trying to become?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-214',
    content: 'The dewdrop contains the ocean.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-215',
    content: 'In the gap between doing and being done, there is pure presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-216',
    content: 'The butterfly does not remember being a caterpillar.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-217',
    content: 'Before the word "God," there is the unnamed presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-218',
    content: 'You are not traveling through time. Time is traveling through you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-219',
    content: 'The candle flame dances yet the light remains.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-220',
    content: 'What is here in the silent space between heartbeats?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-221',
    content: 'The seeker is the final obstacle to what is sought.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-222',
    content: 'Like the fragrance inseparable from the rose, awareness is inseparable from being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-223',
    content: 'The now is not thin—it has infinite depth.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-224',
    content: 'You are not the story being told. You are the listening.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-225',
    content: 'The winter tree stands bare yet complete.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-226',
    content: 'In the surrender of effort, effortlessness is revealed.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-227',
    content: 'The horizon never arrives, yet we are always here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-228',
    content: 'What remains when the mask of personality is set down?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-229',
    content: 'The river does not doubt its way to the sea.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-230',
    content: 'You are the silence in which all music plays.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-231',
    content: 'Before the concept of self and other, there is only this seamless wholeness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-232',
    content: 'The light does not fear the darkness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-233',
    content: 'In the absence of yesterday and tomorrow, what time is it?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-234',
    content: 'The diamond is already perfect beneath the dust.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-235',
    content: 'You are not contained by the body. The body is contained by you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-236',
    content: 'The moon does not chase its reflection in water.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-237',
    content: 'What is aware of confusion is itself not confused.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-238',
    content: 'The pathless path begins where you stand.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-239',
    content: 'In the stillness between words, the whole truth resides.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-240',
    content: 'The wave is always ocean, even when it believes it is separate.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-241',
    content: 'You are the open space in which closed doors appear.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-242',
    content: 'The spider weaves without self-doubt.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-243',
    content: 'Before the naming of enlightenment, there is only wakefulness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-244',
    content: 'What you are is the allowing that permits all experience.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-245',
    content: 'The echo depends on the mountain, but the mountain needs no echo.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-246',
    content: 'In the heart of chaos, stillness is untouched.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-247',
    content: 'You are not the passenger. You are the vehicle and the destination.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-248',
    content: 'The autumn leaf does not resist falling.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-249',
    content: 'What is here when the need to become someone dissolves?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-250',
    content: 'The truth is not hidden. It is too obvious to be seen.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-251',
    content: 'You are the vastness pretending to be small.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-252',
    content: 'The snow falls equally on all rooftops.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-253',
    content: 'Before the interpreter speaks, raw experience is complete.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-254',
    content: 'What remains when all identities are seen through?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-255',
    content: 'The fire needs no fuel to be fire in its essence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-256',
    content: 'You are not moving through life. Life is moving through you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-257',
    content: 'The silence of being requires no words to be understood.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-258',
    content: 'Like the center of a wheel, you remain still while all revolves.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-259',
    content: 'The mountain peak is not superior to the valley.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-260',
    content: 'In the letting go, you discover what cannot be lost.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-261',
    content: 'You are the context, not the content.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-262',
    content: 'The clouds pass. The sky remains.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-263',
    content: 'Before the thought "I am awake," there is wakefulness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-264',
    content: 'What is reading these words existed before words were learned.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-265',
    content: 'The stone sits. The sage sits. Neither make a project of it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-266',
    content: 'In the absence of the one who meditates, meditation is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-267',
    content: 'The river carves stone not by force but by presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-268',
    content: 'You are the light by which all things are seen, including darkness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-269',
    content: 'The bird does not own the sky it flies through.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-270',
    content: 'What if arriving is what you\'ve been doing all along?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-271',
    content: 'The mirror of awareness reflects all yet identifies with none.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-272',
    content: 'In the space between breaths, there is no separation.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-273',
    content: 'You are not the seeker. You are what the seeker seeks.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-274',
    content: 'The sunrise does not need to prove its beauty.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-275',
    content: 'Before the first belief, there is simple being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-276',
    content: 'What remains when the story stops for a breath?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-277',
    content: 'The drop merges with ocean and finds it was always ocean.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-278',
    content: 'You are the answer masquerading as the question.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-279',
    content: 'The empty bowl is useful precisely because it is empty.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-280',
    content: 'In the absence of tomorrow, today is infinite.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-281',
    content: 'The wind moves but the moving itself is still.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-282',
    content: 'You are not looking for peace. Peace is looking through your eyes.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-283',
    content: 'The flower opens without seeking approval.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-284',
    content: 'Before the concept of progress, there is simply presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-285',
    content: 'What is aware of time exists outside of time.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-286',
    content: 'The moon shines with borrowed light yet lacks nothing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-287',
    content: 'In the heart of noise, silence is unshaken.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-288',
    content: 'You are the space that has room for everything.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-289',
    content: 'The candle cannot light itself yet shines.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-290',
    content: 'What remains when the one who is not enough disappears?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-291',
    content: 'The now does not come and go. Coming and going appear in the now.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-292',
    content: 'You are not a fragment of wholeness. You are wholeness appearing as a fragment.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-293',
    content: 'The stone is patient without practicing patience.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-294',
    content: 'Before the first division into subject and object, there is only this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-295',
    content: 'The root nourishes without seeking recognition.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-296',
    content: 'What is here when the effort to be present ends?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-297',
    content: 'You are the eternal observer of the temporary.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-298',
    content: 'The dewdrop reflects the dawn.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-299',
    content: 'In the collapse of seeking, being reveals itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-300',
    content: 'The tree does not try to be rooted.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-301',
    content: 'You are the silence that makes sound possible.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-302',
    content: 'Before the label "spiritual experience," there is experiencing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-303',
    content: 'What is aware of doubt is itself undoubting.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-304',
    content: 'The valley makes no effort to be low.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-305',
    content: 'In the surrender of control, the controller is revealed as illusion.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-306',
    content: 'You are the light that darkness cannot comprehend.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-307',
    content: 'The lake does not try to be still on a windless day.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-308',
    content: 'Before the naming of here and there, location dissolves into presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-309',
    content: 'What remains when all techniques are forgotten?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-310',
    content: 'The star shines for no one and everyone at once.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-311',
    content: 'You are not in consciousness. Consciousness is the fact of you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-312',
    content: 'The horizon is an illusion, yet the seeing is real.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-313',
    content: 'In the death of the seeker, the sought is born.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-314',
    content: 'The wave cannot fall from the ocean.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-315',
    content: 'You are the pristine awareness in which all stains appear.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-316',
    content: 'The clay takes form yet remains clay.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-317',
    content: 'Before the first word of the day, what is already speaking?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-318',
    content: 'What is here when the need for a future falls away?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-319',
    content: 'The mountain stands in stillness, yet seasons dance around it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-320',
    content: 'You are the knowing that requires no knowledge.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-321',
    content: 'The moon needs no mirror to know itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-322',
    content: 'In the space of acceptance, resistance dissolves like morning mist.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-323',
    content: 'You are not seeking wholeness. Wholeness is seeking through you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-324',
    content: 'The bamboo bends without breaking its nature.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-325',
    content: 'Before the concept of consciousness, there is being conscious.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-326',
    content: 'What remains when the one who is incomplete vanishes?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-327',
    content: 'The rain does not choose which ground to nourish.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-328',
    content: 'You are the openness that welcomes all closing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-329',
    content: 'The fish does not study swimming.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-330',
    content: 'In the absence of striving, arrival is always now.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-331',
    content: 'You are the still center of the turning world.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-332',
    content: 'The seed trusts the darkness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-333',
    content: 'Before memory and anticipation, there is raw aliveness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-334',
    content: 'What is aware of seeking has never moved from here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-335',
    content: 'The flame dances, yet the light is constant.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-336',
    content: 'You are not becoming aware. You are awareness becoming apparent.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-337',
    content: 'The frost forms without instruction.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-338',
    content: 'In the letting be, being lets itself be known.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-339',
    content: 'You are the silence between notes that makes the music possible.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-340',
    content: 'Before the words "I am," there is the I AM.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-341',
    content: 'What remains when the mask slips for a moment?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-342',
    content: 'The mountain does not know it is tall.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-343',
    content: 'In the now, nothing is ever missing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-344',
    content: 'You are the formless taking infinite forms.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-345',
    content: 'The spider\'s web glistens with morning dew, neither clinging to nor rejecting.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-346',
    content: 'Before the thought of meditation, there is meditative presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-347',
    content: 'What is here when you stop managing your experience?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-348',
    content: 'The river finds the sea by following its nature.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-349',
    content: 'You are the capacity in which limitation appears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-350',
    content: 'The tide does not apologize for its rhythm.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-351',
    content: 'In the absence of the doer, doing continues effortlessly.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-352',
    content: 'You are not in the present moment. The present moment is in you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-353',
    content: 'The pebble sinks without resistance.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-354',
    content: 'Before the interpretation, there is pure perception.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-355',
    content: 'What remains when the commentary falls silent?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-356',
    content: 'The crystal is clear not by removing impurities, but by being itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-357',
    content: 'You are the unlimited pretending limitation is real.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-358',
    content: 'The smoke rises without choosing its direction.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-359',
    content: 'In the collapse of future and past, eternity opens.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-360',
    content: 'You are the awareness that has never been absent.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-361',
    content: 'The blossom does not regret yesterday\'s bud.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-362',
    content: 'Before the concept of self-improvement, there is the self that needs no improvement.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-363',
    content: 'What is aware of the breath is not breathing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-364',
    content: 'The stone does not wonder if it is being a stone correctly.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-365',
    content: 'In the space of non-resistance, peace reveals itself as your nature.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-366',
    content: 'You are not the river but the riverbed—unchanging, allowing flow.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-367',
    content: 'The moth seeks the flame yet you are the flame itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-368',
    content: 'Before the word "now," there is nowness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-369',
    content: 'What remains when all roles are set aside?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-370',
    content: 'The canyon is carved by water that never tries.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-371',
    content: 'You are the space that makes distance possible.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-372',
    content: 'The owl sees in darkness not by fighting it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-373',
    content: 'In the absence of preference, everything is welcomed equally.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-374',
    content: 'You are not the witness. You are the witnessing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-375',
    content: 'The shadow confirms the substance.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-376',
    content: 'Before the seeker arose, what was already here?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-377',
    content: 'What is aware of time is timeless.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-378',
    content: 'The branch does not fear the autumn.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-379',
    content: 'In the surrender of knowing, the unknown reveals itself as home.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-380',
    content: 'You are the unchanging background to all change.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-381',
    content: 'The sand does not resist the wind.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-382',
    content: 'Before division into inner and outer, there is seamless being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-383',
    content: 'What remains when the struggle ceases?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-384',
    content: 'The snow melts without mourning winter.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-385',
    content: 'You are the silence that listens to all sound.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-386',
    content: 'The pearl forms without complaining about the irritation.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-387',
    content: 'In the absence of seeking, what has always been here is noticed.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-388',
    content: 'You are not traveling to now. You are the destination itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-389',
    content: 'The morning does not announce itself—it simply is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-390',
    content: 'Before all philosophy, there is this simple awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-391',
    content: 'What is aware of incompleteness is itself complete.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-392',
    content: 'The wave never leaves the ocean even when it crashes.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-393',
    content: 'In the falling away of the one who tries, effortlessness remains.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-394',
    content: 'You are the infinite masquerading as the finite.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-395',
    content: 'The leaf does not question its falling.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-396',
    content: 'Before the thought of home, you have never left.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-397',
    content: 'What remains when nothing remains to be done?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-398',
    content: 'The moon does not practice fullness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-399',
    content: 'In this breath, the entire universe appears and disappears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-400',
    content: 'You are the eternal now, pretending to have a past and future.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),

  // --- original_batch_1.dart ---
  // === ORIGINAL POINTINGS - BATCH 1 (100 quotes) ===
  Pointing(
    id: 'ori-1',
    content: 'Rest doesn\'t come from stopping. Notice what has never been disturbed.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-2',
    content: 'You are not looking for peace. You are the peace that is looking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-3',
    content: 'The silence you seek is already here, waiting patiently beneath every sound.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-4',
    content: 'What if nothing needs to be fixed?',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-5',
    content: 'This moment is not happening to you. You are this moment happening.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-6',
    content: 'Before your next thought, what are you?',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-7',
    content: 'The vastness you sense in the night sky is your own nature looking back at itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-8',
    content: 'Home is not a place. It is this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-9',
    content: 'The search ends where it began—here.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-10',
    content: 'What remains when you stop trying to be someone?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-11',
    content: 'Awareness doesn\'t have problems. Notice who is troubled.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-12',
    content: 'The story of your life is not you. What is reading the story?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-13',
    content: 'Stillness is not something you achieve. It is what achieves you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-14',
    content: 'Every breath is an invitation to return.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-15',
    content: 'The present moment is not a duration. It is a depth.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-16',
    content: 'You have never left presence. Only the story says otherwise.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-17',
    content: 'What you are cannot be lost or found.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-18',
    content: 'The witness of confusion is not confused.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-19',
    content: 'Liberation is not an event. It is the noticing of what has always been free.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-20',
    content: 'Your true nature has no edges. Where would it end?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-21',
    content: 'Before the mind wakes, you are. After the mind sleeps, you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-22',
    content: 'The space between thoughts is not empty. It is full of you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-23',
    content: 'Nothing is closer to you than this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-24',
    content: 'The extraordinary is hidden in plain sight—as the ordinary.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-25',
    content: 'You are not in the world. The world appears in you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-26',
    content: 'What if awareness is already complete?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-27',
    content: 'The ocean doesn\'t need to find water.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-28',
    content: 'Suffering is resistance. What happens when resistance is seen?',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-29',
    content: 'This breath. This light. This life. Already whole.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-30',
    content: 'The seeker and the sought are one movement.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-31',
    content: 'What knows this moment? Be that.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-32',
    content: 'Presence doesn\'t come and go. Only attention wanders.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-33',
    content: 'The mind creates time. You create the mind.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-34',
    content: 'Between stimulus and response, there is space. That space is you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-35',
    content: 'Awakening is not a change. It is a seeing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-36',
    content: 'The sun doesn\'t struggle to shine. Neither do you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-37',
    content: 'What is looking through your eyes right now?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-38',
    content: 'Thoughts are clouds. You are the sky.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-39',
    content: 'The deepest truth is the simplest one.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-40',
    content: 'Nothing needs to happen for you to be whole.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-41',
    content: 'Awareness is not something you have. It is what you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-42',
    content: 'The present moment has no opposite.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-43',
    content: 'Who you think you are is not who you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-44',
    content: 'Rest in not knowing. Certainty is a prison.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-45',
    content: 'The answer to every question is the same: presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-46',
    content: 'Life is not a problem to solve. It is a mystery to inhabit.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-47',
    content: 'What would remain if you dropped the story of you?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-48',
    content: 'Enlightenment is not an attainment. It is a subtraction.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-49',
    content: 'You cannot be separate from what is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-50',
    content: 'The door is already open. Notice who keeps closing it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-51',
    content: 'There is only this. And even "this" is too much.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-52',
    content: 'What hears the silence between sounds?',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-53',
    content: 'The mind complicates. Being is simple.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-54',
    content: 'You are the space in which experience unfolds.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-55',
    content: 'Nothing needs to be added to make this moment complete.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-56',
    content: 'The one who wants to wake up is already awake.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-57',
    content: 'Effort happens. Surrender happens. Both appear in stillness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-58',
    content: 'Before you labeled it, what was it?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-59',
    content: 'Peace is not the absence of disturbance. It is the presence that holds disturbance.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-60',
    content: 'What remains constant as everything changes?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-61',
    content: 'The body breathes itself. Life lives itself. You are that.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-62',
    content: 'Every moment is the first moment.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-63',
    content: 'The infinite appears as the intimate.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-64',
    content: 'You have never been other than this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-65',
    content: 'Notice what notices.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-66',
    content: 'The miracle is not in what happens. It is in the happening itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-67',
    content: 'What is it that doesn\'t sleep when the body sleeps?',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-68',
    content: 'All experience confirms presence. No experience denies it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-69',
    content: 'You cannot step outside of now.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-70',
    content: 'The ground beneath seeking is already found.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-71',
    content: 'What is aware of awareness?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-72',
    content: 'This very dissatisfaction points to what is already satisfied.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-73',
    content: 'Silence is not quiet. It is fullness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-74',
    content: 'The self you are protecting doesn\'t exist.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-75',
    content: 'What would change if you stopped imagining yourself into existence?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-76',
    content: 'The world appears. You are the appearing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-77',
    content: 'Every sensation is a doorway home.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-78',
    content: 'What is there before you think about it?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-79',
    content: 'The observer is not separate from what is observed.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-80',
    content: 'Waking from the dream of separation is a gentle thing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-81',
    content: 'You don\'t have to believe anything. Just look.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-82',
    content: 'The path ends where the pathless begins.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-83',
    content: 'All boundaries are imagined.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-84',
    content: 'Stillness moves. Movement rests in stillness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-85',
    content: 'The mind asks "Why?" Being is the answer.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-86',
    content: 'What you resist persists. What you allow, transforms.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-87',
    content: 'The present is not a slice of time. It is eternity.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-88',
    content: 'Nothing is missing from this moment.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-89',
    content: 'The thought "I am not awake" appears in awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-90',
    content: 'You are already there. Where else could you be?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-91',
    content: 'Life is not a rehearsal. This is it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-92',
    content: 'Who you are has no history.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-93',
    content: 'Every ending reveals the beginning that was never lost.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-94',
    content: 'Presence is both the question and the answer.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-95',
    content: 'What sees cannot be seen. What knows cannot be known.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-96',
    content: 'You don\'t need to quiet the mind. Just notice what is already quiet.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-97',
    content: 'The small self is not destroyed. It is seen through.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-98',
    content: 'Now is not a moment in time. It is freedom from time.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-99',
    content: 'The light that illuminates experience is your own light.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-100',
    content: 'Let everything be exactly as it is. What changes?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),

  // --- original_batch_2.dart ---
  // === ORIGINAL POINTINGS - BATCH 2 (100 quotes, ori-101 to ori-200) ===
  Pointing(
    id: 'ori-101',
    content: 'The universe experiences itself through you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-102',
    content: 'What is looking when no one is looking?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-103',
    content: 'Thoughts appear and disappear. You remain.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-104',
    content: 'The cage was never locked.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-105',
    content: 'Surrender is not giving up. It is waking up.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-106',
    content: 'What you are seeking is causing you to seek.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-107',
    content: 'The gap between breaths is not empty.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-108',
    content: 'Being needs no practice.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-109',
    content: 'Every wave is the whole ocean waving.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-110',
    content: 'The question dissolves in the asking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-111',
    content: 'What remains when preference ends?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-112',
    content: 'You are not behind your eyes. You are everything appearing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-113',
    content: 'The mind divides. Awareness includes.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-114',
    content: 'What you truly are has never suffered.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-115',
    content: 'Presence is not something you become. It is what you already are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-116',
    content: 'The witness has no location.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-117',
    content: 'Every experience confirms awareness. Nothing contradicts it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-118',
    content: 'What is aware of reading these words?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-119',
    content: 'The river doesn\'t know it\'s going home to the sea.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-120',
    content: 'Stop. What is already here?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-121',
    content: 'The knower cannot be known as an object.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-122',
    content: 'Life is living you. Let it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-123',
    content: 'The space that holds this moment has no edges.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-124',
    content: 'What if you stopped waiting to begin?',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-125',
    content: 'Pain is inevitable. Suffering is optional.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-126',
    content: 'The separate self exists only in thought.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-127',
    content: 'Before memory, what were you?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-128',
    content: 'Nothing is personal. Everything is intimate.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-129',
    content: 'The mind that seeks is the mind that hides.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-130',
    content: 'Awareness is the constant in all experience.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-131',
    content: 'Where does one moment end and another begin?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-132',
    content: 'You are the knowing, not the known.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-133',
    content: 'What sees the thought as thought?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-134',
    content: 'The one looking for enlightenment is the obstacle to it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-135',
    content: 'Relaxation is not lazy. It is trusting.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-136',
    content: 'No moment has ever been ordinary.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-137',
    content: 'What would be left if you subtracted all concepts?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-138',
    content: 'Consciousness doesn\'t have a boundary.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-139',
    content: 'The end of seeking is not finding. It is seeing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-140',
    content: 'This moment lacks nothing.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-141',
    content: 'Who you are is not a work in progress.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-142',
    content: 'The simplest things are the hardest to see.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-143',
    content: 'What is aware of the sense of being a person?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-144',
    content: 'Everything changes. Awareness doesn\'t.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-145',
    content: 'The peace you seek is the peace you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-146',
    content: 'When you stop moving toward, something opens.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-147',
    content: 'What is it that remains when everything is taken away?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-148',
    content: 'The eye cannot see itself. The self cannot find itself.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-149',
    content: 'Eternity is not long. It is deep.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-150',
    content: 'What hears this silence right now?',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-151',
    content: 'The world is appearing to no one.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-152',
    content: 'Each breath is a beginning.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.morning],
  ),
  Pointing(
    id: 'ori-153',
    content: 'The problem is the search for the solution.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-154',
    content: 'Being is not a state. States come and go in being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-155',
    content: 'What knows itself without thought?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-156',
    content: 'The I that seeks liberation is itself bondage.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-157',
    content: 'All suffering is imaginary. The sufferer is real.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-158',
    content: 'Rest as what you are, not as what you think you are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-159',
    content: 'The background of all experience is you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-160',
    content: 'Where does awareness end and content begin?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-161',
    content: 'What you are looking for is what is looking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-162',
    content: 'The dream of separation ends when it is seen as a dream.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-163',
    content: 'Grace is always falling. Open your hands.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-164',
    content: 'What is the taste of being before you name it?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-165',
    content: 'There is no path to the present.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-166',
    content: 'The only real meditation is what is.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-167',
    content: 'Acceptance is not passive. It is spacious.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-168',
    content: 'You don\'t need more time. You need more now.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-169',
    content: 'The teacher is your own being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-170',
    content: 'What you resist owns you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.stress],
  ),
  Pointing(
    id: 'ori-171',
    content: 'Thinking about awareness is not awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-172',
    content: 'The gateless gate is always open.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-173',
    content: 'What is the shape of now?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-174',
    content: 'Liberation is the recognition that nothing was ever bound.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-175',
    content: 'The space in this room is the space everywhere.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-176',
    content: 'What remains when you stop pretending?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-177',
    content: 'Truth is not a conclusion. It is an opening.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-178',
    content: 'The seeker is a ghost.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-179',
    content: 'What you are cannot be improved.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-180',
    content: 'The destination is the journey recognized.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-181',
    content: 'Don\'t seek. See.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-182',
    content: 'Every phenomenon is empty and luminous.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-183',
    content: 'The treasure is hidden in plain view.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-184',
    content: 'What is the distance between you and now?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-185',
    content: 'You are the openness in which everything appears.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-186',
    content: 'There is no outside to this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-187',
    content: 'The mind says: "Not this." Being says: "Yes, this."',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-188',
    content: 'What is aware of the feeling of being limited?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-189',
    content: 'Every moment is complete.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-190',
    content: 'The I-thought is just another thought.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-191',
    content: 'Enlightenment is the absence of the one who wants it.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-192',
    content: 'What knows doesn\'t come and go.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-193',
    content: 'The one who arrives is not the one who left.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-194',
    content: 'Silence is the language of being.',

    tradition: Tradition.original,
    contexts: [PointingContext.general, PointingContext.evening],
  ),
  Pointing(
    id: 'ori-195',
    content: 'What feels like you is what you seek.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-196',
    content: 'The center is everywhere.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-197',
    content: 'Nothing is happening to anyone.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-198',
    content: 'The now doesn\'t last. It doesn\'t need to.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-199',
    content: 'What is there when you let go completely?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'ori-200',
    content: 'This is it. There is no other.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),

// Helper functions

  // --- generated_quotes.dart ---
  Pointing(
    id: 'adv-121',
    content: 'The Self cannot be known as an object. It is the knower of all objects.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-122',
    content: 'Where is the question of bondage when the Self alone exists?',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-123',
    content: 'Your own Self-Realization is the greatest service you can render the world.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-124',
    content: 'Silence is the most potent form of work. However vast and emphatic the scriptures may be, they fail in their effect.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-125',
    content: 'That which is, is only one. People call it by various names.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-126',
    content: 'Mind is consciousness which has put on limitations. You are originally unlimited and perfect. Later you take on limitations and become the mind.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-127',
    content: 'The degree of freedom from unwanted thoughts and the degree of concentration on a single thought are the measures of your progress.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-128',
    content: 'Wanting to reform the world without discovering one\'s true self is like trying to cover the world with leather to avoid the pain of walking on stones.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-129',
    content: 'Let what comes come. Let what goes go. Find out what remains.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.evening],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-130',
    content: 'There is no greater mystery than this: ourselves being the Reality, we seek to gain Reality.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-131',
    content: 'When you know yourself, all this confusion disappears. You are not the doer, you are not the enjoyer.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-132',
    content: 'To know that you are a prisoner of your mind is the dawn of wisdom.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-133',
    content: 'The real is simple, open, clear and kind, beautiful and joyous. It is free of contradictions.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-134',
    content: 'All you need is already within you, only you must approach yourself with reverence and love.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-135',
    content: 'Once you realize that the road is the goal and that you are always on the road, not to reach a goal but to enjoy its beauty and wisdom, life ceases to be a task.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-136',
    content: 'Wisdom is knowing I am nothing, love is knowing I am everything, and between the two my life moves.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-137',
    content: 'It is the mind that tells you that the mind is there. Don\'t be deceived. All the endless arguments about the mind are produced by the mind itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-138',
    content: 'When I look inside and see that I am nothing, that is wisdom. When I look outside and see that I am everything, that is love.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-139',
    content: 'All suffering is born of desire. True love is never frustrated. How can the sense of unity be frustrated?',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-140',
    content: 'Give up all questions except one: Who am I? After all, the only fact you are sure of is that you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-141',
    content: 'Stop imagining yourself being or doing this or that and the realization that you are the source and heart of all will dawn upon you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-142',
    content: 'The mind creates the abyss, and the heart crosses it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-143',
    content: 'When the birth is forgotten, the pure Self remains.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-144',
    content: 'You are not what you think yourself to be, but what you think, you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-145',
    content: 'Do not be afraid of freedom from desire and fear. It enables you to live a life so different from all you know.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-146',
    content: 'You need not get at it, for you are it. It will get at you if you give it a chance.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-147',
    content: 'If you just sit and observe, you will see how restless your mind is. When you try to calm it, it only makes it worse.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-148',
    content: 'Love is not selective, desire is selective. In love there are no strangers.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-149',
    content: 'The gnani does not live in a world different from yours. His world is the same as yours, but he does not make any mistake about it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-150',
    content: 'Searching for happiness is the sure way to miss it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-151',
    content: 'Simply stop. Be still. Don\'t think, don\'t imagine.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.morning, PointingContext.stress],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-152',
    content: 'You are always free. You only have to keep quiet and watch.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-153',
    content: 'Freedom is here now. Not later. Now. This instant. This very breath.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-154',
    content: 'The river does not make any effort to flow. Likewise, let everything be as it is.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.evening],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-155',
    content: 'There is no practice needed for being what you already are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-156',
    content: 'Stop, look, and be still. This is the practice—no practice.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.morning, PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-157',
    content: 'Keep quiet and everything will be done by itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-158',
    content: 'The Self is not attained, it is revealed when you stop doing, stop thinking, stop seeking.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-159',
    content: 'Be like an ocean: deep, quiet, at peace. Not like the waves, always moving.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.evening, PointingContext.stress],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-160',
    content: 'This moment is all there is. There is no becoming, no future, just this.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-161',
    content: 'Stay as the awareness that you are. No effort is needed.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-162',
    content: 'Don\'t go with your mind, go with your Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-163',
    content: 'Don\'t try to become free. Just know that you already are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-164',
    content: 'Be aware of the aware presence. That is all.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.morning, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-165',
    content: 'Leave your existence to existence, stop caring for yourself so much and let the universe care for you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-166',
    content: 'You are the unchanging seer. All else is transient phenomenon.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-167',
    content: 'Surrender is not weakness. It is the recognition of your true power.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-168',
    content: 'Your natural state is spontaneity and freedom. Return to it.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-169',
    content: 'You are the space in which all experiences occur.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-170',
    content: 'Step out of the traffic of thoughts and rest in pure being.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.evening],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-171',
    content: 'Be without attributes. Be without qualities. Just be.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-172',
    content: 'You are neither bound nor free. You are pure consciousness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-173',
    content: 'In the ocean of being, you are the entire ocean. Not a wave.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-174',
    content: 'The wise person is one who knows that Self and non-Self are both illusion.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-175',
    content: 'Your nature is free. Be free now, not tomorrow.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-176',
    content: 'Let go of meditation. Let go of non-meditation. Just be.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-177',
    content: 'Renounce nothing, grasp nothing, remain as you are.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-178',
    content: 'You are the witness of all things. Untouched, pure, still.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-179',
    content: 'There is no doer. All actions happen by themselves.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-180',
    content: 'The Self is everywhere. It is not to be found. It is not hidden.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-181',
    content: 'Do not seek to become anything. You already are That.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-182',
    content: 'Liberation is not somewhere else. It is right here, right now.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-183',
    content: 'All your efforts are in vain. Be effortlessly yourself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-184',
    content: 'Knowledge, ignorance—both are mere concepts. You are beyond both.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-185',
    content: 'The mind that says "I am bound" is the bondage. The mind that says nothing is freedom.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-186',
    content: 'By knowing that nothing is yours, you become master of all.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ashtavakra Gita',
  ),
  Pointing(
    id: 'adv-187',
    content: 'Abide in the Self. Everything else will fall into place.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-188',
    content: 'The Self shines by itself. No effort can make it shine more.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-189',
    content: 'Grace is always present. You just have to be receptive.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-190',
    content: 'There is no inside or outside. There is only the One.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-191',
    content: 'Be still and know. That is enough.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.morning, PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-192',
    content: 'Nothing real can be threatened. Nothing unreal exists.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-193',
    content: 'The moment you know you are not the person, you become free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-194',
    content: 'You are the immovable behind and beyond all movement.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-195',
    content: 'Understanding is all. The rest comes by itself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-196',
    content: 'In reality, only the Self is. There is nothing but the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-197',
    content: 'When you realize that nothing belongs to you, everything belongs to you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-198',
    content: 'Perfect happiness is the absence of striving for happiness.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-199',
    content: 'Don\'t move, don\'t stir. Just be quiet and see what happens.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.morning, PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-200',
    content: 'The answer is always silence. Words can only point.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-201',
    content: 'The world is a projection of mind. Know the mind, know the truth.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-202',
    content: 'Where attention is, that becomes real. Turn attention to the Self.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-203',
    content: 'The ego is a phantom. When you seek it, it vanishes.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-204',
    content: 'Your burden is of false ideas only. Abandon them and be free.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-205',
    content: 'Don\'t be afraid to let go. What you lose was never yours.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-206',
    content: 'The teacher can only point. You must look.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-207',
    content: 'Throw away all concepts. Stand naked before reality.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-208',
    content: 'The seeing is the evidence of the seer. You are always seeing.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-209',
    content: 'You are prior to all experience. Find that prior state.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'adv-210',
    content: 'Who is it that wants to be free? Look at that one.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-211',
    content: 'Let life flow. Don\'t hold on to anything.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-212',
    content: 'The mind says "later." The heart says "now."',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-213',
    content: 'You don\'t need to improve yourself. You need to discover yourself.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-214',
    content: 'Stop postponing peace. It is here right now.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-215',
    content: 'Be the witness of thoughts, not the thinker.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-216',
    content: 'You are infinite. Don\'t let the body-mind fool you.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'adv-217',
    content: 'Freedom is your natural state. Everything else is imagination.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-218',
    content: 'There is no path to truth. You are already there.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Papaji',
  ),
  Pointing(
    id: 'adv-219',
    content: 'Ask yourself: To whom does this thought arise?',

    tradition: Tradition.advaita,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Ramana Maharshi',
  ),
  Pointing(
    id: 'adv-220',
    content: 'The waves rise and fall. The ocean remains unmoved.',

    tradition: Tradition.advaita,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Nisargadatta Maharaj',
  ),
  Pointing(
    id: 'zen-105',
    content: 'To study Buddhism is to study the self. To study the self is to forget the self.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-106',
    content: 'If you understand, things are just as they are. If you do not understand, things are just as they are.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-107',
    content: 'The perfect way is without difficulty, save that it avoids picking and choosing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-108',
    content: 'If you want the truth to stand clear before you, never be for or against.',

    tradition: Tradition.zen,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-109',
    content: 'The mind is the Buddha, and the Buddha is the mind. Beyond mind there is no Buddha, beyond Buddha there is no mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-110',
    content: 'If you seek, how is that different from pursuing sound and form?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-111',
    content: 'All the Buddhas and all sentient beings are nothing but the One Mind, beside which nothing exists.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-112',
    content: 'Your ordinary mind is the Way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-113',
    content: 'Words are the disease. Silence is the cure.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-114',
    content: 'If you would spend all your time seeking Buddha, you would waste all your time.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-115',
    content: 'Throughout the body are the hands and eyes.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-116',
    content: 'When you paint spring, do not paint willows, plums, peaches, or apricots—just paint spring.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-117',
    content: 'To carry yourself forward and experience myriad things is delusion. That myriad things come forth and experience themselves is awakening.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-118',
    content: 'Do not follow the ideas of others, but learn to listen to the voice within yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-119',
    content: 'If you cannot find the truth right where you are, where else do you expect to find it?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-120',
    content: 'Think non-thinking. How do you think non-thinking? Beyond thinking.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-121',
    content: 'Just practice without seeking, and realization will come naturally.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-122',
    content: 'Time is constantly flying like an arrow. Do not waste your life away in vain.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-123',
    content: 'Not knowing is most intimate.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-124',
    content: 'Before you take another step, where are you?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen koan',
  ),
  Pointing(
    id: 'zen-125',
    content: 'If you wish to see the truth, hold no opinions for or against anything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-126',
    content: 'Not thinking about anything is Zen. Once you know this, walking, sitting, or lying down, everything you do is Zen.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-127',
    content: 'The essence of the Way is detachment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-128',
    content: 'To find a Buddha, you have to see your nature. Whoever sees his nature is a Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-129',
    content: 'All phenomena are empty. There is nothing to attain.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-130',
    content: 'If you use your mind to look for a Buddha, you won\'t see the Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-131',
    content: 'The Buddha is your real body, your original mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-132',
    content: 'If you see your nature, you don\'t need to read sutras or invoke Buddhas.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-133',
    content: 'Your nature is the same as mine. There is no difference.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-134',
    content: 'To have nothing in the mind is to be in harmony with all things.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-135',
    content: 'If you want to understand, know that a sudden comprehension comes without hesitation.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-136',
    content: 'Your unborn Buddha-mind is marvelously illuminating.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-137',
    content: 'All things are perfectly resolved in the Unborn.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-138',
    content: 'When you dwell in the Unborn, you are dwelling in the Unborn Buddha-mind itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-139',
    content: 'Don\'t seek enlightenment. Just give up the thought of becoming enlightened.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-140',
    content: 'No dualism, no separation.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-141',
    content: 'The great way is not difficult for those who have no preferences.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-142',
    content: 'When walking, just walk. When sitting, just sit. Above all, don\'t wobble.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-143',
    content: 'The instant you speak about a thing you miss the mark.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-144',
    content: 'In the beginner\'s mind there are many possibilities. In the expert\'s mind there are few.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-145',
    content: 'The most important thing is to find out what is the most important thing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-146',
    content: 'When you do something, you should burn yourself completely, like a good bonfire, leaving no trace.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-147',
    content: 'Each moment is the universe.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-148',
    content: 'Just be yourself. No need to have some special understanding.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-149',
    content: 'What we call "I" is just a swinging door which moves when we inhale and when we exhale.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-150',
    content: 'Zen is not some kind of excitement, but concentration on our usual everyday routine.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-151',
    content: 'Without thinking, just being there, you become one with everything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-152',
    content: 'Things are not permanent. We should appreciate each moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-153',
    content: 'The seed has no idea of being some particular plant, but it has its own form.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Shunryu Suzuki',
  ),
  Pointing(
    id: 'zen-154',
    content: 'Walk as if you are kissing the earth with your feet.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-155',
    content: 'Breath is the bridge which connects life to consciousness.',

    tradition: Tradition.zen,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-156',
    content: 'The present moment is filled with joy and happiness. If you are attentive, you will see it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-157',
    content: 'Feelings come and go like clouds in a windy sky. Conscious breathing is my anchor.',

    tradition: Tradition.zen,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-158',
    content: 'Smile, breathe, and go slowly.',

    tradition: Tradition.zen,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-159',
    content: 'To be beautiful means to be yourself. You don\'t need to be accepted by others. You need to accept yourself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-160',
    content: 'Letting go gives us freedom, and freedom is the only condition for happiness.',

    tradition: Tradition.zen,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-161',
    content: 'The most precious gift we can offer anyone is our attention.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-162',
    content: 'You are a miracle, and everything you touch could be a miracle.',

    tradition: Tradition.zen,
    contexts: [PointingContext.morning, PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-163',
    content: 'Peace is every step.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.stress],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-164',
    content: 'Drink your tea slowly and reverently, as if it is the axis on which the earth revolves.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-165',
    content: 'The wave does not need to die to become water. She is already water.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-166',
    content: 'Nothing is separate. Everything is interbeing.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-167',
    content: 'No coming, no going. No before, no after.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-168',
    content: 'Life is available only in the present moment.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-169',
    content: 'Silence is essential. We need silence just as much as we need air, just as much as plants need light.',

    tradition: Tradition.zen,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-170',
    content: 'Understanding is love\'s other name.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Thich Nhat Hanh',
  ),
  Pointing(
    id: 'zen-171',
    content: 'No self, no problem.',

    tradition: Tradition.zen,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-172',
    content: 'Before enlightenment, chop wood, carry water. After enlightenment, chop wood, carry water.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-173',
    content: 'If you meet a Buddha on the road, kill him.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-174',
    content: 'Ordinary mind is the way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-175',
    content: 'What is the sound of one hand clapping?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen koan',
  ),
  Pointing(
    id: 'zen-176',
    content: 'Show me your original face before you were born.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen koan',
  ),
  Pointing(
    id: 'zen-177',
    content: 'Does a dog have Buddha nature?',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen koan',
  ),
  Pointing(
    id: 'zen-178',
    content: 'When hungry, eat. When tired, sleep.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-179',
    content: 'In the landscape of spring, there is neither better nor worse.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-180',
    content: 'Mountains and rivers are the body of Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-181',
    content: 'Realization is not about understanding with the head. It is about understanding with the whole body.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Dogen',
  ),
  Pointing(
    id: 'zen-182',
    content: 'Everything is already complete.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-183',
    content: 'The teaching is already within you. You just need to wake up to it.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-184',
    content: 'Sitting still, doing nothing, spring comes and grass grows by itself.',

    tradition: Tradition.zen,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-185',
    content: 'The blue mountains are of themselves blue mountains. The white clouds are of themselves white clouds.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-186',
    content: 'When the student is ready, the teacher appears. When the student is truly ready, the teacher disappears.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-187',
    content: 'One moment of total awareness is one moment of perfect freedom.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-188',
    content: 'The finger pointing to the moon is not the moon.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-189',
    content: 'Empty your cup so that it may be filled.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-190',
    content: 'Move and the way will open.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-191',
    content: 'No snowflake ever falls in the wrong place.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-192',
    content: 'This very place is the Lotus Land. This very body, the Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Zen saying',
  ),
  Pointing(
    id: 'zen-193',
    content: 'Gate gate paragate parasamgate bodhi svaha. Gone, gone, gone beyond, gone altogether beyond. Oh what an awakening!',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Heart Sutra',
  ),
  Pointing(
    id: 'zen-194',
    content: 'Form is emptiness, emptiness is form.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Heart Sutra',
  ),
  Pointing(
    id: 'zen-195',
    content: 'The foolish reject what they see, not what they think. The wise reject what they think, not what they see.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-196',
    content: 'When you seek nothing, you are on the Way.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-197',
    content: 'Mind is Buddha. No mind, no Buddha.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-198',
    content: 'The void is omnipresent, but it neither seeks nor rejects anything.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-199',
    content: 'If you practice non-doing, you will immediately transcend dualism.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Huang Po',
  ),
  Pointing(
    id: 'zen-200',
    content: 'Not creating karma is called non-action. Keeping mind free of defilement is called purity.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-201',
    content: 'The essence of the mind is empty. Mountains and rivers, earth and sky—all are reflected in the mind.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Bodhidharma',
  ),
  Pointing(
    id: 'zen-202',
    content: 'To see things as they truly are is to see with the mind undisturbed.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-203',
    content: 'The marvelous illumination of the unborn Buddha-mind deals freely and spontaneously with anything it encounters.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'zen-204',
    content: 'You can\'t see your Buddha-mind. But you can\'t help seeing it, either.',

    tradition: Tradition.zen,
    contexts: [PointingContext.general],
    teacher: 'Bankei',
  ),
  Pointing(
    id: 'dir-122',
    content: 'Notice that you are aware. This noticing is what you are.',

    tradition: Tradition.direct,
    contexts: [PointingContext.morning, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-123',
    content: 'All experience is made of awareness, just as all waves are made of water.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-124',
    content: 'Happiness is the nature of being, not a state of mind.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-125',
    content: 'There is only one substance in experience: awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-126',
    content: 'The separate self is an activity, not an entity.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-127',
    content: 'There is no person that becomes aware. Awareness simply becomes aware of itself.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-128',
    content: 'Nothing exists independently of awareness. Everything exists in and as awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-129',
    content: 'In the presence of awareness, suffering dissolves naturally.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-130',
    content: 'To know "I am" is to know all that is necessary to know.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-131',
    content: 'The body appears in awareness, not awareness in the body.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-132',
    content: 'Thoughts, like clouds, appear and disappear in the sky of awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-133',
    content: 'All problems are created by the apparent separate self and dissolve in its absence.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-134',
    content: 'We are the presence in which all experience appears.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-135',
    content: 'Simply be knowingly the awareness that you always already are.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-136',
    content: 'The world is a reflection of the divine nature of awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-137',
    content: 'Awareness loses nothing and gains nothing. It simply is.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-138',
    content: 'The search for happiness ends when we realize we are the happiness we are seeking.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-139',
    content: 'Nothing is ever born. Nothing ever dies. Only awareness is.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-140',
    content: 'The mind cannot know awareness, but awareness knows the mind.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-141',
    content: 'All that is required is a change of perspective, not a change of experience.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-142',
    content: 'Awareness never became a person. A person is simply a thought and feeling that appear in awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-143',
    content: 'The only thing that exists is consciousness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-144',
    content: 'There is only one I, and that I is universal consciousness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-145',
    content: 'All objects are made of consciousness and exist only in consciousness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-146',
    content: 'The feeling of separation is the root of all suffering.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-147',
    content: 'The truth is that you are already free. The search for freedom is what binds you.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-148',
    content: 'You are not a body with consciousness. You are consciousness with a body.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-149',
    content: 'The purpose of meditation is to establish yourself in your natural state.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-150',
    content: 'Love and understanding are the same thing.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-151',
    content: 'The recognition of the Self is instantaneous and effortless.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-152',
    content: 'Everything that appears is consciousness appearing as that.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-153',
    content: 'Your true nature is absolute freedom.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-154',
    content: 'Nothing needs to be done. Simply be.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-155',
    content: 'The personal self is a fantasy. Only consciousness is real.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-156',
    content: 'When thought subsides, peace is revealed.',

    tradition: Tradition.direct,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-157',
    content: 'Consciousness is the common ground of all experience.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-158',
    content: 'You are not a seeker. You are what you are seeking.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-159',
    content: 'The moment you become aware of the ego in you, it is no longer the ego, but just an old habit.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-160',
    content: 'When you listen without the idea of right or wrong, you are listening with your whole being.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-161',
    content: 'Don\'t try to become what you already are.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-162',
    content: 'The simplicity of being needs no support from thinking.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-163',
    content: 'In silence, all questions are answered.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-164',
    content: 'You are the openness in which everything appears.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-165',
    content: 'Awareness needs no practice. It is already here.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-166',
    content: 'The body exists in consciousness, not consciousness in the body.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-167',
    content: 'Let everything be as it is without commentary.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-168',
    content: 'You are free from all that appears in you.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-169',
    content: 'The I thought is the first thought. Behind it is pure I am.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-170',
    content: 'All perceptions are in consciousness. Consciousness is not in perceptions.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-171',
    content: 'The witness itself is the witnessed.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-172',
    content: 'To know yourself as consciousness is liberation.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-173',
    content: 'The world is nothing but consciousness appearing as objects.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-174',
    content: 'You are the background of all experience, never an object in it.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-175',
    content: 'Knowing is being. Being is knowing.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-176',
    content: 'The only proof of consciousness is consciousness itself.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-177',
    content: 'The direct path is the shortest. It is also the only path.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-178',
    content: 'Every thought says "I am." This is the truth hidden in every thought.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-179',
    content: 'Awareness is not a product of mind. Mind is a product of awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-180',
    content: 'All you need to do is recognize what you already are.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-181',
    content: 'The peace you long for is the peace you are.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-182',
    content: 'Experience is made of awareness, known by awareness, and is awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-183',
    content: 'Awareness is not located in the body. The body is located in awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-184',
    content: 'The present moment is saturated with eternity.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-185',
    content: 'Every experience is a celebration of awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-186',
    content: 'Love is the recognition of our shared being.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-187',
    content: 'Enlightenment is the recognition that there is no one to become enlightened.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-188',
    content: 'Consciousness is the light that illuminates all experience.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-189',
    content: 'Nothing stands between you and truth. You are truth.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-190',
    content: 'All sorrow is born from the illusion of separation.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-191',
    content: 'Reality is not something to be attained. It is what is.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-192',
    content: 'Your true nature is formless, timeless, spaceless.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-193',
    content: 'The witness and the witnessed are one.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-194',
    content: 'Silence is not the absence of sound. It is the presence of awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-195',
    content: 'Being is presence without object.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-196',
    content: 'What perceives is what is perceived.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-197',
    content: 'Consciousness is the ultimate subject that can never become an object.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-198',
    content: 'The I that thinks it is bound is the same I that is free.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-199',
    content: 'What you are seeking is what is seeking.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-200',
    content: 'All experience is the play of consciousness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-201',
    content: 'Be aware of being aware. That is all.',

    tradition: Tradition.direct,
    contexts: [PointingContext.morning, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-202',
    content: 'Experience doesn\'t happen to awareness. Experience is awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-203',
    content: 'Resistance is the only problem. Allow everything.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-204',
    content: 'The sense of being is the most intimate experience we have.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-205',
    content: 'Nothing is happening to you. Everything is happening as you.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-206',
    content: 'There is no path from here to here.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-207',
    content: 'You are the space in which everything exists.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-208',
    content: 'Peace is your nature. Seeking is what disturbs it.',

    tradition: Tradition.direct,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Francis Lucille',
  ),
  Pointing(
    id: 'dir-209',
    content: 'Consciousness is self-evident. No proof is needed.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-210',
    content: 'The body is in you. You are not in the body.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-211',
    content: 'When the mind is quiet, truth reveals itself.',

    tradition: Tradition.direct,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Jean Klein',
  ),
  Pointing(
    id: 'dir-212',
    content: 'The known and the knower are one in consciousness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-213',
    content: 'Everything is consciousness perceiving itself.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-214',
    content: 'The subject and object are one reality appearing as two.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-215',
    content: 'No separate entity has ever existed. Only consciousness is.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Atmananda Krishna Menon',
  ),
  Pointing(
    id: 'dir-216',
    content: 'Awareness is the only constant in all changing experience.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-217',
    content: 'To be yourself requires no effort. To pretend to be someone else does.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-218',
    content: 'Happiness shines when nothing obscures it.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-219',
    content: 'Awareness is the substance of all experience.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-220',
    content: 'The world is the external manifestation of consciousness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'dir-221',
    content: 'Nothing is ever lost. Everything returns to awareness.',

    tradition: Tradition.direct,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Rupert Spira',
  ),
  Pointing(
    id: 'con-112',
    content: 'Enlightenment is a destructive process. It has nothing to do with becoming better or being happier.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-113',
    content: 'The Truth is beyond time. It is always here, always now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-114',
    content: 'The moment you grasp the mystery, you lose it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-115',
    content: 'Awakening is not a thing. It is not a goal. It is a letting go.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-116',
    content: 'Your natural state is joy. Not the joy that comes from something, but the joy that is the ground of being.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-117',
    content: 'Meditation is not about having an experience. It is about discovering who you are before experience.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-118',
    content: 'The unknown is the root of all freedom.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-119',
    content: 'All you need to do is stop taking yourself to be what you think you are.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-120',
    content: 'The spiritual journey is about unlearning, not learning.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-121',
    content: 'You cannot make yourself awaken. But you can stop pretending to be asleep.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-122',
    content: 'The now has no opposite. It is what is, regardless of what appears within it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-123',
    content: 'Whatever the present moment contains, accept it as if you had chosen it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-124',
    content: 'You are not your thoughts. You are the awareness behind them.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-125',
    content: 'The power of now can only be realized in this moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-126',
    content: 'Suffering is necessary until you realize it is unnecessary.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-127',
    content: 'Time is an illusion. All you have is now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-128',
    content: 'Realize deeply that the present moment is all you ever have.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-129',
    content: 'Awareness is the greatest agent for change.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-130',
    content: 'Where there is anger, there is always pain underneath.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-131',
    content: 'Life will give you whatever experience is most helpful for the evolution of your consciousness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-132',
    content: 'Nothing ever happened in the past; it happened in the now. Nothing will ever happen in the future; it will happen in the now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-133',
    content: 'The secret of life is to die before you die and find that there is no death.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-134',
    content: 'Stillness speaks.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-135',
    content: 'Watch the thought, feel the emotion, observe the reaction. Don\'t make it into an identity.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-136',
    content: 'Presence is pure consciousness without form.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-137',
    content: 'Life is an adventure, not a package tour.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-138',
    content: 'Look at a tree, a flower, a plant. How still they are, how deeply rooted in being.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-139',
    content: 'Is there a difference between happiness and inner peace? Yes. Happiness depends on conditions being perceived as positive; inner peace does not.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-140',
    content: 'Whatever you fight, you strengthen.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-141',
    content: 'Being is the eternal, ever-present One Life beyond the myriad forms of life that are subject to birth and death.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-142',
    content: 'True self is without form, without any experience, yet it experiences everything.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-143',
    content: 'Don\'t start with seeking truth. Start with discovering what is false.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-144',
    content: 'The mind is like a guard at the gate, but who is watching the guard?',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-145',
    content: 'The one who knows that you are thinking is not thinking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-146',
    content: 'You are the unchanging seer of the changing seen.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-147',
    content: 'Rest as the awareness that watches the mind.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-148',
    content: 'The greatest healing is to wake up from what we\'re not.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-149',
    content: 'You are life looking at life through human eyes.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-150',
    content: 'All the waves belong to the ocean. Can a wave be separate from the ocean?',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-151',
    content: 'Be like the sun: just be there and let everything else come to you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-152',
    content: 'The "I" that is looking for something is the main obstacle.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-153',
    content: 'You don\'t have to search for peace. You are peace.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-154',
    content: 'The world appears in you, not you in the world.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-155',
    content: 'Don\'t go by your mind. Go by your heart.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-156',
    content: 'There is a field beyond right doing and wrong doing. I\'ll meet you there.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Rumi',
  ),
  Pointing(
    id: 'con-157',
    content: 'The quieter you become, the more you can hear.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-158',
    content: 'We\'re all just walking each other home.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-159',
    content: 'Be here now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-160',
    content: 'The most exquisite paradox: as soon as you give it all up, you can have it all.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-161',
    content: 'We\'re fascinated by the words, but where we meet is in the silence behind them.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.evening],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-162',
    content: 'What you meet in another being is the projection of your own level of evolution.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Ram Dass',
  ),
  Pointing(
    id: 'con-163',
    content: 'The feeling of being hurried is not usually the result of living a full life. It is born of a vague fear.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-164',
    content: 'In subjective terms, you are not a body in the world. You are the ground in which the world appears.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-165',
    content: 'Look for the one who is looking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-166',
    content: 'Consciousness is the basis of everything you know or could ever know.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-167',
    content: 'There is no place for the meditator to stand separate from the experience of meditation.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-168',
    content: 'The self is an illusion, but it is also the condition you have lived in until now.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-169',
    content: 'Thoughts simply arise. What we are calling "I" cannot be tamed by the will.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-170',
    content: 'Everything experienced in this moment exists only in consciousness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-171',
    content: 'The truth is not some hidden treasure. It is the thing looking.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-172',
    content: 'The illusion of the self can be broken at any moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Sam Harris',
  ),
  Pointing(
    id: 'con-173',
    content: 'A thought is just a thought. Appearing in awareness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-174',
    content: 'Question your thoughts and discover peace.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-175',
    content: 'When you argue with reality, you lose—but only 100% of the time.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-176',
    content: 'Everything happens for me, not to me.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-177',
    content: 'The worst that can happen has already happened. You are already free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-178',
    content: 'Love is what we are born with. Fear is what we have learned here.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-179',
    content: 'Is it true? Can you absolutely know it\'s true?',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-180',
    content: 'I am a lover of what is, not because I\'m a spiritual person, but because it hurts when I argue with reality.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-181',
    content: 'Suffering is optional. Pain is inevitable.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-182',
    content: 'Nothing you believe is true.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-183',
    content: 'Until you can love what is, your happiness is a fantasy.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Byron Katie',
  ),
  Pointing(
    id: 'con-184',
    content: 'The moment you see through the illusion of separation, love floods in.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-185',
    content: 'If you resist nothing, you are free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-186',
    content: 'The personal self is a story. You are what the story appears in.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-187',
    content: 'Silence is the only teaching that has no dogma.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.evening, PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-188',
    content: 'Real meditation is not about mastering a technique. It\'s about letting go of control.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-189',
    content: 'True freedom is freedom from the need to be free.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-190',
    content: 'Only that which is infinite and eternal is real. Everything else is an appearance.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-191',
    content: 'Stop waiting for enlightenment. You are already that which you seek.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Adyashanti',
  ),
  Pointing(
    id: 'con-192',
    content: 'Acceptance doesn\'t mean resignation. It means understanding that this is what is.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-193',
    content: 'The primary cause of unhappiness is never the situation but your thoughts about it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-194',
    content: 'You find peace not by rearranging the circumstances of your life, but by realizing who you are at the deepest level.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-195',
    content: 'Give up defining yourself—to yourself or to others. You won\'t die. You will come to life.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-196',
    content: 'When you make the present moment the focal point of your attention, the compulsion to label it diminishes.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-197',
    content: 'The past has no power over the present moment.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-198',
    content: 'The moment you are identified with the mind, suffering begins.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-199',
    content: 'Your true nature is presence itself.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-200',
    content: 'Underneath the story of suffering is a field of stillness.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.evening],
    teacher: 'Eckhart Tolle',
  ),
  Pointing(
    id: 'con-201',
    content: 'The moment you realize you are not your thoughts, you have already taken the first step to freedom.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-202',
    content: 'Life is not happening to you. Life is responding to you.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-203',
    content: 'No one is obligated to suffer. Suffering is optional.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-204',
    content: 'Freedom is not something you gain. It is what remains when you lose the illusion.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-205',
    content: 'All the while you search outside, you miss the jewel inside your own treasure house.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-206',
    content: 'Watch your thoughts without believing them.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-207',
    content: 'Your real self has no past and no future. It is eternal presence.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-208',
    content: 'In your natural state, you are not a seeker. You are the sought.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-209',
    content: 'Everything flows perfectly when you stop trying to control it.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.stress, PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-210',
    content: 'You are not the wave. You are the ocean pretending to be the wave.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'con-211',
    content: 'The end of seeking is the beginning of living.',

    tradition: Tradition.contemporary,
    contexts: [PointingContext.general, PointingContext.morning],
    teacher: 'Mooji',
  ),
  Pointing(
    id: 'org-9',
    content: 'The thought "I need to wake up" appears in what\'s already awake.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'org-10',
    content: 'Before you open the app, notice who\'s looking.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'org-11',
    content: 'Meditation isn\'t about becoming aware. It\'s about noticing you already are.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-12',
    content: 'The traffic, the deadline, the notification—all arising in the same space.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-13',
    content: 'You don\'t need better thoughts. Notice who\'s listening to them.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-14',
    content: 'The phone is buzzing. The body is reacting. What\'s witnessing both?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-15',
    content: 'Right before you refresh the feed, who\'s here?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-16',
    content: 'The meeting is tense. Notice: is the awareness tense?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-17',
    content: 'You didn\'t start being conscious this morning. Consciousness started experiencing "morning."',

    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-18',
    content: 'That email can wait. This moment can\'t. It\'s already here.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-19',
    content: 'The day is ending. What never started?',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-20',
    content: 'Look at your hands typing. Who\'s looking?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-21',
    content: 'Coffee\'s ready. You\'re already awake.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-22',
    content: 'The problem feels heavy. What\'s holding it feels nothing.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-23',
    content: 'In between two thoughts: this.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-24',
    content: 'The sun set an hour ago. Something else is still shining.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-25',
    content: 'When you say "I\'m stressed," who knows that?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-26',
    content: 'The question arises: Who am I? The answer is what\'s asking.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-27',
    content: 'Notifications: many. Awareness: one.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-28',
    content: 'You can lose your job. Can you lose what\'s aware of having a job?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-29',
    content: 'The to-do list is long. Notice how present the noticing is.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-30',
    content: 'When you finally relax tonight, you\'ll find it was here all along.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-31',
    content: 'Midday. Halfway through the story. Never left the screen it\'s playing on.',

    tradition: Tradition.original,
    contexts: [PointingContext.midday],
  ),
  Pointing(
    id: 'org-32',
    content: 'Check this before you check your email: Are you here?',

    tradition: Tradition.original,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'org-33',
    content: 'The body needs rest. What\'s noticing the tiredness?',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-34',
    content: 'Your inner critic is loud. The one listening is silent.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-35',
    content: 'Before productivity, notice: producing what? For whom?',

    tradition: Tradition.original,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'org-36',
    content: 'Lunch break. Where does awareness take its breaks?',

    tradition: Tradition.original,
    contexts: [PointingContext.midday],
  ),
  Pointing(
    id: 'org-37',
    content: 'The anxiety is real. The space it\'s happening in—even more real.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-38',
    content: 'Thoughts about tomorrow. Arising when?',

    tradition: Tradition.original,
    contexts: [PointingContext.evening, PointingContext.general],
  ),
  Pointing(
    id: 'org-39',
    content: 'Doomscrolling. Notice who\'s noticing the doom.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-40',
    content: 'You woke up worried. What woke up first—you or the worry?',

    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-41',
    content: 'Another meeting. Same presence.',

    tradition: Tradition.original,
    contexts: [PointingContext.midday, PointingContext.stress],
  ),
  Pointing(
    id: 'org-42',
    content: 'The narrative is compelling. What\'s reading it?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-43',
    content: 'Good day, bad day—both reported to the same witness.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening, PointingContext.general],
  ),
  Pointing(
    id: 'org-44',
    content: 'Your playlist is on shuffle. Awareness isn\'t.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-45',
    content: 'Breathing in. Breathing out. Who\'s counting?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-46',
    content: 'The argument replays in your head. Where\'s the replay happening?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.evening],
  ),
  Pointing(
    id: 'org-47',
    content: 'Midnight thoughts. Dawn awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-48',
    content: 'Status: busy. Being: still.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.midday],
  ),
  Pointing(
    id: 'org-49',
    content: 'The world feels chaotic. Check: is awareness chaotic?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-50',
    content: 'Before the coffee kicks in: this. After the coffee kicks in: also this.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-51',
    content: 'Your bank account fluctuates. What\'s looking doesn\'t.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-52',
    content: 'Sunset brings closure. Awareness never opened.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-53',
    content: 'Tabs open: 47. Awareness required: 1.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-54',
    content: 'Imposter syndrome speaking. Real you listening.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-55',
    content: 'The day hasn\'t started yet. Neither has this.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-56',
    content: 'Screen time: excessive. Awareness time: eternal.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-57',
    content: 'The relationship is complicated. The witness is simple.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-58',
    content: 'Clock says 3 PM. Presence says now.',

    tradition: Tradition.original,
    contexts: [PointingContext.midday],
  ),
  Pointing(
    id: 'org-59',
    content: 'Fighting for inner peace. Already surrounded by it.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-60',
    content: 'Tomorrow\'s presentation is stressing today\'s awareness. Check the math.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-61',
    content: 'Alarm goes off. Before you hit snooze, notice: who heard it?',

    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-62',
    content: 'The workout is hard. The awareness watching is effortless.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-63',
    content: 'You remember yesterday. That\'s happening now.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-64',
    content: 'The calendar is full. The space around it is infinite.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.midday],
  ),
  Pointing(
    id: 'org-65',
    content: 'Before you plan tomorrow, witness today witnessing.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-66',
    content: 'Motivation is low. Awareness has no opinion.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-67',
    content: 'The commute is long. Presence carpools with you.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning, PointingContext.evening],
  ),
  Pointing(
    id: 'org-68',
    content: 'Life goals: many. This moment: enough.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-69',
    content: 'Inbox: chaos. Inner space: clear.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.midday],
  ),
  Pointing(
    id: 'org-70',
    content: 'Yesterday\'s mistake plays on repeat. Who\'s pressing play?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.evening],
  ),
  Pointing(
    id: 'org-71',
    content: 'The kids are loud. The space they\'re loud in is quiet.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-72',
    content: 'Battery: 5%. Awareness: fully charged.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-73',
    content: 'Zoom fatigue is real. The one on Zoom never tires.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.midday],
  ),
  Pointing(
    id: 'org-74',
    content: 'Groceries, laundry, taxes. Awareness doesn\'t have a to-do list.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-75',
    content: 'The weather app says rain. Notice who knows the forecast.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-76',
    content: 'Loading... But awareness never buffers.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-77',
    content: 'New year, same awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-78',
    content: 'Algorithm knows you. Awareness is you.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-79',
    content: 'The dream was vivid. The dreamer is here now.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning],
  ),
  Pointing(
    id: 'org-80',
    content: 'Wi-Fi disconnected. Awareness never logged off.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-81',
    content: 'Brain fog. Clear sky of awareness.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'org-82',
    content: 'Happy hour. Awareness doesn\'t drink.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-83',
    content: 'They say be present. You already are. Just notice.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-84',
    content: 'Flight delayed. Presence right on time.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-85',
    content: 'Identity crisis. Who\'s having it?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-86',
    content: 'Playlist ended. Silence reveals what was always playing.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening, PointingContext.general],
  ),
  Pointing(
    id: 'org-87',
    content: 'The like count matters. To whom?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-88',
    content: 'You updated your status. Awareness has none.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-89',
    content: 'Annual review coming. Who\'s been here all year?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress],
  ),
  Pointing(
    id: 'org-90',
    content: 'Dark mode on. Light of awareness: always on.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-91',
    content: 'They ghosted you. Presence stayed.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-92',
    content: 'Therapy is Thursday. Awareness is now.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-93',
    content: 'Sunday scaries. Monday is a thought. This is what is.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening, PointingContext.stress],
  ),
  Pointing(
    id: 'org-94',
    content: 'Five-year plan. One eternal now.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-95',
    content: 'Swipe left, swipe right. Awareness doesn\'t judge.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-96',
    content: 'The news is heavy. What\'s carrying it?',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-97',
    content: 'Track your habits. Notice the tracker.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-98',
    content: 'Mercury retrograde. Awareness in direct motion.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-99',
    content: 'Notifications muted. Presence unmuted.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening, PointingContext.general],
  ),
  Pointing(
    id: 'org-100',
    content: 'FOMO is real. Missing what? You\'re already here.',

    tradition: Tradition.original,
    contexts: [PointingContext.stress, PointingContext.general],
  ),
  Pointing(
    id: 'org-101',
    content: 'Main character energy. Who\'s watching the movie?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-102',
    content: 'Before bed routine: 10 steps. Awareness: 0 steps.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-103',
    content: 'Self-care Sunday. Notice the self that needs no care.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-104',
    content: 'Green juice, cold plunge, breathwork. Awareness was already optimized.',

    tradition: Tradition.original,
    contexts: [PointingContext.morning, PointingContext.general],
  ),
  Pointing(
    id: 'org-105',
    content: 'Manifestation board is full. What\'s already manifesting all of this?',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-106',
    content: 'AirPods in. Awareness has no earbuds.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
  ),
  Pointing(
    id: 'org-107',
    content: 'Time to unplug. From what? This was never plugged in.',

    tradition: Tradition.original,
    contexts: [PointingContext.evening],
  ),
  Pointing(
    id: 'org-108',
    content: 'Out of office. Awareness never clocked in.',

    tradition: Tradition.original,
    contexts: [PointingContext.general],
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

/// Get a pointing by its ID, or null if not found
Pointing? getPointingById(String id) {
  try {
    return pointings.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}
