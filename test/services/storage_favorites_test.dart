import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<StorageService> withStored(Object? value) async {
    SharedPreferences.setMockInitialValues({if (value != null) 'pointer_favorites': value});
    return StorageService(await SharedPreferences.getInstance());
  }

  group('saved favorites in any shape never throw', () {
    for (final (name, value, expected) in <(String, Object?, List<String>)>[
      ('the JSON array every writer produces', '["adv-1","zen-2"]', ['adv-1', 'zen-2']),
      ('nothing stored', null, []),
      ('an empty value', '', []),
      ('a string instead of a list', '"adv-1"', []),
      ('a JSON object', '{"id":"adv-1"}', []),
      ('text that is not JSON', 'adv-1,zen-2', []),
      ('a list with non-strings', '["adv-1",7,null,{"x":1},"","zen-2"]', ['adv-1', 'zen-2']),
      ('a native string list (setStringList)', <String>['adv-1', 'zen-2'], ['adv-1', 'zen-2']),
      // Seeded on the iOS simulator with PlistBuddy, whose shell stripped the inner quotes;
      // jsonDecode threw "Unexpected character (at character 2)" and Today showed the error screen.
      ('the unquoted array a seed script wrote', '[zen-1,dir-1,con-1,adv-1]', []),
    ]) {
      test(name, () async {
        expect((await withStored(value)).favorites, expected);
      });
    }
  });

  test('the next save rewrites a garbled value as the JSON array', () async {
    SharedPreferences.setMockInitialValues({'pointer_favorites': '["adv-1",7]'});
    final prefs = await SharedPreferences.getInstance();
    await StorageService(prefs).addFavorite('zen-2');
    expect(prefs.getString('pointer_favorites'), '["adv-1","zen-2"]');
  });
}
