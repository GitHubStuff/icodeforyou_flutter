// packages/sincewhen_framework/lib/src/database/executor/open_executor_web.dart
// Used in browsers.

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Creates the platform [QueryExecutor] for web (browser) targets.
///
/// Returns a [DatabaseConnection.delayed] wrapper so callers get a usable
/// executor synchronously while [WasmDatabase.open] completes asynchronously
/// in the background; queries issued before the database is ready are queued
/// and run once the connection resolves.
///
/// [path] is accepted only for signature parity with the `dart:io`
/// implementation and is **ignored** on web — browser storage is keyed by
/// database name, not filesystem path.
///
/// The database name is `':memory:'` when [inMemory] is `true` and
/// `'SinceWhen'` otherwise. Drift selects the best storage implementation
/// the browser supports (OPFS, IndexedDB, or an in-memory fallback).
///
/// **Caveat — [inMemory] is name-only on web:** `':memory:'` here is a
/// storage *name*, not a SQLite path, so on browsers with persistent storage
/// the ':memory:'-named database may be persisted rather than truly
/// ephemeral. Treat [inMemory] on web as "isolated under a separate name",
/// not "guaranteed non-persistent".
///
/// **Caveat — silent storage degradation:** the result's `missingFeatures`
/// and `chosenImplementation` are not inspected, so a browser that cannot
/// provide persistent storage will silently fall back to an in-memory
/// database with no warning; data will not survive a page reload on such
/// browsers.
///
/// Required assets: `sqlite3.wasm` and `drift_worker.js` must be served from
/// the application's web root (the `web/` directory in a Flutter project);
/// the URIs here are resolved relative to the page. If either asset is
/// missing, the delayed connection fails at first use, not at call time.
///
/// The `dart:io` counterpart of this function lives in the
/// conditional-import sibling of this file; callers should import the barrel
/// that selects the correct implementation rather than importing this file
/// directly.
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
