// packages/sincewhen_framework/lib/src/database/executor/open_executor_io.dart
// Used on iOS, Android, macOS, Linux (anywhere dart:io exists).

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

QueryExecutor platformExecutor({String? path, bool inMemory = false}) {
  if (inMemory) return NativeDatabase.memory();
  return NativeDatabase.createInBackground(File(path!));
}
