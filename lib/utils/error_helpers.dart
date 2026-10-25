import 'package:flutter/widgets.dart';

import '../theme/app_icons.dart';
import '../widgets/pointer_toast.dart';

/// Shows a calm, floating error message with the given [message].
///
/// Uses the app's [PointerToast] rather than a Material snackbar, so errors share
/// the same quiet surface as every other transient message.
void showErrorSnackBar(BuildContext context, String message) {
  PointerToast.show(context, message, icon: AppIcons.info);
}
