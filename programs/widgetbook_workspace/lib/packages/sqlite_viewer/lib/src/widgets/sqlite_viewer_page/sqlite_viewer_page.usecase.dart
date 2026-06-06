// lib/packages/sqlite_viewer/lib/src/widgets/sqlite_viewer_page/sqlite_viewer_page.usecase.dart
// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Default', type: SqliteViewerPage)
Widget sqliteViewerPageUseCase(BuildContext context) {
  final showQueryInput = context.knobs.boolean(
    label: 'showQueryInput',
    initialValue: true,
  );

  final showRowNumbers = context.knobs.boolean(
    label: 'showRowNumbers',
    initialValue: true,
  );

  final textHandling = context.knobs.object.dropdown<TextHandling>(
    label: 'textHandling',
    options: TextHandling.values,
    initialOption: TextHandling.trunc,
    labelBuilder: (t) => t.name,
  );

  final nullDisplay = context.knobs.string(
    label: 'nullValueDisplay',
    initialValue: 'NULL',
  );

  return _SqliteViewerShowcase(
    showQueryInput: showQueryInput,
    showRowNumbers: showRowNumbers,
    textHandling: textHandling,
    nullValueDisplay: nullDisplay,
  );
}

class _SqliteViewerShowcase extends StatefulWidget {
  const _SqliteViewerShowcase({
    required this.showQueryInput,
    required this.showRowNumbers,
    required this.textHandling,
    required this.nullValueDisplay,
  });

  final bool showQueryInput;
  final bool showRowNumbers;
  final TextHandling textHandling;
  final String nullValueDisplay;

  @override
  State<_SqliteViewerShowcase> createState() => _SqliteViewerShowcaseState();
}

class _SqliteViewerShowcaseState extends State<_SqliteViewerShowcase> {
  late final _InMemorySource _source;
  late final SqliteViewerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _source = _InMemorySource();
    _cubit = SqliteViewerCubit(_source);
    // Connect on first build so the viewer lands on MetadataLoaded.
    unawaited(_cubit.connect());
  }

  @override
  void dispose() {
    unawaited(_cubit.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SqliteViewerPage.forWidgetbook(
      source: _source,
      cubit: _cubit,
      showQueryInput: widget.showQueryInput,
      showRowNumbers: widget.showRowNumbers,
      textHandling: widget.textHandling,
      nullValueDisplay: widget.nullValueDisplay,
    );
  }
}

/// In-memory implementation of [SqliteViewerAbstract] populated with three
/// sample tables: users (5 rows), posts (4 rows), and comments (6 rows).
class _InMemorySource implements SqliteViewerAbstract {
  static const List<Map<String, Object?>> _users = [
    {
      'id': 1,
      'email': 'alex@example.com',
      'name': 'Alex Reyes',
      'created_at': '2024-01-12',
    },
    {
      'id': 2,
      'email': 'priya@example.com',
      'name': 'Priya Sharma',
      'created_at': '2024-02-03',
    },
    {
      'id': 3,
      'email': 'sam@example.com',
      'name': 'Sam Lin',
      'created_at': '2024-03-19',
    },
    {
      'id': 4,
      'email': 'jordan@example.com',
      'name': null,
      'created_at': '2024-04-07',
    },
    {
      'id': 5,
      'email': 'casey@example.com',
      'name': 'Casey Brooks',
      'created_at': '2024-05-22',
    },
  ];

  static const List<Map<String, Object?>> _posts = [
    {
      'id': 101,
      'user_id': 1,
      'title': 'First post',
      'body': 'Hello world from Alex.',
      'published': 1,
    },
    {
      'id': 102,
      'user_id': 2,
      'title': 'Late night thoughts',
      'body':
          'A long rambling reflection on the day, the week, and what comes next.',
      'published': 1,
    },
    {'id': 103, 'user_id': 3, 'title': null, 'body': 'Draft', 'published': 0},
    {
      'id': 104,
      'user_id': 1,
      'title': 'A quick update',
      'body': 'Short and sweet.',
      'published': 1,
    },
  ];

  static const List<Map<String, Object>> _comments = [
    {
      'id': 1001,
      'post_id': 101,
      'user_id': 2,
      'body': 'Welcome!',
      'flagged': 0,
    },
    {'id': 1002, 'post_id': 101, 'user_id': 3, 'body': '👋', 'flagged': 0},
    {
      'id': 1003,
      'post_id': 102,
      'user_id': 1,
      'body': 'Loved this.',
      'flagged': 0,
    },
    {
      'id': 1004,
      'post_id': 102,
      'user_id': 5,
      'body': 'Same here.',
      'flagged': 0,
    },
    {
      'id': 1005,
      'post_id': 104,
      'user_id': 4,
      'body': 'Brevity is the soul of wit.',
      'flagged': 0,
    },
    {
      'id': 1006,
      'post_id': 104,
      'user_id': 3,
      'body': 'spam spam spam',
      'flagged': 1,
    },
  ];

  Map<String, List<Map<String, Object?>>> get _tables => {
    'users': _users,
    'posts': _posts,
    'comments': _comments,
  };

