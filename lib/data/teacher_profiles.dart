// Teacher Profile Seed Data
// Detailed profiles of non-dual teachers featured in the Library
//
// Includes biographical information, key teachings, and cross-references
// to related articles and pointings.

import '../models/teacher_profile.dart';
import 'pointings.dart';

/// Teacher profiles for the Library
const teacherProfiles = <TeacherProfile>[
  // === ADVAITA VEDANTA TEACHERS ===

  TeacherProfile(
    name: 'Nisargadatta Maharaj',
    bio:
        'Nisargadatta Maharaj was a spiritual teacher of nondualism, belonging to the Inchagiri Sampradaya lineage of Navnath. His famous book "I Am That" is a compilation of his talks and is considered a spiritual classic. A simple shopkeeper in Mumbai, he taught from his small loft above his shop, attracting seekers from around the world with his direct, uncompromising approach to truth.',
    dates: '1897-1981',
    primaryTradition: Tradition.advaita,
    quote:
        'Wisdom tells me I am nothing. Love tells me I am everything. Between these two my life flows.',
    location: 'Mumbai, India',
    keyTeachings: [
      'The sense "I Am" as the gateway to truth',
      'You are not what you think yourself to be',
      'Prior to consciousness',
      'The witness and the witnessed are one',
      'Abidance in the "I Am"',
    ],
    articleIds: [
      'art_iam_that_001',
    ],
    pointingIds: [
      'adv-5',
    ],
  ),

  TeacherProfile(
    name: 'Ramana Maharshi',
    bio:
        'Bhagavan Sri Ramana Maharshi was an Indian Hindu sage and jivanmukti. At age 16, he had a profound experience of death and awakening. He left home for Arunachala, where he remained for the rest of his life. His primary teaching was Self-inquiry (Atma Vichara) - the practice of asking "Who am I?" He spoke rarely but his presence was said to convey the teaching directly.',
    dates: '1879-1950',
    primaryTradition: Tradition.advaita,
    quote:
        'Your own Self-Realization is the greatest service you can render the world.',
    location: 'Tiruvannamalai, India',
    keyTeachings: [
      'Self-inquiry (Atma Vichara)',
      'Who am I?',
      'The Self is always realized',
      'Silence is the loudest teaching',
      'Be as you are',
    ],
    articleIds: [
      'art_who_am_i_001',
      'art_be_as_you_are_001',
      'art_self_inquiry_guide_001',
    ],
    pointingIds: [
      'adv-3',
      'adv-6',
    ],
  ),

  TeacherProfile(
    name: 'Papaji (H.W.L. Poonja)',
    bio:
        'Hariwansh Lal Poonja, affectionately known as Papaji, was a direct disciple of Ramana Maharshi. Born in Punjab, he had spiritual experiences from childhood. After meeting Ramana in 1944, his seeking ended. He spent years in obscurity before emerging as a teacher in the 1990s, attracting thousands of Western seekers to Lucknow. Known for his fierce, uncompromising style and his emphasis on instant awakening.',
    dates: '1910-1997',
    primaryTradition: Tradition.advaita,
    quote: 'This instant is freedom.',
    location: 'Lucknow, India',
    keyTeachings: [
      'Instant awakening is possible',
      'Don\'t postpone freedom',
      'The seeker is the problem',
      'Keep quiet',
      'Who is asking?',
    ],
    articleIds: [
      'art_papaji_001',
    ],
    pointingIds: [],
  ),

  TeacherProfile(
    name: 'Mooji',
    bio:
        'Anthony Paul Moo-Young, known as Mooji, is a spiritual teacher originally from Jamaica, now based in Portugal. A former street artist and teacher, he met his master Papaji in Lucknow in 1993. His teaching emphasizes self-inquiry and the recognition of our true nature as pure awareness. Known for his warm, accessible style and his invitation to "just be."',
    dates: 'born 1954',
    primaryTradition: Tradition.contemporary,
    quote: 'Don\'t be a storehouse of memories. Leave past, future and even present thoughts behind.',
    location: 'Monte Sahaja, Portugal',
    keyTeachings: [
      'Just be',
      'You are the unchanging witness',
      'To whom does this arise?',
      'The invitation to freedom',
      'The Isness of being',
    ],
    articleIds: [
      'art_mooji_001',
    ],
    pointingIds: [],
  ),

  // === DIRECT PATH TEACHERS ===

  TeacherProfile(
    name: 'Rupert Spira',
    bio:
        'Rupert Spira is a British spiritual teacher and studio potter. He first encountered the teaching of non-duality through the writings of Wei Wu Wei. He later studied with Francis Lucille, who introduced him to the Direct Path. His teaching is characterized by precision, clarity, and the exploration of experience through what he calls "the Yoga of Self-Inquiry." He is known for his accessible articulation of complex spiritual truths.',
    dates: 'born 1960',
    primaryTradition: Tradition.direct,
    quote: 'We don\'t become present. We notice that we already are.',
    location: 'Oxford, UK',
    keyTeachings: [
      'Awareness is our fundamental nature',
      'The separate self is an illusion',
      'Happiness is our nature, not an achievement',
      'The Direct Path',
      'The yoga of self-inquiry',
    ],
    articleIds: [
      'art_presence_001',
      'art_direct_path_001',
    ],
    pointingIds: [
      'dir-2',
    ],
  ),

  TeacherProfile(
    name: 'Francis Lucille',
    bio:
        'Francis Lucille is a French spiritual teacher in the Advaita Vedanta tradition. He met his teacher Jean Klein in 1975, and this meeting was to be the turning point in his life. For many years he worked as a scientist while living with his teacher. After Jean Klein\'s death, he began teaching more openly. His approach is gentle, precise, and deeply grounded in direct experience.',
    dates: 'born 1944',
    primaryTradition: Tradition.direct,
    quote: 'The separate self is not eliminated. It is seen through.',
    location: 'Temecula, California',
    keyTeachings: [
      'The Direct Path',
      'Awareness is not personal',
      'The body appears in consciousness',
      'Looking for the looker',
      'Beauty as a doorway',
    ],
    articleIds: [
      'art_francis_lucille_001',
      'art_direct_path_001',
    ],
    pointingIds: [
      'dir-3',
    ],
  ),

  TeacherProfile(
    name: 'Jean Klein',
    bio:
        'Jean Klein was a French author and spiritual teacher who traveled to India in the 1950s and there met his teacher, a Pandit and Sanskrit scholar. After returning to Europe, he began teaching the Direct Path - a contemporary expression of Advaita Vedanta. His teaching emphasized the body as a doorway to awakening and the importance of "listening attention." He influenced many contemporary teachers including Francis Lucille and Rupert Spira.',
    dates: '1916-1998',
    primaryTradition: Tradition.direct,
    quote: 'You are the light in which all appears.',
    location: 'Santa Barbara, California',
    keyTeachings: [
      'The listening attention',
      'The body as doorway',
      'There is no path to truth',
      'Beauty and art as spiritual practice',
      'Welcoming all experience',
    ],
    articleIds: [
      'art_jean_klein_001',
      'art_direct_path_001',
    ],
    pointingIds: [],
  ),

  // === CONTEMPORARY TEACHERS ===

  TeacherProfile(
    name: 'Eckhart Tolle',
    bio:
        'Eckhart Tolle is a German-born spiritual teacher and author. At age 29, a profound inner transformation changed the course of his life. The years that followed were devoted to understanding and deepening this transformation. "The Power of Now" and "A New Earth" have become international bestsellers. His teaching focuses on the present moment as the doorway to awakening and the dissolution of the egoic mind.',
    dates: 'born 1948',
    primaryTradition: Tradition.contemporary,
    quote: 'The present moment is all you ever have.',
    location: 'Vancouver, Canada',
    keyTeachings: [
      'The power of Now',
      'The pain body',
      'Presence as transformation',
      'The ego and true identity',
      'Stillness speaks',
    ],
    articleIds: [
      'art_power_of_now_001',
    ],
    pointingIds: [
      'con-2',
    ],
  ),

  // === TRADITIONAL TEXTS (as teacher) ===

  TeacherProfile(
    name: 'Ashtavakra Gita',
    bio:
        'The Ashtavakra Gita is an ancient Sanskrit scripture that presents a dialogue between the sage Ashtavakra and King Janaka on the nature of the Self. It is considered one of the most radical and uncompromising expressions of Advaita Vedanta. Unlike many spiritual texts, it offers no gradual path - only the immediate recognition of already-present freedom. Its date of composition is uncertain, with estimates ranging from 500 BCE to 400 CE.',
    dates: 'c. 500 BCE - 400 CE',
    primaryTradition: Tradition.advaita,
    quote: 'You are already free. Your only bondage is believing you are not.',
    keyTeachings: [
      'The Self is already free',
      'Bondage is a concept',
      'Non-doership',
      'The world as appearance',
      'Immediate liberation',
    ],
    articleIds: [
      'art_ashtavakra_001',
    ],
    pointingIds: [
      'adv-2',
      'adv-4',
    ],
  ),

  // === ZEN TEACHERS ===

  TeacherProfile(
    name: 'Pema Chodron',
    bio:
        'Pema Chodron is an American Tibetan Buddhist nun, author, and teacher. Ordained in 1981, she is a student of Chogyam Trungpa and Dzigar Kongtrul Rinpoche. While not strictly a non-dual teacher, her work on befriending difficult emotions and finding freedom in groundlessness resonates deeply with the direct approach. Her books, including "When Things Fall Apart," have reached millions of readers.',
    dates: 'born 1936',
    primaryTradition: Tradition.zen,
    quote: 'You are the sky. Everything else is just the weather.',
    location: 'Cape Breton, Canada',
    keyTeachings: [
      'Befriending difficult emotions',
      'Groundlessness as freedom',
      'Compassion as path',
      'Start where you are',
      'Letting go of certainty',
    ],
    articleIds: [],
    pointingIds: [
      'con-3',
    ],
  ),
];

/// Get teacher profile by name
TeacherProfile? getTeacherProfile(String name) {
  try {
    return teacherProfiles.firstWhere(
      (t) => t.name.toLowerCase() == name.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
}

/// Get teachers by tradition
List<TeacherProfile> getTeachersByTradition(Tradition tradition) {
  return teacherProfiles
      .where((t) => t.primaryTradition == tradition)
      .toList();
}

/// Get all teacher names
List<String> getAllTeacherNames() {
  return teacherProfiles.map((t) => t.name).toList();
}

/// Get teachers who have articles
List<TeacherProfile> getTeachersWithArticles() {
  return teacherProfiles.where((t) => t.articleIds.isNotEmpty).toList();
}
