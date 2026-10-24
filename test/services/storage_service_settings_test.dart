import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/** Builds a [StorageService] whose saved settings hold [raw] verbatim. */
Future<StorageService> serviceWithSavedSettings(String raw) async {
  SharedPreferences.setMockInitialValues({StorageKeys.settings: raw});
  return StorageService(await SharedPreferences.getInstance());
}

void main() {
  group('saved settings that cannot be read as written', () {
    test('malformed JSON gives default settings', () async {
      final service = await serviceWithSavedSettings('{"hapticFeedback": fal');

      final settings = service.settings;

      expect(settings.toJson(), const AppSettings().toJson());
    });

    test('a JSON value that is not an object gives default settings', () async {
      for (final raw in ['[1, 2]', '"dark"', '42', 'null']) {
        final service = await serviceWithSavedSettings(raw);

        expect(service.settings.toJson(), const AppSettings().toJson(), reason: raw);
      }
    });

    test('a wrong-typed field takes its default and the valid fields are kept', () async {
      final service = await serviceWithSavedSettings(
        jsonEncode({'hapticFeedback': 'yes', 'autoAdvanceDelay': '30', 'theme': 'dark', 'zenMode': true}),
      );

      final settings = service.settings;

      expect(settings.hapticFeedback, const AppSettings().hapticFeedback);
      expect(settings.autoAdvanceDelay, const AppSettings().autoAdvanceDelay);
      expect(settings.theme, 'dark');
      expect(settings.zenMode, isTrue);
    });

    test('the bad value is kept on read and replaced by the next save', () async {
      const bad = '{"theme": ';
      final service = await serviceWithSavedSettings(bad);
      final prefs = await SharedPreferences.getInstance();

      final settings = service.settings;
      expect(prefs.getString(StorageKeys.settings), bad);

      await service.updateSettings(settings.copyWith(theme: 'light'));
      expect(service.settings.theme, 'light');
    });
  });
}
