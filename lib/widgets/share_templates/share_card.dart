import 'package:flutter/material.dart';
import '../../data/pointings.dart';
import '../../services/share_service.dart';
import '../../theme/app_theme.dart';

/**
 * Tradition-specific color palette for share card templates.
 *
 * Each [Tradition] (Advaita, Zen, Direct Path, Contemporary, Original) has
 * a bespoke gradient, text, and accent color scheme used by
 * [ShareCard] when rendering the tradition template variant.
 */
class TraditionColors {
  /** Gradient start color for the card background. */
  final Color background;

  /** Gradient end color for the card background. */
  final Color backgroundEnd;

  /** Primary text color for pointing content. */
  final Color text;

  /** Accent color for teacher attribution and watermark. */
  final Color accent;

  /** Color for the tradition badge border and text. */
  final Color badge;

  const TraditionColors({required this.background, required this.backgroundEnd, required this.text, required this.accent, required this.badge});

  /** Get colors for a tradition.
   *
   * Accent/badge colors for advaita, direct, and contemporary reference
   * [TraditionAccentColors] as the single source of truth. Zen and original
   * use share-card-specific values that differ from the app-wide accents.
   */
  static TraditionColors forTradition(Tradition tradition) {
    switch (tradition) {
      case Tradition.advaita:
        return const TraditionColors(
          background: Color(0xFF1A1206), // Deep gold/brown
          backgroundEnd: Color(0xFF2D1F0A),
          text: Color(0xFFFAF5E9), // Cream
          accent: TraditionAccentColors.advaita,
          badge: TraditionAccentColors.advaita,
        );
      case Tradition.zen:
        return const TraditionColors(
          background: Color(0xFF0A0A0A), // Pure black
          backgroundEnd: Color(0xFF1A1A1A),
          text: Color(0xFFF5F5F5), // White
          accent: Color(0xFF666666), // Gray (share-card specific, differs from app accent)
          badge: Color(0xFF666666),
        );
      case Tradition.direct:
        return const TraditionColors(
          background: Color(0xFF1A0F2E), // Deep purple
          backgroundEnd: Color(0xFF2D1B4E),
          text: Color(0xFFF5F0FF), // Light purple
          accent: TraditionAccentColors.direct,
          badge: TraditionAccentColors.direct,
        );
      case Tradition.contemporary:
        return const TraditionColors(
          background: Color(0xFF0F1A1A), // Dark teal
          backgroundEnd: Color(0xFF1A2D2D),
          text: Color(0xFFE8F5F5), // Light teal
          accent: TraditionAccentColors.contemporary,
          badge: TraditionAccentColors.contemporary,
        );
      case Tradition.original:
        return const TraditionColors(
          background: Color(0xFF1A0F1A), // Dark magenta
          backgroundEnd: Color(0xFF2D1B2D),
          text: Color(0xFFF5F0F5), // Light pink
          accent: Color(0xFFF472B6), // Pink (share-card specific, differs from app accent)
          badge: Color(0xFFF472B6),
        );
    }
  }
}

/**
 * Shareable card widget rendered for image export.
 *
 * Generates a fixed-size card (determined by [ShareFormat]) containing a
 * [Pointing] styled according to one of three [ShareTemplate] variants:
 * minimal (clean white), gradient (dark purple), or tradition (tradition-specific colors).
 *
 * Captured as an image by [ShareService.captureWidget] for sharing via
 * social media or clipboard.
 *
 * See also:
 * - [TraditionColors] for tradition-specific palettes
 * - [ShareService] for the capture and share workflow
 */
class ShareCard extends StatelessWidget {
  /** The pointing content to render on the card. */
  final Pointing pointing;

  /** Visual template variant (minimal, gradient, or tradition). */
  final ShareTemplate template;

  /** Output dimensions (square for posts, tall for stories). */
  final ShareFormat format;

  const ShareCard({super.key, required this.pointing, required this.template, required this.format});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: format.width.toDouble(), height: format.height.toDouble(), child: _buildTemplate());
  }

  Widget _buildTemplate() {
    final style = switch (template) {
      ShareTemplate.minimal => _ShareTemplateStyle.minimal,
      ShareTemplate.gradient => _ShareTemplateStyle.gradient,
      ShareTemplate.tradition => _ShareTemplateStyle.forTradition(pointing.tradition),
    };
    return _ShareTemplate(pointing: pointing, format: format, style: style);
  }
}

