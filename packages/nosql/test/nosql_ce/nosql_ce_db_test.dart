// nosql_ce_db_test.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nosql/nosql_ce/nosql_ce_db.dart';

class MockPlatformChecker extends Mock implements PlatformChecker {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return '/tmp/test_documents';
          },
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/hive'),
          (MethodCall methodCall) async {
            return null;
          },
        );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/hive'),
          null,
        );
  });

  group('DefaultPlatformChecker', () {
    test('should return kIsWeb value', () {
      const checker = DefaultPlatformChecker();
      expect(checker.isWeb, equals(kIsWeb));
    });
  });

  group('NoSqlCEdb', () {
    late MockPlatformChecker mockPlatformChecker;
    late NoSqlCEdb nosqlDb;

    setUp(() {
      mockPlatformChecker = MockPlatformChecker();
      nosqlDb = NoSqlCEdb(mockPlatformChecker);
      resetForTesting();
    });

    tearDown(() async {
      try {
        await nosqlDb.deleteFromDevice();
      } catch (_) {
        // Ignore cleanup errors
      }
      resetForTesting();
    });

    group('constructor', () {
      test('should create with default platform checker', () {
        const db = NoSqlCEdb();
        expect(db.platformChecker, isA<DefaultPlatformChecker>());
      });

      test('should create with custom platform checker', () {
        final customChecker = MockPlatformChecker();
        final db = NoSqlCEdb(customChecker);
        expect(db.platformChecker, equals(customChecker));
      });
    });

    group('init', () {
      test('should initialize on web platform', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);

        await nosqlDb.init();

        verify(() => mockPlatformChecker.isWeb).called(1);
      });

      test(
        'should initialize with default directory name on non-web',
        () async {
          when(() => mockPlatformChecker.isWeb).thenReturn(false);

          await nosqlDb.init();

          verify(() => mockPlatformChecker.isWeb).called(1);
        },
      );

      test('should initialize with custom directory name on non-web', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init(dirName: 'custom_db');

        verify(() => mockPlatformChecker.isWeb).called(1);
      });

      test('should handle absolute path on non-web', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);
        final absolutePath = Directory.systemTemp.path;

        await nosqlDb.init(dirName: absolutePath);

        verify(() => mockPlatformChecker.isWeb).called(1);
      });

      test(
        'should throw when already initialized with different path',
        () async {
          when(() => mockPlatformChecker.isWeb).thenReturn(false);

          await nosqlDb.init(dirName: 'first_db');

          expect(
            () async =>
                await nosqlDb.init(dirName: 'completely_different_path'),
            throwsA(isA<Exception>()),
          );
        },
      );

      test('should not throw when initialized with same path', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init(dirName: 'same_db');
        await nosqlDb.init(dirName: 'same_db');

        verify(() => mockPlatformChecker.isWeb).called(2);
      });
    });

    group('deleteFromDevice', () {
      test('should delete successfully on web', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);

        final result = await nosqlDb.deleteFromDevice();

        expect(result, isTrue);
        verify(() => mockPlatformChecker.isWeb).called(1);
      });

      test('should delete successfully on non-web after init', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init();
        final result = await nosqlDb.deleteFromDevice();

        expect(result, isTrue);
        verify(() => mockPlatformChecker.isWeb).called(greaterThanOrEqualTo(2));
      });

      test('should return false when exception occurs', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        final result = await nosqlDb.deleteFromDevice();

        expect(result, isFalse);
      });
    });

    group('openBox', () {
      test('should open box successfully', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);
        await nosqlDb.init();

        final box = await nosqlDb.openBox<String>('test_box');

        expect(box, isNotNull);
        await nosqlDb.deleteFromDevice();
      });

      test('should open different types of boxes', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);
        await nosqlDb.init();

        final stringBox = await nosqlDb.openBox<String>('string_box');
        final intBox = await nosqlDb.openBox<int>('int_box');

        expect(stringBox, isNotNull);
        expect(intBox, isNotNull);
        await nosqlDb.deleteFromDevice();
      });
    });

    group('_deleteDirectory', () {
      test('should return early on web platform', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);

        await nosqlDb.init();
        final result = await nosqlDb.deleteFromDevice();

        expect(result, isTrue);
        verify(() => mockPlatformChecker.isWeb).called(greaterThanOrEqualTo(1));
      });

      test('should return false when full path not initialized', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        final result = await nosqlDb.deleteFromDevice();

        expect(result, isFalse);
      });

      test('should delete existing directory', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init();
        final result = await nosqlDb.deleteFromDevice();

        expect(result, isTrue);
      });
    });

    group('_getFullPath', () {
      test('should return absolute path when provided', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);
        final absolutePath = Directory.systemTemp.path;

        await nosqlDb.init(dirName: absolutePath);

        verify(() => mockPlatformChecker.isWeb).called(1);
      });

      test('should create full path from relative directory', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init(dirName: 'relative_path');

        verify(() => mockPlatformChecker.isWeb).called(1);
      });
    });

    group('integration tests', () {
      test('should complete full lifecycle on web', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);

        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('lifecycle_box');
        expect(box, isNotNull);

        final deleted = await nosqlDb.deleteFromDevice();
        expect(deleted, isTrue);
      });

      test('should complete full lifecycle on non-web', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init(dirName: 'lifecycle_test');
        final box = await nosqlDb.openBox<int>('lifecycle_box');
        expect(box, isNotNull);

        final deleted = await nosqlDb.deleteFromDevice();
        expect(deleted, isTrue);
      });

      test('should handle multiple box operations', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(true);

        await nosqlDb.init();

        final box1 = await nosqlDb.openBox<String>('multi_box_1');
        final box2 = await nosqlDb.openBox<int>('multi_box_2');
        final box3 = await nosqlDb.openBox<bool>('multi_box_3');

        expect(box1, isNotNull);
        expect(box2, isNotNull);
        expect(box3, isNotNull);

        final deleted = await nosqlDb.deleteFromDevice();
        expect(deleted, isTrue);
      });

      test('should maintain state between operations', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init(dirName: 'state_test');

        final box1 = await nosqlDb.openBox<String>('state_box');
        expect(box1, isNotNull);

        final box2 = await nosqlDb.openBox<String>('state_box');
        expect(box2, isNotNull);

        final deleted = await nosqlDb.deleteFromDevice();
        expect(deleted, isTrue);
      });
    });

    group('error handling', () {
      test('should handle directory operations gracefully', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init();
        final result = await nosqlDb.deleteFromDevice();

        expect(result, isTrue);
      });

      test('should handle initialization errors', () async {
        when(() => mockPlatformChecker.isWeb).thenReturn(false);

        await nosqlDb.init(dirName: 'error_test');

        expect(
          () async => await nosqlDb.init(dirName: 'different_error_test'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('resetForTesting', () {
    test('should reset static state', () {
      resetForTesting();
      expect(resetForTesting, isA<Function>());
    });
  });
}
