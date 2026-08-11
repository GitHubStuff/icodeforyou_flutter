// packages/since_when_framework/lib/src/database/failure/database_failure.dart

/// Sealed failure hierarchy for database-level operations: open, install
/// schema, import, export, close.
sealed class DatabaseFailure implements Exception {
  const DatabaseFailure();
}

// ─── Open-time failures ──────────────────────────────────────────────────────

/// Database name was empty or whitespace.
final class DatabaseInvalidName extends DatabaseFailure {
  ///
  const DatabaseInvalidName();

  @override
  String toString() => 'DatabaseInvalidName: name cannot be empty.';
}

/// File already exists when `DatabaseAccess.create` was requested.
final class DatabaseAlreadyExists extends DatabaseFailure {
  ///
  const DatabaseAlreadyExists();

  @override
  String toString() => 'DatabaseAlreadyExists: database file already exists.';
}

/// File does not exist when `DatabaseAccess.open` was requested.
final class DatabaseNotFound extends DatabaseFailure {
  ///
  const DatabaseNotFound();

  @override
  String toString() => 'DatabaseNotFound: database file does not exist.';
}

/// An unexpected error occurred while opening the database connection.
final class DatabaseOpenFailure extends DatabaseFailure {
  ///
  const DatabaseOpenFailure(this.cause);

  /// General class to encapsule error message.
  final Object cause;

  @override
  String toString() => 'DatabaseOpenFailure: $cause';
}

// ─── Setup failures ──────────────────────────────────────────────────────────

/// A registered setup contribution threw while installing its schema.
final class DatabaseSetupFailure extends DatabaseFailure {
  ///
  const DatabaseSetupFailure({
    required this.setupName,
    required this.cause,
  });

  /// Name of the database/setup
  final String setupName;

  /// Contains the message/reason for the failure
  final Object cause;

  @override
  String toString() => 'DatabaseSetupFailure(setup="$setupName"): $cause';
}

// ─── Import/export failures ──────────────────────────────────────────────────

/// An importer threw while loading data into the database.
final class DatabaseImportFailure extends DatabaseFailure {
  ///
  const DatabaseImportFailure({
    required this.importerName,
    required this.cause,
  });

  /// Name of the import file
  final String importerName;

  /// Contains error information
  final Object cause;

  @override
  String toString() =>
      'DatabaseImportFailure(importer="$importerName"): $cause';
}

/// An exporter threw while writing data out of the database.
final class DatabaseExportFailure extends DatabaseFailure {
  ///
  const DatabaseExportFailure({
    required this.exporterName,
    required this.cause,
  });

  /// Name of the export path
  final String exporterName;

  /// Contains error information
  final Object cause;

  @override
  String toString() =>
      'DatabaseExportFailure(exporter="$exporterName"): $cause';
}

// ─── Close / reset failures ──────────────────────────────────────────────────

/// An unexpected error occurred while closing the database connection.
final class DatabaseCloseFailure extends DatabaseFailure {
  ///
  const DatabaseCloseFailure(this.cause);

  /// Contains error information
  final Object cause;

  @override
  String toString() => 'DatabaseCloseFailure: $cause';
}

/// An unexpected error occurred while erasing the on-device database file.
final class DatabaseEraseFailure extends DatabaseFailure {
  ///
  const DatabaseEraseFailure(this.cause);

  /// Contains error information
  final Object cause;

  @override
  String toString() => 'DatabaseEraseFailure: $cause';
}
