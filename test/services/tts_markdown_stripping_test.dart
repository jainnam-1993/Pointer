import 'package:flutter_test/flutter_test.dart';

/// Test the markdown stripping logic used in TTS
/// This mirrors TTSService._stripMarkdown exactly
String stripMarkdown(String markdown) {
  var text = markdown;

  // Remove headers
  text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

  // Remove images FIRST (before links, since images contain link syntax)
  text = text.replaceAll(RegExp(r'!\[.*?\]\(.+?\)'), '');

  // Remove bold/italic - use replaceAllMapped for capture groups
  text = text.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*'),
    (m) => m.group(1) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'\*(.+?)\*'),
    (m) => m.group(1) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'__(.+?)__'),
    (m) => m.group(1) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'_(.+?)_'),
    (m) => m.group(1) ?? '',
  );

  // Remove links but keep text
  text = text.replaceAllMapped(
    RegExp(r'\[(.+?)\]\(.+?\)'),
    (m) => m.group(1) ?? '',
  );

  // Remove blockquote markers
  text = text.replaceAll(RegExp(r'^>\s*', multiLine: true), '');

  // Remove horizontal rules
  text = text.replaceAll(RegExp(r'^[-*_]{3,}$', multiLine: true), '');

  // Remove code blocks
  text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
  text = text.replaceAllMapped(
    RegExp(r'`(.+?)`'),
    (m) => m.group(1) ?? '',
  );

  // Remove list markers
  text = text.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
  text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

  // Clean up multiple newlines
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

  return text.trim();
}

void main() {
  group('Markdown Stripping for TTS', () {
    test('removes h1 headers', () {
      expect(stripMarkdown('# Hello World'), 'Hello World');
    });

    test('removes h2 headers', () {
      expect(stripMarkdown('## Section Title'), 'Section Title');
    });

    test('removes h3 headers', () {
      expect(stripMarkdown('### Subsection'), 'Subsection');
    });

    test('removes bold formatting with **', () {
      expect(stripMarkdown('This is **bold** text'), 'This is bold text');
    });

    test('removes bold formatting with __', () {
      expect(stripMarkdown('This is __bold__ text'), 'This is bold text');
    });

    test('removes italic formatting with *', () {
      expect(stripMarkdown('This is *italic* text'), 'This is italic text');
    });

    test('removes italic formatting with _', () {
      expect(stripMarkdown('This is _italic_ text'), 'This is italic text');
    });

    test('extracts link text and removes URL', () {
      expect(
        stripMarkdown('Check out [this link](https://example.com)'),
        'Check out this link',
      );
    });

    test('removes images completely', () {
      expect(
        stripMarkdown('Here is an image ![alt text](image.png) in text'),
        'Here is an image  in text',
      );
    });

    test('removes blockquote markers', () {
      expect(stripMarkdown('> This is a quote'), 'This is a quote');
    });

    test('removes horizontal rules', () {
      expect(stripMarkdown('Text\n---\nMore text'), 'Text\n\nMore text');
    });

    test('removes code blocks', () {
      expect(
        stripMarkdown('Before\n```dart\ncode here\n```\nAfter'),
        'Before\n\nAfter',
      );
    });

    test('removes inline code backticks', () {
      expect(
        stripMarkdown('Use the `print()` function'),
        'Use the print() function',
      );
    });

    test('removes unordered list markers with -', () {
      expect(stripMarkdown('- Item one\n- Item two'), 'Item one\nItem two');
    });

    test('removes unordered list markers with *', () {
      expect(stripMarkdown('* Item one\n* Item two'), 'Item one\nItem two');
    });

    test('removes ordered list markers', () {
      expect(stripMarkdown('1. First\n2. Second'), 'First\nSecond');
    });

    test('collapses multiple newlines', () {
      expect(stripMarkdown('Line one\n\n\n\nLine two'), 'Line one\n\nLine two');
    });

    test('handles complex real-world article', () {
      const article = '''
# The Nature of Awareness

## Introduction

This is a **profound** teaching about *awareness*.

> Look within yourself

Key points:
- Point one
- Point two

For more info, see [this link](https://example.com).

## Conclusion

The end.
''';

      final stripped = stripMarkdown(article);

      // Should not contain markdown syntax
      expect(stripped.contains('#'), isFalse);
      expect(stripped.contains('**'), isFalse);
      expect(stripped.contains('*'), isFalse);
      expect(stripped.contains('['), isFalse);
      expect(stripped.contains('>'), isFalse);
      expect(stripped.contains('- '), isFalse);

      // Should contain the actual text
      expect(stripped.contains('The Nature of Awareness'), isTrue);
      expect(stripped.contains('profound'), isTrue);
      expect(stripped.contains('awareness'), isTrue);
      expect(stripped.contains('Look within yourself'), isTrue);
      expect(stripped.contains('Point one'), isTrue);
      expect(stripped.contains('this link'), isTrue);
      expect(stripped.contains('The end'), isTrue);
    });

    test('handles empty string', () {
      expect(stripMarkdown(''), '');
    });

    test('handles plain text with no markdown', () {
      expect(
        stripMarkdown('Just plain text here.'),
        'Just plain text here.',
      );
    });

    test('preserves paragraph structure', () {
      final result = stripMarkdown('First paragraph.\n\nSecond paragraph.');
      expect(result.contains('\n\n'), isTrue);
    });
  });

  group('TTS Text Preparation - Edge Cases', () {
    test('handles nested formatting', () {
      expect(
        stripMarkdown('This is ***bold and italic*** text'),
        'This is bold and italic text',
      );
    });

    test('handles multiple links in one line', () {
      expect(
        stripMarkdown('[Link1](url1) and [Link2](url2)'),
        'Link1 and Link2',
      );
    });

    test('handles mixed content line', () {
      expect(
        stripMarkdown('# **Bold Header** with *italic*'),
        'Bold Header with italic',
      );
    });
  });
}
