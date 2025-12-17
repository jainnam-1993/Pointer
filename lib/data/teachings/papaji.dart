// Papaji Teachings
// H.W.L. Poonja (Papaji) - Direct disciple of Ramana Maharshi
// Source: https://avadhuta.com/category/read/

import '../teaching.dart';
import '../pointings.dart';

const String _teacher = 'Papaji';
const Tradition _lineage = Tradition.advaita;
const String _sourceBase = 'https://avadhuta.com';

/// Papaji's teachings indexed from avadhuta.com
final List<Teaching> papajiTeachings = [
  // === CORE TEACHINGS ===
  Teaching(
    id: 'papaji-no-chooser',
    content:
        'There is no chooser and there is no choice. Everything is spontaneously arising.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.mind},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/no-chooser-no-choice/',
  ),

  Teaching(
    id: 'papaji-ultimate-truth',
    content:
        'The ultimate truth is so simple. It is nothing more than being in one\'s own natural state.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.truth, TopicTags.awareness, TopicTags.nature},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/the-ultimate-truth/',
  ),

  Teaching(
    id: 'papaji-what-is-enlightenment',
    content:
        'Enlightenment is not something you achieve. It is the absence of something. All your life you have been going toward something. Enlightenment is giving up all that.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.enlightenment, TopicTags.surrender},
    moodTags: {MoodTags.general, MoodTags.contemplative},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/what-is-enlightenment/',
  ),

  Teaching(
    id: 'papaji-you-are-that',
    content:
        'You are That. You are God. Not the God that you have heard of, but the God that you are.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.awareness, TopicTags.selfInquiry, TopicTags.truth},
    moodTags: {MoodTags.uplifting},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/you-are-that/',
  ),

  // === MIND & CONSCIOUSNESS ===
  Teaching(
    id: 'papaji-mind-darkness',
    content:
        'The mind keeps you in darkness. It creates the illusion of separation. When mind is still, there is light.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.mind, TopicTags.awareness},
    moodTags: {MoodTags.challenging},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/mind-keeps-you-in-darkness/',
  ),

  Teaching(
    id: 'papaji-what-is-self',
    content:
        'What is the Self? It is not the body, not the mind, not the intellect. It is that which is aware of all these.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.selfInquiry, TopicTags.awareness, TopicTags.nature},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/what-is-the-self/',
  ),

  // === PRACTICE & INQUIRY ===
  Teaching(
    id: 'papaji-keep-quiet',
    content:
        'Keep Quiet! Keep Quiet! Keep Quiet! This is the highest teaching. In this Quietness, you will find what you have been looking for.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.silence, TopicTags.practice},
    moodTags: {MoodTags.stress, MoodTags.contemplative},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/keep-quiet/',
  ),

  Teaching(
    id: 'papaji-no-practice',
    content:
        'No practice is needed. What is needed is the understanding that you are already That which you are seeking.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.practice, TopicTags.freedom, TopicTags.truth},
    moodTags: {MoodTags.challenging},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/no-practice-is-needed/',
  ),

  Teaching(
    id: 'papaji-one-moment',
    content:
        'Simply sit quiet for one moment. In this one moment, all your questions will be answered.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.silence, TopicTags.practice, TopicTags.presence},
    moodTags: {MoodTags.stress, MoodTags.morning},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/simply-sit-quiet/',
  ),

  Teaching(
    id: 'papaji-how-to-inquire',
    content:
        'Ask yourself "Who am I?" and remain as the answer. The answer is not a thought. It is the Silence from which thoughts arise.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.selfInquiry, TopicTags.silence, TopicTags.practice},
    moodTags: {MoodTags.morning, MoodTags.contemplative},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/how-to-practice-enquiry/',
  ),

  // === LIBERATION & FREEDOM ===
  Teaching(
    id: 'papaji-not-bound',
    content:
        'You are not bound. You have never been bound. It is only the mind that tells you that you are bound.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.mind},
    moodTags: {MoodTags.uplifting},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/you-are-not-bound/',
  ),

  Teaching(
    id: 'papaji-freedom-here',
    content:
        'Freedom is always here. It does not come and go. What comes and goes is the thought that you are not free.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.awareness, TopicTags.presence},
    moodTags: {MoodTags.uplifting},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/freedom-is-always-here/',
  ),

  Teaching(
    id: 'papaji-decide-now',
    content:
        'Decide right now to be free. Not tomorrow, not later, but right now. This decision itself is freedom.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.presence},
    moodTags: {MoodTags.challenging, MoodTags.morning},
    type: TeachingType.extract,
    sourceUrl: '$_sourceBase/decide-right-now/',
  ),

  // === TALKS ===
  Teaching(
    id: 'papaji-reveal-itself',
    content:
        'Don\'t try to understand. Don\'t make any effort. Just remain still. It will reveal itself.',
    teacher: _teacher,
    source: 'Talk',
    lineage: _lineage,
    topicTags: {TopicTags.awareness, TopicTags.surrender, TopicTags.silence},
    moodTags: {MoodTags.contemplative, MoodTags.stress},
    type: TeachingType.talk,
    sourceUrl: '$_sourceBase/it-will-reveal-itself/',
  ),

  Teaching(
    id: 'papaji-one-second',
    content:
        'Devote one second to your nature. Just one second of seeing who you really are, and everything changes.',
    teacher: _teacher,
    source: 'Talk',
    lineage: _lineage,
    topicTags: {TopicTags.practice, TopicTags.awareness, TopicTags.nature},
    moodTags: {MoodTags.morning, MoodTags.general},
    type: TeachingType.talk,
    sourceUrl: '$_sourceBase/devote-one-second/',
  ),

  Teaching(
    id: 'papaji-vigilance',
    content:
        'Only vigilance is needed. Stay alert. Watch the mind. Don\'t let it pull you into its stories.',
    teacher: _teacher,
    source: 'Talk',
    lineage: _lineage,
    topicTags: {TopicTags.practice, TopicTags.awareness, TopicTags.mind},
    moodTags: {MoodTags.general},
    type: TeachingType.talk,
    sourceUrl: '$_sourceBase/only-vigilance-is-needed/',
  ),

  Teaching(
    id: 'papaji-this-moment',
    content:
        'This moment is your home. You don\'t need to go anywhere. You don\'t need to become anything. This moment is complete.',
    teacher: _teacher,
    source: 'Talk',
    lineage: _lineage,
    topicTags: {TopicTags.presence, TopicTags.awareness},
    moodTags: {MoodTags.stress, MoodTags.general},
    type: TeachingType.talk,
    sourceUrl: '$_sourceBase/this-moment-is-your-home/',
  ),

  Teaching(
    id: 'papaji-burning-desire',
    content:
        'The burning desire for freedom is itself the fire that burns all bondage.',
    teacher: _teacher,
    source: 'Talk',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.devotion},
    moodTags: {MoodTags.challenging, MoodTags.uplifting},
    type: TeachingType.talk,
    sourceUrl: '$_sourceBase/the-burning-desire-for-freedom/',
  ),

  // === ADDITIONAL CORE TEACHINGS ===
  Teaching(
    id: 'papaji-no-effort',
    content:
        'Effortlessness is the key. Any effort you make takes you away from yourself.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.practice, TopicTags.surrender},
    moodTags: {MoodTags.contemplative, MoodTags.stress},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'papaji-dont-postpone',
    content:
        'Don\'t postpone. Don\'t say "tomorrow." This instant is freedom. There is no other time.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.presence},
    moodTags: {MoodTags.challenging, MoodTags.morning},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'papaji-who-wants',
    content:
        'Find out who wants enlightenment. When you look, you cannot find this one. That is enlightenment.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.selfInquiry, TopicTags.enlightenment, TopicTags.ego},
    moodTags: {MoodTags.contemplative},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'papaji-wake-up',
    content:
        'Wake up and roar! You were never the small one you took yourself to be.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.awareness, TopicTags.nature},
    moodTags: {MoodTags.uplifting, MoodTags.morning},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'papaji-no-past',
    content:
        'You have no past. The past is only a thought arising now. You have no future. The future is only a thought arising now. You have only Now.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.presence, TopicTags.mind, TopicTags.truth},
    moodTags: {MoodTags.contemplative, MoodTags.general},
    type: TeachingType.extract,
  ),

  Teaching(
    id: 'papaji-celebrate',
    content: 'Celebrate! You were never bound! The chains were made of thought.',
    teacher: _teacher,
    source: 'Satsang Extract',
    lineage: _lineage,
    topicTags: {TopicTags.freedom, TopicTags.mind},
    moodTags: {MoodTags.uplifting},
    type: TeachingType.extract,
  ),
];
