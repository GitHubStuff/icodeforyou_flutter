// packages/sincewhen_framework/lib/src/database/executor/open_executor.dart

import 'package:drift/drift.dart';

import 'open_executor_stub.dart'
    if (dart.library.io) 'open_executor_io.dart'
    if (dart.library.js_interop) 'open_executor_web.dart';

/// Returns the platform-appropriate [QueryExecutor].
///
/// Exactly one of [path] / [inMemory] applies: pass a full file path for
/// persistent storage, or `inMemory: true` for a volatile database.
QueryExecutor openExecutor({String? path, bool inMemory = false}) =>
    platformExecutor(path: path, inMemory: inMemory);
