/**
 * Data model and seed data for guided self-inquiry sessions.
 *
 * [InquirySession] is the simplified session model used by [InquiryScreen]
 * for session selection. Contains a fixed list of beginner-to-advanced sessions.
 *
 * See also:
 * - [Inquiry] in `models/inquiry.dart` for the timed inquiry model
 * - [InquiryPlayerScreen] for the timed presentation UI
 */
library;

import 'package:flutter/material.dart';

import '../models/tradition.dart';
import '../theme/app_theme.dart';

/**
 * Data model for a guided self-inquiry session.
 *
 * Each session belongs to a [Tradition] and has a difficulty level.
 */
class InquirySession {
  /** Unique identifier for the session. */
  final String id;

  /** Display title (e.g., "Who Am I?"). */
  final String title;

  /** Short description of the inquiry approach. */
  final String description;

  /** Human-readable duration string (e.g., "5 min"). */
  final String duration;

  /** Difficulty level: Beginner, Intermediate, or Advanced. */
  final String level;

  /** The spiritual tradition this inquiry belongs to. */
  final Tradition tradition;

  const InquirySession({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.level,
    required this.tradition,
  });

  /** Get the accent color for this session's tradition */
  Color get accentColor {
    switch (tradition) {
      case Tradition.advaita:
        return TraditionAccentColors.advaita;
      case Tradition.zen:
        return TraditionAccentColors.zen;
      case Tradition.direct:
        return TraditionAccentColors.direct;
      case Tradition.contemporary:
        return TraditionAccentColors.contemporary;
      case Tradition.original:
        return TraditionAccentColors.original;
    }
  }
}

/** All available inquiry sessions, ordered from beginner to advanced. */
const inquirySessions = [
  InquirySession(
    id: '1',
    title: 'Who Am I?',
    description: 'The fundamental inquiry',
    duration: '5 min',
    level: 'Beginner',
    tradition: Tradition.advaita,
  ),
  InquirySession(
    id: '2',
    title: 'Finding the Looker',
    description: 'Turn attention to its source',
    duration: '7 min',
    level: 'Beginner',
    tradition: Tradition.direct,
  ),
  InquirySession(
    id: '3',
    title: 'The Space of Awareness',
    description: "Recognizing what doesn't change",
    duration: '10 min',
    level: 'Intermediate',
    tradition: Tradition.direct,
  ),
  InquirySession(
    id: '4',
    title: 'Investigating Thoughts',
    description: 'What are thoughts made of?',
    duration: '8 min',
    level: 'Intermediate',
    tradition: Tradition.zen,
  ),
  InquirySession(
    id: '5',
    title: 'Resting as Awareness',
    description: 'Beyond the practice',
    duration: '12 min',
    level: 'Advanced',
    tradition: Tradition.contemporary,
  ),
];
