// test/src/database/executor/open_executor_io_test.dart
@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sincewhen_framework/src/database/executor/open_executor_io.dart';
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
  group('platformExecutor (io)', () {
    test(
        'returns a working in-memory database when inMemory is true, '
        'ignoring path', () async {
      final QueryExecutor executor = platformExecutor(
        path: p.join('ignored', 'by', 'in-memory.db'),
        inMemory: true,
      );

      await executor.ensureOpen(const _FakeExecutorUser());
      final List<Map<String, Object?>> rows =
          await executor.runSelect('SELECT 1 AS v', const <Object?>[]);

      expect(rows.single['v'], 1);

      await executor.close();
    });

    test('returns a working file-backed database when path is provided',
        () async {
      final Directory tempDir =
          Directory.systemTemp.createTempSync('sincewhen_executor_test');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final String dbPath = p.join(tempDir.path, 'test.db');
      final QueryExecutor executor = platformExecutor(path: dbPath);

      await executor.ensureOpen(const _FakeExecutorUser());
      final List<Map<String, Object?>> rows =
          await executor.runSelect('SELECT 42 AS v', const <Object?>[]);

      expect(rows.single['v'], 42);

      await executor.close();

      expect(File(dbPath).existsSync(), isTrue);
    });

    test(
        'throws ArgumentError naming path when path is null and '
        'inMemory is false', () {
      expect(
        () => platformExecutor(),
        throwsA(
          isA<ArgumentError>()
              .having((ArgumentError e) => e.name, 'name', 'path'),
        ),
      );
    });
  });
}
