// startup_demo/lib/src/pages/database_page/demo/demo_things_setup.dart

import 'package:since_when_framework/database.dart'
    show DatabaseHandle, DatabaseSetup;

/// Demo [DatabaseSetup] contribution that creates the `demo_things`
/// table on open.
///
/// Schema:
/// ```
/// CREATE TABLE IF NOT EXISTS demo_things (
///   id    INTEGER PRIMARY KEY AUTOINCREMENT,
///   label TEXT    NOT NULL,
///   value INTEGER NOT NULL
/// )
/// ```
///
/// Used as one of the two [DatabaseSetup]s registered with the
/// lifecycle cubit in `DatabasePageBody._open()`. Pairs with
/// [DemoLogsSetup] — the SQL pad's `insert demo row (txn)` action
/// writes one row to each table inside a single transaction to
/// demonstrate the framework's atomic-commit guarantee.
///
/// Idempotent (`IF NOT EXISTS`); safe to run on every open.
class DemoThingsSetup implements DatabaseSetup {
  const DemoThingsSetup();

  @override
  String get name => 'demo_things';

  @override
  Future<void> install(DatabaseHandle handle) async {
    await handle.execute(
      '''
CREATE TABLE IF NOT EXISTS demo_things (
  id    INTEGER PRIMARY KEY AUTOINCREMENT,
  label TEXT    NOT NULL,
  value INTEGER NOT NULL
)
''',
    );
  }
}
