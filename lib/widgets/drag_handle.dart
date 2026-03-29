import 'package:flutter/material.dart';

/// Glassmorphic drag handle pill for modal bottom sheets.
///
/// Replaces the 3 inline `Container(width: 40, height: 4, ...)` drag-handle
/// implementations across [GlassBottomSheet], [TeacherSheet], and
/// [_TraditionDetailSheet]. Uses a fixed 0.3 white alpha for glass consistency.
class DragHandle extends StatelessWidget {
  /// Optional bottom margin. Defaults to 0 (callers control spacing).
  final double bottomMargin;

  const DragHandle({super.key, this.bottomMargin = 0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: bottomMargin > 0 ? EdgeInsets.only(bottom: bottomMargin) : null,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
