/**
 * Display-time typographic polish. The JSON and Markdown sources keep plain
 * ASCII punctuation; text is set with curly quotes and real dashes only when shown.
 */
library;

final RegExp _doubleDash = RegExp(r'(?<!-)--(?!-)');
final RegExp _spacedHyphen = RegExp(r'(?<=\S) - (?=\S)');
final RegExp _numericRange = RegExp(r'(?<=\d)-(?=\d)');
final RegExp _openingContext = RegExp(r'[\s(\[{—–"“‘]');

/**
 * Returns [text] with typographer's punctuation:
 * - `--` becomes an em dash, a spaced ` - ` becomes a spaced en dash, `3-5` becomes `3–5`;
 * - straight double quotes become “ and ”, and straight single quotes become ‘ and ’
 *   (an apostrophe inside or at the end of a word is always ’).
 *
 * Lines that are only dashes or asterisks (Markdown rules) are left alone, and
 * runs of three or more hyphens are never touched. Pure and idempotent.
 */
String smartPunctuation(String text) {
  if (text.isEmpty) return text;
  final lines = text.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (RegExp(r'^\s*([-*_]\s*){3,}$').hasMatch(line)) continue;
    lines[i] = _quotes(line.replaceAll(_doubleDash, '—').replaceAll(_spacedHyphen, ' – ').replaceAll(_numericRange, '–'));
  }
  return lines.join('\n');
}

String _quotes(String line) {
  final out = StringBuffer();
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (ch != '"' && ch != "'") {
      out.write(ch);
      continue;
    }
    final prev = i == 0 ? null : line[i - 1];
    final opening = prev == null || _openingContext.hasMatch(prev);
    if (ch == '"') {
      out.write(opening ? '“' : '”');
    } else {
      out.write(opening ? '‘' : '’');
    }
  }
  return out.toString();
}
