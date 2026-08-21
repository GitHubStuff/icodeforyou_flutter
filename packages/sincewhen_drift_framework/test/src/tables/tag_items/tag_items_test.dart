// packages/sincewhen_drift_framework/test/src/tables/tag_items/tag_items_test.dart

import 'package:sincewhen_drift_framework/src/tables/tag_items/tag_items.dart';
import 'package:test/test.dart';

void main() {
  group(TagItems, () {
    final table = TagItems();

    test('tableName maps to the legacy tags table', () {
      expect(table.tableName, 'tags');
    });

    group('DSL guards', () {
      // The column DSL exists only for drift_dev to parse: every builder
      // method bodies out to `_isGenerated()`, which throws
      // [UnsupportedError] at runtime. These tests pin that contract on a
      // bare (non-generated) instance — each getter must throw, proving
      // the runtime schema comes exclusively from the generated
      // $TagItemsTable. The throw happens at `integer()`, before any
      // multi-line expression's trailing `()` — or the uniqueKeys list
      // literal — can execute; the source excludes those unreachable
      // lines with inline `coverage:ignore-line` markers on the column
      // closers and an `ignore-start`/`ignore-end` fence around
      // uniqueKeys.
      test('id throws outside generated code', () {
        expect(() => table.id, throwsUnsupportedError);
      });

      test('recordTimestamp throws outside generated code', () {
        expect(() => table.recordTimestamp, throwsUnsupportedError);
      });

      test('glossaryTimestamp throws outside generated code', () {
        expect(() => table.glossaryTimestamp, throwsUnsupportedError);
      });

      test('uniqueKeys throws outside generated code', () {
        // Element sets evaluate before the list literal is built, so the
        // first column getter's throw surfaces here too. The getter is
        // coverage-fenced in the source, but this test still pins its
        // runtime behavior.
        expect(() => table.uniqueKeys, throwsUnsupportedError);
      });
    });
  });
}
