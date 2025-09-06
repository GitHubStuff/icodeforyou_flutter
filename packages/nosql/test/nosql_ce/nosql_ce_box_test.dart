// nosql_ce_box_test.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nosql/nosql.dart' show NoSqlCEdb, resetForTesting;

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

  group('NoSqlCEBox', () {
    late NoSqlCEdb nosqlDb;

    setUp(() {
      nosqlDb = const NoSqlCEdb();
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

    group('get method', () {
      test('should return value when get succeeds', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('test_box');

        expect(box, isNotNull);
        if (box != null) {
          await box.put('key1', 'value1');
          final result = await box.get('key1');

          expect(result, equals('value1'));
        }

        await nosqlDb.deleteFromDevice();
      });

      test('should return default value when key not found', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('test_box');

        expect(box, isNotNull);
        if (box != null) {
          final result = await box.get('nonexistent', defaultValue: 'default');

          expect(result, equals('default'));
        }

        await nosqlDb.deleteFromDevice();
      });

      test('should return null when key not found and no default', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('test_box');

        expect(box, isNotNull);
        if (box != null) {
          final result = await box.get('nonexistent');

          expect(result, isNull);
        }

        await nosqlDb.deleteFromDevice();
      });

      test('should return null when get throws exception', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('exception_box');

        expect(box, isNotNull);
        if (box != null) {
          // Close the database which should invalidate the box
          await nosqlDb.deleteFromDevice();

          // Now trying to get should trigger the `on Object catch` block
          final result = await box.get('key1');

          expect(result, isNull);
        }

        // Clean up - db is already deleted above
      });
    });

    group('put method', () {
      test('should return true when put succeeds', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('test_box');

        expect(box, isNotNull);
        if (box != null) {
          final result = await box.put('key1', 'value1');

          expect(result, isTrue);

          final getValue = await box.get('key1');
          expect(getValue, equals('value1'));
        }

        await nosqlDb.deleteFromDevice();
      });

      test('should return false when put throws exception', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('exception_box');

        expect(box, isNotNull);
        if (box != null) {
          await nosqlDb.deleteFromDevice();

          final result = await box.put('key1', 'value1');

          expect(result, isFalse);
        }
      });

      test('should handle different key types', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('test_box');

        expect(box, isNotNull);
        if (box != null) {
          final result1 = await box.put('string_key', 'value1');
          final result2 = await box.put(42, 'value2');

          expect(result1, isTrue);
          expect(result2, isTrue);

          final getValue1 = await box.get('string_key');
          final getValue2 = await box.get(42);
          expect(getValue1, equals('value1'));
          expect(getValue2, equals('value2'));
        }

        await nosqlDb.deleteFromDevice();
      });
    });

    group('type safety', () {
      test('should work with int type', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<int>('int_box');

        expect(box, isNotNull);
        if (box != null) {
          final putResult = await box.put('int_key', 42);
          expect(putResult, isTrue);

          final getResult = await box.get('int_key');
          expect(getResult, equals(42));
        }

        await nosqlDb.deleteFromDevice();
      });

      test('should work with bool type', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<bool>('bool_box');

        expect(box, isNotNull);
        if (box != null) {
          final putResult = await box.put('bool_key', true);
          expect(putResult, isTrue);

          final getResult = await box.get('bool_key');
          expect(getResult, isTrue);
        }

        await nosqlDb.deleteFromDevice();
      });
    });

    group('integration tests', () {
      test('should handle multiple operations in sequence', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('integration_box');

        expect(box, isNotNull);
        if (box != null) {
          await box.put('key1', 'value1');
          await box.put('key2', 'value2');
          await box.put('key3', 'value3');

          final result1 = await box.get('key1');
          final result2 = await box.get('key2');
          final result3 = await box.get('key3');

          expect(result1, equals('value1'));
          expect(result2, equals('value2'));
          expect(result3, equals('value3'));
        }

        await nosqlDb.deleteFromDevice();
      });

      test('should handle overwriting existing values', () async {
        await nosqlDb.init();
        final box = await nosqlDb.openBox<String>('overwrite_box');

        expect(box, isNotNull);
        if (box != null) {
          await box.put('key', 'initial_value');
          final initial = await box.get('key');
          expect(initial, equals('initial_value'));

          await box.put('key', 'updated_value');
          final updated = await box.get('key');
          expect(updated, equals('updated_value'));
        }

        await nosqlDb.deleteFromDevice();
      });
    });
  });
}
