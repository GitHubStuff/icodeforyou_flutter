// packages/platform_tools/test/src/os_platform_test.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/platform_tools.dart';

void main() {
  group('OSPlatform', () {
    tearDown(() {
      OSPlatform.override();
      debugDefaultTargetPlatformOverride = null;
    });

    group('current', () {
      group('maps defaultTargetPlatform', () {
        const cases = <TargetPlatform, OSPlatform>{
          TargetPlatform.android: OSPlatform.android,
          TargetPlatform.fuchsia: OSPlatform.fuchsia,
          TargetPlatform.iOS: OSPlatform.iOS,
          TargetPlatform.linux: OSPlatform.linux,
          TargetPlatform.macOS: OSPlatform.macOS,
          TargetPlatform.windows: OSPlatform.windows,
        };

        for (final MapEntry(key: target, value: expected) in cases.entries) {
          test('$target to $expected', () {
            debugDefaultTargetPlatformOverride = target;

            expect(OSPlatform.current, expected);
          });
        }

        test('covers every TargetPlatform value', () {
          expect(cases.keys, containsAll(TargetPlatform.values));
        });
      });

      test('returns the override when one is set', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        OSPlatform.override(to: OSPlatform.windows);

        expect(OSPlatform.current, OSPlatform.windows);
      });

      test('override takes precedence for every platform value', () {
        for (final platform in OSPlatform.values) {
          OSPlatform.override(to: platform);

          expect(OSPlatform.current, platform);
        }
      });
    });

    group('override', () {
      test('clears the override when called with no argument', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.linux;
        OSPlatform.override(to: OSPlatform.iOS);
        expect(OSPlatform.current, OSPlatform.iOS);

        OSPlatform.override();

        expect(OSPlatform.current, OSPlatform.linux);
      });

      test('clears the override when called with null', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        OSPlatform.override(to: OSPlatform.android);
        expect(OSPlatform.current, OSPlatform.android);

        OSPlatform.override(to: null);

        expect(OSPlatform.current, OSPlatform.macOS);
      });

      test('replaces a previous override', () {
        OSPlatform.override(to: OSPlatform.android);
        OSPlatform.override(to: OSPlatform.web);

        expect(OSPlatform.current, OSPlatform.web);
      });
    });

    group('values', () {
      test('contains exactly the expected platforms', () {
        expect(
          OSPlatform.values,
          orderedEquals(const [
            OSPlatform.android,
            OSPlatform.fuchsia,
            OSPlatform.iOS,
            OSPlatform.linux,
            OSPlatform.macOS,
            OSPlatform.web,
            OSPlatform.windows,
          ]),
        );
      });

      test('has one value per TargetPlatform plus web', () {
        expect(OSPlatform.values.length, TargetPlatform.values.length + 1);
      });
    });
  });
}
