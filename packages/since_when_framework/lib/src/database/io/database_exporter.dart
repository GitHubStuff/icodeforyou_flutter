// packages/since_when_framework/lib/src/database/io/database_exporter.dart

import 'package:since_when_framework/src/database/handle/database_handle.dart';

/// A pluggable strategy for writing the open database's contents out to
/// an external destination.
///
/// Implementations choose their own output format and target — SQL dump,
/// JSON snapshot, CSV, raw file copy, network upload, etc. The lifecycle
/// cubit orchestrates the state transitions (`Exporting` → `Ready` |
/// `Failed`) and delegates the actual work to the implementation.
abstract interface class DatabaseExporter {
  /// Human-readable name used for logging and failure reporting.
  String get name;

  /// Read from the database via [handle] and write to the external
  /// destination owned by this implementation.
  Future<void> export(DatabaseHandle handle);
}
