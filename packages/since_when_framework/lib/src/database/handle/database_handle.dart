// packages/since_when_framework/lib/src/database/handle/database_handle.dart

/// The single seam between the framework and a database backend.
///
/// All consumers — setup contributions, importers/exporters, application
/// code — speak SQL through this interface. The backend implementation
/// translates SQL + args into whatever its underlying engine understands.
///
/// The default implementation in this package is sqflite-backed. Other
/// implementations (drift, an in-memory fake, a non-SQL store with a
/// translation layer) drop in without touching consumers.
///
/// Concurrency is the backend's responsibility. sqflite serialises all calls
/// internally; other backends must honour the same guarantee or expose true
/// parallelism — either way, [transaction] is the contract for atomicity.
abstract interface class DatabaseHandle {
  /// Execute a SELECT-style statement.
  ///
  /// Returns the result rows as a list of column-name → value maps, matching
  /// sqflite's row shape so the rest of the framework can read rows
  /// uniformly regardless of backend.
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> args,
  ]);

  /// Execute a non-SELECT statement (INSERT, UPDATE, DELETE, DDL).
  ///
  /// Returns the number of rows affected. For INSERT statements that need the
  /// new row's id, follow with a `SELECT last_insert_rowid()` query or use a
  /// `RETURNING` clause where the backend supports it.
  Future<int> execute(
    String sql, [
    List<Object?> args,
  ]);

  /// Run [work] inside a backend-native transaction.
  ///
  /// The handle passed to [work] is scoped to the transaction; all calls
  /// made on it are part of the same atomic unit. The transaction commits
  /// when [work] completes normally and rolls back if it throws.
  Future<T> transaction<T>(
    Future<T> Function(DatabaseHandle txn) work,
  );

  /// Whether the underlying connection is open.
  bool get isOpen;

  /// Close the underlying connection. Safe to call more than once.
  Future<void> close();
}
