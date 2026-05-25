// startup_demo/lib/src/pages/database_page/sql_pad/sql_result.dart

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Renders the outcome of the most recent SQL pad action.
///
/// Exactly one of the three inputs is expected to be non-null at any
/// time; all three null collapses to [SizedBox.shrink] (the "no action
/// run yet" state).
///
/// Output by precedence:
/// 1. [error] non-null → red error banner with the error's `toString()`.
/// 2. [affectedRows] non-null → single-line summary of `execute()`.
/// 3. [rows] non-null and non-empty → horizontally-scrollable [DataTable].
/// 4. [rows] non-null and empty → "(no rows)" label.
/// 5. All null → empty.
class SqlResult extends StatelessWidget {
  const SqlResult({
    required this.rows,
    required this.affectedRows,
    required this.error,
    super.key,
  });

  /// Rows returned by a `query` call. Null means the last action wasn't
  /// a query (or no action has run yet).
  final List<Map<String, Object?>>? rows;

  /// Row-count returned by an `execute` call. Null means the last
  /// action wasn't an execute (or no action has run yet).
  final int? affectedRows;

  /// Error thrown by the last action, if any.
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (error != null) return _ErrorBanner(error: error!, theme: theme);
    if (affectedRows != null) {
      return Text(
        'execute() returned $affectedRows',
        style: theme.textTheme.bodyMedium,
      );
    }
    final currentRows = rows;
    if (currentRows == null) return const SizedBox.shrink();
    if (currentRows.isEmpty) {
      return Text('(no rows)', style: theme.textTheme.bodySmall);
    }
    return _RowsTable(rows: currentRows);
  }
}

/// Red banner showing the error's stringified form in monospace.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error, required this.theme});

  final Object error;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$error',
        style: TextStyle(
          color: theme.colorScheme.onErrorContainer,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// Horizontally-scrollable [DataTable] built from the column-name → value
/// maps returned by the handle. Column order follows the first row's
/// key insertion order (matching sqflite's response shape).
class _RowsTable extends StatelessWidget {
  const _RowsTable({required this.rows});

  final List<Map<String, Object?>> rows;

  @override
  Widget build(BuildContext context) {
    final columns = rows.first.keys.toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
        rows: rows
            .map(
              (row) => DataRow(
                cells: columns
                    .map((c) => DataCell(Text('${row[c] ?? '∅'}')))
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}
