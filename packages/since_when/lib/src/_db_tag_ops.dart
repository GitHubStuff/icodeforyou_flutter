// lib/src/_db_tag_ops.dart

part of 'since_when_database.dart';

/// Tag glossary operations.
extension SinceWhenTagOps on SinceWhenDatabase {
  /// Creates a new tag definition in the glossary.
  Future<Either<SinceWhenFailure, TagDefinition>> createTag({
    required String tagName,
    required String tagDescription,
    required int color,
  }) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return CreateOperations.createTagDefinition(
      _db,
      tagName: tagName,
      tagDescription: tagDescription,
      color: color,
    );
  }

  /// Gets a tag definition by its createdTimeStamp.
  Future<Either<SinceWhenFailure, TagDefinition>> getTagByTimestamp(
    String createdTimeStamp,
  ) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return ReadOperations.getTagDefinitionByTimestamp(_db, createdTimeStamp);
  }

  /// Gets a tag definition by its name.
  Future<Either<SinceWhenFailure, TagDefinition>> getTagByName(
    String tagName,
  ) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return ReadOperations.getTagDefinitionByName(_db, tagName);
  }

  /// Gets all tag definitions from the glossary.
  Future<Either<SinceWhenFailure, List<TagDefinition>>> getAllTags() async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return ReadOperations.getAllTagDefinitions(_db);
  }

  /// Updates a tag definition in the glossary.
  Future<Either<SinceWhenFailure, TagDefinition>> updateTag({
    required String createdTimeStamp,
    required String tagName,
    required String tagDescription,
    required int color,
  }) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return UpdateOperations.updateTagDefinition(
      _db,
      createdTimeStamp: createdTimeStamp,
      tagName: tagName,
      tagDescription: tagDescription,
      color: color,
    );
  }

  /// Deletes a tag definition from the glossary.
  Future<Either<SinceWhenFailure, bool>> deleteTag(
    String createdTimeStamp, {
    bool force = false,
  }) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return DeleteOperations.deleteTagDefinition(
      _db,
      createdTimeStamp,
      force: force,
    );
  }

  /// Adds a tag to a record.
  Future<Either<SinceWhenFailure, bool>> addTagToRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    try {
      await _db.rawInsert(
        SqlStatements.insertRecordTag,
        [recordTimestamp, glossaryTimestamp],
      );
      return const Right(true);
    } on Exception catch (e) {
      return Left(UnexpectedDatabaseError('Failed to add tag to record', e));
    }
  }

  /// Removes a tag from a record.
  Future<Either<SinceWhenFailure, bool>> removeTagFromRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(DatabaseNotInitialized());
    return DeleteOperations.removeTagFromRecord(
      _db,
      recordTimestamp,
      glossaryTimestamp,
    );
  }
}
