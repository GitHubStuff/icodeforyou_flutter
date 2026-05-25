// startup_demo/lib/src/pages/database_page/demo/demo_json_exporter.dart

import 'dart:convert';

import 'package:since_when_framework/database.dart'
    show DatabaseExporter, DatabaseHandle;

/// Demo [DatabaseExporter] that snapshots both demo tables to a
/// pretty-printed JSON string and hands the result back through a
/// callback.
///
/// Output shape:
/// ```json
/// {
///   "demo_things": [ { "id": 1, "label": "...", "value": ... }, ... ],
///   "demo_logs":   [ { "id": 1, "timestamp": ..., "message": "..." }, ... ]
/// }
/// ```
///
/// Callback-based rather than file-system-based so the SQL pad demo
/// can keep the snapshot in memory and round-trip it through
/// [DemoJsonImporter] without touching the disk. A real exporter
/// would typically write to a file or upload to a remote endpoint.
class DemoJsonExporter implements DatabaseExporter {
  const DemoJsonExporter({required this.onSnapshotProduced});

  /// Called with the JSON-encoded snapshot once both tables have been
  /// read. Fires exactly once per [export] call.
  final void Function(String snapshot) onSnapshotProduced;

  @override
  String get name => 'demo_json';

  @override
  Future<void> export(DatabaseHandle handle) async {
    final things = await handle.query('SELECT * FROM demo_things');
    final logs = await handle.query('SELECT * FROM demo_logs');
    final snapshot = const JsonEncoder.withIndent('  ').convert({
      'demo_things': things,
      'demo_logs': logs,
    });
    onSnapshotProduced(snapshot);
  }
}
