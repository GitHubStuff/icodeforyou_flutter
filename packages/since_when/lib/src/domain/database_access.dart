// ignore_for_file: public_member_api_docs

/// Controls how [SinceWhenDatabase] behaves when opening a database file.
///
/// - [create]    — fails if the database already exists.
/// - [open]      — fails if the database does not exist.
/// - [automatic] — creates if absent, opens if present.
enum DatabaseAccess { create, open, automatic }
