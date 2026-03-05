// lib/src/since_when_database.dart

import 'package:fpdart/fpdart.dart';
import 'package:since_when/since_when.dart' show SinceWhenRecordStore;
import 'package:since_when/src/constants/database_constants.dart';
import 'package:since_when/src/database/_database_initializer.dart';
import 'package:since_when/src/domain/data_store_failure.dart';
import 'package:since_when/src/domain/since_when_failure.dart';
import 'package:since_when/src/domain/since_when_import_mode.dart';
import 'package:since_when/src/domain/since_when_record.dart';
import 'package:since_when/src/domain/table_info.dart';
import 'package:since_when/src/domain/tag_definition.dart';
import 'package:since_when/src/domain/tag_match_mode.dart';
import 'package:since_when/src/sql/_sql_statements.dart';
import 'package:since_when/src/sql/create/_create_operations.dart';
import 'package:since_when/src/sql/delete/_delete_operations.dart';
import 'package:since_when/src/sql/read/_read_record_operations.dart';
import 'package:since_when/src/sql/read/_read_tag_operations.dart';
import 'package:since_when/src/sql/update/_update_operations.dart';
import 'package:since_when/src/store/since_when_data_store.dart';
import 'package:since_when/src/store/since_when_data_transfer_store.dart'
    show SinceWhenDataTransferStore;
import 'package:since_when/src/store/store.dart' show SinceWhenTagStore;
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

part '_db_viewer_impl.dart';
part '_database_record_impl.dart';
part '_database_tag_impl.dart';
part '_database_transfer_impl.dart';

/// SQLite implementation of [SinceWhenDataStore].
///
/// Consumers should depend on the interfaces ([SinceWhenRecordStore],
/// [SinceWhenTagStore], [SinceWhenDataTransferStore], or
/// [SinceWhenDataStore]) and receive this class via constructor injection.
///
/// ```dart
/// final result = await SinceWhenDatabase.openOrCreate();
/// final db = result.getOrElse(() => throw Exception('Failed'));
/// final cubit = RecordCubit(recordStore: db);
/// ```
class SinceWhenDatabase
    with
        _DatabaseRecordMixin,
        _DatabaseTagMixin,
        _DatabaseTransferMixin,
        _DatabaseViewerMixin
    implements SinceWhenDataStore, SqliteViewerAbstract {
  SinceWhenDatabase._({
    required Database db,
    required String fullPath,
    required bool isInMemory,
  })  : _db = db,
        _fullPath = fullPath,
        _isInMemory = isInMemory;

  @override
  final Database _db;
  final String _fullPath;
  final bool _isInMemory;

  static SinceWhenDatabase? _fileInstance;

  /// Returns true if a file-based singleton instance exists.
  static bool get hasFileInstance => _fileInstance != null;

  @override
  bool get isOpen => _db.isOpen;

  /// Returns true if this is an in-memory database.
  bool get isInMemory => _isInMemory;

  /// Exposes the underlying [Database] for advanced operations.
  Database get database => _db;

  /// Returns [Left] with [InvalidDatabaseName] if name is empty.
  /// Returns [Left] with [ReservedDatabaseName] if name is 'since_when.db'.
  /// Returns [Left] with [DatabaseAlreadyInitialized] if already open.
  static Future<Either<SinceWhenFailure, SinceWhenDatabase>> openOrCreate({
    String dbName = kDefaultDatabaseName,
    String dbPath = kDefaultDatabasePath,
  }) async {
    if (dbName.trim().isEmpty) {
      return const Left(InvalidDatabaseName('Database name cannot be empty'));
    }
    if (dbName == 'since_when.db') {
      return const Left(ReservedDatabaseName());
    }
    if (_fileInstance != null) {
      return const Left(DatabaseAlreadyInitialized('Already initialized.'));
    }
    try {
      final result = await DatabaseInitializer.openOrCreateDatabase(
        dbName: dbName,
        dbPath: dbPath,
      );
      _fileInstance = SinceWhenDatabase._(
        db: result.database,
        fullPath: result.fullPath,
        isInMemory: false,
      );
      return Right(_fileInstance!);
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to open database', e));
    }
  }

  /// Creates an in-memory database for testing (non-singleton).
  static Future<SinceWhenDatabase> openInMemory() async {
    final result = await DatabaseInitializer.openInMemoryDatabase();
    return SinceWhenDatabase._(
      db: result.database,
      fullPath: kInMemoryPath,
      isInMemory: true,
    );
  }

  @override
  Future<void> close() async {
    await _db.close();
    if (!_isInMemory && _fileInstance == this) {
      _fileInstance = null;
    }
  }
}
