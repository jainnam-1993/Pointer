import 'package:flutter/material.dart';

/// Shows a floating error snackbar with the given [message].
///
/// Uses [ScaffoldMessenger] so it works from any widget context within
/// the scaffold tree. Styled with the current theme's error color.
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}
