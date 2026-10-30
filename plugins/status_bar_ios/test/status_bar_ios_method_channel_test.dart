// plugins/status_bar_ios/test/status_bar_ios_method_channel_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_ios/src/status_bar_ios_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelStatusBarIos', () {
    const channel = MethodChannel('status_bar_ios');

    late MethodChannelStatusBarIos platform;
    late List<MethodCall> calls;

    setUp(() {
      platform = MethodChannelStatusBarIos();
      calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('uses the status_bar_ios channel', () {
      expect(platform.methodChannel, channel);
    });

    test(
      'setStatusBar(isHidden: true) invokes setStatusBar with isHidden true',
      () async {
        await platform.setVisibility(isHidden: true);

        expect(calls, hasLength(1));
        expect(calls.single.method, 'setStatusBar');
        expect(calls.single.arguments, <String, Object>{'isHidden': true});
      },
    );

    test(
      'setStatusBar(isHidden: false) invokes setStatusBar with isHidden false',
      () async {
        await platform.setVisibility(isHidden: false);

        expect(calls, hasLength(1));
        expect(calls.single.method, 'setStatusBar');
        expect(calls.single.arguments, <String, Object>{'isHidden': false});
      },
    );
  });
}
