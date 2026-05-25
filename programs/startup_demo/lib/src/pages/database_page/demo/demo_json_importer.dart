// startup_demo/lib/src/pages/database_page/demo/demo_json_importer.dart

import 'dart:convert';

import 'package:since_when_framework/database.dart'
    show DatabaseHandle, DatabaseImporter;

/// Demo [DatabaseImporter] that wipes both demo tables and reloads
/// them from a JSON snapshot produced by [DemoJsonExporter].
///
/// Input shape — the inverse of the exporter:
/// ```json
/// {
///   "demo_things": [ { "id": 1, "label": "...", "value": ... }, ... ],
///   "demo_logs":   [ { "id": 1, "timestamp": ..., "message": "..." }, ... ]
/// }
/// ```
///
/// The entire wipe + reload runs inside a single
/// [DatabaseHandle.transaction] so a partial load cannot leave the
/// database in a half-imported state — either every row is present
/// or none of them is. Demonstrates the framework's transaction
/// contract end-to-end.
class DemoJsonImporter implements DatabaseImporter {
  const DemoJsonImporter({required this.snapshot});

  /// The JSON-encoded snapshot to replay into the database.
  final String snapshot;

  @override
  String get name => 'demo_json';

  @override
  Future<void> import(DatabaseHandle handle) async {
    final decoded = jsonDecode(snapshot) as Map<String, dynamic>;
    final things = (decoded['demo_things'] as List)
        .cast<Map<String, dynamic>>();
    final logs = (decoded['demo_logs'] as List).cast<Map<String, dynamic>>();

    await handle.transaction((txn) async {
      await txn.execute('DELETE FROM demo_things');
      await txn.execute('DELETE FROM demo_logs');
      for (final row in things) {
        await txn.execute(
          'INSERT INTO demo_things (id, label, value) VALUES (?, ?, ?)',
          [row['id'], row['label'], row['value']],
        );
      }
      for (final row in logs) {
        await txn.execute(
          'INSERT INTO demo_logs (id, timestamp, message) VALUES (?, ?, ?)',
          [row['id'], row['timestamp'], row['message']],
        );
      }
    });
  }
}
