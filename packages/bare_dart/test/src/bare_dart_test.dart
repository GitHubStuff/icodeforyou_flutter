// packages/bare_dart/test/bare_dart_base_test.dart

import 'package:bare_dart/bare_dart.dart';
import 'package:test/test.dart';

void main() {
  group('BareDart', () {
    late BareDart awesome;

    setUp(() {
      awesome = BareDart();
    });

    test('can be instantiated', () {
      expect(awesome, isA<BareDart>());
    });

    test('isAwesome returns true', () {
      expect(awesome.isAwesome, isTrue);
    });
  });
}
