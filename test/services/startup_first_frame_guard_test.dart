/**
 * Guards cold start: everything awaited before `runApp()` delays the first frame,
 * and the cold_start regress check (lab.sh regress, limit 1500 ms) measures exactly that.
 *
 * The test reads the startup source and lists every `await` on the path to
 * `runApp()`: the body of `main()` before `runApp(`, [AppInitializer.initialize],
 * and its `_initCore` helper. Each awaited call must be on the allowlist below.
 * Work the first frame does not need belongs in [AppInitializer.startAfterFirstFrame].
 */
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/**
 * Awaited calls allowed before the first frame, with the reason each is needed there.
 */
const _allowedAwaits = <String, String>{
  // main(): the bootstrap itself.
  'AppInitializer.initialize': 'creates the provider container runApp() needs',
  // AppInitializer.initialize(): the one platform read the first frame depends on.
  '_initCore': 'loads SharedPreferences',
  // _initCore(): onboarding redirect, theme mode and contrast are read from prefs while building the first frame.
  'SharedPreferences.getInstance': 'the first frame reads onboarding, theme and contrast settings from it',
};

/** Calls that must not start before runApp(); they belong after the first frame. */
const _deferred = ['startBackgroundInitialization', 'tipPurchaseListenerProvider'];

String _read(String path) => File(path).readAsStringSync();

/** Body of the first block starting at [signature], by brace matching. */
String _body(String source, String signature) {
  final start = source.indexOf(signature);
  if (start < 0) throw StateError('startup source no longer contains "$signature"; update this guard');
  // The body brace follows the parameter list, which may itself hold `{named}` parameters.
  final open = RegExp(r'\)\s*(async\s*)?\{').firstMatch(source.substring(start))!.end - 1 + start;
  var depth = 0;
  for (var i = open; i < source.length; i++) {
    if (source[i] == '{') depth++;
    if (source[i] == '}' && --depth == 0) return source.substring(open + 1, i);
  }
  throw StateError('unbalanced braces after "$signature"');
}

/** Strip line comments so prose mentioning await or runApp does not count. */
String _code(String body) => body.split('\n').map((l) => l.replaceFirst(RegExp(r'//.*$'), '')).join('\n');

/** Callee of every `await` in [code], e.g. `AppInitializer.initialize`. */
List<String> _awaited(String code) =>
    RegExp(r'await\s+([A-Za-z_][\w.]*)').allMatches(code).map((m) => m.group(1)!).toList();

void main() {
  final mainSource = _read('lib/main.dart');
  final initSource = _read('lib/services/app_initializer.dart');

  final mainBody = _code(_body(mainSource, 'void main() async'));
  final runApp = mainBody.indexOf('runApp(');
  final beforeRunApp = runApp < 0 ? mainBody : mainBody.substring(0, runApp);
  final initialize = _code(_body(initSource, 'static Future<InitResult> initialize('));
  final initCore = _code(_body(initSource, 'static Future<SharedPreferences> _initCore('));

  final paths = {'main() before runApp()': beforeRunApp, 'AppInitializer.initialize()': initialize, 'AppInitializer._initCore()': initCore};

  test('main() calls runApp()', () {
    expect(runApp, isNonNegative);
  });

  for (final MapEntry(key: where, value: code) in paths.entries) {
    test('$where awaits only allowlisted work', () {
      final extra = _awaited(code).where((c) => !_allowedAwaits.containsKey(c)).toList();
      expect(
        extra,
        isEmpty,
        reason:
            '$where awaits $extra before the first frame. Move it to AppInitializer.startAfterFirstFrame, '
            'make it lazy, or add it to _allowedAwaits with the reason the first frame needs it.',
      );
    });

    test('$where does not start deferred work', () {
      final early = _deferred.where(code.contains).toList();
      expect(early, isEmpty, reason: '$where starts $early before runApp(); it belongs in AppInitializer.startAfterFirstFrame.');
    });
  }

  test('main() schedules the deferred work after runApp()', () {
    expect(mainBody.substring(runApp), contains('AppInitializer.startAfterFirstFrame('));
  });
}
