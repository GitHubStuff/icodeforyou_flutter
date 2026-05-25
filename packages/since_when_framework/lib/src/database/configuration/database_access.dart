// packages/since_when_framework/lib/src/database/configuration/database_access.dart

/// Controls how a file-based database behaves when the lifecycle cubit
/// is asked to open it.
///
/// - [create]    — fail if the file already exists.
/// - [open]      — fail if the file does not exist.
/// - [automatic] — create if absent, open if present.
enum DatabaseAccess {
  create,
  open,
  automatic,
}
