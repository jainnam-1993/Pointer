import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/data/pointings.dart';
import 'package:pointer/services/widget_service.dart';

void main() {
  final a = Pointing(id: 'a-1', content: 'Look.', tradition: Tradition.values.first, contexts: []);
  final b = Pointing(id: 'b-1', content: 'Who is aware?', tradition: Tradition.values.first, contexts: []);

  test('signature is stable for the same content and favorites', () {
    expect(widgetCacheSignature([a, b], '["a-1"]'), widgetCacheSignature([a, b], '["a-1"]'));
  });

  test('signature changes when favorites or content change', () {
    final base = widgetCacheSignature([a, b], '["a-1"]');
    expect(widgetCacheSignature([a, b], '["a-1","b-1"]'), isNot(base));
    expect(widgetCacheSignature([a], '["a-1"]'), isNot(base));
    expect(widgetCacheSignature([a, b], null), isNot(base));
  });

  test('parsePointingsJson decodes the bundled shape', () {
    final list = parsePointingsJson('[{"id":"x","content":"c","tradition":"${Tradition.values.first.name}","contexts":[]}]');
    expect(list.single.id, 'x');
  });
}
