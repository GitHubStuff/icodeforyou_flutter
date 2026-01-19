// test/src/models/pragma_key_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('PragmaKey', () {
    test('has tableInfo value', () {
      expect(PragmaKey.tableInfo, isA<PragmaKey>());
      expect(PragmaKey.tableInfo.name, 'tableInfo');
    });

    test('has indexList value', () {
      expect(PragmaKey.indexList, isA<PragmaKey>());
      expect(PragmaKey.indexList.name, 'indexList');
    });

    test('has foreignKeyList value', () {
      expect(PragmaKey.foreignKeyList, isA<PragmaKey>());
      expect(PragmaKey.foreignKeyList.name, 'foreignKeyList');
    });

    test('has exactly 3 values', () {
      expect(PragmaKey.values.length, 3);
    });

    test('values contains all enum values', () {
      expect(PragmaKey.values, contains(PragmaKey.tableInfo));
      expect(PragmaKey.values, contains(PragmaKey.indexList));
      expect(PragmaKey.values, contains(PragmaKey.foreignKeyList));
    });

    test('values are in expected order', () {
      expect(PragmaKey.values[0], PragmaKey.tableInfo);
      expect(PragmaKey.values[1], PragmaKey.indexList);
      expect(PragmaKey.values[2], PragmaKey.foreignKeyList);
    });

    test('index values are correct', () {
      expect(PragmaKey.tableInfo.index, 0);
      expect(PragmaKey.indexList.index, 1);
      expect(PragmaKey.foreignKeyList.index, 2);
    });
  });
}
