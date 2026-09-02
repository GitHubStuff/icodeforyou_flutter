// packages/sincewhen_drift_framework/test/sincewhen_drift_framework_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sincewhen_drift_framework/sincewhen_drift_framework.dart';

void main() {
  group('sincewhen_drift_framework barrel', () {
    test('exports the public API surface', () {
      // Referencing each symbol through the barrel proves the export
      // list resolves; the export directives themselves carry no
      // executable lines.
      expect(SinceWhenDatabase, isNotNull);
      expect(ColorCollector, isNotNull);
      expect(DriftGlossaryRepository, isNotNull);
      expect(DriftSinceWhenRepository, isNotNull);
      expect(DriftTagRepository, isNotNull);
      expect(SinceWhenConfiguration, isNotNull);
      expect(SinceWhenDocumentsConfiguration, isNotNull);
      expect(SinceWhenAppFolderConfiguration, isNotNull);
      expect(SinceWhenInMemoryConfiguration, isNotNull);
      expect(SinceWhenStartup, isNotNull);
      expect(GlossaryItems, isNotNull);
      expect(GlossaryItemsDao, isNotNull);
    });

    test('exports the SinceWhenDatabaseOpening extension', () async {
      // Extension names are not expressions, so the export is proven by
      // invoking a member through the barrel import.
      final database = SinceWhenDatabaseOpening.inMemory();
      addTearDown(database.close);

      final rows = await database.customSelect('SELECT 1 AS one').get();
      expect(rows.single.read<int>('one'), 1);
    });
  });
}
