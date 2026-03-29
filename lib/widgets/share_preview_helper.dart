import 'package:flutter/material.dart';
import '../data/pointings.dart';
import '../screens/share_preview_screen.dart';

/// Shows the [SharePreviewScreen] as a modal bottom sheet for a [Pointing].
///
/// Standardizes the `showModalBottomSheet` invocation with consistent
/// parameters (`useRootNavigator: true`, `useSafeArea: true`, 90% height,
/// top-rounded clip). Replaces 4 duplicated invocations across home, article
/// reader, library, and library_widgets screens.
void showSharePreview(BuildContext context, Pointing pointing) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (ctx) => SizedBox(
      height: MediaQuery.of(ctx).size.height * 0.9,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SharePreviewScreen(pointing: pointing),
      ),
    ),
  );
}
