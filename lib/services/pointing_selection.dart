/**
 * What the user's tradition choices and learned affinity mean for selection.
 *
 * One value object answers both questions every picker needs: which pointings
 * are eligible (Manage Lineages) and how likely each is to come up early
 * (affinity from views and saves). Home's round-robin order and the
 * notification rotation both read it, so they cannot drift apart.
 */
library;

import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/pointings.dart';
import 'affinity_service.dart';
import 'storage_service.dart';

class PointingSelection {
  /** Traditions the user receives pointings from. Empty means all. */
  final Set<Tradition> enabled;

  /** Learned affinity per tradition, summing to about 1 (uniform when there is no data). */
  final Map<Tradition, double> affinity;

  const PointingSelection({this.enabled = const {}, this.affinity = const {}});

  /** No filter and no learned preference. */
  static const all = PointingSelection();

  /** Read both inputs from preferences (usable from background isolates). */
  factory PointingSelection.fromPrefs(SharedPreferences prefs) {
    final names = StorageService(prefs).preferredTraditions.toSet();
    final enabled = Tradition.values.where((t) => names.contains(t.name)).toSet();
    return PointingSelection.of(enabled, AffinityService(prefs));
  }

  factory PointingSelection.of(Set<Tradition> enabled, AffinityService affinity) =>
      PointingSelection(enabled: enabled, affinity: {for (final t in Tradition.values) t: affinity.getAffinityScore(t)});

  bool isEligible(Pointing p) => enabled.isEmpty || enabled.contains(p.tradition);

  /** Pointings from enabled traditions; falls back to [all] so a picker never runs dry. */
  List<Pointing> eligible(List<Pointing> all) {
    final filtered = all.where(isEligible).toList();
    return filtered.isEmpty ? all : filtered;
  }

  /**
   * Relative draw weight. A tradition at the uniform share weighs 1; one the
   * user views and saves most can weigh up to about 1 + [Tradition.values.length].
   * Every eligible tradition keeps a floor of 0.5 so it still appears.
   */
  double weightOf(Pointing p) {
    final score = affinity[p.tradition];
    if (score == null) return 1;
    return max(0.5, score * Tradition.values.length);
  }

  /** Weighted random order (Efraimidis-Spirakis): higher weight tends to come earlier. */
  List<T> weightedShuffle<T>(List<T> items, double Function(T) weight, Random rng) {
    final keyed = [for (final item in items) (item, pow(rng.nextDouble(), 1 / weight(item)).toDouble())];
    keyed.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final k in keyed) k.$1];
  }

  /** Home's round-robin order: eligible ids, affinity-weighted. */
  List<String> order(List<Pointing> all, Random rng) => weightedShuffle(eligible(all), weightOf, rng).map((p) => p.id).toList();
}
