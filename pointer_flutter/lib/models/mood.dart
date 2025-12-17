import 'package:flutter/material.dart';

/// User mood states for pointing selection matching.
enum Mood {
  peaceful,
  anxious,
  curious,
  restless,
  grateful,
  heavy,
  open,
  seeking,
}

/// Mood metadata with display info and matching contexts.
class MoodInfo {
  final String name;
  final String emoji;
  final String description;
  final IconData icon;
  /// Which pointing contexts work well for this mood
  final List<String> matchingContexts;

  const MoodInfo({
    required this.name,
    required this.emoji,
    required this.description,
    required this.icon,
    required this.matchingContexts,
  });
}

/// Mood metadata mapping
const moodInfo = <Mood, MoodInfo>{
  Mood.peaceful: MoodInfo(
    name: 'Peaceful',
    emoji: '🧘',
    description: 'Calm and centered',
    icon: Icons.spa,
    matchingContexts: ['morning', 'general'],
  ),
  Mood.anxious: MoodInfo(
    name: 'Anxious',
    emoji: '😰',
    description: 'Worried or stressed',
    icon: Icons.storm,
    matchingContexts: ['stress', 'general'],
  ),
  Mood.curious: MoodInfo(
    name: 'Curious',
    emoji: '🤔',
    description: 'Open to inquiry',
    icon: Icons.lightbulb_outline,
    matchingContexts: ['general', 'morning'],
  ),
  Mood.restless: MoodInfo(
    name: 'Restless',
    emoji: '💨',
    description: 'Unsettled energy',
    icon: Icons.air,
    matchingContexts: ['stress', 'evening'],
  ),
  Mood.grateful: MoodInfo(
    name: 'Grateful',
    emoji: '🙏',
    description: 'Appreciative',
    icon: Icons.favorite_outline,
    matchingContexts: ['morning', 'evening', 'general'],
  ),
  Mood.heavy: MoodInfo(
    name: 'Heavy',
    emoji: '🌑',
    description: 'Weighed down',
    icon: Icons.cloud,
    matchingContexts: ['stress', 'evening'],
  ),
  Mood.open: MoodInfo(
    name: 'Open',
    emoji: '✨',
    description: 'Receptive',
    icon: Icons.all_inclusive,
    matchingContexts: ['morning', 'general'],
  ),
  Mood.seeking: MoodInfo(
    name: 'Seeking',
    emoji: '🔍',
    description: 'Looking for truth',
    icon: Icons.explore,
    matchingContexts: ['general', 'midday'],
  ),
};
