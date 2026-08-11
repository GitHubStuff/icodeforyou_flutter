// packages/since_when_framework/lib/src/database/configuration/database_access.dart

/// {@template database_access.dart}
/// Controls how a file-based database behaves when the lifecycle cubit
/// is asked to open it.
///
/// - [create]    — fail if the file already exists.
/// - [open]      — fail if the file does not exist.
/// - [automatic] — create if absent, open if present.
/// {@endtemplate}
enum DatabaseAccess {
  /// Create a new database file.
  ///
  /// Fails if the file already exists — guards against silently
  /// opening (and mutating) a database that was expected to be fresh.
  create,

  /// Open an existing database file.
  ///
  /// Fails if the file does not exist — guards against silently
  /// creating an empty database where real data was expected.
  open,

  /// Create the file if absent, open it if present.
  ///
  /// The convenient default for app-owned databases whose first launch
  /// and every subsequent launch share one code path.
  automatic,
}
