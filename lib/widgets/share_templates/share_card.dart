import 'package:flutter/material.dart';
import '../../data/pointings.dart';
import '../../services/share_service.dart';

/// Tradition-specific color palettes for share cards
class TraditionColors {
  final Color background;
  final Color backgroundEnd;
  final Color text;
  final Color accent;
  final Color badge;

  const TraditionColors({
    required this.background,
    required this.backgroundEnd,
    required this.text,
    required this.accent,
    required this.badge,
  });

  /// Get colors for a tradition
  static TraditionColors forTradition(Tradition tradition) {
    switch (tradition) {
      case Tradition.advaita:
        return const TraditionColors(
          background: Color(0xFF1A1206), // Deep gold/brown
          backgroundEnd: Color(0xFF2D1F0A),
          text: Color(0xFFFAF5E9), // Cream
          accent: Color(0xFFD4A574), // Gold
          badge: Color(0xFFD4A574),
        );
      case Tradition.zen:
        return const TraditionColors(
          background: Color(0xFF0A0A0A), // Pure black
          backgroundEnd: Color(0xFF1A1A1A),
          text: Color(0xFFF5F5F5), // White
          accent: Color(0xFF666666), // Gray
          badge: Color(0xFF666666),
        );
      case Tradition.direct:
        return const TraditionColors(
          background: Color(0xFF1A0F2E), // Deep purple
          backgroundEnd: Color(0xFF2D1B4E),
          text: Color(0xFFF5F0FF), // Light purple
          accent: Color(0xFF8B5CF6), // Violet
          badge: Color(0xFF8B5CF6),
        );
      case Tradition.contemporary:
        return const TraditionColors(
          background: Color(0xFF0F1A1A), // Dark teal
          backgroundEnd: Color(0xFF1A2D2D),
          text: Color(0xFFE8F5F5), // Light teal
          accent: Color(0xFF06B6D4), // Cyan
          badge: Color(0xFF06B6D4),
        );
      case Tradition.original:
        return const TraditionColors(
          background: Color(0xFF1A0F1A), // Dark magenta
          backgroundEnd: Color(0xFF2D1B2D),
          text: Color(0xFFF5F0F5), // Light pink
          accent: Color(0xFFF472B6), // Pink
          badge: Color(0xFFF472B6),
        );
    }
  }
}

/// Shareable card widget for export
class ShareCard extends StatelessWidget {
  final Pointing pointing;
  final ShareTemplate template;
  final ShareFormat format;

  const ShareCard({
    super.key,
    required this.pointing,
    required this.template,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: format.width.toDouble(),
      height: format.height.toDouble(),
      child: _buildTemplate(),
    );
  }

  Widget _buildTemplate() {
    switch (template) {
      case ShareTemplate.minimal:
        return _MinimalTemplate(pointing: pointing, format: format);
      case ShareTemplate.gradient:
        return _GradientTemplate(pointing: pointing, format: format);
      case ShareTemplate.tradition:
        return _TraditionTemplate(pointing: pointing, format: format);
    }
  }
}

/// Minimal template - clean, text-focused
class _MinimalTemplate extends StatelessWidget {
  final Pointing pointing;
  final ShareFormat format;

  const _MinimalTemplate({required this.pointing, required this.format});

  @override
  Widget build(BuildContext context) {
    final isStory = format == ShareFormat.story;
    final safePadding = isStory ? 180.0 : 80.0; // Story safe zones

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 80,
        vertical: safePadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Pointing text
          Text(
            '"${pointing.content}"',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: _calculateFontSize(pointing.content.length, isStory),
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1A1A),
              height: 1.5,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Teacher attribution
          if (pointing.teacher != null)
            Text(
              '— ${pointing.teacher}',
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontStyle: FontStyle.italic,
                color: Color(0xFF666666),
              ),
            ),
          const Spacer(),
          // Watermark
          _Watermark(color: const Color(0xFF999999)),
        ],
      ),
    );
  }

  double _calculateFontSize(int length, bool isStory) {
    if (length < 50) return isStory ? 48 : 40;
    if (length < 100) return isStory ? 40 : 34;
    if (length < 200) return isStory ? 32 : 28;
    return isStory ? 26 : 24;
  }
}

/// Gradient template - app gradient background
class _GradientTemplate extends StatelessWidget {
  final Pointing pointing;
  final ShareFormat format;

  const _GradientTemplate({required this.pointing, required this.format});

  @override
  Widget build(BuildContext context) {
    final isStory = format == ShareFormat.story;
    final safePadding = isStory ? 180.0 : 80.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0B1A), // Deep purple-black
            Color(0xFF1A1025), // Dark purple
            Color(0xFF150D20), // Midnight
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 80,
        vertical: safePadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Tradition badge
          _TraditionBadge(tradition: pointing.tradition),
          const SizedBox(height: 40),
          // Pointing text
          Text(
            '"${pointing.content}"',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: _calculateFontSize(pointing.content.length, isStory),
              fontWeight: FontWeight.w400,
              color: const Color(0xFFF5F0FF),
              height: 1.5,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Teacher attribution
          if (pointing.teacher != null)
            Text(
              '— ${pointing.teacher}',
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontStyle: FontStyle.italic,
                color: Color(0xFFA78BFA),
              ),
            ),
          const Spacer(),
          // Watermark
          _Watermark(color: const Color(0xFF8B5CF6).withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  double _calculateFontSize(int length, bool isStory) {
    if (length < 50) return isStory ? 48 : 40;
    if (length < 100) return isStory ? 40 : 34;
    if (length < 200) return isStory ? 32 : 28;
    return isStory ? 26 : 24;
  }
}

/// Tradition template - colors matching the tradition
class _TraditionTemplate extends StatelessWidget {
  final Pointing pointing;
  final ShareFormat format;

  const _TraditionTemplate({required this.pointing, required this.format});

  @override
  Widget build(BuildContext context) {
    final colors = TraditionColors.forTradition(pointing.tradition);
    final isStory = format == ShareFormat.story;
    final safePadding = isStory ? 180.0 : 80.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.background, colors.backgroundEnd],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 80,
        vertical: safePadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Tradition badge
          _TraditionBadge(
            tradition: pointing.tradition,
            color: colors.badge,
          ),
          const SizedBox(height: 40),
          // Pointing text
          Text(
            '"${pointing.content}"',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: _calculateFontSize(pointing.content.length, isStory),
              fontWeight: FontWeight.w400,
              color: colors.text,
              height: 1.5,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Teacher attribution
          if (pointing.teacher != null)
            Text(
              '— ${pointing.teacher}',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 24,
                fontStyle: FontStyle.italic,
                color: colors.accent,
              ),
            ),
          const Spacer(),
          // Watermark
          _Watermark(color: colors.accent.withValues(alpha: 0.6)),
        ],
      ),
    );
  }

  double _calculateFontSize(int length, bool isStory) {
    if (length < 50) return isStory ? 48 : 40;
    if (length < 100) return isStory ? 40 : 34;
    if (length < 200) return isStory ? 32 : 28;
    return isStory ? 26 : 24;
  }
}

/// Tradition badge for share cards
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
          Text(
            info.icon,
            style: TextStyle(fontSize: 20, color: badgeColor),
          ),
          const SizedBox(width: 8),
          Text(
            info.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: badgeColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// App watermark for share cards
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: color,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
