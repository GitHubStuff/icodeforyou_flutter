// packages/platform_utils/test/src/app_platform_test.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_utils/src/app_platform.dart' show AppPlatform;

void main() {
  tearDown(() {
    AppPlatform.setPlatform();
    debugDefaultTargetPlatformOverride = null;
  });

  group('AppPlatform.current', () {
    test('honors the setPlatform override for every value', () {
      for (final platform in AppPlatform.values) {
        AppPlatform.setPlatform(to: platform);
        expect(AppPlatform.current(), platform);
      }
    });

    test('setPlatform with no argument clears the override', () {
      AppPlatform.setPlatform(to: AppPlatform.iOS);
      AppPlatform.setPlatform();

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(AppPlatform.current(), AppPlatform.windows);
    });

    test('maps every TargetPlatform to its AppPlatform', () {
      const mapping = {
        TargetPlatform.android: AppPlatform.android,
        TargetPlatform.fuchsia: AppPlatform.fuchsia,
        TargetPlatform.iOS: AppPlatform.iOS,
        TargetPlatform.linux: AppPlatform.linux,
        TargetPlatform.macOS: AppPlatform.macOS,
        TargetPlatform.windows: AppPlatform.windows,
      };
      for (final entry in mapping.entries) {
        debugDefaultTargetPlatformOverride = entry.key;
        expect(AppPlatform.current(), entry.value);
      }
    });
  });

  group('AppPlatform.isMobile', () {
    test('is true only for android and iOS', () {
      expect(AppPlatform.android.isMobile, isTrue);
      expect(AppPlatform.iOS.isMobile, isTrue);
      expect(AppPlatform.linux.isMobile, isFalse);
      expect(AppPlatform.macOS.isMobile, isFalse);
      expect(AppPlatform.web.isMobile, isFalse);
      expect(AppPlatform.windows.isMobile, isFalse);
    });

    test('throws UnimplementedError for fuchsia', () {
      expect(
        () => AppPlatform.fuchsia.isMobile,
        throwsUnimplementedError,
      );
    });
  });

  group('AppPlatform.isDesktop', () {
    test('is true only for linux, macOS, and windows', () {
      expect(AppPlatform.linux.isDesktop, isTrue);
      expect(AppPlatform.macOS.isDesktop, isTrue);
      expect(AppPlatform.windows.isDesktop, isTrue);
      expect(AppPlatform.android.isDesktop, isFalse);
      expect(AppPlatform.iOS.isDesktop, isFalse);
      expect(AppPlatform.web.isDesktop, isFalse);
    });

    test('throws UnimplementedError for fuchsia', () {
      expect(
        () => AppPlatform.fuchsia.isDesktop,
        throwsUnimplementedError,
      );
    });
  });
}
