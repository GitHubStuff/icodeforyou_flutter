// packages/{{name.snakeCase()}}/test/{{name.snakeCase()}}_base_test.dart

import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';
import 'package:test/test.dart';

void main() {
  group('{{name.pascalCase()}}', () {
    late {{name.pascalCase()}} awesome;

    setUp(() {
      awesome = {{name.pascalCase()}}();
    });

    test('can be instantiated', () {
      expect(awesome, isA<{{name.pascalCase()}}>());
    });

    test('isAwesome returns true', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}
