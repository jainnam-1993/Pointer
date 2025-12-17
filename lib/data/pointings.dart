// Pointer - Core data models and enum definitions
//
// This file contains the Tradition enum used across the app for categorizing
// spiritual teachings by their tradition/lineage.

/// Spiritual traditions/lineages for categorizing content
enum Tradition {
  /// Advaita Vedanta - The path of non-duality
  advaita,

  /// Zen Buddhism - Direct pointing, no words, no concepts
  zen,

  /// Direct Path - Contemporary clarity, awareness recognizing itself
  direct,

  /// Contemporary - Modern teachers, ancient truth in fresh words
  contemporary,

  /// Original - Written for now, this moment
  original,
}

/// Human-readable information about each tradition
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

/// Tradition display information map
const traditions = <Tradition, TraditionInfo>{
  Tradition.advaita: TraditionInfo(
    name: 'Advaita Vedanta',
    icon: 'Om',
    description: 'The path of non-duality. You are already what you seek.',
  ),
  Tradition.zen: TraditionInfo(
    name: 'Zen Buddhism',
    icon: 'Enso',
    description: 'Direct pointing. No words, no concepts.',
  ),
  Tradition.direct: TraditionInfo(
    name: 'Direct Path',
    icon: 'Diamond',
    description: 'Contemporary clarity. Awareness recognizing itself.',
  ),
  Tradition.contemporary: TraditionInfo(
    name: 'Contemporary',
    icon: 'Star',
    description: 'Modern teachers. Ancient truth, fresh words.',
  ),
  Tradition.original: TraditionInfo(
    name: 'Original',
    icon: 'Infinity',
    description: 'Written for now. This moment, this life.',
  ),
};
