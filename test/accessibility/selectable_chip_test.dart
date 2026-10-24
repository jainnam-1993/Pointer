import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/selectable_chip.dart';

/** The schedule chips announce their selected state and spoken label, and are at least 44 pt tall. */
void main() {
  Future<void> pumpChips(WidgetTester tester, ValueNotifier<int> selected) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: selected,
            builder: (context, value, _) => Wrap(
              children: [
                for (final hours in [1, 3])
                  SelectableChip(
                    label: '${hours}h',
                    semanticLabel: hours == 1 ? 'Every hour' : 'Every $hours hours',
                    selected: value == hours,
                    onSelected: () => selected.value = hours,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('chip exposes button, selected state and spoken label', (tester) async {
    final handle = tester.ensureSemantics();
    final selected = ValueNotifier<int>(1);
    await pumpChips(tester, selected);

    expect(
      tester.getSemantics(find.byType(SelectableChip).first),
      matchesSemantics(
        label: 'Every hour',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasSelectedState: true,
        isSelected: true,
        isInMutuallyExclusiveGroup: true,
        hasTapAction: true,
      ),
    );
    expect(find.bySemanticsLabel('Every 3 hours'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('chip meets the 44 pt touch target and selects on tap', (tester) async {
    final selected = ValueNotifier<int>(1);
    await pumpChips(tester, selected);

    for (final element in find.byType(SelectableChip).evaluate()) {
      final size = (element.renderObject! as RenderBox).size;
      expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
      expect(size.width, greaterThanOrEqualTo(AppSpacing.minTouchTarget));
    }
    await tester.tap(find.text('3h'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(selected.value, 3);
  });
}