  static const _tableInfo = <String, List<Map<String, Object?>>>{
    'users': [
      {
        'cid': 0,
        'name': 'id',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': null,
        'pk': 1,
      },
      {
        'cid': 1,
        'name': 'email',
        'type': 'TEXT',
        'notnull': 1,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 2,
        'name': 'name',
        'type': 'TEXT',
        'notnull': 0,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 3,
        'name': 'created_at',
        'type': 'TEXT',
        'notnull': 1,
        'dflt_value': null,
        'pk': 0,
      },
    ],
    'posts': [
      {
        'cid': 0,
        'name': 'id',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': null,
        'pk': 1,
      },
      {
        'cid': 1,
        'name': 'user_id',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 2,
        'name': 'title',
        'type': 'TEXT',
        'notnull': 0,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 3,
        'name': 'body',
        'type': 'TEXT',
        'notnull': 1,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 4,
        'name': 'published',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': '0',
        'pk': 0,
      },
    ],
    'comments': [
      {
        'cid': 0,
        'name': 'id',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': null,
        'pk': 1,
      },
      {
        'cid': 1,
        'name': 'post_id',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 2,
        'name': 'user_id',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 3,
        'name': 'body',
        'type': 'TEXT',
        'notnull': 1,
        'dflt_value': null,
        'pk': 0,
      },
      {
        'cid': 4,
        'name': 'flagged',
        'type': 'INTEGER',
        'notnull': 1,
        'dflt_value': '0',
        'pk': 0,
      },
    ],
  };

  static const _indexList = <String, List<Map<String, Object?>>>{
    'users': [
      {
        'seq': 0,
        'name': 'idx_users_email',
        'unique': 1,
        'origin': 'c',
        'partial': 0,
      },
    ],
    'posts': [
      {
        'seq': 0,
        'name': 'idx_posts_user_id',
        'unique': 0,
        'origin': 'c',
        'partial': 0,
      },
    ],
    'comments': [
      {
        'seq': 0,
        'name': 'idx_comments_post_id',
        'unique': 0,
        'origin': 'c',
        'partial': 0,
      },
    ],
  };

  static const _foreignKeyList = <String, List<Map<String, Object?>>>{
    'users': [],
    'posts': [
      {
        'id': 0,
        'seq': 0,
        'table': 'users',
        'from': 'user_id',
        'to': 'id',
        'on_update': 'NO ACTION',
        'on_delete': 'CASCADE',
        'match': 'NONE',
      },
    ],
    'comments': [
      {
        'id': 0,
        'seq': 0,
        'table': 'posts',
        'from': 'post_id',
        'to': 'id',
        'on_update': 'NO ACTION',
        'on_delete': 'CASCADE',
        'match': 'NONE',
      },
      {
        'id': 1,
        'seq': 0,
        'table': 'users',
        'from': 'user_id',
        'to': 'id',
        'on_update': 'NO ACTION',
        'on_delete': 'CASCADE',
        'match': 'NONE',
      },
    ],
  };

  @override
  Future<Either<SqliteViewerFailure, String>> getFullPath() async =>
      const Right(':memory:');

  @override
  Future<Either<SqliteViewerFailure, String>> getSqliteVersion() async =>
      const Right('3.45.0');

  @override
  Future<Either<SqliteViewerFailure, int>> getDatabaseSize() async =>
      const Right(81920);

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getTableNames() async =>
      Right(_tables.keys.toList());

  @override
  Future<Either<SqliteViewerFailure, int>> getRowCount(
    String tableName,
  ) async {
    final table = _tables[tableName];
    if (table == null) return Left(ViewerTableNotFound(tableName));
    return Right(table.length);
  }

  @override
  Future<Either<SqliteViewerFailure, List<String>>> getColumnNames(
    String tableName,
  ) async {
    final info = _tableInfo[tableName];
    if (info == null) return Left(ViewerTableNotFound(tableName));
    return Right(info.map((row) => row['name']! as String).toList());
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> getPragma({
    required String tableName,
    required PragmaKey key,
  }) async {
    final source = switch (key) {
      PragmaKey.tableInfo => _tableInfo,
      PragmaKey.indexList => _indexList,
      PragmaKey.foreignKeyList => _foreignKeyList,
    };
    final rows = source[tableName];
    if (rows == null) return Left(ViewerTableNotFound(tableName));
    return Right(rows);
  }

  @override
  Future<Either<SqliteViewerFailure, List<Map<String, Object?>>>> executeSelect(
    String sql,
  ) async {
    final trimmed = sql.trim().toLowerCase();
    if (!trimmed.startsWith('select') && !trimmed.startsWith('with')) {
      return Left(
        ViewerInvalidQuery(sql, 'Only SELECT and WITH queries are supported'),
      );
    }
    // Naive shortcut: if the query mentions a known table, return its rows.
    for (final entry in _tables.entries) {
      if (trimmed.contains(entry.key)) return Right(entry.value);
    }
    // Fall through with a tiny synthetic result so the grid still renders.
    return const Right([
      {'result': 'ok', 'rows_returned': 0},
    ]);
  }
}
