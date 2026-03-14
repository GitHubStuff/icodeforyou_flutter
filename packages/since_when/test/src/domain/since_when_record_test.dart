// test/src/domain/since_when_record_test.dart

// ignore_for_file: lines_longer_than_80_chars, document_ignores, no_leading_underscores_for_local_identifiers

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/domain/since_when_record.dart';

void main() {
  const _id = 1;
  const _created = 1700000000000;
  const _parent = 1699999999000;
  const _reviewed = 1700000001000;
  const _edited = 1700000002000;
  const _meta = 1700000003000;
  const _metaData = 'some meta';
  const _sequence = 0;
  const _data = 'some data';
  const _category = 'some category';

  SinceWhenRecord _fullRecord() => const SinceWhenRecord(
    id: _id,
    createdTimeStamp: _created,
    parentTimeStamp: _parent,
    reviewedTimeStamp: _reviewed,
    editedTimeStamp: _edited,
    metaTimeStamp: _meta,
    metaData: _metaData,
    sequenceNumber: _sequence,
    dataString: _data,
    category: _category,
  );

  SinceWhenRecord _minimalRecord() => const SinceWhenRecord(
    createdTimeStamp: _created,
    reviewedTimeStamp: _reviewed,
    editedTimeStamp: _edited,
    metaData: _metaData,
    sequenceNumber: _sequence,
    dataString: _data,
    category: _category,
  );

  group('SinceWhenRecord constructor', () {
    test('sets all required fields', () {
      final record = _minimalRecord();

      expect(record.id, isNull);
      expect(record.createdTimeStamp, _created);
      expect(record.parentTimeStamp, isNull);
      expect(record.reviewedTimeStamp, _reviewed);
      expect(record.editedTimeStamp, _edited);
      expect(record.metaTimeStamp, isNull);
      expect(record.metaData, _metaData);
      expect(record.sequenceNumber, _sequence);
      expect(record.dataString, _data);
      expect(record.category, _category);
    });

    test('sets all optional fields', () {
      final record = _fullRecord();

      expect(record.id, _id);
      expect(record.parentTimeStamp, _parent);
      expect(record.metaTimeStamp, _meta);
    });
  });

  group('SinceWhenRecord.fromRow', () {
    test('maps all columns including nullables', () {
      final row = <String, dynamic>{
        'id': _id,
        'createdTimeStamp': _created,
        'parentTimeStamp': _parent,
        'reviewedTimeStamp': _reviewed,
        'editedTimeStamp': _edited,
        'metaTimeStamp': _meta,
        'metaData': _metaData,
        'sequenceNumber': _sequence,
        'dataString': _data,
        'category': _category,
      };

      final record = SinceWhenRecord.fromRow(row);

      expect(record.id, _id);
      expect(record.createdTimeStamp, _created);
      expect(record.parentTimeStamp, _parent);
      expect(record.reviewedTimeStamp, _reviewed);
      expect(record.editedTimeStamp, _edited);
      expect(record.metaTimeStamp, _meta);
      expect(record.metaData, _metaData);
      expect(record.sequenceNumber, _sequence);
      expect(record.dataString, _data);
      expect(record.category, _category);
    });

    test('maps null optional columns', () {
      final row = <String, dynamic>{
        'id': _id,
        'createdTimeStamp': _created,
        'parentTimeStamp': null,
        'reviewedTimeStamp': _reviewed,
        'editedTimeStamp': _edited,
        'metaTimeStamp': null,
        'metaData': _metaData,
        'sequenceNumber': _sequence,
        'dataString': _data,
        'category': _category,
      };

      final record = SinceWhenRecord.fromRow(row);

      expect(record.parentTimeStamp, isNull);
      expect(record.metaTimeStamp, isNull);
    });
  });

  group('toRow', () {
    test('excludes id', () {
      final row = _fullRecord().toRow();
      expect(row.containsKey('id'), isFalse);
    });

    test('includes all non-id fields with correct values', () {
      final row = _fullRecord().toRow();

      expect(row['createdTimeStamp'], _created);
      expect(row['parentTimeStamp'], _parent);
      expect(row['reviewedTimeStamp'], _reviewed);
      expect(row['editedTimeStamp'], _edited);
      expect(row['metaTimeStamp'], _meta);
      expect(row['metaData'], _metaData);
      expect(row['sequenceNumber'], _sequence);
      expect(row['dataString'], _data);
      expect(row['category'], _category);
    });

    test('includes null optional fields', () {
      final row = _minimalRecord().toRow();

      expect(row['parentTimeStamp'], isNull);
      expect(row['metaTimeStamp'], isNull);
    });
  });

  group('copyWith', () {
    test('returns equal record when no args provided', () {
      final record = _fullRecord();
      expect(record.copyWith(), equals(record));
    });

    test('replaces required int fields', () {
      const newCreated = 1800000000000;
      const newReviewed = 1800000001000;
      const newEdited = 1800000002000;
      const newSequence = 3;

      final updated = _fullRecord().copyWith(
        createdTimeStamp: newCreated,
        reviewedTimeStamp: newReviewed,
        editedTimeStamp: newEdited,
        sequenceNumber: newSequence,
      );

      expect(updated.createdTimeStamp, newCreated);
      expect(updated.reviewedTimeStamp, newReviewed);
      expect(updated.editedTimeStamp, newEdited);
      expect(updated.sequenceNumber, newSequence);
    });

    test('replaces required String fields', () {
      const newMeta = 'new meta';
      const newData = 'new data';
      const newCategory = 'new category';

      final updated = _fullRecord().copyWith(
        metaData: newMeta,
        dataString: newData,
        category: newCategory,
      );

      expect(updated.metaData, newMeta);
      expect(updated.dataString, newData);
      expect(updated.category, newCategory);
    });

    test('replaces id', () {
      final updated = _fullRecord().copyWith(id: 99);
      expect(updated.id, 99);
    });

    test('sets parentTimeStamp to a value via Some', () {
      const newParent = 1600000000000;
      final updated = _minimalRecord().copyWith(
        parentTimeStamp: const Some(_parent),
      );
      expect(updated.parentTimeStamp, _parent);
      final updated2 = updated.copyWith(
        parentTimeStamp: const Some(newParent),
      );
      expect(updated2.parentTimeStamp, newParent);
    });

    test('clears parentTimeStamp to null via None', () {
      final updated = _fullRecord().copyWith(
        parentTimeStamp: const None(),
      );
      expect(updated.parentTimeStamp, isNull);
    });

    test('preserves parentTimeStamp when arg is omitted', () {
      final updated = _fullRecord().copyWith(metaData: 'changed');
      expect(updated.parentTimeStamp, _parent);
    });

    test('sets metaTimeStamp to a value via Some', () {
      final updated = _minimalRecord().copyWith(
        metaTimeStamp: const Some(_meta),
      );
      expect(updated.metaTimeStamp, _meta);
    });

    test('clears metaTimeStamp to null via None', () {
      final updated = _fullRecord().copyWith(
        metaTimeStamp: const None(),
      );
      expect(updated.metaTimeStamp, isNull);
    });

    test('preserves metaTimeStamp when arg is omitted', () {
      final updated = _fullRecord().copyWith(metaData: 'changed');
      expect(updated.metaTimeStamp, _meta);
    });
  });

  group('Equatable', () {
    test('equal when all fields match', () {
      expect(_fullRecord(), equals(_fullRecord()));
    });

    test('not equal when createdTimeStamp differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(createdTimeStamp: 9999999999999);
      expect(a, isNot(equals(b)));
    });

    test('not equal when id differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(id: 42);
      expect(a, isNot(equals(b)));
    });

    test('not equal when nullable field differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(parentTimeStamp: const None());
      expect(a, isNot(equals(b)));
    });

    test('props contains all fields', () {
      final record = _fullRecord();
      expect(
        record.props,
        [
          _id,
          _created,
          _parent,
          _reviewed,
          _edited,
          _meta,
          _metaData,
          _sequence,
          _data,
          _category,
        ],
      );
    });
  });
}
