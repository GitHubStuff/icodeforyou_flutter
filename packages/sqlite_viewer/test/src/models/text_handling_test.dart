// test/src/models/text_handling_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('TextHandling', () {
    test('has trunc value', () {
      expect(TextHandling.trunc, isA<TextHandling>());
      expect(TextHandling.trunc.name, 'trunc');
    });

    test('has wrap value', () {
      expect(TextHandling.wrap, isA<TextHandling>());
      expect(TextHandling.wrap.name, 'wrap');
    });

    test('has exactly 2 values', () {
      expect(TextHandling.values.length, 2);
    });

    test('values contains all enum values', () {
      expect(TextHandling.values, contains(TextHandling.trunc));
      expect(TextHandling.values, contains(TextHandling.wrap));
    });

    test('values are in expected order', () {
      expect(TextHandling.values[0], TextHandling.trunc);
      expect(TextHandling.values[1], TextHandling.wrap);
    });

    test('index values are correct', () {
      expect(TextHandling.trunc.index, 0);
      expect(TextHandling.wrap.index, 1);
    });
  });
}
