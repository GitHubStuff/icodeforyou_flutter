// plugins/{{name.snakeCase()}}/lib/{{name.snakeCase()}}.dart
import '{{name.snakeCase()}}_platform_interface.dart';

class {{name.pascalCase()}} {
  Future<String?> getPlatformVersion() {
    return {{name.pascalCase()}}Platform.instance.getPlatformVersion();
  }
}
