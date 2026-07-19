// plugins/status_bar_chameleon/test/src/status_bar_chameleon_test.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_chameleon/src/status_bar_chameleon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'status_bar_chameleon/status_bar',
  );

  late List<MethodCall> recordedCalls;

  setUp(() {
    recordedCalls = <MethodCall>[];
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          recordedCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('StatusBarChameleon.setStatusBarHidden', () {
    test('invokes the channel with hidden and durationMs on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await StatusBarChameleon.setStatusBarHidden(
        hidden: true,
        duration: const Duration(milliseconds: 300),
      );

      expect(recordedCalls, hasLength(1));
      expect(recordedCalls.single.method, 'setStatusBarHidden');
      expect(recordedCalls.single.arguments, <String, Object?>{
        'hidden': true,
        'durationMs': 300,
      });
      expect(StatusBarChameleon.isHidden, isTrue);
    });

    test('invokes the channel with default zero duration on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await StatusBarChameleon.setStatusBarHidden(hidden: false);

      expect(recordedCalls, hasLength(1));
      expect(recordedCalls.single.arguments, <String, Object?>{
        'hidden': false,
        'durationMs': 0,
      });
      expect(StatusBarChameleon.isHidden, isFalse);
    });

    test('is a no-op on non-mobile platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await StatusBarChameleon.setStatusBarHidden(hidden: true);
      recordedCalls.clear();

      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      await StatusBarChameleon.setStatusBarHidden(hidden: false);

      expect(recordedCalls, isEmpty);
      // State must be untouched by the early return: still true from the
      // Android call above, not false from the ignored macOS call.
      expect(StatusBarChameleon.isHidden, isTrue);
    });
  });

  group('StatusBarChameleon.isHidden', () {
    test('tracks the last successfully applied value on mobile', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await StatusBarChameleon.setStatusBarHidden(hidden: true);
      expect(StatusBarChameleon.isHidden, isTrue);

      await StatusBarChameleon.setStatusBarHidden(hidden: false);
      expect(StatusBarChameleon.isHidden, isFalse);
    });
  });
}
