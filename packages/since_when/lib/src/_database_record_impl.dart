// lib/src/_database_record_impl.dart

part of 'since_when_database.dart';

mixin _DatabaseRecordMixin implements SinceWhenRecordStore {
  Database get _db;

  @override
  Future<Either<DataStoreFailure, SinceWhenRecord>> create({
    required String metaData,
    required String dataString,
    required String category,
    required List<String> tagTimestamps,
    String? parentTimeStamp,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return CreateOperations.createRecord(
      _db,
      metaData: metaData,
      dataString: dataString,
      category: category,
      tagTimestamps: tagTimestamps,
      parentTimeStamp: parentTimeStamp,
    );
  }

  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByCreatedTimeStamp(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('getByCreatedTimeStamp not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagTimestamp(
    String glossaryTimestamp,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagTimestamp(_db, glossaryTimestamp);
  }

  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagName(
    String tagName,
  ) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagName(_db, tagName);
  }

  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagTimestamps(
    List<String> tagTimestamps, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagTimestamps(
      _db,
      tagTimestamps,
      mode: mode,
    );
  }

  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByTagNames(
    List<String> tagNames, {
    TagMatchMode mode = TagMatchMode.any,
  }) async {
    if (!_db.isOpen) return const Left(StoreNotReady());
    return ReadRecordOperations.getByTagNames(_db, tagNames, mode: mode);
  }

  @override
  Future<Either<DataStoreFailure, List<SinceWhenRecord>>> getByCategory(
    String category,
  ) async {
    throw UnimplementedError('getByCategory not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, SinceWhenRecord>> update(
    SinceWhenRecord record,
  ) async {
    throw UnimplementedError('update not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, SinceWhenRecord>> markReviewed(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('markReviewed not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, bool>> delete(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('delete not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, int>> deleteWithDescendants(
    String createdTimeStamp,
  ) async {
    throw UnimplementedError('deleteWithDescendants not yet implemented');
  }
}
