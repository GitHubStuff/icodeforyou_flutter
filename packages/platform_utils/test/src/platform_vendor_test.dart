// packages/platform_utils/test/src/platform_vendor_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/src/app_platform.dart' show AppPlatform;
import 'package:platform_utils/src/platform_vendor.dart'
    show PlatformVendor;

void main() {
  tearDown(AppPlatform.setPlatform);

  group('PlatformVendor.current', () {
    test('google owns android and fuchsia', () {
      for (final platform in [AppPlatform.android, AppPlatform.fuchsia]) {
        AppPlatform.setPlatform(to: platform);
        expect(PlatformVendor.current(), PlatformVendor.google);
      }
    });

    test('apple owns iOS and macOS', () {
      for (final platform in [AppPlatform.iOS, AppPlatform.macOS]) {
        AppPlatform.setPlatform(to: platform);
        expect(PlatformVendor.current(), PlatformVendor.apple);
      }
    });

    test('microsoft owns windows', () {
      AppPlatform.setPlatform(to: AppPlatform.windows);
      expect(PlatformVendor.current(), PlatformVendor.microsoft);
    });

    test('linux and web have no single controlling vendor', () {
      for (final platform in [AppPlatform.linux, AppPlatform.web]) {
        AppPlatform.setPlatform(to: platform);
        expect(PlatformVendor.current(), PlatformVendor.other);
      }
    });

    test('follows the AppPlatform override — one source of truth', () {
      AppPlatform.setPlatform(to: AppPlatform.iOS);
      expect(PlatformVendor.current(), PlatformVendor.apple);

      AppPlatform.setPlatform(to: AppPlatform.android);
      expect(PlatformVendor.current(), PlatformVendor.google);
    });
  });
}
