import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointer/providers/settings_providers.dart';
import 'package:pointer/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SlowPrefs extends Mock implements SharedPreferences {}

void main() {
  test('rapid setters keep both changes and persist the latest state in order', () async {
    final prefs = _SlowPrefs();
    final writes = <Map<String, dynamic>>[];
    final gates = <Completer<bool>>[];
    when(() => prefs.getString(StorageKeys.settings)).thenReturn(null);
    when(() => prefs.setString(StorageKeys.settings, any())).thenAnswer((inv) {
      writes.add(jsonDecode(inv.positionalArguments[1] as String) as Map<String, dynamic>);
      final gate = Completer<bool>();
      gates.add(gate);
      return gate.future;
    });

    final notifier = SettingsNotifier(StorageService(prefs));
    final a = notifier.setZenMode(true);
    final b = notifier.setAutoAdvance(false);

    // State updates synchronously, so the second setter does not drop the first.
    expect(notifier.state.zenMode, true);
    expect(notifier.state.autoAdvance, false);

    // Writes are serialized: the second waits for the first.
    await Future<void>.delayed(Duration.zero);
    expect(writes, hasLength(1));
    gates[0].complete(true);
    await a;
    await Future<void>.delayed(Duration.zero);
    expect(writes, hasLength(2));
    gates[1].complete(true);
    await b;
    expect(writes.last['zenMode'], true);
    expect(writes.last['autoAdvance'], false);
  });
}
