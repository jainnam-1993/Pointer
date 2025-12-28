// Screenshot testing helpers for Flutter integration tests
//
// Provides utilities for capturing screenshots at key user interactions
// and organizing them by feature/flow.
//
// Usage: Import this file in your integration tests for organized screenshot capture

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Screenshot capture configuration
class ScreenshotConfig {
  static const outputDir = 'screenshots';
  static int _screenshotCounter = 0;
  static String _currentFlow = 'default';

  /// Set the current flow name for organizing screenshots
  static void setFlow(String flowName) {
    _currentFlow = flowName.replaceAll(' ', '_').toLowerCase();
    _screenshotCounter = 0;
  }

  /// Generate screenshot filename
  static String getFileName(String stepName) {
    _screenshotCounter++;
    final sanitizedStep = stepName.replaceAll(' ', '_').toLowerCase();
    return '${_currentFlow}/${_screenshotCounter.toString().padLeft(2, '0')}_$sanitizedStep';
  }

  /// Reset counter (call between test groups)
  static void reset() {
    _screenshotCounter = 0;
    _currentFlow = 'default';
  }
}

/// Screenshot capture helper for integration tests
class ScreenshotCapture {
  final IntegrationTestWidgetsFlutterBinding binding;
  final List<ScreenshotRecord> records = [];

  ScreenshotCapture(this.binding);

  /// Capture a screenshot with description
  /// Must be called after tester.pump() for proper rendering
  Future<void> capture(
    WidgetTester tester,
    String stepName, {
    String? description,
  }) async {
    final fileName = ScreenshotConfig.getFileName(stepName);

    try {
      // Prepare surface for screenshot (required on Android)
      await binding.convertFlutterSurfaceToImage();
      // Pump frame after surface conversion
      await tester.pump();
      // Capture screenshot
      await binding.takeScreenshot(fileName);

      records.add(ScreenshotRecord(
        fileName: fileName,
        stepName: stepName,
        description: description,
        timestamp: DateTime.now(),
      ));

      // ignore: avoid_print
      print('📸 Screenshot: $fileName');
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Screenshot failed: $fileName - $e');
    }
  }

  /// Generate HTML report of all captured screenshots
  String generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html><head>');
    buffer
        .writeln('<title>Screenshot Report - ${ScreenshotConfig._currentFlow}</title>');
    buffer.writeln('<style>');
    buffer.writeln(
        'body { font-family: system-ui; max-width: 1200px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #eee; }');
    buffer.writeln('h1 { color: #8b5cf6; }');
    buffer.writeln(
        '.screenshot { margin: 20px 0; padding: 20px; background: #16213e; border-radius: 12px; }');
    buffer.writeln('.screenshot img { max-width: 300px; border-radius: 8px; }');
    buffer.writeln('.screenshot h3 { color: #06b6d4; margin: 0 0 10px 0; }');
    buffer.writeln('.screenshot p { color: #888; margin: 5px 0; }');
    buffer.writeln(
        '.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 20px; }');
    buffer.writeln('</style>');
    buffer.writeln('</head><body>');
    buffer.writeln(
        '<h1>📱 Screenshot Report: ${ScreenshotConfig._currentFlow}</h1>');
    buffer.writeln('<p>Generated: ${DateTime.now()}</p>');
    buffer.writeln('<div class="grid">');

    for (final record in records) {
      buffer.writeln('<div class="screenshot">');
      buffer.writeln('<h3>${record.stepName}</h3>');
      if (record.description != null) {
        buffer.writeln('<p>${record.description}</p>');
      }
      buffer.writeln(
          '<img src="${record.fileName}.png" alt="${record.stepName}">');
      buffer.writeln('<p class="timestamp">${record.timestamp}</p>');
      buffer.writeln('</div>');
    }

    buffer.writeln('</div>');
    buffer.writeln('</body></html>');
    return buffer.toString();
  }
}

/// Record of a captured screenshot
class ScreenshotRecord {
  final String fileName;
  final String stepName;
  final String? description;
  final DateTime timestamp;

  ScreenshotRecord({
    required this.fileName,
    required this.stepName,
    this.description,
    required this.timestamp,
  });
}

/// UX Issue tracker for identifying gaps during testing
class UXIssueTracker {
  static final List<UXIssue> issues = [];

  /// Record a UX issue discovered during testing
  static void record({
    required String title,
    required String description,
    required String screenshotRef,
    UXSeverity severity = UXSeverity.medium,
  }) {
    issues.add(UXIssue(
      title: title,
      description: description,
      screenshotRef: screenshotRef,
      severity: severity,
      timestamp: DateTime.now(),
    ));
    // ignore: avoid_print
    print('🚨 UX Issue [${severity.name}]: $title');
  }

  /// Generate UX issues report
  static String generateReport() {
    if (issues.isEmpty) return 'No UX issues found.';

    final buffer = StringBuffer();
    buffer.writeln('# UX Issues Report');
    buffer.writeln('Generated: ${DateTime.now()}\n');

    for (final issue in issues) {
      buffer.writeln('## ${issue.severity.emoji} ${issue.title}');
      buffer.writeln('**Severity:** ${issue.severity.name}');
      buffer.writeln('**Screenshot:** ${issue.screenshotRef}');
      buffer.writeln('\n${issue.description}\n');
    }

    return buffer.toString();
  }

  /// Clear all recorded issues
  static void clear() => issues.clear();
}

/// UX Issue record
class UXIssue {
  final String title;
  final String description;
  final String screenshotRef;
  final UXSeverity severity;
  final DateTime timestamp;

  UXIssue({
    required this.title,
    required this.description,
    required this.screenshotRef,
    required this.severity,
    required this.timestamp,
  });
}

/// UX Issue severity levels
enum UXSeverity {
  critical('🔴'),
  high('🟠'),
  medium('🟡'),
  low('🟢');

  final String emoji;
  const UXSeverity(this.emoji);
}
