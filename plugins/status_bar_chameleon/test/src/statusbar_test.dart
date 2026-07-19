// status_bar_chameleon/test/src/statusbar_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:status_bar_chameleon/src/status_bar_chameleon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('status_bar_chameleon/status_bar');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'setStatusBarHidden forwards the flag over the platform channel',
    () async {
      await StatusBarChameleon.setStatusBarHidden(hidden: true);
      await StatusBarChameleon.setStatusBarHidden(hidden: false);

      expect(calls, hasLength(2));
      expect(
        calls.map((call) => call.method),
        everyElement(equals('setStatusBarHidden')),
      );
      // The two calls must carry distinct arguments — otherwise hide and show
      // are indistinguishable on the native side.
      expect(calls.first.arguments, isNot(calls.last.arguments));
    },
  );
}
