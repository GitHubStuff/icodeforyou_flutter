// test/src/database/executor/open_executor_test.dart
@TestOn('vm')
library;

// On the VM, the conditional import resolves to the `dart:io`
// implementation, so this file verifies the barrel's delegation and covers
// its single expression; the io-specific branches are covered in depth by
// open_executor_io_test.dart.

import 'package:drift/drift.dart';
import 'package:sincewhen_framework/src/database/executor/open_executor.dart';
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
  group('openExecutor', () {
    test('delegates to the platform implementation (in-memory)', () async {
      final QueryExecutor executor = openExecutor(inMemory: true);

      await executor.ensureOpen(const _FakeExecutorUser());
      final List<Map<String, Object?>> rows =
          await executor.runSelect('SELECT 1 AS v', const <Object?>[]);

      expect(rows.single['v'], 1);

      await executor.close();
    });

    test('propagates the platform ArgumentError contract on VM', () {
      expect(() => openExecutor(), throwsArgumentError);
    });
  });
}
