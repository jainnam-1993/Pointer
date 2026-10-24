import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/utils/typography.dart';

void main() {
  group('smartPunctuation', () {
    test('curls double quotes', () {
      expect(smartPunctuation('He said "look" now.'), 'He said “look” now.');
      expect(smartPunctuation('"Who am I?"'), '“Who am I?”');
    });

    test('apostrophes inside and at the end of words are right single quotes', () {
      expect(smartPunctuation("Don't answer. It's here."), 'Don’t answer. It’s here.');
      expect(smartPunctuation("the teachers' words"), 'the teachers’ words');
    });

    test('opening single quotes after a space or bracket', () {
      expect(smartPunctuation("the sense 'I am'"), 'the sense ‘I am’');
      expect(smartPunctuation("('this')"), '(‘this’)');
    });

    test('nested quotes open after an opening double quote', () {
      expect(smartPunctuation('"Watch the sense \'I am\'."'), '“Watch the sense ‘I am’.”');
    });

    test('dashes', () {
      expect(smartPunctuation('not this--not that'), 'not this—not that');
      expect(smartPunctuation('look - just look'), 'look – just look');
      expect(smartPunctuation('pages 3-5'), 'pages 3–5');
      expect(smartPunctuation('non-dual'), 'non-dual');
    });

    test('leaves Markdown rules, list markers and long hyphen runs alone', () {
      expect(smartPunctuation('---'), '---');
      expect(smartPunctuation('* * *'), '* * *');
      expect(smartPunctuation('- item one'), '- item one');
      expect(smartPunctuation('a ---- b'), 'a ---- b');
    });

    test('is idempotent and keeps line structure', () {
      const source = '# Title\n\n"Quote" -- here\nNext line';
      final once = smartPunctuation(source);
      expect(smartPunctuation(once), once);
      expect(once.split('\n').length, source.split('\n').length);
    });

    test('empty input', () => expect(smartPunctuation(''), ''));
  });
}
