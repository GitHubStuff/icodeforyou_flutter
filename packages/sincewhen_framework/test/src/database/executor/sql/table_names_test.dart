// packages/sincewhen_framework/test/src/database/executor/sql/table_names_test.dart
@TestOn('vm')
library;

import 'package:sincewhen_framework/src/sql/table_names.dart';
import 'package:test/test.dart';

void main() {
  group('TableNames', () {
    test('declares exactly three tables in canonical order', () {
      expect(
        TableNames.values,
        orderedEquals(<TableNames>[
          TableNames.sinceWhen,
          TableNames.glossary,
          TableNames.tags,
        ]),
      );
    });

    test('name yields the exact SQL identifier for each table', () {
      // These strings are burned into every DDL statement and query in the
      // framework AND into any existing on-device databases. Changing an
      // enum identifier silently renames the SQL table — this test exists
      // to make that a loud failure instead.
      expect(TableNames.sinceWhen.name, 'sinceWhen');
      expect(TableNames.glossary.name, 'glossary');
      expect(TableNames.tags.name, 'tags');
    });
  });
}
