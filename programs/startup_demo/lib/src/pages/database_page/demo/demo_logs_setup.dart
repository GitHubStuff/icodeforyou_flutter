// startup_demo/lib/src/pages/database_page/demo/demo_logs_setup.dart

import 'package:since_when_framework/database.dart'
    show DatabaseHandle, DatabaseSetup;

/// Demo [DatabaseSetup] contribution that creates the `demo_logs`
/// table on open.
///
/// Schema:
/// ```
/// CREATE TABLE IF NOT EXISTS demo_logs (
///   id        INTEGER PRIMARY KEY AUTOINCREMENT,
///   timestamp INTEGER NOT NULL,
///   message   TEXT    NOT NULL
/// )
/// ```
///
/// Used as one of the two [DatabaseSetup]s registered with the
/// lifecycle cubit in `DatabasePageBody._open()`. Pairs with
/// [DemoThingsSetup] for the transactional-insert demo.
///
/// Idempotent (`IF NOT EXISTS`); safe to run on every open.
class DemoLogsSetup implements DatabaseSetup {
  const DemoLogsSetup();

  @override
  String get name => 'demo_logs';

  @override
  Future<void> install(DatabaseHandle handle) async {
    await handle.execute(
      '''
CREATE TABLE IF NOT EXISTS demo_logs (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp INTEGER NOT NULL,
  message   TEXT    NOT NULL
)
''',
    );
  }
}
