// plugins/island_control_ios/test/island_control_ios_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_control_ios/island_control_ios.dart';
import 'package:island_control_ios/island_control_ios_method_channel.dart';
import 'package:island_control_ios/island_control_ios_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakePlatform extends IslandControlIosPlatform
    with MockPlatformInterfaceMixin {
  final List<bool> hiddenCalls = <bool>[];

  @override
  Future<void> setIsland({required bool isHidden}) async {
    hiddenCalls.add(isHidden);
  }
}

class _UnimplementedPlatform extends IslandControlIosPlatform {}

class _UnverifiedPlatform implements IslandControlIosPlatform {
  @override
  Future<void> setIsland({required bool isHidden}) async {}
}

void main() {
  group('IslandControlIosPlatform', () {
    final initialPlatform = IslandControlIosPlatform.instance;

    tearDown(() {
      IslandControlIosPlatform.instance = initialPlatform;
    });

    test('defaults to MethodChannelIslandControlIos', () {
      expect(initialPlatform, isA<MethodChannelIslandControlIos>());
    });

    test('accepts a verified instance', () {
      final fake = _FakePlatform();

      IslandControlIosPlatform.instance = fake;

      expect(IslandControlIosPlatform.instance, same(fake));
    });

    test('rejects an unverified instance', () {
      expect(
        () => IslandControlIosPlatform.instance = _UnverifiedPlatform(),
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

  group('IslandControlIos.setIsland', () {
    final initialPlatform = IslandControlIosPlatform.instance;
    late _FakePlatform fake;

    setUp(() {
      fake = _FakePlatform();
      IslandControlIosPlatform.instance = fake;
    });

    tearDown(() {
      IslandControlIosPlatform.instance = initialPlatform;
      debugDefaultTargetPlatformOverride = null;
    });

    test('delegates to the platform instance on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await IslandControlIos.setIsland(isHidden: true);
      await IslandControlIos.setIsland(isHidden: false);

      expect(fake.hiddenCalls, <bool>[true, false]);
    });

    test('is a no-op on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await IslandControlIos.setIsland(isHidden: true);

      expect(fake.hiddenCalls, isEmpty);
    });

    test('is a no-op on desktop platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await IslandControlIos.setIsland(isHidden: true);

      expect(fake.hiddenCalls, isEmpty);
    });
  });
}
