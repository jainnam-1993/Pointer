/**
 * Core data models and curated content for non-dual pointings.
 *
 * Defines [Tradition], [PointingContext], [Pointing], and [TraditionInfo],
 * plus the master [pointings] list and helper query functions.
 *
 * Pointing data is loaded asynchronously from `assets/data/pointings.json`
 * via [loadPointings], which must be called during app initialization
 * before any access to [pointings] or the query helpers.
 *
 * This file is the single source of truth for all pointing content and
 * is imported by nearly every other library in the app.
 */
library;

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

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

/**
 * A single non-dual pointing — the atomic unit of content in the app.
 *
 * Pointings are short spiritual pointers drawn from various [Tradition]s,
 * displayed on the home screen and shared via [ShareService].
 *
 * See also:
 * - [Teaching] for the extended model with topic/mood tags
 * - [Article] for longer-form library content
 */
class Pointing {
  /** Unique identifier (e.g., `'adv-1'`, `'zen-3'`). */
  final String id;

  /** The pointing text shown to the user. */
  final String content;

  /** Optional practice instruction (e.g., "Just look. Don't answer."). */
  final String? instruction;

  /** Source spiritual tradition. See [Tradition]. */
  final Tradition tradition;

  /** Situational contexts where this pointing is relevant. */
  final List<PointingContext> contexts;

  /** Teacher or text attribution, if known. */
  final String? teacher;

  /** Source text or talk (e.g., `'I Am That'`). */
  final String? source;

  /** Optional explanatory commentary. */
  final String? commentary;

  /** Asset path for a pre-recorded audio reading. */
  final String? audioUrl;

  /** Asset path for an associated video. */
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

  /** Deserialize a [Pointing] from a JSON map. */
  factory Pointing.fromJson(Map<String, dynamic> json) {
    return Pointing(
      id: json['id'] as String,
      content: json['content'] as String,
      instruction: json['instruction'] as String?,
      tradition: Tradition.values.byName(json['tradition'] as String),
      contexts: (json['contexts'] as List<dynamic>)
          .map((c) => PointingContext.values.byName(c as String))
          .toList(),
      teacher: json['teacher'] as String?,
      source: json['source'] as String?,
      commentary: json['commentary'] as String?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  /** Serialize this [Pointing] to a JSON-compatible map. */
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      if (instruction != null) 'instruction': instruction,
      'tradition': tradition.name,
      'contexts': contexts.map((c) => c.name).toList(),
      if (teacher != null) 'teacher': teacher,
      if (source != null) 'source': source,
      if (commentary != null) 'commentary': commentary,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (videoUrl != null) 'videoUrl': videoUrl,
    };
  }
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

// ===========================================================================
// Async-loaded pointings data with pre-built indexes
// ===========================================================================

/** All pointings, loaded from `assets/data/pointings.json`. */
late List<Pointing> pointings;

bool _pointingsLoaded = false;

/// Pre-built index: pointing ID -> Pointing
late Map<String, Pointing> _byId;

/// Pre-built index: tradition -> list of pointings
late Map<Tradition, List<Pointing>> _byTradition;

/// Pre-built index: teacher name -> list of pointings
late Map<String, List<Pointing>> _byTeacher;

/// Pre-built index: context -> list of pointings
late Map<PointingContext, List<Pointing>> _byContext;

/**
 * Load all pointings from the bundled JSON asset and build indexes.
 *
 * Must be called once during app initialization (see [AppInitializer])
 * before any access to [pointings] or the query helper functions.
 *
 * Safe to call multiple times — subsequent calls are no-ops.
 */
Future<void> loadPointings() async {
  if (_pointingsLoaded) return;

  final jsonString = await rootBundle.loadString('assets/data/pointings.json');
  final list = (jsonDecode(jsonString) as List<dynamic>).cast<Map<String, dynamic>>();
  pointings = list.map((e) => Pointing.fromJson(e)).toList(growable: false);

  // Build indexes
  _byId = {for (final p in pointings) p.id: p};

  _byTradition = {};
  _byTeacher = {};
  _byContext = {};

  for (final p in pointings) {
    _byTradition.putIfAbsent(p.tradition, () => []).add(p);

    if (p.teacher != null) {
      _byTeacher.putIfAbsent(p.teacher!, () => []).add(p);
    }

    for (final ctx in p.contexts) {
      _byContext.putIfAbsent(ctx, () => []).add(p);
    }
  }

  _pointingsLoaded = true;
}

/**
 * Whether [loadPointings] has completed successfully.
 *
 * Useful for guards and assertions in code that depends on pointings data.
 */
bool get pointingsLoaded => _pointingsLoaded;

// ===========================================================================
// Helper functions (index-backed)
// ===========================================================================

final _random = Random();

/**
 * Returns a random [Pointing], optionally filtered by [tradition] and/or [context].
 *
 * Falls back to the first pointing if no matches are found.
 */
Pointing getRandomPointing({Tradition? tradition, PointingContext? context}) {
  List<Pointing> filtered;

  if (tradition != null && context != null) {
    // Intersect tradition and context indexes
    final byTradition = _byTradition[tradition] ?? [];
    filtered = byTradition.where((p) => p.contexts.contains(context)).toList();
  } else if (tradition != null) {
    filtered = _byTradition[tradition] ?? [];
  } else if (context != null) {
    filtered = _byContext[context] ?? [];
  } else {
    filtered = pointings;
  }

  if (filtered.isEmpty) return pointings.first;
  return filtered[_random.nextInt(filtered.length)];
}

/** Returns all pointings belonging to the given [tradition]. */
List<Pointing> getPointingsByTradition(Tradition tradition) {
  return _byTradition[tradition] ?? [];
}

/** Returns all pointings tagged with the given situational [context]. */
List<Pointing> getPointingsByContext(PointingContext context) {
  return _byContext[context] ?? [];
}

/** Get a pointing by its ID, or null if not found. */
Pointing? getPointingById(String id) {
  return _byId[id];
}

/** Returns all pointings attributed to the given [teacherName]. */
List<Pointing> getPointingsByTeacher(String teacherName) {
  return _byTeacher[teacherName] ?? [];
}

// ===========================================================================
// Test support
// ===========================================================================

/**
 * Initialize pointings from an in-memory list instead of the asset bundle.
 *
 * Used by unit tests that cannot load Flutter assets. Builds the same
 * indexes as [loadPointings].
 */
void initPointingsForTest(List<Pointing> testPointings) {
  pointings = testPointings;

  _byId = {for (final p in pointings) p.id: p};

  _byTradition = {};
  _byTeacher = {};
  _byContext = {};

  for (final p in pointings) {
    _byTradition.putIfAbsent(p.tradition, () => []).add(p);
    if (p.teacher != null) {
      _byTeacher.putIfAbsent(p.teacher!, () => []).add(p);
    }
    for (final ctx in p.contexts) {
      _byContext.putIfAbsent(ctx, () => []).add(p);
    }
  }

  _pointingsLoaded = true;
}

/**
 * Reset pointings state. Used by tests to ensure clean state between runs.
 */
void resetPointingsForTest() {
  _pointingsLoaded = false;
}
