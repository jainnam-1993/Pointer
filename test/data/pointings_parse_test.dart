import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';

void main() {
  test('parsePointingsJson decodes the bundled shape', () {
    final list = parsePointingsJson('[{"id":"x","content":"c","tradition":"${Tradition.values.first.name}","contexts":[]}]');
    expect(list.single.id, 'x');
  });
}
