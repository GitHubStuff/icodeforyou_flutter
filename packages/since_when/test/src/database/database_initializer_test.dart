// test/src/database/database_initializer_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:since_when/since_when.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _MockPathProvider
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _MockPathProvider(this._tempDir);
  final String _tempDir;
  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDir;
  @override
  Future<String?> getApplicationCachePath() async => _tempDir;
  @override
  Future<String?> getTemporaryPath() async => _tempDir;
  @override
  Future<String?> getApplicationSupportPath() async => _tempDir;
  @override
  Future<String?> getLibraryPath() async => null;
  @override
  Future<String?> getDownloadsPath() async => null;
  @override
  Future<List<String>?> getExternalCachePaths() async => null;
  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async =>
      null;
  @override
  Future<String?> getExternalStoragePath() async => null;
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('db_init_test_');
    PathProviderPlatform.instance = _MockPathProvider(tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  group('SinceWhenDatabase.open — path normalisation', () {
    test('empty dbPath resolves directly to documents directory', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'empty_path.sqlite',
        dbPath: '',
        access: DatabaseAccess.automatic,
      );
      expect(result.isRight(), isTrue);
      final db = result.getOrElse((_) => throw Exception());
      expect(db.fullPath, equals('${tempDir.path}/empty_path.sqlite'));
      await db.close();
    });

    test('leading slash in dbPath is stripped', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'leading.sqlite',
        dbPath: '/sub',
        access: DatabaseAccess.automatic,
      );
      expect(result.isRight(), isTrue);
      final db = result.getOrElse((_) => throw Exception());
      expect(db.fullPath, equals('${tempDir.path}/sub/leading.sqlite'));
      await db.close();
    });

    test('trailing slash in dbPath is stripped', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'trailing.sqlite',
        dbPath: 'sub/',
        access: DatabaseAccess.automatic,
      );
      expect(result.isRight(), isTrue);
      final db = result.getOrElse((_) => throw Exception());
      expect(db.fullPath, equals('${tempDir.path}/sub/trailing.sqlite'));
      await db.close();
    });

    test('leading and trailing slashes in dbPath are both stripped', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'both.sqlite',
        dbPath: '/sub/',
        access: DatabaseAccess.automatic,
      );
      expect(result.isRight(), isTrue);
      final db = result.getOrElse((_) => throw Exception());
      expect(db.fullPath, equals('${tempDir.path}/sub/both.sqlite'));
      await db.close();
    });
  });
}
