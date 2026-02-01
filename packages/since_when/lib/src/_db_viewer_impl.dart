// lib/src/_db_viewer_impl.dart

part of 'since_when_database.dart';

/// Additional viewer/table info operations.
extension SinceWhenViewerImpl on SinceWhenDatabase {
  /// Gets detailed table info including row counts.
  Future<Either<SinceWhenFailure, List<TableInfo>>> getTableInfo() async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    try {
      final tables = await _db.rawQuery(
        'SELECT name FROM sqlite_master '
        "WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
      );
      final list = <TableInfo>[];
      for (final row in tables) {
        final name = row['name']! as String;
        final countResult = await _db.rawQuery(
          'SELECT COUNT(*) as count FROM "$name"',
        );
        list.add(TableInfo(
          tableName: name,
          rowCount: countResult.first['count']! as int,
        ));
      }
      return Right(list);
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to get table info', e));
    }
  }
}