/**
 * Style configuration for share card templates.
 *
 * Captures all visual differences between the minimal, gradient, and
 * tradition templates so they can share a single [_ShareTemplate] widget.
 */
class _ShareTemplateStyle {
  /** Container decoration (solid color or gradient). */
  final BoxDecoration decoration;

  /** Primary text color for the pointing content. */
  final Color textColor;

  /** Color for teacher attribution. */
  final Color accentColor;

  /** Color for source citation (typically accent with reduced alpha). */
  final Color sourceColor;

  /** Watermark color. */
  final Color watermarkColor;

  /** Whether to show the tradition badge above the pointing text. */
  final bool showBadge;

  /** Optional badge color override (null uses default purple). */
  final Color? badgeColor;

  const _ShareTemplateStyle({
    required this.decoration,
    required this.textColor,
    required this.accentColor,
    required this.sourceColor,
    required this.watermarkColor,
    this.showBadge = false,
    this.badgeColor,
  });

  /** Clean white background, no badge. */
  static const minimal = _ShareTemplateStyle(
    decoration: BoxDecoration(color: Colors.white),
    textColor: Color(0xFF1A1A1A),
    accentColor: Color(0xFF666666),
    sourceColor: Color(0xFF999999),
    watermarkColor: Color(0xFF999999),
  );

  /** Dark purple gradient with default badge. */
  static _ShareTemplateStyle gradient = _ShareTemplateStyle(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F0B1A), Color(0xFF1A1025), Color(0xFF150D20)],
      ),
    ),
    textColor: const Color(0xFFF5F0FF),
    accentColor: const Color(0xFFA78BFA),
    sourceColor: const Color(0xFFA78BFA).withValues(alpha: 0.6),
    watermarkColor: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
    showBadge: true,
  );

  /** Tradition-specific colors and badge. */
  static _ShareTemplateStyle forTradition(Tradition tradition) {
    final colors = TraditionColors.forTradition(tradition);
    return _ShareTemplateStyle(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [colors.background, colors.backgroundEnd]),
      ),
      textColor: colors.text,
      accentColor: colors.accent,
      sourceColor: colors.accent.withValues(alpha: 0.6),
      watermarkColor: colors.accent.withValues(alpha: 0.6),
      showBadge: true,
      badgeColor: colors.badge,
    );
  }
}

/** Unified share card template driven by [_ShareTemplateStyle]. */
class _ShareTemplate extends StatelessWidget {
  final Pointing pointing;
  final ShareFormat format;
  final _ShareTemplateStyle style;

  const _ShareTemplate({required this.pointing, required this.format, required this.style});

  @override
  Widget build(BuildContext context) {
    final isStory = format == ShareFormat.story;
    final safePadding = isStory ? 180.0 : 80.0;

    return Container(
      decoration: style.decoration,
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: safePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          if (style.showBadge) ...[
            _TraditionBadge(tradition: pointing.tradition, color: style.badgeColor),
            const SizedBox(height: 40),
          ],
          Text(
            '"${pointing.content}"',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: _calculateFontSize(pointing.content.length, isStory),
              fontWeight: FontWeight.w400,
              color: style.textColor,
              height: 1.5,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          if (pointing.teacher != null)
            Text(
              '— ${pointing.teacher}',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 24, fontStyle: FontStyle.italic, color: style.accentColor),
            ),
          if (pointing.source != null)
            Text(
              pointing.source!,
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: style.sourceColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          _Watermark(color: style.watermarkColor),
        ],
      ),
    );
  }

  static double _calculateFontSize(int length, bool isStory) {
    if (length < 50) return isStory ? 48 : 40;
    if (length < 100) return isStory ? 40 : 34;
    if (length < 200) return isStory ? 32 : 28;
    return isStory ? 26 : 24;
  }
}

/** Tradition badge for share cards */
class _TraditionBadge extends StatelessWidget {
  final Tradition tradition;
  final Color? color;

  const _TraditionBadge({required this.tradition, this.color});

  @override
  Widget build(BuildContext context) {
    final info = traditions[tradition]!;
    final badgeColor = color ?? const Color(0xFF8B5CF6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: badgeColor, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info.icon, style: TextStyle(fontSize: 20, color: badgeColor)),
          const SizedBox(width: 8),
          Text(
            info.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: badgeColor, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

/** App watermark for share cards */
class _Watermark extends StatelessWidget {
  final Color color;

  const _Watermark({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enso-like circle
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Here Now',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color, letterSpacing: 1),
        ),
      ],
    );
  }
}
