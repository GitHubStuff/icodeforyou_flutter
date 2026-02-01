// lib/src/domain/since_when_failure.dart

/// Base failure class for all SinceWhen operations.
///
/// Use pattern matching (switch) to handle specific failure types.
sealed class SinceWhenFailure {
  /// Creates a [SinceWhenFailure].
  const SinceWhenFailure();
}

/// Database has not been initialized.
///
/// Ensure the database is opened before performing operations.
class DatabaseNotInitialized extends SinceWhenFailure {
  /// Creates a [DatabaseNotInitialized] failure.
  const DatabaseNotInitialized();

  @override
  String toString() => 'DatabaseNotInitialized: Database has not been opened.';
}

/// Record with specified createdTimeStamp was not found.
class RecordNotFound extends SinceWhenFailure {
  /// Creates a [RecordNotFound] failure.
  const RecordNotFound(this.createdTimeStamp);

  /// The createdTimeStamp that was not found.
  final String createdTimeStamp;

  @override
  String toString() =>
      'RecordNotFound: No record with '
      'createdTimeStamp "$createdTimeStamp".';
}

/// Parent record with specified parentTimeStamp does not exist.
class ParentNotFound extends SinceWhenFailure {
  /// Creates a [ParentNotFound] failure.
  const ParentNotFound(this.parentTimeStamp);

  /// The parentTimeStamp that was not found.
  final String parentTimeStamp;

  @override
  String toString() =>
      'ParentNotFound: No parent record with '
      'createdTimeStamp "$parentTimeStamp".';
}

/// Unique timestamp could not be generated after maximum retry attempts.
class TimestampCollisionRetryExhausted extends SinceWhenFailure {
  /// Creates a [TimestampCollisionRetryExhausted] failure.
  const TimestampCollisionRetryExhausted();

  @override
  String toString() =>
      'TimestampCollisionRetryExhausted: '
      'Failed to generate unique timestamp after maximum retries.';
}

/// Attempted to use reserved database name 'since_when.db' for named instance.
class ReservedDatabaseName extends SinceWhenFailure {
  /// Creates a [ReservedDatabaseName] failure.
  const ReservedDatabaseName();

  @override
  String toString() =>
      'ReservedDatabaseName: '
      '"since_when.db" is reserved for singleton. Use a different name.';
}

/// File not found at specified path during import.
class FileNotFound extends SinceWhenFailure {
  /// Creates a [FileNotFound] failure.
  const FileNotFound(this.path);

  /// The file path that was not found.
  final String path;

  @override
  String toString() => 'FileNotFound: No file at "$path".';
}

/// JSON string could not be parsed during import.
class InvalidJsonFormat extends SinceWhenFailure {
  /// Creates an [InvalidJsonFormat] failure.
  const InvalidJsonFormat(this.message);

  /// Description of the JSON parsing error.
  final String message;

  @override
  String toString() => 'InvalidJsonFormat: $message';
}

/// Failed to write file during export.
class ExportFailed extends SinceWhenFailure {
  /// Creates an [ExportFailed] failure.
  const ExportFailed(this.message, [this.originalError]);

  /// Description of the export error.
  final String message;

  /// The original error that caused the failure, if available.
  final Object? originalError;

  @override
  String toString() => 'ExportFailed: $message';
}

/// Failed to read file during import.
class ImportFailed extends SinceWhenFailure {
  /// Creates an [ImportFailed] failure.
  const ImportFailed(this.message, [this.originalError]);

  /// Description of the import error.
  final String message;

  /// The original error that caused the failure, if available.
  final Object? originalError;

  @override
  String toString() => 'ImportFailed: $message';
}

/// Unexpected database error occurred.
class UnexpectedDatabaseError extends SinceWhenFailure {
  /// Creates an [UnexpectedDatabaseError] failure.
  const UnexpectedDatabaseError(this.message, [this.originalError]);

  /// Description of the database error.
  final String message;

  /// The original error that caused the failure, if available.
  final Object? originalError;

  @override
  String toString() => 'UnexpectedDatabaseError: $message';
}

/// Invalid database name provided.
class InvalidDatabaseName extends SinceWhenFailure {
  /// Creates an [InvalidDatabaseName] failure.
  const InvalidDatabaseName(this.message);

  /// Description of why the name is invalid.
  final String message;

  @override
  String toString() => 'InvalidDatabaseName: $message';
}

/// Database has already been initialized.
///
/// Returned when attempting to open a file-based database
/// when one is already open. Call `SinceWhenDatabase.close()`
/// before opening with different parameters.
class DatabaseAlreadyInitialized extends SinceWhenFailure {
  /// Creates a [DatabaseAlreadyInitialized] failure.
  const DatabaseAlreadyInitialized(this.message);

  /// Description of the conflict.
  final String message;

  @override
  String toString() => 'DatabaseAlreadyInitialized: $message';
}

// ═══════════════════════════════════════════════════════════════════════════
// TAG-RELATED FAILURES
// ═══════════════════════════════════════════════════════════════════════════

/// Tag definition with specified createdTimeStamp was not found.
class TagNotFound extends SinceWhenFailure {
  /// Creates a [TagNotFound] failure.
  const TagNotFound(this.identifier);

  /// The identifier (timestamp or name) that was not found.
  final String identifier;

  @override
  String toString() => 'TagNotFound: No tag with identifier "$identifier".';
}

/// Tag name already exists in the glossary.
class TagNameAlreadyExists extends SinceWhenFailure {
  /// Creates a [TagNameAlreadyExists] failure.
  const TagNameAlreadyExists(this.tagName);

  /// The tag name that already exists.
  final String tagName;

  @override
  String toString() =>
      'TagNameAlreadyExists: Tag "$tagName" already exists in glossary.';
}

/// Tag name is invalid (empty or whitespace-only).
class InvalidTagName extends SinceWhenFailure {
  /// Creates an [InvalidTagName] failure.
  const InvalidTagName(this.message);

  /// Description of why the tag name is invalid.
  final String message;

  @override
  String toString() => 'InvalidTagName: $message';
}

/// Tag is still in use by records and cannot be deleted.
class TagInUse extends SinceWhenFailure {
  /// Creates a [TagInUse] failure.
  const TagInUse(this.tagName, this.usageCount);

  /// The tag name that is in use.
  final String tagName;

  /// Number of records using this tag.
  final int usageCount;

  @override
  String toString() =>
      'TagInUse: Tag "$tagName" is used by $usageCount record(s). '
      'Remove tag from records first or use force delete.';
}
