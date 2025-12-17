// Adyashanti Teachings
// Contemporary Zen-influenced teacher
// Source: https://adyashanti.opengatesangha.org/teachings/library

import '../teaching.dart';
import '../pointings.dart';

const String _teacher = 'Adyashanti';
const Tradition _lineage = Tradition.contemporary;
const String _sourceBase =
    'https://adyashanti.opengatesangha.org/teachings/library/writing';

/// Adyashanti's teachings indexed from Open Gate Sangha
final List<Teaching> adyashantiTeachings = [
  // === SELF-INQUIRY / AWARENESS ===
  Teaching(
    id: 'adya-art-of-inquiry',
    content:
        'True self-inquiry is not asking yourself questions and looking for answers within the mind. It is resting in not knowing and allowing the truth to reveal itself.',
    teacher: _teacher,
    source: 'The Art of Self-Inquiry',
    lineage: _lineage,
    topicTags: {TopicTags.selfInquiry, TopicTags.surrender},
    moodTags: {MoodTags.morning, MoodTags.contemplative},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/10',
  ),

  Teaching(
    id: 'adya-doorway-i-am',
    content:
        'The doorway of "I Am" is the entry point to the infinite. When you rest in the sense of "I Am" without adding anything to it, you discover your true nature.',
    teacher: _teacher,
    source: 'The Doorway of "I Am"',
    lineage: _lineage,
    topicTags: {TopicTags.selfInquiry, TopicTags.awareness, TopicTags.nature},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/10',
  ),

  Teaching(
    id: 'adya-inner-revolution',
    content:
        'An inner revolution is not a political act. It is the most intimate act of all—the willingness to question every belief you have ever held about yourself and reality.',
    teacher: _teacher,
    source: 'An Inner Revolution',
    lineage: _lineage,
    topicTags: {TopicTags.awareness, TopicTags.selfInquiry, TopicTags.truth},
    moodTags: {MoodTags.challenging},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/10',
  ),

  Teaching(
    id: 'adya-paradox-true-nature',
    content:
        'Embracing the paradox of true nature means accepting that you are both nothing and everything, empty and full, separate and inseparable.',
    teacher: _teacher,
    source: 'Embracing the Paradox of True Nature',
    lineage: _lineage,
    topicTags: {TopicTags.awareness, TopicTags.truth, TopicTags.nature},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/10',
  ),

  Teaching(
    id: 'adya-awe-wonder',
    content:
        'The awe and wonder of existence is always available. It is not something to be achieved but something to be noticed. Right now, existence is happening.',
    teacher: _teacher,
    source: 'The Awe and Wonder of Existence',
    lineage: _lineage,
    topicTags: {TopicTags.awareness, TopicTags.life, TopicTags.presence},
    moodTags: {MoodTags.uplifting, MoodTags.morning},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/10',
  ),

  // === RELATIONSHIP ===
  Teaching(
    id: 'adya-relationship',
    content:
        'In relationship, we have the opportunity to see ourselves clearly. The other person becomes a mirror, reflecting back to us what we have not yet seen in ourselves.',
    teacher: _teacher,
    source: 'Relationship',
    lineage: _lineage,
    topicTags: {TopicTags.relationship, TopicTags.awareness},
    moodTags: {MoodTags.general},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/2',
  ),

  // === SPIRITUAL LIFE ===
  Teaching(
    id: 'adya-spiritual-life',
    content:
        'What is a spiritual life? It is not about becoming someone special. It is about becoming more and more ordinary, more and more simple, more and more present.',
    teacher: _teacher,
    source: 'What Is a Spiritual Life?',
    lineage: _lineage,
    topicTags: {TopicTags.life, TopicTags.practice, TopicTags.presence},
    moodTags: {MoodTags.morning, MoodTags.general},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/16',
  ),

  Teaching(
    id: 'adya-world-needs',
    content:
        'What the world really needs is not more information, more beliefs, or more opinions. What it needs is more presence, more stillness, more compassion.',
    teacher: _teacher,
    source: 'What the World Really Needs',
    lineage: _lineage,
    topicTags: {TopicTags.life, TopicTags.presence, TopicTags.silence},
    moodTags: {MoodTags.general, MoodTags.contemplative},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/16',
  ),

  // === MEDITATION ===
  Teaching(
    id: 'adya-meditation-discoveries',
    content:
        'Meditation is not about controlling the mind. It is about discovering what is already free. The thoughts come and go, but awareness remains untouched.',
    teacher: _teacher,
    source: 'Meditation Discoveries',
    lineage: _lineage,
    topicTags: {TopicTags.meditation, TopicTags.practice, TopicTags.freedom},
    moodTags: {MoodTags.morning, MoodTags.general},
    type: TeachingType.article,
    sourceUrl: '$_sourceBase/subject/17',
  ),

  // === AWAKENING ===
  Teaching(
    id: 'adya-end-of-seeking',
    content:
        'The end of seeking is not finding what you were looking for. It is the falling away of the one who was looking.',
    teacher: _teacher,
    source: 'The End of Your World',
    lineage: _lineage,
    topicTags: {TopicTags.enlightenment, TopicTags.ego, TopicTags.surrender},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'adya-falling-away',
    content:
        'Awakening is a shift in identity from thought to awareness. It is not adding something to who you are. It is the falling away of who you thought you were.',
    teacher: _teacher,
    source: 'Falling into Grace',
    lineage: _lineage,
    topicTags: {TopicTags.enlightenment, TopicTags.awareness, TopicTags.ego},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'adya-ordinary-awakening',
    content:
        'Awakening is the most ordinary thing there is. It is simply seeing what has always been here, what we have overlooked because we were looking for something extraordinary.',
    teacher: _teacher,
    source: 'Emptiness Dancing',
    lineage: _lineage,
    topicTags: {TopicTags.enlightenment, TopicTags.awareness, TopicTags.truth},
    moodTags: {MoodTags.general},
    type: TeachingType.extract,
  ),

  // === THE MIND ===
  Teaching(
    id: 'adya-thinking-not-problem',
    content:
        'Thinking is not the problem. Identification with thinking is the problem. Thoughts are like clouds passing through the sky of awareness.',
    teacher: _teacher,
    source: 'Emptiness Dancing',
    lineage: _lineage,
    topicTags: {TopicTags.mind, TopicTags.awareness, TopicTags.ego},
    moodTags: {MoodTags.stress, MoodTags.general},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'adya-suffering-resistance',
    content:
        'All suffering is caused by resisting what is. Peace is found not by changing what is happening, but by changing your relationship to what is happening.',
    teacher: _teacher,
    source: 'True Meditation',
    lineage: _lineage,
    topicTags: {TopicTags.surrender, TopicTags.presence, TopicTags.freedom},
    moodTags: {MoodTags.stress},
    type: TeachingType.extract,
  ),

  // === TRUE NATURE ===
  Teaching(
    id: 'adya-silence-speaks',
    content:
        'There is a silence inside of you that you can trust. It is the silence from which you came and to which you will return.',
    teacher: _teacher,
    source: 'The Way of Liberation',
    lineage: _lineage,
    topicTags: {TopicTags.silence, TopicTags.nature, TopicTags.truth},
    moodTags: {MoodTags.contemplative, MoodTags.evening},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'adya-what-you-are',
    content:
        'What you are is not the product of your life. What you are is beyond birth and death. You are the awareness in which everything appears.',
    teacher: _teacher,
    source: 'Emptiness Dancing',
    lineage: _lineage,
    topicTags: {TopicTags.awareness, TopicTags.nature, TopicTags.truth},
    moodTags: {MoodTags.contemplative, MoodTags.uplifting},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'adya-ground-of-being',
    content:
        'Rest in the ground of being. Not in your thoughts about being, not in your feelings about being, but in being itself.',
    teacher: _teacher,
    source: 'True Meditation',
    lineage: _lineage,
    topicTags: {TopicTags.meditation, TopicTags.awareness, TopicTags.presence},
    moodTags: {MoodTags.morning, MoodTags.evening},
    type: TeachingType.extract,
  ),

  // === LETTING GO ===
  Teaching(
    id: 'adya-let-everything-go',
    content:
        'Let everything go. Let all of it fall away. What remains is what you truly are.',
    teacher: _teacher,
    source: 'Falling into Grace',
    lineage: _lineage,
    topicTags: {TopicTags.surrender, TopicTags.freedom, TopicTags.nature},
    moodTags: {MoodTags.contemplative, MoodTags.stress},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'adya-grace',
    content:
        'Grace is always present. It is the recognition that you do not have to hold yourself together. You can fall and be caught.',
    teacher: _teacher,
    source: 'Falling into Grace',
    lineage: _lineage,
    topicTags: {TopicTags.surrender, TopicTags.devotion, TopicTags.freedom},
    moodTags: {MoodTags.uplifting, MoodTags.stress},
    type: TeachingType.extract,
  ),

  // === TRUTH ===
  Teaching(
    id: 'adya-truth-simple',
    content:
        'The truth is much simpler than you think. It is so simple that the mind cannot grasp it. It can only be lived.',
    teacher: _teacher,
    source: 'The Way of Liberation',
    lineage: _lineage,
    topicTags: {TopicTags.truth, TopicTags.mind, TopicTags.life},
    moodTags: {MoodTags.general},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'adya-no-location',
    content:
        'You cannot locate yourself. When you try to find where you are, you discover that you are everywhere and nowhere. That is your true nature.',
    teacher: _teacher,
    source: 'The Impact of Awakening',
    lineage: _lineage,
    topicTags: {TopicTags.selfInquiry, TopicTags.awareness, TopicTags.nature},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.extract,
  ),
];
