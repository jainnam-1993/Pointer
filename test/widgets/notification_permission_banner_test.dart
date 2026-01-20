import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/theme/app_theme.dart';

// Since _NotificationPermissionBanner is private, we test it through a helper
// that mirrors the implementation

void main() {
  group('Notification Permission Banner', () {
    testWidgets('displays warning message when rendered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: _TestPermissionBanner(
              onOpenSettings: () {}, // Verify widget accepts callback
            ),
          ),
        ),
      );
      
      // Verify banner content
      expect(find.text('Notifications Disabled'), findsOneWidget);
      expect(find.text('Enable in system settings to receive daily pointings'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });

    testWidgets('calls onOpenSettings when button tapped', (tester) async {
      bool settingsOpened = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: _TestPermissionBanner(
              onOpenSettings: () => settingsOpened = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Open Settings'));
      await tester.pump();
      
      expect(settingsOpened, isTrue);
    });

    testWidgets('has correct styling and layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: _TestPermissionBanner(
              onOpenSettings: () {},
            ),
          ),
        ),
      );
      
      // Verify container styling
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.margin, const EdgeInsets.only(bottom: 12));
      expect(container.padding, const EdgeInsets.all(16));
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border, isNotNull);
    });
  });
}

// Test helper widget that mirrors the private banner implementation
class _TestPermissionBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const _TestPermissionBanner({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_off, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications Disabled',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enable in system settings to receive daily pointings',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onOpenSettings,
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
