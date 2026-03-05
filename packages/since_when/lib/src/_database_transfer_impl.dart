// lib/src/_database_transfer_impl.dart

part of 'since_when_database.dart';

mixin _DatabaseTransferMixin implements SinceWhenDataTransferStore {
  @override
  Future<Either<DataStoreFailure, String>> exportToString() async {
    throw UnimplementedError('exportToString not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, String>> exportToFile({
    required String path,
  }) async {
    throw UnimplementedError('exportToFile not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, int>> importFromString(
    String data, {
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromString not yet implemented');
  }

  @override
  Future<Either<DataStoreFailure, int>> importFromFile({
    required String path,
    SinceWhenImportMode mode = SinceWhenImportMode.merge,
  }) async {
    throw UnimplementedError('importFromFile not yet implemented');
  }
}
