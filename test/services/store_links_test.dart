import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointer/providers/providers.dart';
import 'package:pointer/services/share_service.dart';

void main() {
  group('ShareService.storeUrl', () {
    test('iOS shares the App Store listing', () {
      expect(ShareService.storeUrl(TargetPlatform.iOS), 'https://apps.apple.com/app/id6757376352');
    });

    test('Android shares the Play listing for com.dailypointer', () {
      expect(ShareService.storeUrl(TargetPlatform.android), 'https://play.google.com/store/apps/details?id=com.dailypointer');
    });
  });

  test('packageInfoProvider reports the installed version', () async {
    PackageInfo.setMockInitialValues(appName: 'Here Now', packageName: 'com.dailypointer', version: '9.8.7', buildNumber: '42', buildSignature: '');
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final info = await container.read(packageInfoProvider.future);
    expect(info.version, '9.8.7');
    expect(info.buildNumber, '42');
  });
}
