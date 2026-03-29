/**
 * Teacher database loaded from `assets/data/teachers.json`.
 *
 * Provides the unified [Teacher] data set (replacing the former split between
 * lightweight `teachers` map and extended `teacherProfiles` list) along with
 * query helpers used by [TeacherSheet], [LibraryScreen], and providers.
 *
 * Call [loadTeachers] once at startup before accessing any data.
 */
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/teacher.dart';
import 'pointings.dart';

// ---------------------------------------------------------------------------
// Data (populated by loadTeachers)
// ---------------------------------------------------------------------------

/** All [Teacher] records keyed by name. */
final Map<String, Teacher> teachers = {};

/** All [Teacher] records as an unmodifiable list. */
List<Teacher> get allTeachers => List.unmodifiable(teachers.values);

// ---------------------------------------------------------------------------
// Lazy-built indexes (cleared on reload)
// ---------------------------------------------------------------------------

Map<String, Teacher>? _teachersByLowerName;
Map<Tradition, List<Teacher>>? _teachersByTradition;
List<Teacher>? _teachersWithArticles;
List<Teacher>? _teachersWithPointings;
List<String>? _allTeacherNames;
Map<String, String>? _teacherSearchCorpus;

void _clearIndexes() {
  _teachersByLowerName = null;
  _teachersByTradition = null;
  _teachersWithArticles = null;
  _teachersWithPointings = null;
  _allTeacherNames = null;
  _teacherSearchCorpus = null;
}

Map<String, Teacher> get _byLowerName =>
    _teachersByLowerName ??= {for (final t in teachers.values) t.name.toLowerCase(): t};

Map<Tradition, List<Teacher>> get _byTradition => _teachersByTradition ??= {
      for (final tradition in Tradition.values)
        tradition: List<Teacher>.unmodifiable(
          teachers.values.where((t) => t.tradition == tradition).toList(growable: false),
        ),
    };

List<Teacher> get _withArticles => _teachersWithArticles ??= List<Teacher>.unmodifiable(
      teachers.values.where((t) => t.articleIds.isNotEmpty).toList(growable: false),
    );

List<Teacher> get _withPointings => _teachersWithPointings ??= List<Teacher>.unmodifiable(
      teachers.values.where((t) => t.pointingIds.isNotEmpty).toList(growable: false),
    );

List<String> get _names =>
    _allTeacherNames ??= List<String>.unmodifiable(teachers.values.map((t) => t.name).toList(growable: false));

Map<String, String> get _searchCorpus => _teacherSearchCorpus ??= {
      for (final t in teachers.values) t.name: [t.name, t.bio ?? '', ...t.keyTeachings].join('\n').toLowerCase(),
    };

// ---------------------------------------------------------------------------
// Loader
// ---------------------------------------------------------------------------

/**
 * Load teacher data from `assets/data/teachers.json`.
 *
 * Must be called once during app startup (via [AppInitializer]) before any
 * teacher queries. Replaces the former compile-time `const teachers` map.
 */
Future<void> loadTeachers() async {
  final jsonString = await rootBundle.loadString('assets/data/teachers.json');
  final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

  teachers.clear();
  _clearIndexes();

  for (final item in jsonList) {
    final teacher = Teacher.fromJson(item as Map<String, dynamic>);
    teachers[teacher.name] = teacher;
  }
}

// ---------------------------------------------------------------------------
// Query helpers (backward-compatible API surface)
// ---------------------------------------------------------------------------

/** Get teacher by name, returns null if not found. */
Teacher? getTeacher(String? name) {
  if (name == null) return null;
  return teachers[name];
}

/** Get teacher by name (case-insensitive). */
Teacher? getTeacherProfile(String name) {
  return _byLowerName[name.toLowerCase()];
}

/** Get all pointings by a specific teacher. */
List<Pointing> getPointingsByTeacher(String teacherName) {
  return pointings.where((p) => p.teacher == teacherName).toList();
}

/** Get teachers by tradition. */
List<Teacher> getTeachersByTradition(Tradition tradition) {
  return _byTradition[tradition] ?? const <Teacher>[];
}

/** Get all teacher names. */
List<String> getAllTeacherNames() {
  return _names;
}

/** Get teachers who have related articles. */
List<Teacher> getTeachersWithArticles() {
  return _withArticles;
}

/** Get teachers who have related pointings. */
List<Teacher> getTeachersWithPointings() {
  return _withPointings;
}

/** Search teacher profiles by name, bio, and key teachings. */
List<Teacher> searchTeacherProfiles(String query) {
  final normalizedQuery = query.toLowerCase().trim();
  if (normalizedQuery.isEmpty) return const <Teacher>[];
  return teachers.values
      .where((t) => (_searchCorpus[t.name] ?? '').contains(normalizedQuery))
      .toList(growable: false);
}
