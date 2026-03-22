// since_when/test/src/records/record_tag_definition_test.dart

// ignore_for_file: lines_longer_than_80_chars, document_ignores, no_leading_underscores_for_local_identifiers

import 'package:flutter_test/flutter_test.dart';
import 'package:since_when/src/records/record_tag_definition.dart';

void main() {
  const _id = 1;
  const _created = 1700000000000;
  const _tagName = 'flutter';
  const _color = 0xFF2196F3;

  RecordTagDefinition _fullTag() => const RecordTagDefinition(
        id: _id,
        createdTimeStamp: _created,
        tagName: _tagName,
        color: _color,
      );

  RecordTagDefinition _minimalTag() => const RecordTagDefinition(
        createdTimeStamp: _created,
        tagName: _tagName,
        color: _color,
      );

  group('RecordTagDefinition constructor', () {
    test('sets all required fields', () {
      final tag = _minimalTag();

      expect(tag.id, isNull);
      expect(tag.createdTimeStamp, _created);
      expect(tag.tagName, _tagName);
      expect(tag.color, _color);
    });

    test('sets optional id', () {
      final tag = _fullTag();
      expect(tag.id, _id);
    });
  });

  group('RecordTagDefinition.fromRow', () {
    test('maps all columns', () {
      final row = <String, dynamic>{
        'id': _id,
        'createdTimeStamp': _created,
        'tagName': _tagName,
        'color': _color,
      };

      final tag = RecordTagDefinition.fromRow(row);

      expect(tag.id, _id);
      expect(tag.createdTimeStamp, _created);
      expect(tag.tagName, _tagName);
      expect(tag.color, _color);
    });
  });

  group('toRow', () {
    test('excludes id', () {
      final row = _fullTag().toRow();
      expect(row.containsKey('id'), isFalse);
    });

    test('includes all non-id fields with correct values', () {
      final row = _fullTag().toRow();

      expect(row['createdTimeStamp'], _created);
      expect(row['tagName'], _tagName);
      expect(row['color'], _color);
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

    test('replaces createdTimeStamp', () {
      const newTs = 1800000000000;
      final updated = _fullTag().copyWith(createdTimeStamp: newTs);
      expect(updated.createdTimeStamp, newTs);
    });

    test('replaces tagName', () {
      final updated = _fullTag().copyWith(tagName: 'dart');
      expect(updated.tagName, 'dart');
    });

    test('replaces color', () {
      const newColor = 0xFFFF5722;
      final updated = _fullTag().copyWith(color: newColor);
      expect(updated.color, newColor);
    });

    test('preserves tagName when only color replaced', () {
      const newColor = 0xFFFF5722;
      final updated = _fullTag().copyWith(color: newColor);
      expect(updated.tagName, _tagName);
    });

    test('preserves color when only tagName replaced', () {
      final updated = _fullTag().copyWith(tagName: 'dart');
      expect(updated.color, _color);
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

    test('not equal when createdTimeStamp differs', () {
      final a = _fullTag();
      final b = _fullTag().copyWith(createdTimeStamp: 9999999999999);
      expect(a, isNot(equals(b)));
    });

    test('not equal when tagName differs', () {
      final a = _fullTag();
      final b = _fullTag().copyWith(tagName: 'other');
      expect(a, isNot(equals(b)));
    });

    test('not equal when color differs', () {
      final a = _fullTag();
      final b = _fullTag().copyWith(color: 0xFF000000);
      expect(a, isNot(equals(b)));
    });

    test('props contains all fields in correct order', () {
      final tag = _fullTag();
      expect(tag.props, [_id, _created, _tagName, _color]);
    });
  });
}
