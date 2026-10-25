/** Experience settings section: auto-advance toggle. */
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pointer_switch.dart';
import '../../utils/haptics.dart';

/** Auto-advance toggle for automatic pointing rotation */
class AutoAdvanceToggle extends ConsumerWidget {
  const AutoAdvanceToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isEnabled = ref.watch(autoAdvanceProvider);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_mode, color: colors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Advance',
                      style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text('New pointing every minute', style: TextStyle(color: colors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              PointerSwitch(
                value: isEnabled,
                onChanged: (value) {
                  Haptics.selection();
                  ref.read(settingsProvider.notifier).setAutoAdvance(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
