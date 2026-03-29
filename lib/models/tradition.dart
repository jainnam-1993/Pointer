/**
 * Spiritual tradition model and associated display metadata.
 *
 * Defines [Tradition], [PointingContext], [TraditionInfo], and the
 * [traditions] map used across the app for content classification
 * and display.
 */
library;

/** Spiritual lineage/tradition a pointing originates from. */
enum Tradition {
  /** Advaita Vedanta — the path of non-duality. */
  advaita,

  /** Zen Buddhism — direct pointing, no concepts. */
  zen,

  /** Direct Path — contemporary clarity (Spira, Lucille, Klein). */
  direct,

  /** Contemporary — modern teachers, ancient truth. */
  contemporary,

  /** Original — writings created specifically for this app. */
  original,
}

/** Time-of-day or situational context for delivering a pointing. */
enum PointingContext {
  /** Best suited for morning contemplation. */
  morning,

  /** Best suited for midday pause. */
  midday,

  /** Best suited for evening reflection. */
  evening,

  /** Helpful during stressful moments. */
  stress,

  /** Appropriate at any time. */
  general,
}

/** Display metadata for a [Tradition] — name, icon glyph, and description. */
class TraditionInfo {
  /** Human-readable tradition name (e.g., `'Advaita Vedanta'`). */
  final String name;

  /** Single-character icon glyph (e.g., `'ॐ'`, `'◯'`). */
  final String icon;

  /** Short description of the tradition's essence. */
  final String description;

  const TraditionInfo({required this.name, required this.icon, required this.description});
}

/** Map of [Tradition] to its [TraditionInfo] display metadata. */
const traditions = <Tradition, TraditionInfo>{
  Tradition.advaita: TraditionInfo(name: 'Advaita Vedanta', icon: 'ॐ', description: 'The path of non-duality. You are already what you seek.'),
  Tradition.zen: TraditionInfo(name: 'Zen Buddhism', icon: '◯', description: 'Direct pointing. No words, no concepts.'),
  Tradition.direct: TraditionInfo(name: 'Direct Path', icon: '◇', description: 'Contemporary clarity. Awareness recognizing itself.'),
  Tradition.contemporary: TraditionInfo(name: 'Contemporary', icon: '✦', description: 'Modern teachers. Ancient truth, fresh words.'),
  Tradition.original: TraditionInfo(name: 'Original', icon: '∞', description: 'Written for now. This moment, this life.'),
};
