// packages/status_bar_visibility_framework/test/status_bar_visiblity_framework_test.dart
import 'package:custom_errors/custom_errors.dart' show PluginError;
import 'package:flutter_test/flutter_test.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:status_bar_android/src/status_bar_android_platform_interface.dart'
    show StatusBarAndroidPlatform;
import 'package:status_bar_ios/src/status_bar_ios_platform_interface.dart'
    show StatusBarIosPlatform;
import 'package:status_bar_visibility/status_bar_visibility.dart'
    show StatusBarVisibility;

// --- Mock Platform Interfaces ---

class MockStatusBarAndroidPlatform extends StatusBarAndroidPlatform
    with MockPlatformInterfaceMixin {
  bool shouldThrow = false;
  bool? lastSetHidden;

  @override
  Future<void> setVisibility({required bool isHidden}) async {
    if (shouldThrow) {
      throw Exception('Native Android failure');
    }
    lastSetHidden = isHidden;
  }
}

class MockStatusBarIosPlatform extends StatusBarIosPlatform
    with MockPlatformInterfaceMixin {
  bool shouldThrow = false;
  bool? lastSetHidden;

  @override
  Future<void> setVisibility({bool isHidden = true}) async {
    if (shouldThrow) {
      throw Exception('Native iOS failure');
    }
    lastSetHidden = isHidden;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StatusBarVisibility framework;
  late MockStatusBarAndroidPlatform mockAndroidPlatform;
  late MockStatusBarIosPlatform mockIosPlatform;

  setUp(() {
    framework = StatusBarVisibility();

    mockAndroidPlatform = MockStatusBarAndroidPlatform();
    StatusBarAndroidPlatform.instance = mockAndroidPlatform;

    mockIosPlatform = MockStatusBarIosPlatform();
    StatusBarIosPlatform.instance = mockIosPlatform;
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
      expect(mockAndroidPlatform.lastSetHidden, isTrue);
    });

    test('successfully sets status bar visibility to visible', () async {
      final result = await framework.setStatusBarVisibility(isHidden: false);

      expect(result, isTrue);
      expect(framework.isInitialized(), isTrue);
      expect(framework.isBarHidden(), isFalse);
      expect(mockAndroidPlatform.lastSetHidden, isFalse);
    });

    test('throws PluginError when platform call throws Exception', () async {
      mockAndroidPlatform.shouldThrow = true;

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

      // State remains unmutated on failure
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
      expect(mockIosPlatform.lastSetHidden, isTrue);
    });

    test('successfully sets status bar visibility to visible', () async {
      final result = await framework.setStatusBarVisibility(isHidden: false);

      expect(result, isTrue);
      expect(framework.isInitialized(), isTrue);
      expect(framework.isBarHidden(), isFalse);
      expect(mockIosPlatform.lastSetHidden, isFalse);
    });

    test('throws PluginError when platform call throws Exception', () async {
      mockIosPlatform.shouldThrow = true;

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
