// plugins/status_bar_android/test/status_bar_android_method_channel_test.dart
// Version: 0.0.1-a StatusBarAndroid

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_android/src/status_bar_android_method_channel.dart'
    show MethodChannelStatusBarAndroid;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MethodChannelStatusBarAndroid platform;
  late List<MethodCall> log;

  /// The native reply for the next call; a [PlatformException] here is
  /// thrown to the Dart caller by the channel.
  Object? nativeReply;

  setUp(() {
    platform = MethodChannelStatusBarAndroid();
    log = <MethodCall>[];
    nativeReply = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.channel, (call) async {
          log.add(call);
          final Object? reply = nativeReply;
          if (reply is PlatformException) {
            throw reply;
          }
          return reply;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platform.channel, null);
  });

  group('MethodChannelStatusBarAndroid', () {
    test('uses the channel name the Kotlin side listens on', () {
      expect(platform.channel.name, 'status_bar_android');
      expect(MethodChannelStatusBarAndroid.channelName, 'status_bar_android');
    });

    test('withChannel uses the supplied channel', () {
      const channel = MethodChannel('custom');

      final custom = MethodChannelStatusBarAndroid.withChannel(channel);

      expect(custom.channel, same(channel));
    });

    test('setVisibility(isHidden: true) sends the expected call', () async {
      await platform.setVisibility(isHidden: true);

      expect(log, hasLength(1));
      expect(log.single.method, 'setVisibility');
      expect(log.single.arguments, <String, Object>{'isHidden': true});
    });

    test('setVisibility(isHidden: false) sends the expected call', () async {
      await platform.setVisibility(isHidden: false);

      expect(log, hasLength(1));
      expect(log.single.method, 'setVisibility');
      expect(log.single.arguments, <String, Object>{'isHidden': false});
    });

    test('propagates a PlatformException raised by the native side', () {
      nativeReply = PlatformException(
        code: 'NO_ACTIVITY',
        message: 'No activity is attached.',
      );

      expect(
        () => platform.setVisibility(isHidden: true),
        throwsA(
          isA<PlatformException>()
              .having((e) => e.code, 'code', 'NO_ACTIVITY')
              .having((e) => e.message, 'message', 'No activity is attached.'),
        ),
      );
    });
  });
}
