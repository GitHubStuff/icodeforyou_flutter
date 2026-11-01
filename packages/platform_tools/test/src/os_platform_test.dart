// packages/platform_tools/test/src/os_platform_test.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/src/os_platform.dart';

void main() {
  group('OSPlatform', () {
    tearDown(OSPlatform.override);

    test('resolves runtime platform when no override is set', () {
      final expected = switch (defaultTargetPlatform) {
        TargetPlatform.android => OSPlatform.android,
        TargetPlatform.fuchsia => OSPlatform.fuchsia,
        TargetPlatform.iOS => OSPlatform.iOS,
        TargetPlatform.linux => OSPlatform.linux,
        TargetPlatform.macOS => OSPlatform.macOS,
        TargetPlatform.windows => OSPlatform.windows,
      };

      expect(OSPlatform.current, equals(expected));
    });

    test('override takes precedence over runtime platform', () {
      for (final platform in OSPlatform.values) {
        OSPlatform.override(to: platform);
        expect(OSPlatform.current, equals(platform));
      }
    });

    test('clearing override restores default platform resolution', () {
      OSPlatform.override(to: OSPlatform.fuchsia);
      expect(OSPlatform.current, equals(OSPlatform.fuchsia));

      OSPlatform.override();

      final expected = switch (defaultTargetPlatform) {
        TargetPlatform.android => OSPlatform.android,
        TargetPlatform.fuchsia => OSPlatform.fuchsia,
        TargetPlatform.iOS => OSPlatform.iOS,
        TargetPlatform.linux => OSPlatform.linux,
        TargetPlatform.macOS => OSPlatform.macOS,
        TargetPlatform.windows => OSPlatform.windows,
      };

      expect(OSPlatform.current, equals(expected));
    });

    group('isMobile', () {
      test('returns true for android and iOS', () {
        OSPlatform.override(to: OSPlatform.android);
        expect(OSPlatform.isMobile(), isTrue);

        OSPlatform.override(to: OSPlatform.iOS);
        expect(OSPlatform.isMobile(), isTrue);
      });

      test('returns false for desktop platforms, fuchsia, and web', () {
        const nonMobilePlatforms = [
          OSPlatform.fuchsia,
          OSPlatform.linux,
          OSPlatform.macOS,
          OSPlatform.web,
          OSPlatform.windows,
        ];

        for (final platform in nonMobilePlatforms) {
          OSPlatform.override(to: platform);
          expect(OSPlatform.isMobile(), isFalse);
        }
      });
    });

    test('exercises all TargetPlatform switch cases via debugDefaultTargetPlatformOverride', () {
      const mappings = {
        TargetPlatform.android: OSPlatform.android,
        TargetPlatform.fuchsia: OSPlatform.fuchsia,
        TargetPlatform.iOS: OSPlatform.iOS,
        TargetPlatform.linux: OSPlatform.linux,
        TargetPlatform.macOS: OSPlatform.macOS,
        TargetPlatform.windows: OSPlatform.windows,
      };

      for (final entry in mappings.entries) {
        debugDefaultTargetPlatformOverride = entry.key;
        expect(OSPlatform.current, equals(entry.value));
      }

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
