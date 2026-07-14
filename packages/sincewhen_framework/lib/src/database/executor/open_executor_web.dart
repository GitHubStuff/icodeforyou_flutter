// packages/sincewhen_framework/lib/src/database/executor/open_executor_web.dart
// Used in browsers.

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor platformExecutor({String? path, bool inMemory = false}) {
  return DatabaseConnection.delayed(
    Future(() async {
      final result = await WasmDatabase.open(
        databaseName: inMemory ? ':memory:' : 'SinceWhen',
        sqlite3Uri: Uri.parse('sqlite3.wasm'),
        driftWorkerUri: Uri.parse('drift_worker.js'),
      );
      return result.resolvedExecutor;
    }),
  );
}
