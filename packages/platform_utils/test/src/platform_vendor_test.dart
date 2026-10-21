// packages/platform_utils/test/src/platform_vendor_test.dart

import 'package:flutter_test/flutter_test.dart';
import '../../../platform_tools/lib/src/os_platform.dart' show OSPlatform;
import 'package:platform_utils/src/platform_vendor.dart' show PlatformVendor;

void main() {
  tearDown(OSPlatform.override);

  group('PlatformVendor.current', () {
    test('google owns android and fuchsia', () {
      for (final platform in [OSPlatform.android, OSPlatform.fuchsia]) {
        OSPlatform.override(to: platform);
        expect(PlatformVendor.current(), PlatformVendor.google);
      }
    });

    test('apple owns iOS and macOS', () {
      for (final platform in [OSPlatform.iOS, OSPlatform.macOS]) {
        OSPlatform.override(to: platform);
        expect(PlatformVendor.current(), PlatformVendor.apple);
      }
    });

    test('microsoft owns windows', () {
      OSPlatform.override(to: OSPlatform.windows);
      expect(PlatformVendor.current(), PlatformVendor.microsoft);
    });

    test('linux and web have no single controlling vendor', () {
      for (final platform in [OSPlatform.linux, OSPlatform.web]) {
        OSPlatform.override(to: platform);
        expect(PlatformVendor.current(), PlatformVendor.other);
      }
    });

    test('follows the AppPlatform override — one source of truth', () {
      OSPlatform.override(to: OSPlatform.iOS);
      expect(PlatformVendor.current(), PlatformVendor.apple);

      OSPlatform.override(to: OSPlatform.android);
      expect(PlatformVendor.current(), PlatformVendor.google);
    });
  });
}
