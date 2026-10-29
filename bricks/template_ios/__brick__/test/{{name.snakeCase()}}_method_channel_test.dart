// plugins/{{name.snakeCase()}}/test/{{name.snakeCase()}}_method_channel_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannel{{name.pascalCase()}} platform = MethodChannel{{name.pascalCase()}}();
  const MethodChannel channel = MethodChannel('{{name.snakeCase()}}');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
