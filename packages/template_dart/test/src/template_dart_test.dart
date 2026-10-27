// packages/template_dart/test/src/template_dart_base_test.dart

import 'package:template_dart/template_dart.dart' show TemplateDart;
import 'package:test/test.dart';

void main() {
  group('TemplateDart', () {
    test('can be instantiated', () {
      expect(TemplateDart(), isA<TemplateDart>());
    });

    group('isAwesome', () {
      test('returns true', () {
        expect(TemplateDart().isAwesome, isTrue);
      });
    });
  });
}
