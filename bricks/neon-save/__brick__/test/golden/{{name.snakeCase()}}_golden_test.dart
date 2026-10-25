// packages/{{name.snakeCase()}}/test/golden/{{name.snakeCase()}}_golden_test.dart

import 'package:test/test.dart';
import '../../lib/{{name.snakeCase()}}.dart' show {{name.pascalCase()}};

void main() {
  group({{name.pascalCase()}}, () {
    test('can be instantiated', () =>
      expect({{name.pascalCase()}}(), isNotNull)
    );
  });
}
