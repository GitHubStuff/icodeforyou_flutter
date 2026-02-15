// lib/src/domain/data_store_failure.dart

import 'package:since_when/since_when.dart'
    show ReservedDatabaseName, SinceWhenFailure;

/// Base failure class for all data store operations.
///
/// Unlike [SinceWhenFailure] (which is sealed and SQLite-specific),
/// this class is **not sealed** — implementations are free to extend it
/// with backend-specific failure types.
///
/// Common failures that apply to any backend live here.
/// SQLite-specific failures (e.g., [ReservedDatabaseName]) remain
/// in [SinceWhenFailure].
///
/// ```dart
/// // Pattern matching on common failures:
/// result.match(
///   (failure) => switch (failure) {
///     StoreNotReady()     => showError('Store not ready'),
///     RecordNotFound()    => showError('Not found'),
///     DataStoreFailure()  => showError('Unexpected: $failure'),
///   },
///   (record) => showRecord(record),
/// );
/// ```
abstract class DataStoreFailure {
  /// Creates a [DataStoreFailure].
  const DataStoreFailure();
}

// ===========================================================================
// Lifecycle Failures
// ===========================================================================

/// The data store has not been opened or initialized.
///
/// Returned when an operation is attempted before the store is ready.
class StoreNotReady extends DataStoreFailure {
  /// Creates a [StoreNotReady] failure.
  const StoreNotReady([this.message]);

  /// Optional detail about why the store is not ready.
  final String? message;

  @override
  String toString() =>
      'StoreNotReady: ${message ?? 'Data store has not been opened.'}';
}

// ===========================================================================
// Record Failures
// ===========================================================================

/// Record with specified identifier was not found.
class RecordNotFound extends DataStoreFailure {
  /// Creates a [RecordNotFound] failure.
  const RecordNotFound(this.identifier);

  /// The identifier (timestamp, key, etc.) that was not found.
  final String identifier;

  @override
  String toString() =>
      'RecordNotFound: No record with identifier "$identifier".';
}

/// Parent record does not exist.
class ParentNotFound extends DataStoreFailure {
  /// Creates a [ParentNotFound] failure.
  const ParentNotFound(this.parentIdentifier);

  /// The parent identifier that was not found.
  final String parentIdentifier;

  @override
  String toString() =>
      'ParentNotFound: No parent record with '
      'identifier "$parentIdentifier".';
}

/// A unique identifier could not be generated.
class IdentifierCollision extends DataStoreFailure {
  /// Creates an [IdentifierCollision] failure.
  const IdentifierCollision([this.message]);

  /// Optional detail about the collision.
  final String? message;

  @override
  String toString() =>
      'IdentifierCollision: '
      '${message ?? 'Failed to generate unique identifier.'}';
}

// ===========================================================================
// Tag Failures
// ===========================================================================

/// Tag with specified identifier was not found.
class TagNotFound extends DataStoreFailure {
  /// Creates a [TagNotFound] failure.
  const TagNotFound(this.identifier);

  /// The identifier (timestamp, name, etc.) that was not found.
  final String identifier;

  @override
  String toString() => 'TagNotFound: No tag with identifier "$identifier".';
}

/// Tag name already exists.
class TagNameAlreadyExists extends DataStoreFailure {
  /// Creates a [TagNameAlreadyExists] failure.
  const TagNameAlreadyExists(this.tagName);

  /// The tag name that already exists.
  final String tagName;

  @override
  String toString() => 'TagNameAlreadyExists: Tag "$tagName" already exists.';
}

/// Tag name is invalid (empty or whitespace-only).
class InvalidTagName extends DataStoreFailure {
  /// Creates an [InvalidTagName] failure.
  const InvalidTagName(this.message);

  /// Description of why the tag name is invalid.
  final String message;

  @override
  String toString() => 'InvalidTagName: $message';
}

/// Tag is still in use and cannot be deleted.
class TagInUse extends DataStoreFailure {
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

// ===========================================================================
// Data Transfer Failures
// ===========================================================================

/// File was not found at the specified path.
class FileNotFound extends DataStoreFailure {
  /// Creates a [FileNotFound] failure.
  const FileNotFound(this.path);

  /// The file path that was not found.
  final String path;

  @override
  String toString() => 'FileNotFound: No file at "$path".';
}

/// Data format was invalid during import.
class InvalidDataFormat extends DataStoreFailure {
  /// Creates an [InvalidDataFormat] failure.
  const InvalidDataFormat(this.message);

  /// Description of the format error.
  final String message;

  @override
  String toString() => 'InvalidDataFormat: $message';
}

/// Export operation failed.
class ExportFailed extends DataStoreFailure {
  /// Creates an [ExportFailed] failure.
  const ExportFailed(this.message, [this.originalError]);

  /// Description of the export error.
  final String message;

  /// The original error, if available.
  final Object? originalError;

  @override
  String toString() => 'ExportFailed: $message';
}

/// Import operation failed.
class ImportFailed extends DataStoreFailure {
  /// Creates an [ImportFailed] failure.
  const ImportFailed(this.message, [this.originalError]);

  /// Description of the import error.
  final String message;

  /// The original error, if available.
  final Object? originalError;

  @override
  String toString() => 'ImportFailed: $message';
}

// ===========================================================================
// Catch-all
// ===========================================================================

/// An unexpected error occurred in the data store.
///
/// This is the catch-all for errors that don't fit a specific category.
/// Implementations should prefer specific failure types when possible.
class UnexpectedStoreError extends DataStoreFailure {
  /// Creates an [UnexpectedStoreError] failure.
  const UnexpectedStoreError(this.message, [this.originalError]);

  /// Description of the error.
  final String message;

  /// The original error, if available.
  final Object? originalError;

  @override
  String toString() => 'UnexpectedStoreError: $message';
}
