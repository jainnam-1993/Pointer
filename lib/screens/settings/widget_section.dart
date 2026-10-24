/** Settings row that helps the user put the Home Screen widget on their Home Screen. */
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme.dart';
import '../../utils/haptics.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pointer_toast.dart';

/**
 * "Add widget to Home Screen".
 *
 * Android 8+: shown only when the launcher supports pinning (`isRequestPinAppWidgetSupported`);
 * a tap asks the launcher to pin the widget, and the launcher shows its own confirmation.
 * iOS has no pin API, so the row opens a short how-to sheet instead. Other platforms: hidden.
 */
class AddWidgetRow extends StatefulWidget {
  const AddWidgetRow({super.key});

  /** The native side lives in MainActivity on the existing settings channel. */
  static const channel = MethodChannel('com.dailypointer/settings');

  @override
  State<AddWidgetRow> createState() => _AddWidgetRowState();
}

class _AddWidgetRowState extends State<AddWidgetRow> {
  /** null while the Android support check is pending. */
  bool? _available;

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (_isIOS) {
      _available = true;
    } else if (_isAndroid) {
      _checkSupport();
    } else {
      _available = false;
    }
  }

  Future<void> _checkSupport() async {
    bool supported = false;
    try {
      supported = await AddWidgetRow.channel.invokeMethod<bool>('isPinWidgetSupported') ?? false;
    } on PlatformException {
      supported = false;
    } on MissingPluginException {
      supported = false;
    }
    if (mounted) setState(() => _available = supported);
  }

  Future<void> _onTap() async {
    Haptics.light();
    if (_isIOS) {
      await showAddWidgetHowTo(context);
      return;
    }
    bool requested = false;
    try {
      requested = await AddWidgetRow.channel.invokeMethod<bool>('requestPinWidget') ?? false;
    } on PlatformException {
      requested = false;
    }
    if (!requested && mounted) {
      PointerToast.show(context, 'Your launcher could not add the widget. Long-press the Home Screen, then Widgets.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_available != true) return const SizedBox.shrink();
    final colors = context.colors;
    // Spacing lives here, so a hidden row leaves the Settings layout exactly as it was.
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        button: true,
        label: 'Add widget to Home Screen',
        hint: _isIOS ? 'Shows how to add the widget' : 'Asks your launcher to add the widget',
        excludeSemantics: true,
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          onTap: _onTap,
          child: Row(
            children: [
              Icon(AppIcons.widget, color: colors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add widget to Home Screen',
                      style: TextStyle(color: colors.textPrimary, fontSize: AppType.body, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'A pointing that follows your wallpaper',
                      style: TextStyle(color: colors.textMuted, fontSize: AppType.caption),
                    ),
                  ],
                ),
              ),
              RotatedBox(quarterTurns: 3, child: Icon(AppIcons.chevronDown, color: colors.textMuted, size: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

/** iOS how-to: the system has no API to add a widget for the user. */
Future<void> showAddWidgetHowTo(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const AddWidgetHowToSheet(),
  );
}

class AddWidgetHowToSheet extends StatelessWidget {
  const AddWidgetHowToSheet({super.key});

  static const steps = [
    'Long-press an empty spot on your Home Screen.',
    'Tap Edit, then Add Widget.',
    'Search for Here Now.',
    'Pick a size and tap Add Widget.',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Add the widget',
                  style: TextStyle(color: colors.textPrimary, fontSize: AppType.headline, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              for (final (i, step) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}.',
                          style: TextStyle(color: colors.textSecondary, fontSize: AppType.callout, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(color: colors.textPrimary, fontSize: AppType.callout, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Done',
                    style: TextStyle(color: colors.textPrimary, fontSize: AppType.callout),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
