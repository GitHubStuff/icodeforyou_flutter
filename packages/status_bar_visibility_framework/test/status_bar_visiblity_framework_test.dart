import 'package:custom_errors/custom_errors.dart' show PluginError;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:status_bar_android/status_bar_android.dart'
    as android
    show StatusBar;

import 'package:status_bar_ios/status_bar_ios.dart' as ios show StatusBar;

import 'package:status_bar_visibility_framework/status_bar_visibility_framework.dart'
    show StatusBarVisibilityFramework;

void main() {
  late StatusBarVisibilityFramework framework;

  setUp(() {
    framework = StatusBarVisibilityFramework();
  });

  tearDown(() {
    OSPlatform.override(to: null);
  });

  group('Initial State', () {
    test('isInitialized returns false prior to any updates', () {
      expect(framework.isInitialized(), isFalse);
    });

    test('isBarHidden returns false prior to any updates', () {
      expect(framework.isBarHidden(), isFalse);
    });
  });

  group('Supported Platforms - Android', () {
    setUp(() {
      OSPlatform.override(to: .android);
    });

    test('successfully sets status bar visibility to hidden', () async {
      final result = await framework.setStatusBarVisibility(isHidden: true);

      expect(result, isTrue);
      expect(framework.isInitialized(), isTrue);
      expect(framework.isBarHidden(), isTrue);
    });

    test('successfully sets status bar visibility to visible', () async {
      final result = await framework.setStatusBarVisibility(isHidden: false);

      expect(result, isTrue);
      expect(framework.isInitialized(), isTrue);
      expect(framework.isBarHidden(), isFalse);
    });

    test('throws PluginError when platform call throws Exception', () async {
      android.StatusBar.setMockException(Exception('Native Android failure'));

      expect(
        () => framework.setStatusBarVisibility(isHidden: true),
        throwsA(
          isA<PluginError>().having(
            (e) => e.message,
            'message',
            contains('StatusBar Visiblity'),
          ),
        ),
      );

      // State must remain unmutated on failure
      expect(framework.isInitialized(), isFalse);
      expect(framework.isBarHidden(), isFalse);
    });
  });

  group('Supported Platforms - iOS', () {
    setUp(() {
      OSPlatform.override(to: .iOS);
    });

    test('successfully sets status bar visibility to hidden', () async {
      final result = await framework.setStatusBarVisibility(isHidden: true);

      expect(result, isTrue);
      expect(framework.isInitialized(), isTrue);
      expect(framework.isBarHidden(), isTrue);
    });

    test('throws PluginError when platform call throws Exception', () async {
      ios.StatusBar.setMockException(Exception('Native iOS failure'));

      expect(
        () => framework.setStatusBarVisibility(isHidden: true),
        throwsA(isA<PluginError>()),
      );

      expect(framework.isInitialized(), isFalse);
      expect(framework.isBarHidden(), isFalse);
    });
  });

  group('Unsupported Platforms', () {
    const unsupportedPlatforms = <OSPlatform>[
      OSPlatform.fuchsia,
      OSPlatform.linux,
      OSPlatform.macOS,
      OSPlatform.web,
      OSPlatform.windows,
    ];

    for (final platform in unsupportedPlatforms) {
      test(
        'returns false and does not update state on ${platform.name}',
        () async {
          OSPlatform.override(to: platform);

          final result = await framework.setStatusBarVisibility(isHidden: true);

          expect(result, isFalse);
          expect(framework.isInitialized(), isFalse);
          expect(framework.isBarHidden(), isFalse);
        },
      );
    }
  });
}
