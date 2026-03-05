// lib/src/_database_tag_impl.dart

part of 'since_when_database.dart';

mixin _DatabaseTagMixin implements SinceWhenTagStore {
  Database get _db;

  @override
  Future<Either<DataStoreFailure, TagDefinition>> createTag({
    required String tagName,
    required int color,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return CreateOperations.createTagDefinition(
      _db,
      tagName: tagName,
      color: color,
    );
  }

  @override
  Future<Either<DataStoreFailure, TagDefinition>> getTagByTimestamp(
    String createdTimeStamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadTagOperations.getTagDefinitionByTimestamp(_db, createdTimeStamp);
  }

  @override
  Future<Either<DataStoreFailure, TagDefinition>> getTagByName(
    String tagName,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadTagOperations.getTagDefinitionByName(_db, tagName);
  }

  @override
  Future<Either<DataStoreFailure, List<TagDefinition>>> getAllTags() async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadTagOperations.getAllTagDefinitions(_db);
  }

  @override
  Future<Either<DataStoreFailure, TagDefinition>> updateTag({
    required String createdTimeStamp,
    required String tagName,
    required int color,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return UpdateOperations.updateTagDefinition(
      _db,
      createdTimeStamp: createdTimeStamp,
      tagName: tagName,
      color: color,
    );
  }

  @override
  Future<Either<DataStoreFailure, bool>> deleteTag(
    String createdTimeStamp, {
    bool force = false,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return DeleteOperations.deleteTagDefinition(
      _db,
      createdTimeStamp,
      force: force,
    );
  }

  @override
  Future<Either<DataStoreFailure, bool>> addTagToRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    try {
      await _db.rawInsert(
        SqlStatements.insertRecordTag,
        [recordTimestamp, glossaryTimestamp],
      );
      return const Right(true);
    } on Exception catch (e) {
      return Left(UnexpectedStoreError('Failed to add tag to record', e));
    }
  }

  @override
  Future<Either<DataStoreFailure, bool>> removeTagFromRecord(
    String recordTimestamp,
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return DeleteOperations.removeTagFromRecord(
      _db,
      recordTimestamp,
      glossaryTimestamp,
    );
  }
}
