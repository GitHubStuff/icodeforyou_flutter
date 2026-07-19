// packages/sincewhen_framework/lib/src/database/executor/open_executor_stub.dart
// Fallback if neither dart:io nor dart:js_interop is available.

import 'package:drift/drift.dart';

/// Fallback [QueryExecutor] factory for platforms where neither `dart:io`
/// nor `dart:js_interop` is available.
///
/// This stub exists solely to satisfy the conditional-import mechanism: its
/// signature must remain identical to the `dart:io` and web implementations
/// so that the barrel file can select between them at compile time. It is
/// never expected to execute on any supported platform.
///
/// Always throws an [UnsupportedError]. Both [path] and [inMemory] are
/// accepted for signature parity but are ignored.
QueryExecutor platformExecutor({String? path, bool inMemory = false}) =>
    throw UnsupportedError('No SinceWhen database executor for this platform.');
