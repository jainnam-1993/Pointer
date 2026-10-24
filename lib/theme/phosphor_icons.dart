/*
 * The Phosphor glyphs this app uses, as plain IconData on the fonts bundled by the
 * phosphor_flutter package (MIT). Its own Dart API is not imported: PhosphorIconData
 * extends IconData, which Flutter 3.47 made final, so that library no longer compiles.
 * Codepoints are copied from phosphor_flutter 2.1.0 lib/src/phosphor_icons_<style>.dart.
 * To add a glyph, copy its codepoint from there.
 */
library;

import 'package:flutter/widgets.dart';

const _package = 'phosphor_flutter';

/** Phosphor Light weight (font family PhosphorLight). */
abstract final class PhosphorIconsLight {
  static const IconData bird = IconData(0xe72c, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData bookOpen = IconData(0xe0e6, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData brain = IconData(0xe74e, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData caretDown = IconData(0xe136, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData caretLeft = IconData(0xe138, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData check = IconData(0xe182, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData circle = IconData(0xe18a, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData circleDashed = IconData(0xe602, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData cloudSun = IconData(0xe540, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData coffee = IconData(0xe1c2, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData couch = IconData(0xe7f6, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData diamond = IconData(0xe1ec, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData dot = IconData(0xecde, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData drop = IconData(0xe210, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData export = IconData(0xeaf0, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData fire = IconData(0xe242, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData gift = IconData(0xe276, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData handHeart = IconData(0xe810, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData heart = IconData(0xe2a8, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData infinity = IconData(0xe634, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData info = IconData(0xe2ce, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData leaf = IconData(0xe2da, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData lightning = IconData(0xe2de, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData moon = IconData(0xe330, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData moonStars = IconData(0xe58e, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData mountains = IconData(0xe7ae, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData plant = IconData(0xebae, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData question = IconData(0xe3e8, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData quotes = IconData(0xe660, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData slidersHorizontal = IconData(0xe434, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData squaresFour = IconData(0xe464, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData sparkle = IconData(0xe6a2, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData speakerSlash = IconData(0xe45a, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData sun = IconData(0xe472, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData sunHorizon = IconData(0xe5b6, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData timer = IconData(0xe492, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData userCircle = IconData(0xe4c4, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData waves = IconData(0xe6de, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData wind = IconData(0xe5d2, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
  static const IconData x = IconData(0xe4f6, fontFamily: 'PhosphorLight', fontPackage: _package, matchTextDirection: true);
}

/** Phosphor Regular weight (font family PhosphorRegular). */
abstract final class PhosphorIconsRegular {
  static const IconData bookOpen = IconData(0xe0e6, fontFamily: 'PhosphorRegular', fontPackage: _package, matchTextDirection: true);
  static const IconData question = IconData(0xe3e8, fontFamily: 'PhosphorRegular', fontPackage: _package, matchTextDirection: true);
  static const IconData slidersHorizontal = IconData(0xe434, fontFamily: 'PhosphorRegular', fontPackage: _package, matchTextDirection: true);
  static const IconData sunHorizon = IconData(0xe5b6, fontFamily: 'PhosphorRegular', fontPackage: _package, matchTextDirection: true);
}

/** Phosphor Fill weight (font family PhosphorFill). */
abstract final class PhosphorIconsFill {
  static const IconData heart = IconData(0xe2a8, fontFamily: 'PhosphorFill', fontPackage: _package, matchTextDirection: true);
}
