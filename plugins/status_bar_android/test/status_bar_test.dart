// plugins/status_bar_android/test/status_bar_test.dart
// Version: 0.0.1-a StatusBarAndroid

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_android/src/status_bar_android_method_channel.dart'
    show MethodChannelStatusBarAndroid;
import 'package:status_bar_android/src/status_bar_android_platform_interface.dart'
    show StatusBarAndroidPlatform;
import 'package:status_bar_android/status_bar_android.dart' show StatusBar;

/// Records every call so the facade's forwarding can be asserted.
///
/// Extends (not merely implements) [StatusBarAndroidPlatform] so the
/// token check in the `instance` setter accepts it.
class _RecordingPlatform extends StatusBarAndroidPlatform {
  _RecordingPlatform({this.error});

  /// When non-null, [setVisibility] completes with this error.
  final Object? error;

  final List<bool> receivedIsHidden = <bool>[];

  @override
  Future<void> setVisibility({required bool isHidden}) {
    receivedIsHidden.add(isHidden);
    final Object? failure = error;
    if (failure != null) {
      return Future<void>.error(failure);
    }
    return Future<void>.value();
  }
}

/// Implements the interface without extending it, so it carries no
/// token and must be rejected by the `instance` setter.
class _ImplementsOnlyPlatform implements StatusBarAndroidPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late StatusBarAndroidPlatform originalInstance;

  setUp(() {
    originalInstance = StatusBarAndroidPlatform.instance;
  });

  tearDown(() {
    StatusBarAndroidPlatform.instance = originalInstance;
  });

  group('StatusBarAndroidPlatform.instance', () {
    test('defaults to the method-channel implementation', () {
      expect(
        StatusBarAndroidPlatform.instance,
        isA<MethodChannelStatusBarAndroid>(),
      );
    });

    test('accepts a subclass', () {
      final platform = _RecordingPlatform();

      StatusBarAndroidPlatform.instance = platform;

      expect(StatusBarAndroidPlatform.instance, same(platform));
    });

    test('rejects an implementation that does not extend the interface', () {
      expect(
        () => StatusBarAndroidPlatform.instance = _ImplementsOnlyPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('StatusBar.setVisibility', () {
    late _RecordingPlatform platform;

    setUp(() {
      platform = _RecordingPlatform();
      StatusBarAndroidPlatform.instance = platform;
    });

    test('defaults to hiding', () async {
      await StatusBar.setVisibility();

      expect(platform.receivedIsHidden, <bool>[true]);
    });

    test('forwards isHidden: true', () async {
      await StatusBar.setVisibility(isHidden: true);

      expect(platform.receivedIsHidden, <bool>[true]);
    });

    test('forwards isHidden: false', () async {
      await StatusBar.setVisibility(isHidden: false);

      expect(platform.receivedIsHidden, <bool>[false]);
    });

    test('propagates a PlatformException from the implementation', () {
      final exception = PlatformException(code: 'NO_ACTIVITY');
      StatusBarAndroidPlatform.instance = _RecordingPlatform(error: exception);

      expect(StatusBar.setVisibility, throwsA(same(exception)));
    });
  });
}
