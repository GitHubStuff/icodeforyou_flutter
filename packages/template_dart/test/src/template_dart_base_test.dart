// packages/template_dart/test/src/template_dart_base_test.dart

import 'package:template_dart/template_dart.dart';
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
