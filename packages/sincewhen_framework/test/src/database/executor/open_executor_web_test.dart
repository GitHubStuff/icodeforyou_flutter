// test/src/database/executor/open_executor_web_test.dart
@TestOn('browser')
library;

// This file only compiles and runs on web (`drift/wasm` requires
// `dart:js_interop`). Run it with:
//
//   flutter test --platform chrome test/src/database/executor/open_executor_web_test.dart
//
// LCOV caveat: Dart coverage collection is VM-only, so open_executor_web.dart
// cannot appear as covered in lcov.info even though every line executes here.
// Strip it from the report:
//
//   lcov --remove coverage/lcov.info '*open_executor_web.dart' -o coverage/lcov.info
//
// These tests assume sqlite3.wasm / drift_worker.js are NOT served by the
// test harness (the default), so first use of the connection is expected to
// fail — which is exactly the documented "fails at first use, not at call
// time" contract.

import 'package:drift/drift.dart';
import 'package:sincewhen_framework/src/database/executor/open_executor_web.dart';
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
  group('platformExecutor (web)', () {
    test('returns a delayed connection synchronously (persistent branch)',
        () async {
      final QueryExecutor executor = platformExecutor(path: '/ignored.db');

      expect(executor, isA<QueryExecutor>());

      // Without sqlite3.wasm / drift_worker.js served, the delayed open must
      // surface its failure on first use — awaiting here both asserts that
      // contract and drains the inner future so no unhandled async error
      // escapes the test zone.
      await expectLater(
        executor.ensureOpen(const _FakeExecutorUser()),
        throwsA(anything),
      );
    });

    test('returns a delayed connection synchronously (in-memory branch)',
        () async {
      final QueryExecutor executor = platformExecutor(inMemory: true);

      expect(executor, isA<QueryExecutor>());

      await expectLater(
        executor.ensureOpen(const _FakeExecutorUser()),
        throwsA(anything),
      );
    });
  });
}
