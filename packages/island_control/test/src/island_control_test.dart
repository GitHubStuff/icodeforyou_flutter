// packages/island_control/test/src/island_control_test.dart

import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';
import 'package:island_control/island_control.dart' show IslandControl;
import 'package:island_control_android/island_control_android_platform_interface.dart'
    show IslandControlAndroidPlatform;
import 'package:island_control_ios/island_control_ios_platform_interface.dart';
import 'package:platform_tools/platform_tools.dart' show OSPlatform;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakeAndroidPlatform extends IslandControlAndroidPlatform
    with MockPlatformInterfaceMixin {
  final List<bool> hiddenCalls = <bool>[];

  @override
  Future<void> setIsland({required bool isHidden}) async {
    hiddenCalls.add(isHidden);
  }
}

class _FakeIosPlatform extends IslandControlIosPlatform
    with MockPlatformInterfaceMixin {
  final List<bool> hiddenCalls = <bool>[];

  @override
  Future<void> setIsland({required bool isHidden}) async {
    hiddenCalls.add(isHidden);
  }
}

/// Forces both [OSPlatform.current] and the framework's
/// `defaultTargetPlatform` so that the facade *and* the plugin it delegates
/// to agree on where the test is "running".
void _simulate(OSPlatform platform, {TargetPlatform? target}) {
  OSPlatform.override(to: platform);
  debugDefaultTargetPlatformOverride = target;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final initialAndroid = IslandControlAndroidPlatform.instance;
  final initialIos = IslandControlIosPlatform.instance;

  late _FakeAndroidPlatform android;
  late _FakeIosPlatform ios;

  setUp(() {
    android = _FakeAndroidPlatform();
    ios = _FakeIosPlatform();
    IslandControlAndroidPlatform.instance = android;
    IslandControlIosPlatform.instance = ios;
  });

  tearDown(() {
    IslandControlAndroidPlatform.instance = initialAndroid;
    IslandControlIosPlatform.instance = initialIos;
    OSPlatform.override();
    debugDefaultTargetPlatformOverride = null;
  });

  group('IslandControl.isHidden', () {
    // Static state cannot be reset, so this must be the first test that
    // touches IslandControl. Do not reorder.
    test('defaults to false (visible)', () {
      expect(IslandControl.isHidden, isFalse);
    });

    test('reflects the last value passed to setIsland', () {
      _simulate(OSPlatform.linux);

      IslandControl.setIsland(isHidden: true);
      expect(IslandControl.isHidden, isTrue);

      IslandControl.setIsland(isHidden: false);
      expect(IslandControl.isHidden, isFalse);
    });

    test('setIsland with no argument hides', () {
      _simulate(OSPlatform.linux);

      IslandControl.setIsland();

      expect(IslandControl.isHidden, isTrue);
    });
  });

  group('IslandControl.setIsland on Android', () {
    setUp(() {
      _simulate(OSPlatform.android, target: TargetPlatform.android);
    });

    test('delegates hide to IslandControlAndroid', () {
      IslandControl.setIsland(isHidden: true);

      expect(android.hiddenCalls, <bool>[true]);
      expect(ios.hiddenCalls, isEmpty);
      expect(IslandControl.isHidden, isTrue);
    });

    test('delegates show to IslandControlAndroid', () {
      IslandControl.setIsland(isHidden: false);

      expect(android.hiddenCalls, <bool>[false]);
      expect(ios.hiddenCalls, isEmpty);
      expect(IslandControl.isHidden, isFalse);
    });
  });

  group('IslandControl.setIsland on iOS', () {
    setUp(() {
      _simulate(OSPlatform.iOS, target: TargetPlatform.iOS);
    });

    test('delegates hide to IslandControlIos', () {
      IslandControl.setIsland(isHidden: true);

      expect(ios.hiddenCalls, <bool>[true]);
      expect(android.hiddenCalls, isEmpty);
      expect(IslandControl.isHidden, isTrue);
    });

    test('delegates show to IslandControlIos', () {
      IslandControl.setIsland(isHidden: false);

      expect(ios.hiddenCalls, <bool>[false]);
      expect(android.hiddenCalls, isEmpty);
      expect(IslandControl.isHidden, isFalse);
    });
  });

  group('IslandControl.setIsland on unsupported platforms', () {
    for (final platform in <OSPlatform>[
      OSPlatform.fuchsia,
      OSPlatform.linux,
      OSPlatform.macOS,
      OSPlatform.web,
      OSPlatform.windows,
    ]) {
      test('$platform updates isHidden and calls no plugin', () {
        _simulate(platform);

        IslandControl.setIsland(isHidden: true);

        expect(android.hiddenCalls, isEmpty);
        expect(ios.hiddenCalls, isEmpty);
        expect(IslandControl.isHidden, isTrue);
      });
    }
  });
}
