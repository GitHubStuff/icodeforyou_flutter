// packages/{{name.snakeCase()}}/test/src/{{name.snakeCase()}}_test.dart

import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';
import 'package:test/test.dart';

void main() {
  group(ArcheTypes, () {
    test('can be instantiated', () {
      expect(ArcheTypes(), isNotNull);
    });
  });
}
