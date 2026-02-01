// lib/src/_db_record_ops.dart

part of 'since_when_database.dart';

/// CRUD operations for SinceWhenRecord.
extension SinceWhenRecordOps on SinceWhenDatabase {
  /// Creates a new record.
  Future<Either<SinceWhenFailure, SinceWhenRecord>> create({
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tagTimestamps,
    String? parentTimeStamp,
  }) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return CreateOperations.createRecord(
      _db,
      metaData: metaData,
      dataString: dataString,
      category: category,
      tagTimestamps: tagTimestamps,
      parentTimeStamp: parentTimeStamp,
    );
  }

  /// Gets a record and its direct children by createdTimeStamp.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByCreatedTimeStamp(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('getByCreatedTimeStamp not yet implemented');
  }

  /// Gets all records matching a specific tag by glossary timestamp.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTagTimestamp(
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return ReadOperations.getByTagTimestamp(_db, glossaryTimestamp);
  }

  /// Gets all records matching a specific tag by name.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTagName(
    String tagName,
  ) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return ReadOperations.getByTagName(_db, tagName);
  }

  /// Gets all records matching the specified tags based on [mode].
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTagTimestamps(
    List<String> tagTimestamps, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return ReadOperations.getByTagTimestamps(_db, tagTimestamps, mode: mode);
  }

  /// Gets all records matching the specified tag names based on [mode].
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByTagNames(
    List<String> tagNames, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return ReadOperations.getByTagNames(_db, tagNames, mode: mode);
  }

  /// Gets all records in a category.
  Future<Either<SinceWhenFailure, List<SinceWhenRecord>>> getByCategory(
    String category,
  ) async {
    throw UnimplementedError('getByCategory not yet implemented');
  }

  /// Updates an existing record.
  Future<Either<SinceWhenFailure, SinceWhenRecord>> update(
    SinceWhenRecord record,
  ) async {
    throw UnimplementedError('update not yet implemented');
  }

  /// Marks a record as reviewed.
  Future<Either<SinceWhenFailure, SinceWhenRecord>> markReviewed(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('markReviewed not yet implemented');
  }

  /// Deletes a record by its createdTimeStamp.
  Future<Either<SinceWhenFailure, bool>> delete(String createdTimeStamp) async {
    throw UnimplementedError('delete not yet implemented');
  }

  /// Deletes a record and all its descendants.
  Future<Either<SinceWhenFailure, int>> deleteWithDescendants(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('deleteWithDescendants not yet implemented');
  }

  /// Exports all records to a JSON string.
  Future<Either<SinceWhenFailure, String>> exportToString() async {
    throw UnimplementedError('exportToString not yet implemented');
  }

  /// Imports records from a JSON string.
  Future<Either<SinceWhenFailure, int>> importFromString(
    String jsonString, {
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromString not yet implemented');
  }

  /// Exports all records to a JSON file.
  Future<Either<SinceWhenFailure, String>> exportToFile({
    required String path,
  }) async {
    throw UnimplementedError('exportToFile not yet implemented');
  }

  /// Imports records from a JSON file.
  Future<Either<SinceWhenFailure, int>> importFromFile({
    required String path,
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromFile not yet implemented');
  }
}
