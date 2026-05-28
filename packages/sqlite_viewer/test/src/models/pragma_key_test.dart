// test/src/models/pragma_key_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

void main() {
  group('PragmaKey', () {
    test('has exactly three values', () {
      expect(PragmaKey.values, hasLength(3));
    });

    test('contains tableInfo, indexList, foreignKeyList', () {
      expect(
        PragmaKey.values,
        containsAll(<PragmaKey>[
          PragmaKey.tableInfo,
          PragmaKey.indexList,
          PragmaKey.foreignKeyList,
        ]),
      );
    });

    test('values expose .name as expected', () {
      expect(PragmaKey.tableInfo.name, 'tableInfo');
      expect(PragmaKey.indexList.name, 'indexList');
      expect(PragmaKey.foreignKeyList.name, 'foreignKeyList');
    });
  });
}
