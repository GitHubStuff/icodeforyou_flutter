// test/src/since_when_failure_test.dart

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
  }) async => null;

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
    tempDir = await Directory.systemTemp.createTemp('since_when_failure_test_');
    PathProviderPlatform.instance = _MockPathProvider(tempDir.path);
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  group('SinceWhenFailure — toString', () {
    test('SinceWhenInvalidName toString', () {
      const failure = SinceWhenInvalidName();
      expect(
        failure.toString(),
        equals('SinceWhenInvalidName: name cannot be empty.'),
      );
    });

    test('SinceWhenAlreadyExists toString', () {
      const failure = SinceWhenAlreadyExists();
      expect(
        failure.toString(),
        equals('SinceWhenAlreadyExists: database file already exists.'),
      );
    });

    test('SinceWhenNotFound toString', () {
      const failure = SinceWhenNotFound();
      expect(
        failure.toString(),
        equals('SinceWhenNotFound: database file does not exist.'),
      );
    });

    test('SinceWhenOpenFailure toString includes cause', () {
      final cause = Exception('disk error');
      final failure = SinceWhenOpenFailure(cause);
      expect(failure.toString(), contains('SinceWhenOpenFailure'));
      expect(failure.toString(), contains('disk error'));
    });

    test('SinceWhenOpenFailure exposes cause', () {
      final cause = Exception('disk error');
      final failure = SinceWhenOpenFailure(cause);
      expect(failure.cause, equals(cause));
    });
  });
  group('SinceWhenDatabase properties', () {
    test('isInMemory is false for file-based database', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'props.sqlite',
        access: DatabaseAccess.automatic,
      );
      final db = result.getOrElse((_) => throw Exception());
      expect(db.isInMemory, isFalse);
      await db.close();
    });

    test('fullPath contains database name', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'path_check.sqlite',
        access: DatabaseAccess.automatic,
      );
      final db = result.getOrElse((_) => throw Exception());
      expect(db.fullPath, contains('path_check.sqlite'));
      await db.close();
    });

    test('isOpen reflects database state', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'state_check.sqlite',
        access: DatabaseAccess.automatic,
      );
      final db = result.getOrElse((_) => throw Exception());
      expect(db.isOpen, isTrue);
      await db.close();
      expect(db.isOpen, isFalse);
    });
  });
}
