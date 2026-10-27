// packages/platform_utils/test/src/app_platform_test.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;

void main() {
  tearDown(() {
    OSPlatform.override();
    debugDefaultTargetPlatformOverride = null;
  });

  group('AppPlatform.current', () {
    test('honors the setPlatform override for every value', () {
      for (final platform in OSPlatform.values) {
        OSPlatform.override(to: platform);
        expect(OSPlatform.current, platform);
      }
    });

    test('setPlatform with no argument clears the override', () {
      OSPlatform.override(to: OSPlatform.iOS);
      OSPlatform.override();

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(OSPlatform.current, OSPlatform.windows);
    });

    test('maps every TargetPlatform to its AppPlatform', () {
      const mapping = {
        TargetPlatform.android: OSPlatform.android,
        TargetPlatform.fuchsia: OSPlatform.fuchsia,
        TargetPlatform.iOS: OSPlatform.iOS,
        TargetPlatform.linux: OSPlatform.linux,
        TargetPlatform.macOS: OSPlatform.macOS,
        TargetPlatform.windows: OSPlatform.windows,
      };
      for (final entry in mapping.entries) {
        debugDefaultTargetPlatformOverride = entry.key;
        expect(OSPlatform.current, entry.value);
      }
    });
  });
}
