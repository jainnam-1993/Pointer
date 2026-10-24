import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('home_widget');

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('iOS cold-start widget URL is read after the App Group is set', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    String? group;
    // Mirrors the native plugin: without an App Group it fails with code -7.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'setAppGroupId':
          group = (call.arguments as Map)['groupId'] as String?;
          return true;
        case 'initiallyLaunchedFromHomeWidget':
          if (group == null) throw PlatformException(code: '-7', message: 'AppGroupId not set. Call setAppGroupId first');
          return 'dailypointer://pointing/ori-308';
      }
      return null;
    });

    final uri = await WidgetService.initialLaunchUri();
    expect(group, WidgetService.iosAppGroup);
    expect(uri?.pathSegments.single, 'ori-308');
  });
}
