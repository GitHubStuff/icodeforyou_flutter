// packages/since_when_framework/lib/src/database/io/database_importer.dart

import 'package:since_when_framework/src/database/handle/database_handle.dart';

/// A pluggable strategy for loading external data into the open database.
///
/// Implementations choose their own source format and shape — SQL dump,
/// JSON snapshot, CSV, raw file copy, etc. The lifecycle cubit orchestrates
/// the state transitions (`Importing` → `Ready` | `Failed`) and delegates
/// the actual work to the implementation.
///
/// Implementations should wrap multi-row work in
/// [DatabaseHandle.transaction] so a partial import does not leave the
/// database in an inconsistent state.
abstract interface class DatabaseImporter {
  /// Human-readable name used for logging and failure reporting.
  String get name;

  /// Read external data and write it into the database via [handle].
  Future<void> import(DatabaseHandle handle);
}
