// packages/since_when_framework/lib/src/database/handle/sqflite_handle.dart

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:since_when_framework/src/database/configuration/database_configuration.dart';
import 'package:since_when_framework/src/database/handle/database_handle.dart';
import 'package:sqflite/sqflite.dart';

/// The default [DatabaseHandle] implementation, backed by sqflite.
///
/// Construct via [open], which dispatches on the [DatabaseConfiguration]
/// variant. Foreign keys are enabled on every open. Schema installation is
/// the responsibility of the lifecycle cubit running registered setup
/// contributions against the returned handle — nothing about the database's
/// schema lives in here.
class SqfliteHandle implements DatabaseHandle {
  SqfliteHandle._({
    required DatabaseExecutor executor,
    required Database root,
    required String fullPath,
  }) : _executor = executor,
       _root = root,
       _fullPath = fullPath;

  final DatabaseExecutor _executor;
  final Database _root;
  final String _fullPath;

  /// Filesystem path of the underlying database, or `:memory:` for
  /// in-memory handles. Useful for diagnostics and the viewer.
  String get fullPath => _fullPath;

  /// Open the database described by [configuration].
  static Future<SqfliteHandle> open(
    DatabaseConfiguration configuration,
  ) async {
    final fullPath = await configuration.resolvePath();

    if (configuration.isFileBacked) {
      final directory = Directory(p.dirname(fullPath));
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }
    }

    final database = await openDatabase(
      fullPath,
      version: 1,
      onOpen: _enableForeignKeys,
    );

    return SqfliteHandle._(
      executor: database,
      root: database,
      fullPath: fullPath,
    );
  }

  static Future<void> _enableForeignKeys(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, [
    List<Object?> args = const [],
  ]) {
    return _executor.rawQuery(sql, args);
  }

  @override
  Future<int> execute(
    String sql, [
    List<Object?> args = const [],
  ]) async {
    await _executor.execute(sql, args);
    return 0;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseHandle txn) work,
  ) {
    return _root.transaction<T>((txn) {
      final txnHandle = SqfliteHandle._(
        executor: txn,
        root: _root,
        fullPath: _fullPath,
      );
      return work(txnHandle);
    });
  }

  @override
  bool get isOpen => _root.isOpen;

  @override
  Future<void> close() async {
    if (_root.isOpen) {
      await _root.close();
    }
  }
}
