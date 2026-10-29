// plugins/{{name.snakeCase()}}/lib/{{name.snakeCase()}}_method_channel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '{{name.snakeCase()}}_platform_interface.dart';

/// An implementation of [{{name.pascalCase()}}Platform] that uses method channels.
class MethodChannel{{name.pascalCase()}} extends {{name.pascalCase()}}Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('{{name.snakeCase()}}');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
