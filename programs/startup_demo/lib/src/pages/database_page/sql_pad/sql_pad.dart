// startup_demo/lib/src/pages/database_page/sql_pad/sql_pad.dart

// ignore_for_file: public_member_api_docs

import 'package:edittext_popover/edittext_popover.dart' show EditorTextField;
import 'package:flutter/material.dart';
import 'package:since_when_framework/database.dart' show DatabaseHandle;
import 'package:startup_demo/src/pages/database_page/sql_pad/sql_result.dart';

/// SQL pad — only visible when the database is `DatabaseReady`.
///
/// Three actions against the live [DatabaseHandle]:
///
/// | Button                  | Calls                              |
/// |-------------------------|------------------------------------|
/// | query                   | `handle.query(sql)`                |
/// | execute                 | `handle.execute(sql)`              |
/// | insert demo row (txn)   | `handle.transaction((txn) { ... })`|
///
/// The SQL itself is entered via an [EditorTextField] — tapping the
/// field opens a full-screen popover editor (from `edittext_popover`).
/// This avoids burning vertical space on a permanently-expanded
/// multi-line textarea while still giving the user a proper editor for
/// anything beyond a single statement.
///
/// All three actions clear the previous result before running so the
/// UI never shows stale rows alongside a fresh execute or error.
class SqlPad extends StatefulWidget {
  const SqlPad({required this.handle, super.key});

  /// The live database handle. Sourced from `DatabaseReady.handle` by
  /// the page body's `BlocBuilder`.
  final DatabaseHandle handle;

  @override
  State<SqlPad> createState() => _SqlPadState();
}

class _SqlPadState extends State<SqlPad> {
  /// The user's SQL. Seeded with a harmless `sqlite_master` query so
  /// the pad has something useful to run on first tap.
  late final TextEditingController _sqlController = TextEditingController(
    text: "SELECT name FROM sqlite_master WHERE type = 'table'",
  );

  /// Result of the most recent action. Exactly one of `_rows`,
  /// `_affectedRows`, `_error` is non-null at any time; all three null
  /// means "no action run yet."
  List<Map<String, Object?>>? _rows;
  int? _affectedRows;
  Object? _error;

  @override
  void dispose() {
    _sqlController.dispose();
    super.dispose();
  }

  /// Resets the result trio to "no action run yet."
  void _clearResult() {
    setState(() {
      _rows = null;
      _affectedRows = null;
      _error = null;
    });
  }

  Future<void> _runQuery() async {
    _clearResult();
    try {
      final rows = await widget.handle.query(_sqlController.text);
      setState(() => _rows = rows);
    } on Object catch (e) {
      setState(() => _error = e);
    }
  }

  Future<void> _runExecute() async {
    _clearResult();
    try {
      final affected = await widget.handle.execute(_sqlController.text);
      setState(() => _affectedRows = affected);
    } on Object catch (e) {
      setState(() => _error = e);
    }
  }

  /// Inserts one row into each demo table inside a single transaction,
  /// then re-queries `demo_things` so the result table shows what was
  /// just written. Exercises [DatabaseHandle.transaction] directly so
  /// the user can verify the atomic-commit guarantee end-to-end.
  Future<void> _runInsertDemo() async {
    _clearResult();
    try {
      await widget.handle.transaction((txn) async {
        final now = DateTime.now().millisecondsSinceEpoch;
        await txn.execute(
          'INSERT INTO demo_things (label, value) VALUES (?, ?)',
          ['thing-$now', now % 1000],
        );
        await txn.execute(
          'INSERT INTO demo_logs (timestamp, message) VALUES (?, ?)',
          [now, 'inserted thing-$now'],
        );
      });
      final rows = await widget.handle.query(
        'SELECT * FROM demo_things ORDER BY id DESC LIMIT 10',
      );
      setState(() => _rows = rows);
    } on Object catch (e) {
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('SQL pad', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'handle.query() / handle.execute() / handle.transaction()',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            EditorTextField(
              controller: _sqlController,
              style: const TextStyle(fontFamily: 'monospace'),
              editorTextStyle: const TextStyle(fontFamily: 'monospace'),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'Tap to edit SQL…',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _runQuery,
                  child: const Text('query'),
                ),
                FilledButton.tonal(
                  onPressed: _runExecute,
                  child: const Text('execute'),
                ),
                OutlinedButton(
                  onPressed: _runInsertDemo,
                  child: const Text('insert demo row (txn)'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SqlResult(
              rows: _rows,
              affectedRows: _affectedRows,
              error: _error,
            ),
          ],
        ),
      ),
    );
  }
}
