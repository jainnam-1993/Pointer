import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';

void main() {
  group('Pointings Data', () {
    test('has all traditions', () {
      expect(Tradition.values.length, 5);
      expect(Tradition.values, contains(Tradition.advaita));
      expect(Tradition.values, contains(Tradition.zen));
      expect(Tradition.values, contains(Tradition.direct));
      expect(Tradition.values, contains(Tradition.contemporary));
      expect(Tradition.values, contains(Tradition.original));
    });

    test('has pointings for each tradition', () {
      for (final tradition in Tradition.values) {
        final traditionPointings = getPointingsByTradition(tradition);
        expect(traditionPointings.isNotEmpty, true,
            reason: '${tradition.name} should have pointings');
      }
    });

    test('getRandomPointing returns valid pointing', () {
      final pointing = getRandomPointing();
      expect(pointing.id, isNotEmpty);
      expect(pointing.content, isNotEmpty);
      expect(Tradition.values, contains(pointing.tradition));
    });

    test('traditions map has all traditions', () {
      expect(traditions.length, 5);
      for (final tradition in Tradition.values) {
        expect(traditions.containsKey(tradition), true,
            reason: '${tradition.name} should be in traditions map');
      }
    });
  });
}
