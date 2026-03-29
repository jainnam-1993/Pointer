/**
 * Predefined tag constants for content classification and filtering.
 *
 * Provides [TopicTags] and [MoodTags] used by [Teaching] and [Article]
 * for topic-based and mood-based browsing in the library.
 */
library;

/**
 * Predefined topic tag constants for consistent content classification.
 *
 * Used by [Teaching.topicTags] and [Article.topicTags] to enable
 * topic-based browsing in [TopicTeachingsScreen].
 */
class TopicTags {
  TopicTags._();

  /** "Who am I?" and related investigative practices. */
  static const selfInquiry = 'self-inquiry';

  /** Recognition of awareness as one's true nature. */
  static const awareness = 'awareness';

  /** Formal and informal meditation practices. */
  static const meditation = 'meditation';

  /** Awakening within interpersonal dynamics. */
  static const relationship = 'relationship';

  /** Nature and transcendence of the thinking mind. */
  static const mind = 'mind';

  /** Liberation from identification and suffering. */
  static const freedom = 'freedom';

  /** Bhakti, prayer, and devotional surrender. */
  static const devotion = 'devotion';

  /** The teaching power of stillness and quiet. */
  static const silence = 'silence';

  /** Confrontation with mortality and the deathless. */
  static const death = 'death';

  /** Spiritual renewal and cyclical transformation. */
  static const rebirth = 'rebirth';

  /** Concrete techniques and disciplines. */
  static const practice = 'practice';

  /** The nature and pursuit of awakening. */
  static const enlightenment = 'enlightenment';

  /** Applying realization in everyday circumstances. */
  static const life = 'life';

  /** The absolute reality underlying appearances. */
  static const truth = 'truth';

  /** Resting as the present moment. */
  static const presence = 'presence';

  /** Letting go of personal will and control. */
  static const surrender = 'surrender';

  /** The constructed self-image and its dissolution. */
  static const ego = 'ego';

  /** One's innate, original nature prior to conditioning. */
  static const nature = 'nature';

  /** All available topic tags. */
  static const all = [
    selfInquiry,
    awareness,
    meditation,
    relationship,
    mind,
    freedom,
    devotion,
    silence,
    death,
    rebirth,
    practice,
    enlightenment,
    life,
    truth,
    presence,
    surrender,
    ego,
    nature,
  ];

  /** Human-readable display names for topics */
  static String displayName(String tag) {
    switch (tag) {
      case selfInquiry:
        return 'Self-Inquiry';
      case awareness:
        return 'Awareness';
      case meditation:
        return 'Meditation';
      case relationship:
        return 'Relationship';
      case mind:
        return 'Mind';
      case freedom:
        return 'Freedom';
      case devotion:
        return 'Devotion';
      case silence:
        return 'Silence';
      case death:
        return 'Death';
      case rebirth:
        return 'Rebirth';
      case practice:
        return 'Practice';
      case enlightenment:
        return 'Enlightenment';
      case life:
        return 'Daily Life';
      case truth:
        return 'Truth';
      case presence:
        return 'Presence';
      case surrender:
        return 'Surrender';
      case ego:
        return 'Ego';
      case nature:
        return 'True Nature';
      default:
        return tag;
    }
  }

  /** Icon for topic */
  static String icon(String tag) {
    switch (tag) {
      case selfInquiry:
        return '?';
      case awareness:
        return '◯';
      case meditation:
        return '🧘';
      case relationship:
        return '♡';
      case mind:
        return '🧠';
      case freedom:
        return '🕊';
      case devotion:
        return '🙏';
      case silence:
        return '🤫';
      case death:
        return '☽';
      case rebirth:
        return '∞';
      case practice:
        return '⚡';
      case enlightenment:
        return '✦';
      case life:
        return '🌱';
      case truth:
        return '◇';
      case presence:
        return '•';
      case surrender:
        return '🌊';
      case ego:
        return '👤';
      case nature:
        return 'ॐ';
      default:
        return '•';
    }
  }
}

/**
 * Predefined mood/context tag constants for situational content delivery.
 *
 * Used by [Teaching.moodTags] and [Article.moodTags] to enable
 * mood-based browsing in [MoodTeachingsScreen].
 */
class MoodTags {
  MoodTags._();

  /** Early-morning contemplation. */
  static const morning = 'morning';

  /** Midday pause or lunch-break reflection. */
  static const midday = 'midday';

  /** Evening wind-down reflection. */
  static const evening = 'evening';

  /** Helpful during stressful or anxious moments. */
  static const stress = 'stress';

  /** Appropriate at any time of day. */
  static const general = 'general';

  /** Deep, reflective, inward-looking tone. */
  static const contemplative = 'contemplative';

  /** Joyful, encouraging, or inspiring tone. */
  static const uplifting = 'uplifting';

  /** Provocative or destabilizing — questions assumptions. */
  static const challenging = 'challenging';

  /** All available mood tags. */
  static const all = [morning, midday, evening, stress, general, contemplative, uplifting, challenging];

  /** Human-readable display names for moods */
  static String displayName(String tag) {
    switch (tag) {
      case morning:
        return 'Morning';
      case midday:
        return 'Midday';
      case evening:
        return 'Evening';
      case stress:
        return 'When Stressed';
      case general:
        return 'Anytime';
      case contemplative:
        return 'Contemplative';
      case uplifting:
        return 'Uplifting';
      case challenging:
        return 'Challenging';
      default:
        return tag;
    }
  }

  /** Icon for mood */
  static String icon(String tag) {
    switch (tag) {
      case morning:
        return '🌅';
      case midday:
        return '☀️';
      case evening:
        return '🌙';
      case stress:
        return '🌊';
      case general:
        return '◯';
      case contemplative:
        return '🪷';
      case uplifting:
        return '✨';
      case challenging:
        return '🔥';
      default:
        return '•';
    }
  }
}
