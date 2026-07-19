// packages/sincewhen_framework/lib/src/database/executor/open_executor.dart

import 'package:drift/drift.dart';

import 'package:sincewhen_framework/src/database/executor/open_executor_stub.dart'
    if (dart.library.io) 'package:sincewhen_framework/src/database/executor/open_executor_io.dart'
    if (dart.library.js_interop) 'package:sincewhen_framework/src/database/executor/open_executor_web.dart';

/// Returns the platform-appropriate [QueryExecutor].
///
/// This is the single public entry point for opening a SinceWhen database
/// executor. The conditional import above selects the implementation at
/// compile time:
///
/// * `dart:io` platforms (iOS, Android, macOS, Linux) — a file-backed
///   `NativeDatabase` running on a background isolate, or a native
///   in-memory database when [inMemory] is `true`.
/// * Web — a WASM database opened via a delayed connection; see the web
///   implementation's caveats regarding [path] being ignored and [inMemory]
///   being name-isolation rather than guaranteed ephemerality.
/// * Any other platform — a stub that always throws [UnsupportedError].
///
/// Exactly one of [path] / [inMemory] applies: pass a full file path for
/// persistent storage, or `inMemory: true` for a volatile database. On
/// `dart:io` platforms, omitting [path] while [inMemory] is `false` throws
/// an [ArgumentError]. On web, [path] is ignored entirely.
///
/// Callers should always use this function rather than importing a platform
/// implementation file directly; direct imports break compilation on the
/// other platforms.
QueryExecutor openExecutor({String? path, bool inMemory = false}) =>
    platformExecutor(path: path, inMemory: inMemory);
