// test/src/models/text_handling_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('TextHandling', () {
    test('has exactly two values', () {
      expect(TextHandling.values, hasLength(2));
    });

    test('contains trunc and wrap', () {
      expect(
        TextHandling.values,
        containsAll(<TextHandling>[TextHandling.trunc, TextHandling.wrap]),
      );
    });

    test('values expose .name as expected', () {
      expect(TextHandling.trunc.name, 'trunc');
      expect(TextHandling.wrap.name, 'wrap');
    });
  });
}
