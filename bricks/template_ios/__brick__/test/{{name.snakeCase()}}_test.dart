// plugins/{{name.snakeCase()}}/test/{{name.snakeCase()}}_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}_platform_interface.dart';
import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class Mock{{name.pascalCase()}}Platform
    with MockPlatformInterfaceMixin
    implements {{name.pascalCase()}}Platform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final {{name.pascalCase()}}Platform initialPlatform = {{name.pascalCase()}}Platform.instance;

  test('$MethodChannel{{name.pascalCase()}} is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannel{{name.pascalCase()}}>());
  });

  test('getPlatformVersion', () async {
    {{name.pascalCase()}} {{name.camelCase()}}Plugin = {{name.pascalCase()}}();
    Mock{{name.pascalCase()}}Platform fakePlatform = Mock{{name.pascalCase()}}Platform();
    {{name.pascalCase()}}Platform.instance = fakePlatform;

    expect(await {{name.camelCase()}}Plugin.getPlatformVersion(), '42');
  });
}
