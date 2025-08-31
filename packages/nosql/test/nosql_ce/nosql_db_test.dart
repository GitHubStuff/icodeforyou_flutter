// test/nosql_db_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nosql/abstract/nosql_db.dart' show NoSqlDB;
import 'package:nosql/nosql_ce/nosql_box.dart' show NoSqlBox;
import 'package:nosql/nosql_ce/nosql_db.dart';

class MockPlatformChecker extends Mock implements PlatformChecker {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NoSqlHive Tests', () {
    late MockPlatformChecker mockPlatformChecker;

    setUp(() {
      mockPlatformChecker = MockPlatformChecker();
      resetForTesting();
    });

    tearDown(() async {
      try {
        await Hive.deleteFromDisk();
      } catch (e) {
        // Ignore cleanup errors
      }
      resetForTesting();
    });

    group('web platform tests', () {
      test('should initialize for web platform', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);
        final nosqlHive = NoSqlHiveImpl(mockPlatformChecker);

        await nosqlHive.init();

        verify(() => mockPlatformChecker.isWeb).called(1);
      });

      test('should delete on web platform', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);
        final nosqlHive = NoSqlHiveImpl(mockPlatformChecker);

        final result = await nosqlHive.deleteFromDevice();

        expect(result, isTrue);
        verify(() => mockPlatformChecker.isWeb).called(1);
      });

      test('should open box on web', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);
        final nosqlHive = NoSqlHiveImpl(mockPlatformChecker);

        await nosqlHive.init();
        final box = await nosqlHive.openBox<String>('testBox');

        expect(box, isNotNull);
        expect(box, isA<NoSqlBox<String>>());
      });
    });

    group('non-web platform tests', () {
      test('should initialize for non-web with absolute path', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);
        final nosqlHive = NoSqlHiveImpl(mockPlatformChecker);
        final tempDir = Directory.systemTemp.createTempSync();

        try {
          await nosqlHive.init(dirName: tempDir.path);
          verify(() => mockPlatformChecker.isWeb).called(1);
        } finally {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('should throw when reinitializing with different path', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);
        final nosqlHive = NoSqlHiveImpl(mockPlatformChecker);
        final tempDir1 = Directory.systemTemp.createTempSync();
        final tempDir2 = Directory.systemTemp.createTempSync();

        try {
          await nosqlHive.init(dirName: tempDir1.path);

          expect(
            () async => await nosqlHive.init(dirName: tempDir2.path),
            throwsA(isA<Exception>()),
          );
        } finally {
          tempDir1.deleteSync(recursive: true);
          tempDir2.deleteSync(recursive: true);
        }
      });

      test('should delete on non-web platform', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);
        final nosqlHive = NoSqlHiveImpl(mockPlatformChecker);
        final tempDir = Directory.systemTemp.createTempSync();

        try {
          await nosqlHive.init(dirName: tempDir.path);
          final result = await nosqlHive.deleteFromDevice();
          expect(result, isTrue);
        } finally {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        }
      });

      test('should return false when deletion fails', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);
        final nosqlHive = NoSqlHiveImpl(mockPlatformChecker);

        final result = await nosqlHive.deleteFromDevice();
        expect(result, isFalse);
      });
    });

    group('utility tests', () {
      test('should reset for testing', () {
        expect(() => resetForTesting(), returnsNormally);
      });

      test('constant should implement NoSqlDB', () {
        expect(NoSqlHive, isA<NoSqlDB>());
      });
    });
  });
}
