// text_handling_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('TextHandling', () {
    test('has trunc value', () {
      expect(TextHandling.trunc, isNotNull);
      expect(TextHandling.trunc.name, equals('trunc'));
    });

    test('has wrap value', () {
      expect(TextHandling.wrap, isNotNull);
      expect(TextHandling.wrap.name, equals('wrap'));
    });

    test('values contains both options', () {
      expect(TextHandling.values, hasLength(2));
      expect(TextHandling.values, contains(TextHandling.trunc));
      expect(TextHandling.values, contains(TextHandling.wrap));
    });

    test('trunc has index 0', () {
      expect(TextHandling.trunc.index, equals(0));
    });

    test('wrap has index 1', () {
      expect(TextHandling.wrap.index, equals(1));
    });
  });
}
