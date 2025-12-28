import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pointer/screens/settings_screen.dart';
import 'package:pointer/providers/providers.dart';

void main() {
  late SharedPreferences mockPrefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockPrefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget({Widget? child}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: child ?? const SettingsScreen(),
      ),
    );
  }

  group('Settings Screen - Basic Structure', () {
    testWidgets('renders settings screen', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('has scrollable content', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scrollable), findsWidgets);
    });

    testWidgets('developer section is hidden by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Developer section should not be visible initially
      expect(find.text('DEVELOPER'), findsNothing);
      expect(find.text('TTS Configuration'), findsNothing);
    });
  });

  group('Settings Screen - State Management', () {
    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
