// Golden Tests for UI Components
//
// These tests verify individual components haven't visually changed.
// Catches regressions in buttons, cards, badges, and other reusable widgets.
//
// Generate/update baselines:
//   flutter test --update-goldens test/golden/components_golden_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/widgets/glass_card.dart';
import 'package:pointer/widgets/tradition_badge.dart';
import 'package:pointer/widgets/animated_gradient.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/theme/app_theme.dart';
import 'golden_test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupGoldenTests();
  });

  tearDownAll(() {
    teardownGoldenTests();
  });

  // ==========================================================
  // GLASS CARD GOLDEN TESTS
  // ==========================================================
  group('GlassCard Golden Tests', () {
    testWidgets('glass card default', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: GlassCard(
              padding: EdgeInsets.all(24),
              child: Text(
                'Glass Card Content',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        size: const Size(400, 200),
      );

      await expectGoldenMatches(tester, 'glass_card_default');
    });

    testWidgets('glass card with custom border', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              padding: const EdgeInsets.all(24),
              borderColor: PointerColors.dark.gold.withOpacity(0.5),
              child: const Text(
                'Gold Border Card',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        size: const Size(400, 200),
      );

      await expectGoldenMatches(tester, 'glass_card_gold_border');
    });

    testWidgets('glass card large content', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: const Padding(
            padding: EdgeInsets.all(24),
            child: GlassCard(
              padding: EdgeInsets.all(32),
              borderRadius: 32,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'What is aware of this moment?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Simply notice.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        size: const Size(400, 300),
      );

      await expectGoldenMatches(tester, 'glass_card_large_content');
    });
  });

  // ==========================================================
  // GLASS BUTTON GOLDEN TESTS
  // ==========================================================
  group('GlassButton Golden Tests', () {
    testWidgets('glass button primary', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: GlassButton(
            label: 'Next',
            onPressed: () {},
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
        ),
        size: const Size(300, 150),
      );

      await expectGoldenMatches(tester, 'glass_button_primary');
    });

    testWidgets('glass button secondary', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: GlassButton(
            label: 'Share',
            onPressed: () {},
            isPrimary: false,
            icon: const Icon(Icons.share_outlined, color: Colors.white),
          ),
        ),
        size: const Size(300, 150),
      );

      await expectGoldenMatches(tester, 'glass_button_secondary');
    });

    testWidgets('glass button loading', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: GlassButton(
            label: 'Loading',
            onPressed: () {},
            isLoading: true,
          ),
        ),
        size: const Size(300, 150),
      );

      await expectGoldenMatches(tester, 'glass_button_loading');
    });

    testWidgets('button row layout', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlassButton(
                label: 'Share',
                onPressed: () {},
                isPrimary: false,
                icon: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 16),
              GlassButton(
                label: 'Next',
                onPressed: () {},
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
        size: const Size(400, 150),
      );

      await expectGoldenMatches(tester, 'glass_buttons_row');
    });
  });

  // ==========================================================
  // TRADITION BADGE GOLDEN TESTS
  // ==========================================================
  group('TraditionBadge Golden Tests', () {
    testWidgets('all tradition badges', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TraditionBadge(tradition: Tradition.advaita),
              SizedBox(height: 12),
              TraditionBadge(tradition: Tradition.zen),
              SizedBox(height: 12),
              TraditionBadge(tradition: Tradition.direct),
              SizedBox(height: 12),
              TraditionBadge(tradition: Tradition.contemporary),
              SizedBox(height: 12),
              TraditionBadge(tradition: Tradition.original),
            ],
          ),
        ),
        size: const Size(300, 400),
      );

      await expectGoldenMatches(tester, 'tradition_badges_all');
    });

    testWidgets('advaita badge', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: const TraditionBadge(tradition: Tradition.advaita),
        ),
        size: const Size(300, 100),
      );

      await expectGoldenMatches(tester, 'tradition_badge_advaita');
    });

    testWidgets('zen badge', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          child: const TraditionBadge(tradition: Tradition.zen),
        ),
        size: const Size(300, 100),
      );

      await expectGoldenMatches(tester, 'tradition_badge_zen');
    });
  });

  // ==========================================================
  // ANIMATED GRADIENT GOLDEN TESTS
  // ==========================================================
  group('AnimatedGradient Golden Tests', () {
    testWidgets('gradient background static', (tester) async {
      await pumpForGolden(
        tester,
        createComponentTestWrapper(
          backgroundColor: Colors.black,
          child: const SizedBox(
            width: 400,
            height: 800,
            child: AnimatedGradient(),
          ),
        ),
        size: const Size(400, 800),
      );

      await expectGoldenMatches(tester, 'animated_gradient_static');
    });
  });
}
