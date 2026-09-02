// packages/prism_bubble_widget/test/src/shader_load_exception_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_bubble_widget/src/shader_load_exception.dart';

void main() {
  group('ShaderLoadException', () {
    test('stores message and formats toString correctly', () {
      const errorMessage = 'Failed to load asset at path/to/shader.frag';
      final exception = ShaderLoadException(errorMessage);

      expect(exception.message, equals(errorMessage));
      expect(
        exception.toString(),
        equals('ShaderLoadException: $errorMessage'),
      );
      expect(exception, isA<Exception>());
    });
  });
}
