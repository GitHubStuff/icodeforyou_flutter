// test/src/domain/log_record_test.dart

// ignore_for_file: lines_longer_than_80_chars, document_ignores, no_leading_underscores_for_local_identifiers

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:since_when/src/domain/log_action.dart';
import 'package:since_when/src/domain/log_record.dart';

void main() {
  const _id = 1;
  const _logTs = 1700000000000;
  const _action = LogAction.create;
  const _tableName = 'since_when';
  const _targetId = 1699999999000;
  const _detail = 'some detail';

  LogRecord _fullRecord() => const LogRecord(
        id: _id,
        logTimeStamp: _logTs,
        action: _action,
        tableName: _tableName,
        targetId: _targetId,
        detail: _detail,
      );

  LogRecord _minimalRecord() => const LogRecord(
        logTimeStamp: _logTs,
        action: _action,
        tableName: _tableName,
      );

  group('LogRecord constructor', () {
    test('sets all required fields', () {
      final record = _minimalRecord();

      expect(record.id, isNull);
      expect(record.logTimeStamp, _logTs);
      expect(record.action, _action);
      expect(record.tableName, _tableName);
      expect(record.targetId, isNull);
      expect(record.detail, isNull);
    });

    test('sets all optional fields', () {
      final record = _fullRecord();

      expect(record.id, _id);
      expect(record.targetId, _targetId);
      expect(record.detail, _detail);
    });
  });

  group('LogRecord.fromRow', () {
    test('maps all columns including nullables', () {
      final row = <String, dynamic>{
        'id': _id,
        'logTimeStamp': _logTs,
        'action': 'create',
        'tableName': _tableName,
        'targetId': _targetId,
        'detail': _detail,
      };

      final record = LogRecord.fromRow(row);

      expect(record.id, _id);
      expect(record.logTimeStamp, _logTs);
      expect(record.action, LogAction.create);
      expect(record.tableName, _tableName);
      expect(record.targetId, _targetId);
      expect(record.detail, _detail);
    });

    test('maps all LogAction values', () {
      for (final action in LogAction.values) {
        final row = <String, dynamic>{
          'id': _id,
          'logTimeStamp': _logTs,
          'action': action.name,
          'tableName': _tableName,
          'targetId': null,
          'detail': null,
        };

        final record = LogRecord.fromRow(row);
        expect(record.action, action);
      }
    });

    test('maps null optional columns', () {
      final row = <String, dynamic>{
        'id': _id,
        'logTimeStamp': _logTs,
        'action': 'delete',
        'tableName': _tableName,
        'targetId': null,
        'detail': null,
      };

      final record = LogRecord.fromRow(row);

      expect(record.targetId, isNull);
      expect(record.detail, isNull);
    });
  });

  group('toRow', () {
    test('excludes id', () {
      final row = _fullRecord().toRow();
      expect(row.containsKey('id'), isFalse);
    });

    test('includes all non-id fields with correct values', () {
      final row = _fullRecord().toRow();

      expect(row['logTimeStamp'], _logTs);
      expect(row['action'], 'create');
      expect(row['tableName'], _tableName);
      expect(row['targetId'], _targetId);
      expect(row['detail'], _detail);
    });

    test('includes null optional fields', () {
      final row = _minimalRecord().toRow();

      expect(row['targetId'], isNull);
      expect(row['detail'], isNull);
    });

    test('serialises all LogAction values by name', () {
      for (final action in LogAction.values) {
        final record = LogRecord(
          logTimeStamp: _logTs,
          action: action,
          tableName: _tableName,
        );
        expect(record.toRow()['action'], action.name);
      }
    });
  });

  group('copyWith', () {
    test('returns equal record when no args provided', () {
      final record = _fullRecord();
      expect(record.copyWith(), equals(record));
    });

    test('replaces id', () {
      final updated = _fullRecord().copyWith(id: 99);
      expect(updated.id, 99);
    });

    test('replaces logTimeStamp', () {
      const newTs = 1800000000000;
      final updated = _fullRecord().copyWith(logTimeStamp: newTs);
      expect(updated.logTimeStamp, newTs);
    });

    test('replaces action', () {
      final updated = _fullRecord().copyWith(action: LogAction.delete);
      expect(updated.action, LogAction.delete);
    });

    test('replaces tableName', () {
      final updated = _fullRecord().copyWith(tableName: 'other_table');
      expect(updated.tableName, 'other_table');
    });

    test('sets targetId to a value via Some', () {
      const newTarget = 1600000000000;
      final updated = _minimalRecord().copyWith(
        targetId: const Some(newTarget),
      );
      expect(updated.targetId, newTarget);
    });

    test('clears targetId to null via None', () {
      final updated = _fullRecord().copyWith(targetId: const None());
      expect(updated.targetId, isNull);
    });

    test('preserves targetId when arg is omitted', () {
      final updated = _fullRecord().copyWith(tableName: 'changed');
      expect(updated.targetId, _targetId);
    });

    test('sets detail to a value via Some', () {
      final updated = _minimalRecord().copyWith(
        detail: const Some('new detail'),
      );
      expect(updated.detail, 'new detail');
    });

    test('clears detail to null via None', () {
      final updated = _fullRecord().copyWith(detail: const None());
      expect(updated.detail, isNull);
    });

    test('preserves detail when arg is omitted', () {
      final updated = _fullRecord().copyWith(tableName: 'changed');
      expect(updated.detail, _detail);
    });
  });

  group('Equatable', () {
    test('equal when all fields match', () {
      expect(_fullRecord(), equals(_fullRecord()));
    });

    test('not equal when id differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(id: 42);
      expect(a, isNot(equals(b)));
    });

    test('not equal when logTimeStamp differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(logTimeStamp: 9999999999999);
      expect(a, isNot(equals(b)));
    });

    test('not equal when action differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(action: LogAction.update);
      expect(a, isNot(equals(b)));
    });

    test('not equal when tableName differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(tableName: 'other');
      expect(a, isNot(equals(b)));
    });

    test('not equal when targetId differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(targetId: const None());
      expect(a, isNot(equals(b)));
    });

    test('not equal when detail differs', () {
      final a = _fullRecord();
      final b = _fullRecord().copyWith(detail: const None());
      expect(a, isNot(equals(b)));
    });

    test('props contains all fields', () {
      final record = _fullRecord();
      expect(
        record.props,
        [_id, _logTs, _action, _tableName, _targetId, _detail],
      );
    });
  });
}
