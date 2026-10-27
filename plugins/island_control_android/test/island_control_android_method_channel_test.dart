// plugins/island_control_android/test/island_control_android_method_channel_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_control_android/island_control_android_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelIslandControlAndroid', () {
    const channel = MethodChannel('island_control_android');

    late MethodChannelIslandControlAndroid platform;
    late List<MethodCall> calls;

    setUp(() {
      platform = MethodChannelIslandControlAndroid();
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

    test('uses the island_control_android channel', () {
      expect(platform.methodChannel, channel);
    });

    test(
      'setIsland(isHidden: true) invokes setIsland with isHidden true',
      () async {
        await platform.setIsland(isHidden: true);

        expect(calls, hasLength(1));
        expect(calls.single.method, 'setIsland');
        expect(calls.single.arguments, <String, Object>{'isHidden': true});
      },
    );

    test(
      'setIsland(isHidden: false) invokes setIsland with isHidden false',
      () async {
        await platform.setIsland(isHidden: false);

        expect(calls, hasLength(1));
        expect(calls.single.method, 'setIsland');
        expect(calls.single.arguments, <String, Object>{'isHidden': false});
      },
    );
  });
}
