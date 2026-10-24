import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/theme/app_theme.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/widgets/shared_ambient.dart';

void main() {
  setUpAll(() => AnimatedGradient.disableAnimations = true);
  tearDownAll(() => AnimatedGradient.disableAnimations = false);

  Widget app({required bool shared}) => ProviderScope(
    overrides: [
      oledModeProvider.overrideWith((ref) => false),
      themeModeProvider.overrideWith((ref) => AppThemeMode.dark),
      reduceMotionOverrideProvider.overrideWith((ref) => null),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      builder: shared ? (context, child) => SharedAmbientHost(child: child!) : null,
      home: const Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: RouteAmbient()),
            Text('page'),
          ],
        ),
      ),
    ),
  );

  testWidgets('under a host, routes paint no background of their own (design 9)', (tester) async {
    await tester.pumpWidget(app(shared: true));
    expect(find.byType(AnimatedGradient), findsOneWidget);
    expect(find.descendant(of: find.byType(RouteAmbient), matching: find.byType(AnimatedGradient)), findsNothing);
    final scaffoldTheme = Theme.of(tester.element(find.text('page')));
    expect(scaffoldTheme.scaffoldBackgroundColor, Colors.transparent);
    expect(scaffoldTheme.pageTransitionsTheme.builders[TargetPlatform.iOS], isA<AmbientPageTransitionsBuilder>());
  });

  testWidgets('pushing a page keeps exactly one background', (tester) async {
    await tester.pumpWidget(app(shared: true));
    Navigator.of(tester.element(find.text('page'))).push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: RouteAmbient()),
              Text('next'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(AnimatedGradient), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('next'), findsOneWidget);
  });

  testWidgets('without a host, a screen keeps its own background', (tester) async {
    await tester.pumpWidget(app(shared: false));
    expect(find.descendant(of: find.byType(RouteAmbient), matching: find.byType(AnimatedGradient)), findsOneWidget);
  });
}
