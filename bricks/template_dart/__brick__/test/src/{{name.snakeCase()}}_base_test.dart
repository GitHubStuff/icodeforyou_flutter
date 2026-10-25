// packages/{{name.snakeCase()}}/test/{{name.snakeCase()}}_base_test.dart

import 'package:{{name.snakeCase()}}/{{name.snakeCase()}}.dart';
import 'package:test/test.dart';

void main() {
  group('Awesome', () {
    late Awesome awesome;

    setUp(() {
      awesome = Awesome();
    });

    test('can be instantiated', () {
      expect(awesome, isA<Awesome>());
    });

    test('isAwesome returns true', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}
