// packages/{{name.snakeCase()}}/test/{{name.snakeCase()}}_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';

void main() {
  test('adds one to input values', () {
    final calculator = {{name.pascalCase()}}();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });
}
