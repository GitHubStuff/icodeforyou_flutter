// packages/sincewhen_framework/test/src/database/executor/sql/tables/create_tables_test.dart
@TestOn('vm')
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sincewhen_framework/src/sql/table_names.dart';
import 'package:sincewhen_framework/src/sql/tables/create_tables.dart';
import 'package:test/test.dart';

/// Minimal [QueryExecutorUser] allowing an executor to be opened without a
/// full drift database class.
class _FakeExecutorUser implements QueryExecutorUser {
  const _FakeExecutorUser();

  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

void main() {
  group('createTableStatements', () {
    late QueryExecutor executor;

    setUp(() async {
      executor = NativeDatabase.memory();
      await executor.ensureOpen(const _FakeExecutorUser());
      await executor.runCustom('PRAGMA foreign_keys = ON', const <Object?>[]);
    });

    tearDown(() async {
      await executor.close();
    });

    test('lists all three DDL statements in dependency order', () {
      expect(createTableStatements, hasLength(3));
      expect(
        createTableStatements,
        orderedEquals(<String>[
          createTableSinceWhen,
          createTableTagGlossary,
          createTableTags,
        ]),
      );
    });

    test('every statement executes cleanly in listed order', () async {
      for (final String statement in createTableStatements) {
        await executor.runCustom(statement, const <Object?>[]);
      }

      final List<Map<String, Object?>> tables = await executor.runSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
        const <Object?>[],
      );
      final Iterable<Object?> names = tables.map(
        (Map<String, Object?> row) => row['name'],
      );

      expect(names, contains(TableNames.sinceWhen.name));
      expect(names, contains(TableNames.glossary.name));
      expect(names, contains(TableNames.tags.name));
    });

    test('IF NOT EXISTS makes the full set idempotent', () async {
      for (final String statement in createTableStatements) {
        await executor.runCustom(statement, const <Object?>[]);
      }
      for (final String statement in createTableStatements) {
        await expectLater(
          executor.runCustom(statement, const <Object?>[]),
          completes,
        );
      }
    });

    test('tags table enforces ON DELETE CASCADE from since_when', () async {
      for (final String statement in createTableStatements) {
        await executor.runCustom(statement, const <Object?>[]);
      }

      await executor.runCustom(
        'INSERT INTO ${TableNames.sinceWhen.name} '
        '(createdTimeStamp, reviewedTimeStamp, editedTimeStamp, data) '
        'VALUES (?, ?, ?, ?)',
        const <Object?>[1000, 1000, 1000, 'record'],
      );
      await executor.runCustom(
        'INSERT INTO ${TableNames.glossary.name} '
        '(createdTimeStamp, tagName, color) VALUES (?, ?, ?)',
        const <Object?>[2000, 'urgent', 0xFF0000],
      );
      await executor.runCustom(
        'INSERT INTO ${TableNames.tags.name} '
        '(record_timestamp, glossary_timestamp) VALUES (?, ?)',
        const <Object?>[1000, 2000],
      );

      await executor.runCustom(
        'DELETE FROM ${TableNames.sinceWhen.name} WHERE createdTimeStamp = ?',
        const <Object?>[1000],
      );

      final List<Map<String, Object?>> remaining = await executor.runSelect(
        'SELECT COUNT(*) AS n FROM ${TableNames.tags.name}',
        const <Object?>[],
      );

      expect(remaining.single['n'], 0);
    });

    test('glossary rejects empty tagName via CHECK constraint', () async {
      for (final String statement in createTableStatements) {
        await executor.runCustom(statement, const <Object?>[]);
      }

      await expectLater(
        executor.runCustom(
          'INSERT INTO ${TableNames.glossary.name} '
          '(createdTimeStamp, tagName, color) VALUES (?, ?, ?)',
          const <Object?>[3000, '', 0x00FF00],
        ),
        throwsA(anything),
      );
    });
  });
}
