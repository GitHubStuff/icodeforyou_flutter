// plugins/island_control_ios/test/island_control_ios_method_channel_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_control_ios/island_control_ios_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MethodChannelIslandControlIos', () {
    const channel = MethodChannel('island_control_ios');

    late MethodChannelIslandControlIos platform;
    late List<MethodCall> calls;

    setUp(() {
      platform = MethodChannelIslandControlIos();
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

    test('uses the island_control_ios channel', () {
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
