// test/nosql_box_missing_branches_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive_ce_flutter/hive_flutter.dart' show Box;
import 'package:nosql/nosql_ce/nosql_box.dart';

class MockBox<T> extends Mock implements Box<T> {}

void main() {
  group('NoSqlBox<T> missing branches', () {
    test('get() returns null when _box.get throws', () {
      final box = MockBox<String>();
      when(() => box.get('k', defaultValue: 'd')).thenThrow(Exception('boom'));
      final sut = NoSqlBox<String>(box);

      expect(sut.get('k', defaultValue: 'd'), isNull);
      verify(() => box.get('k', defaultValue: 'd')).called(1);
    });

    test('put() returns false when _box.put throws Exception', () async {
      final box = MockBox<String>();
      when(() => box.put('k', 'v')).thenThrow(Exception('boom'));
      final sut = NoSqlBox<String>(box);

      expect(await sut.put('k', 'v'), isFalse);
      verify(() => box.put('k', 'v')).called(1);
    });

    test(
      'close() returns true when ENOENT detected via message (not code)',
      () async {
        final box = MockBox<String>();
        when(() => box.close()).thenThrow(
          FileSystemException(
            'Cannot delete file',
            '/tmp/testbox.lock',
            const OSError(
              'No such file or directory',
              0,
            ), // triggers message branch
          ),
        );
        final sut = NoSqlBox<String>(box);

        expect(await sut.close(), isTrue);
        verify(() => box.close()).called(1);
      },
    );

    test('close() returns false on non-FileSystem Exception', () async {
      final box = MockBox<String>();
      when(() => box.close()).thenThrow(StateError('bad state'));
      final sut = NoSqlBox<String>(box);

      expect(await sut.close(), isFalse);
      verify(() => box.close()).called(1);
    });
  });
}
