// packages/since_when_framework/lib/src/since_when/since_when.dart

import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:since_when_framework/src/database/configuration/database_configuration.dart';
import 'package:since_when_framework/src/database/failure/database_failure.dart';
import 'package:since_when_framework/src/database/handle/database_handle.dart';
import 'package:since_when_framework/src/since_when/sql/create_indexes.dart';
import 'package:since_when_framework/src/since_when/sql/create_tables.dart';
import 'package:since_when_framework/src/since_when/sql/drop_tables.dart';

/// since_when schema setup and reset.
///
/// Two responsibilities:
///   * `setup` — create the three since_when tables and their indexes.
///   * `reset` — drop the three tables and erase the on-device file.
///
/// Setup is idempotent (`CREATE TABLE IF NOT EXISTS`, `CREATE INDEX IF
/// NOT EXISTS`), so calling it on an already-initialised database is a
/// no-op. Reset is destructive — it removes both the schema and, for
/// file-backed databases, the database file itself.
abstract final class SinceWhen {
  /// Human-readable name used by the framework when wrapping a setup
  /// failure in a `DatabaseSetupFailure`.
  static const String setupName = 'since_when';

  /// Create the three since_when tables and their indexes against
  /// [handle]. All DDL runs inside a single transaction so a partial
  /// failure leaves the database untouched.
  ///
  /// Returns `Right(unit)` on success, `Left(DatabaseSetupFailure)` on
  /// failure with the underlying cause attached.
  static Future<Either<DatabaseFailure, Unit>> setup(
    DatabaseHandle handle,
  ) async {
    try {
      await handle.transaction((txn) async {
        for (final statement in createTableStatements) {
          await txn.execute(statement);
        }
        for (final statement in createIndexStatements) {
          await txn.execute(statement);
        }
      });
      return const Right(unit);
    } on Object catch (e) {
      return Left(
        DatabaseSetupFailure(setupName: setupName, cause: e),
      );
    }
  }

  /// Drop the three since_when tables and, for file-backed
  /// configurations, erase the on-device database file.
  ///
  /// [handle] is used to issue the DROP statements. [configuration] is
  /// used to locate the file for deletion; pass an in-memory
  /// configuration to skip the file-erase step.
  ///
  /// The handle should be closed by the caller before calling reset if
  /// the file is going to be erased — sqflite holds the file open until
  /// the database is closed. The reset method itself does not close the
  /// handle so the caller stays in control of lifecycle.
  ///
  /// Returns `Right(unit)` on success, `Left(DatabaseFailure)` on
  /// failure: `DatabaseSetupFailure` if a DROP fails,
  /// `DatabaseEraseFailure` if the file delete fails.
  static Future<Either<DatabaseFailure, Unit>> reset(
    DatabaseHandle handle,
    DatabaseConfiguration configuration,
  ) async {
    final dropResult = await _dropTables(handle);
    if (dropResult.isLeft()) return dropResult;

    if (!configuration.isFileBacked) return const Right(unit);

    return _eraseFile(configuration);
  }

  static Future<Either<DatabaseFailure, Unit>> _dropTables(
    DatabaseHandle handle,
  ) async {
    try {
      await handle.transaction((txn) async {
        for (final statement in dropTableStatements) {
          await txn.execute(statement);
        }
      });
      return const Right(unit);
    } on Object catch (e) {
      return Left(
        DatabaseSetupFailure(setupName: setupName, cause: e),
      );
    }
  }

  static Future<Either<DatabaseFailure, Unit>> _eraseFile(
    DatabaseConfiguration configuration,
  ) async {
    try {
      final fullPath = await configuration.resolvePath();
      final file = File(fullPath);
      if (file.existsSync()) {
        await file.delete();
      }
      return const Right(unit);
    } on Object catch (e) {
      return Left(DatabaseEraseFailure(e));
    }
  }
}
