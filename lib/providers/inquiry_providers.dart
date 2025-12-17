// Inquiry Providers
// State management for inquiry selection, filtering, and mini-inquiry triggers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inquiries.dart';
import '../models/inquiry.dart';
import '../data/pointings.dart';

/// Provides a random inquiry, optionally filtered by type or tradition
final inquirySelectorProvider = Provider.family<Inquiry, InquiryFilter?>((ref, filter) {
  if (filter == null) {
    return getRandomInquiry();
  }

  return getRandomInquiry(
    type: filter.type,
    tradition: filter.tradition,
  );
});

/// Filter options for inquiry selection
class InquiryFilter {
  final InquiryType? type;
  final Tradition? tradition;

  const InquiryFilter({this.type, this.tradition});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InquiryFilter &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          tradition == other.tradition;

  @override
  int get hashCode => type.hashCode ^ tradition.hashCode;
}

/// Today's inquiry count for mini-inquiry trigger logic
///
/// Free users: trigger mini-inquiry every 3 pointings (3, 6, 9...)
/// Premium users: trigger mini-inquiry every 5 pointings (5, 10, 15...)
final todayInquiryCountProvider = StateProvider<int>((ref) => 0);

/// Daily view count for mini-inquiry trigger
///
/// Tracks total pointing views today to determine when to show mini-inquiry
final todayViewCountProvider = StateProvider<int>((ref) => 0);

/// Check if mini-inquiry should be triggered based on view count
///
/// Free tier: Every 3 pointings
/// Premium tier: Every 5 pointings
final shouldShowMiniInquiryProvider = Provider.family<bool, bool>((ref, isPremium) {
  final viewCount = ref.watch(todayViewCountProvider);

  if (viewCount == 0) return false;

  final triggerInterval = isPremium ? 5 : 3;
  return viewCount % triggerInterval == 0;
});
