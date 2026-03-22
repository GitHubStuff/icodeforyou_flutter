// since_when/test/src/records/record_tag_test.dart

// ignore_for_file: lines_longer_than_80_chars, document_ignores, no_leading_underscores_for_local_identifiers

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when/src/records/record_tag.dart';

void main() {
  const _id = 1;
  const _recordTs = 1700000000000;
  const _glossaryTs = 1700000001000;

  RecordTag _fullTag() => const RecordTag(
        id: _id,
        recordTimestamp: _recordTs,
        glossaryTimestamp: _glossaryTs,
      );

  RecordTag _minimalTag() => const RecordTag(
        recordTimestamp: _recordTs,
        glossaryTimestamp: _glossaryTs,
      );

  group('RecordTag constructor', () {
    test('sets all required fields', () {
      final tag = _minimalTag();

      expect(tag.id, isNull);
      expect(tag.recordTimestamp, _recordTs);
      expect(tag.glossaryTimestamp, _glossaryTs);
    });

    test('sets optional id', () {
      final tag = _fullTag();
      expect(tag.id, _id);
    });
  });

  group('RecordTag.fromRow', () {
    test('maps all columns', () {
      final row = <String, dynamic>{
        'id': _id,
        'record_timestamp': _recordTs,
        'glossary_timestamp': _glossaryTs,
      };

      final tag = RecordTag.fromRow(row);

      expect(tag.id, _id);
      expect(tag.recordTimestamp, _recordTs);
      expect(tag.glossaryTimestamp, _glossaryTs);
    });
  });

  group('toRow', () {
    test('excludes id', () {
      final row = _fullTag().toRow();
      expect(row.containsKey('id'), isFalse);
    });

    test('includes all non-id fields with correct values', () {
      final row = _fullTag().toRow();

      expect(row['record_timestamp'], _recordTs);
      expect(row['glossary_timestamp'], _glossaryTs);
    });
  });

  group('copyWith', () {
    test('returns equal record when no args provided', () {
      final tag = _fullTag();
      expect(tag.copyWith(), equals(tag));
    });

    test('replaces id', () {
      final updated = _fullTag().copyWith(id: 99);
      expect(updated.id, 99);
    });

    test('replaces recordTimestamp', () {
      const newTs = 1800000000000;
      final updated = _fullTag().copyWith(recordTimestamp: newTs);
      expect(updated.recordTimestamp, newTs);
    });

    test('replaces glossaryTimestamp', () {
      const newTs = 1800000001000;
      final updated = _fullTag().copyWith(glossaryTimestamp: newTs);
      expect(updated.glossaryTimestamp, newTs);
    });

    test('preserves recordTimestamp when only glossaryTimestamp replaced', () {
      const newTs = 1800000001000;
      final updated = _fullTag().copyWith(glossaryTimestamp: newTs);
      expect(updated.recordTimestamp, _recordTs);
    });

    test('preserves glossaryTimestamp when only recordTimestamp replaced', () {
      const newTs = 1800000000000;
      final updated = _fullTag().copyWith(recordTimestamp: newTs);
      expect(updated.glossaryTimestamp, _glossaryTs);
    });
  });

  group('Equatable', () {
    test('equal when all fields match', () {
      expect(_fullTag(), equals(_fullTag()));
    });

    test('not equal when id differs', () {
      final a = _fullTag();
      final b = _fullTag().copyWith(id: 42);
      expect(a, isNot(equals(b)));
    });

    test('not equal when recordTimestamp differs', () {
      final a = _fullTag();
      final b = _fullTag().copyWith(recordTimestamp: 9999999999999);
      expect(a, isNot(equals(b)));
    });

    test('not equal when glossaryTimestamp differs', () {
      final a = _fullTag();
      final b = _fullTag().copyWith(glossaryTimestamp: 9999999999999);
      expect(a, isNot(equals(b)));
    });

    test('props contains all fields in correct order', () {
      final tag = _fullTag();
      expect(tag.props, [_id, _recordTs, _glossaryTs]);
    });
  });
}
