// packages/sincewhen_framework/lib/src/database/executor/open_executor_stub.dart
// Fallback if neither dart:io nor dart:js_interop is available.

import 'package:drift/drift.dart';

QueryExecutor platformExecutor({String? path, bool inMemory = false}) =>
    throw UnsupportedError('No SinceWhen database executor for this platform.');
