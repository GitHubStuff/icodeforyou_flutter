// plugins/status_bar_chameleon/test/status_bar_chameleon_test.dart

// ignore_for_file: avoid_types_on_closure_parameters

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_chameleon/status_bar_chameleon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'status_bar_chameleon/status_bar',
  );

  final List<MethodCall> log = <MethodCall>[];

  void mockHandler() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          log.add(call);
          return null;
        });
  }

  setUp(mockHandler);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    log.clear();
    debugDefaultTargetPlatformOverride = null;
  });

  group('StatusBarChameleon', () {
    test('invokes channel and flips isHidden true on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await StatusBarChameleon.setStatusBarHidden(
        hidden: true,
        duration: const Duration(milliseconds: 250),
      );

      expect(StatusBarChameleon.isHidden, isTrue);
      expect(log, hasLength(1));
      expect(log.single.method, 'setStatusBarHidden');
      expect(
        log.single.arguments,
        <String, Object?>{'hidden': true, 'durationMs': 250},
      );
    });

    test('invokes channel and flips isHidden false on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      await StatusBarChameleon.setStatusBarHidden(hidden: false);

      expect(StatusBarChameleon.isHidden, isFalse);
      expect(log, hasLength(1));
      expect(log.single.method, 'setStatusBarHidden');
      expect(
        log.single.arguments,
        <String, Object?>{'hidden': false, 'durationMs': 0},
      );
    });

    test('defaults duration to zero milliseconds', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await StatusBarChameleon.setStatusBarHidden(hidden: true);

      expect(
        (log.single.arguments as Map<Object?, Object?>)['durationMs'],
        0,
      );
    });

    test('no-ops on unsupported platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      await StatusBarChameleon.setStatusBarHidden(hidden: true);

      expect(log, isEmpty);
    });
  });
}
