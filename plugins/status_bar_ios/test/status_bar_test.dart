// test/status_bar_ios_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:status_bar_ios/src/status_bar.dart' show StatusBar;
import 'package:status_bar_ios/src/status_bar_ios_platform_interface.dart'
    show StatusBarIosPlatform;

class MockStatusBarIosPlatform extends StatusBarIosPlatform
    with MockPlatformInterfaceMixin {
  bool? lastIsHiddenValue;
  int callCount = 0;

  @override
  Future<void> setVisibility({required bool isHidden}) async {
    callCount++;
    lastIsHiddenValue = isHidden;
  }
}

void main() {
  late MockStatusBarIosPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockStatusBarIosPlatform();
    StatusBarIosPlatform.instance = mockPlatform;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('StatusBar.setVisibility', () {
    test('calls platform interface when running on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await StatusBar.setVisibility(isHidden: true);
      expect(mockPlatform.callCount, 1);
      expect(mockPlatform.lastIsHiddenValue, isTrue);

      await StatusBar.setVisibility(isHidden: false);
      expect(mockPlatform.callCount, 2);
      expect(mockPlatform.lastIsHiddenValue, isFalse);
    });

    test('is a no-op on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await StatusBar.setVisibility(isHidden: true);

      expect(mockPlatform.callCount, 0);
      expect(mockPlatform.lastIsHiddenValue, isNull);
    });

    test('is a no-op on macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await StatusBar.setVisibility(isHidden: true);

      expect(mockPlatform.callCount, 0);
      expect(mockPlatform.lastIsHiddenValue, isNull);
    });
  });
}
