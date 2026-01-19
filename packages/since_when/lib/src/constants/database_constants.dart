// packages/since_when/lib/src/constants/database_constants.dart

/// Token used to identify in-memory databases.
///
/// When `SinceWhenDatabase.openInMemory` is called, the `fullPath`
/// property returns this value.
///
/// This matches SQLite's standard in-memory database identifier.
const String kInMemoryPath = ':memory:';

/// Default database filename when none is specified.
const String kDefaultDatabaseName = 'since_when.sqlite';

/// Default subfolder within documents directory for database storage.
const String kDefaultDatabasePath = 'db';
