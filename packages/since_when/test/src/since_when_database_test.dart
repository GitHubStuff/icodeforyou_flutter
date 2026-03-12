// test/src/since_when_database_test.dart

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
    tempDir = await Directory.systemTemp.createTemp('since_when_test_');
    PathProviderPlatform.instance = _MockPathProvider(tempDir.path);
  });

  tearDown(() async {
    SinceWhenDatabase.resetOpenOrCreateOverride();
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  group('SinceWhenDatabase.inMemory', () {
    test('opens successfully', () async {
      final db = await SinceWhenDatabase.inMemory();
      expect(db.isOpen, isTrue);
      expect(db.isInMemory, isTrue);
      await db.close();
    });
    test('is not open after close', () async {
      final db = await SinceWhenDatabase.inMemory();
      await db.close();
      expect(db.isOpen, isFalse);
    });
    test('each call returns an independent instance', () async {
      final a = await SinceWhenDatabase.inMemory();
      final b = await SinceWhenDatabase.inMemory();
      expect(identical(a, b), isFalse);
      await a.close();
      await b.close();
    });
    test('fullPath is :memory:', () async {
      final db = await SinceWhenDatabase.inMemory();
      expect(db.fullPath, equals(':memory:'));
      await db.close();
    });
  });

  group('SinceWhenDatabase.open — automatic', () {
    test('creates database when file absent', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'auto_new.sqlite',
        access: DatabaseAccess.automatic,
      );
      expect(result.isRight(), isTrue);
      await result.getOrElse((_) => throw Exception()).close();
    });
    test('opens database when file present', () async {
      final first = await SinceWhenDatabase.open(
        dbName: 'auto_existing.sqlite',
        access: DatabaseAccess.automatic,
      );
      await first.getOrElse((_) => throw Exception()).close();
      final second = await SinceWhenDatabase.open(
        dbName: 'auto_existing.sqlite',
        access: DatabaseAccess.automatic,
      );
      expect(second.isRight(), isTrue);
      await second.getOrElse((_) => throw Exception()).close();
    });
  });

  group('SinceWhenDatabase.open — create', () {
    test('creates database when file absent', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'create_new.sqlite',
        access: DatabaseAccess.create,
      );
      expect(result.isRight(), isTrue);
      await result.getOrElse((_) => throw Exception()).close();
    });
    test('fails when file already exists', () async {
      final first = await SinceWhenDatabase.open(
        dbName: 'create_existing.sqlite',
        access: DatabaseAccess.create,
      );
      await first.getOrElse((_) => throw Exception()).close();
      final second = await SinceWhenDatabase.open(
        dbName: 'create_existing.sqlite',
        access: DatabaseAccess.create,
      );
      expect(second.isLeft(), isTrue);
      final failure = second.swap().getOrElse((_) => throw Exception());
      expect(failure, isA<SinceWhenAlreadyExists>());
    });
  });

  group('SinceWhenDatabase.open — open', () {
    test('fails when file does not exist', () async {
      final result = await SinceWhenDatabase.open(
        dbName: 'nonexistent.sqlite',
        access: DatabaseAccess.open,
      );
      expect(result.isLeft(), isTrue);
      final failure = result.swap().getOrElse((_) => throw Exception());
      expect(failure, isA<SinceWhenNotFound>());
    });
    test('opens when file exists', () async {
      final created = await SinceWhenDatabase.open(
        dbName: 'open_existing.sqlite',
        access: DatabaseAccess.create,
      );
      await created.getOrElse((_) => throw Exception()).close();
      final opened = await SinceWhenDatabase.open(
        dbName: 'open_existing.sqlite',
        access: DatabaseAccess.open,
      );
      expect(opened.isRight(), isTrue);
      await opened.getOrElse((_) => throw Exception()).close();
    });
  });

  group('SinceWhenDatabase.open — validation', () {
    test('fails on empty name', () async {
      final result = await SinceWhenDatabase.open(dbName: '   ');
      expect(result.isLeft(), isTrue);
      final failure = result.swap().getOrElse((_) => throw Exception());
      expect(failure, isA<SinceWhenInvalidName>());
    });
    test('returns SinceWhenOpenFailure when initializer throws', () async {
      SinceWhenDatabase.openOrCreateOverride = ({
        required String dbName,
        required String dbPath,
      }) =>
          throw Exception('forced failure');
      final result = await SinceWhenDatabase.open(
        dbName: 'throw_test.sqlite',
        access: DatabaseAccess.automatic,
      );
      expect(result.isLeft(), isTrue);
      final failure = result.swap().getOrElse((_) => throw Exception());
      expect(failure, isA<SinceWhenOpenFailure>());
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
