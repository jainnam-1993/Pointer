import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/**
 * Expandable commentary section for pointings.
 *
 * Shows extended context and guidance. Users can toggle the commentary
 * open/closed with a smooth height-factor animation.
 *
 * Renders nothing when [commentary] is null.
 */
class CommentarySection extends StatefulWidget {
  /// The extended commentary text; when null, the widget renders empty.
  final String? commentary;

  /// Identifier of the associated pointing (reserved for analytics/tracking).
  final String pointingId;

  const CommentarySection({super.key, required this.commentary, required this.pointingId});

  @override
  State<CommentarySection> createState() => _CommentarySectionState();
}

class _CommentarySectionState extends State<CommentarySection> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.commentary == null) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Column(
      children: [
        // Header with expand/collapse
        GestureDetector(
          onTap: _toggleExpand,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Extended Commentary',
                  style: AppTextStyles.footerText(
                    context,
                  ).copyWith(color: colors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                RotationTransition(
                  turns: _iconTurns,
                  child: Icon(Icons.keyboard_arrow_down, size: 20, color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),

        // Expandable content
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Align(alignment: Alignment.topCenter, heightFactor: _heightFactor.value, child: child),
            );
          },
          child: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Text(
              widget.commentary!,
              style: AppTextStyles.instructionText(context).copyWith(fontStyle: FontStyle.normal),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
