// {{folder_source}}/{{name.snakeCase()}}/test/{{name.snakeCase()}}_test.dart

import 'package:test/test.dart';

import '../../lib/{{name.snakeCase()}}.dart' show {{name.pascalCase()}};

void main() {
  group('{{name.pascalCase()}}', () {
    late {{name.pascalCase()}} {{name.camelCase()}};

    setUp(() {
      {{name.camelCase()}} = {{name.pascalCase()}}();
    });

    test('can be instantiated', () {
      expect({{name.camelCase()}}, isA<{{name.pascalCase()}}>());
    });
  });
}
