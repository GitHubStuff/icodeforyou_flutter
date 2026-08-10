// packages/ice_chips/test/src/glossary_types_todo_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:ice_chips/src/glossary_types_todo.dart'
    show RecordTagDefinition, SinceWhenFailure;
import 'package:since_when_framework/database.dart'
    show DatabaseOpenFailure;

/// Concrete [DatabaseOpenFailure] used as the wrapped cause under test.
const _kCause = DatabaseOpenFailure('boom');

/// Reference record used across the [RecordTagDefinition] tests.
const _kRecord = RecordTagDefinition(
  id: 7,
  createdTimeStamp: 1000,
  tagName: 'ALPHA',
  color: 0xFF112233,
);

void main() {
  group('SinceWhenFailure', () {
    test('exposes its cause and value equality via props', () {
      const a = SinceWhenFailure(_kCause);
      const b = SinceWhenFailure(_kCause);
      expect(a.cause, same(_kCause));
      expect(a, equals(b));
      expect(a.props, [_kCause]);
    });

    test('toString includes the cause', () {
      expect(
        const SinceWhenFailure(_kCause).toString(),
        'SinceWhenFailure: DatabaseOpenFailure: boom',
      );
    });
  });

  group('RecordTagDefinition', () {
    test('id defaults to null for unpersisted records', () {
      const record = RecordTagDefinition(
        createdTimeStamp: 1,
        tagName: 'NEW',
        color: 0xFF000000,
      );
      expect(record.id, isNull);
    });

    test('copyWith with no arguments returns an equal record', () {
      final copy = _kRecord.copyWith();
      expect(copy, equals(_kRecord));
      expect(copy.id, 7);
      expect(copy.createdTimeStamp, 1000);
      expect(copy.tagName, 'ALPHA');
      expect(copy.color, 0xFF112233);
    });

    test('copyWith replaces every provided field', () {
      final copy = _kRecord.copyWith(
        id: 8,
        createdTimeStamp: 2000,
        tagName: 'BETA',
        color: 0xFF445566,
      );
      expect(copy.id, 8);
      expect(copy.createdTimeStamp, 2000);
      expect(copy.tagName, 'BETA');
      expect(copy.color, 0xFF445566);
    });

    test('props carry all four fields', () {
      expect(_kRecord.props, [7, 1000, 'ALPHA', 0xFF112233]);
    });
  });
}
