// packages/sincewhen_framework/lib/src/database/executor/open_executor_io.dart
// Used on iOS, Android, macOS, Linux (anywhere dart:io exists).

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Creates the platform [QueryExecutor] for `dart:io` targets
/// (iOS, Android, macOS, Linux).
///
/// When [inMemory] is `true`, returns a [NativeDatabase.memory] instance and
/// [path] is ignored. In-memory databases are ephemeral: all data is lost when
/// the executor is closed. Intended for tests and throwaway sessions.
///
/// When [inMemory] is `false` (the default), returns a file-backed database
/// via [NativeDatabase.createInBackground], which runs all database work on a
/// background isolate to keep the UI isolate free of synchronous I/O.
///
/// [path] must be a non-null absolute path to the database file whenever
/// [inMemory] is `false`. Passing `null` in that case throws an
/// [ArgumentError] naming the offending parameter. Drift creates the database
/// file on first open, but the parent directory must already exist — this
/// function does not create missing directories.
///
/// The web counterpart of this function lives in the conditional-import
/// sibling of this file; callers should import the barrel that selects the
/// correct implementation rather than importing this file directly.
QueryExecutor platformExecutor({String? path, bool inMemory = false}) {
  if (inMemory) return NativeDatabase.memory();
  final String dbPath = ArgumentError.checkNotNull(path, 'path');
  return NativeDatabase.createInBackground(File(dbPath));
}
