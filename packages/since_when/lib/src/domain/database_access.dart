// lib/src/domain/database_access.dart

/// Controls how [SinceWhenDatabase] behaves when opening a database file.
///
/// - [create]    — fails if the database already exists.
/// - [open]      — fails if the database does not exist.
/// - [automatic] — creates if absent, opens if present.
enum DatabaseAccess { create, open, automatic }
