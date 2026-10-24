/**
 * The one icon set: Phosphor (MIT) in its Light weight, a thin even line that
 * matches the enso stroke. Active tabs use the Regular weight.
 *
 * Use these semantic names instead of Material [Icons]. No lotus, no seated
 * figure: the app points at what is already here, it does not depict practice.
 */
library;

import 'package:flutter/widgets.dart';
import 'package:pointer/theme/phosphor_icons.dart';

class AppIcons {
  const AppIcons._();

  // Tabs
  static const IconData home = PhosphorIconsLight.sunHorizon;
  static const IconData homeActive = PhosphorIconsRegular.sunHorizon;
  static const IconData inquiry = PhosphorIconsLight.question;
  static const IconData inquiryActive = PhosphorIconsRegular.question;
  static const IconData library = PhosphorIconsLight.bookOpen;
  static const IconData libraryActive = PhosphorIconsRegular.bookOpen;
  static const IconData settings = PhosphorIconsLight.slidersHorizontal;
  static const IconData settingsActive = PhosphorIconsRegular.slidersHorizontal;

  // Tip tiers (distinct from the tabs)
  static const IconData tipTea = PhosphorIconsLight.coffee;
  static const IconData tipCushion = PhosphorIconsLight.couch;
  static const IconData tipIncense = PhosphorIconsLight.wind;
  static const IconData tipRetreat = PhosphorIconsLight.mountains;
  static const IconData tipFallback = PhosphorIconsLight.gift;

  // Common
  static const IconData heart = PhosphorIconsLight.heart;
  static const IconData chevronDown = PhosphorIconsLight.caretDown;
  static const IconData check = PhosphorIconsLight.check;
  static const IconData close = PhosphorIconsLight.x;
  static const IconData share = PhosphorIconsLight.export;
  static const IconData info = PhosphorIconsLight.info;

  /** A teacher (library browse card). */
  static const IconData teacher = PhosphorIconsLight.quotes;

  /** Stands for timer-and-streak meditation apps on the onboarding contrast page. */
  static const IconData timer = PhosphorIconsLight.timer;

  /** Every icon above by name, for tests and audits. */
  static const Map<String, IconData> all = {
    'home': home,
    'homeActive': homeActive,
    'inquiry': inquiry,
    'inquiryActive': inquiryActive,
    'library': library,
    'libraryActive': libraryActive,
    'settings': settings,
    'settingsActive': settingsActive,
    'tipTea': tipTea,
    'tipCushion': tipCushion,
    'tipIncense': tipIncense,
    'tipRetreat': tipRetreat,
    'tipFallback': tipFallback,
    'heart': heart,
    'chevronDown': chevronDown,
    'check': check,
    'close': close,
    'share': share,
    'info': info,
    'timer': timer,
    'teacher': teacher,
  };
}
