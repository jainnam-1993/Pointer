/**
 * Inquiry providers - Selection, filtering, and mini-inquiry triggers.
 *
 * Manages guided [Inquiry] selection via [inquirySelectorProvider] with
 * optional [InquiryFilter] by type or tradition. Tracks daily view counts
 * for mini-inquiry trigger logic (every N pointings based on tier).
 *
 * Mini-inquiries surface short contemplative prompts between pointing
 * rotations to deepen engagement without requiring explicit navigation.
 */
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inquiries.dart';
import '../models/inquiry.dart';
import '../data/pointings.dart';

/** Provides a random inquiry, optionally filtered by type or tradition */
final inquirySelectorProvider = Provider.family<Inquiry, InquiryFilter?>((ref, filter) {
  if (filter == null) {
    return getRandomInquiry();
  }

  return getRandomInquiry(type: filter.type, tradition: filter.tradition);
});

/**
 * Filter options for [Inquiry] selection.
 *
 * Passed to [inquirySelectorProvider] to narrow random inquiry selection
 * by [InquiryType] (e.g., self-inquiry, koan) and/or [Tradition].
 * Implements value equality for Riverpod `.family` key deduplication.
 */
class InquiryFilter {
  /** Optional inquiry type filter (e.g., self-inquiry, contemplation, koan). */
  final InquiryType? type;

  /** Optional spiritual tradition filter. */
  final Tradition? tradition;

  const InquiryFilter({this.type, this.tradition});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InquiryFilter && runtimeType == other.runtimeType && type == other.type && tradition == other.tradition;

  @override
  int get hashCode => type.hashCode ^ tradition.hashCode;
}

/** Today's inquiry count for mini-inquiry trigger logic */
final todayInquiryCountProvider = StateProvider<int>((ref) => 0);

/**
 * Daily view count for mini-inquiry trigger
 *
 * Tracks total pointing views today to determine when to show mini-inquiry
 */
final todayViewCountProvider = StateProvider<int>((ref) => 0);

/**
 * Check if mini-inquiry should be triggered based on view count
 *
 * Triggers every 5 pointings (5, 10, 15...)
 */
final shouldShowMiniInquiryProvider = Provider<bool>((ref) {
  final viewCount = ref.watch(todayViewCountProvider);

  if (viewCount == 0) return false;

  return viewCount % 5 == 0;
});

/**
 * Provides a specific inquiry by ID
 * Returns null if the inquiry is not found
 */
final inquiryByIdProvider = Provider.family<Inquiry?, String>((ref, id) {
  return getInquiryById(id);
});

/** Current inquiry for the player, allows random selection */
final currentInquiryProvider = StateProvider<Inquiry?>((ref) => null);
