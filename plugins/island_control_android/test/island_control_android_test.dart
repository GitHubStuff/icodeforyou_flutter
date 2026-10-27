// plugins/island_control_android/test/island_control_android_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:island_control_android/island_control_android.dart';
import 'package:island_control_android/island_control_android_method_channel.dart';
import 'package:island_control_android/island_control_android_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePlatform extends IslandControlAndroidPlatform
    with MockPlatformInterfaceMixin {
  final List<bool> hiddenCalls = <bool>[];

  @override
  Future<void> setIsland({required bool isHidden}) async {
    hiddenCalls.add(isHidden);
  }
}

class _UnimplementedPlatform extends IslandControlAndroidPlatform {}

class _UnverifiedPlatform implements IslandControlAndroidPlatform {
  @override
  Future<void> setIsland({required bool isHidden}) async {}
}

void main() {
  group('IslandControlAndroidPlatform', () {
    final initialPlatform = IslandControlAndroidPlatform.instance;

    tearDown(() {
      IslandControlAndroidPlatform.instance = initialPlatform;
    });

    test('defaults to MethodChannelIslandControlAndroid', () {
      expect(initialPlatform, isA<MethodChannelIslandControlAndroid>());
    });

    test('accepts a verified instance', () {
      final fake = _FakePlatform();

      IslandControlAndroidPlatform.instance = fake;

      expect(IslandControlAndroidPlatform.instance, same(fake));
    });

    test('rejects an unverified instance', () {
      expect(
        () => IslandControlAndroidPlatform.instance = _UnverifiedPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });

    test('setIsland throws UnimplementedError by default', () {
      expect(
        () => _UnimplementedPlatform().setIsland(isHidden: true),
        throwsUnimplementedError,
      );
    });
  });

  group('IslandControlAndroid', () {
    final initialPlatform = IslandControlAndroidPlatform.instance;
    late _FakePlatform fake;

    setUp(() {
      fake = _FakePlatform();
    });

    tearDown(() {
      IslandControlAndroidPlatform.instance = initialPlatform;
    });

    test('delegates to the injected platform', () async {
      final control = IslandControlAndroid(platform: fake);

      await control.setIsland(isHidden: true);
      await control.setIsland(isHidden: false);

      expect(fake.hiddenCalls, <bool>[true, false]);
    });

    test('defaults to IslandControlAndroidPlatform.instance', () async {
      IslandControlAndroidPlatform.instance = fake;

      await IslandControlAndroid().setIsland(isHidden: true);

      expect(fake.hiddenCalls, <bool>[true]);
    });
  });
}
