// test/src/presentation/cubits/time_picker/time_picker_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/time_picker/time_picker_cubit.dart';

void main() {
  group('TimePickerState', () {
    test('should create with required values', () {
      final dateTime = DateTime(2024, 1, 1, 14, 30, 45);
      final state = TimePickerState(dateTime: dateTime);

      expect(state.dateTime, equals(dateTime));
      expect(state.isScrolling, false);
    });

    test('should create with custom scrolling state', () {
      final dateTime = DateTime(2024, 1, 1, 14, 30, 45);
      final state = TimePickerState(
        dateTime: dateTime,
        isScrolling: true,
      );

      expect(state.dateTime, equals(dateTime));
      expect(state.isScrolling, true);
    });

    group('hour12 getter', () {
      test('should return 12 for midnight (0 hours)', () {
        final state = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 0, 30, 0),
        );
        expect(state.hour12, 12);
      });

      test('should return 12 for noon (12 hours)', () {
        final state = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 30, 0),
        );
        expect(state.hour12, 12);
      });

      test('should return morning hours as is (1-11)', () {
        for (int hour = 1; hour <= 11; hour++) {
          final state = TimePickerState(
            dateTime: DateTime(2024, 1, 1, hour, 0, 0),
          );
          expect(state.hour12, hour);
        }
      });

      test('should convert afternoon hours (13-23)', () {
        for (int hour = 13; hour <= 23; hour++) {
          final state = TimePickerState(
            dateTime: DateTime(2024, 1, 1, hour, 0, 0),
          );
          expect(state.hour12, hour - 12);
        }
      });
    });

    group('isAm getter', () {
      test('should return true for morning hours (0-11)', () {
        for (int hour = 0; hour <= 11; hour++) {
          final state = TimePickerState(
            dateTime: DateTime(2024, 1, 1, hour, 0, 0),
          );
          expect(state.isAm, true, reason: 'Hour $hour should be AM');
        }
      });

      test('should return false for afternoon hours (12-23)', () {
        for (int hour = 12; hour <= 23; hour++) {
          final state = TimePickerState(
            dateTime: DateTime(2024, 1, 1, hour, 0, 0),
          );
          expect(state.isAm, false, reason: 'Hour $hour should be PM');
        }
      });
    });

    group('minute and second getters', () {
      test('should return correct minute', () {
        final state = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 45, 30),
        );
        expect(state.minute, 45);
      });

      test('should return correct second', () {
        final state = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 45, 30),
        );
        expect(state.second, 30);
      });
    });

    group('copyWith', () {
      test('should copy with new dateTime', () {
        final original = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 0),
          isScrolling: true,
        );

        final newDateTime = DateTime(2024, 1, 2, 15, 45, 30);
        final modified = original.copyWith(dateTime: newDateTime);

        expect(modified.dateTime, equals(newDateTime));
        expect(modified.isScrolling, true); // Preserved
      });

      test('should copy with new scrolling state', () {
        final original = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 0),
          isScrolling: false,
        );

        final modified = original.copyWith(isScrolling: true);

        expect(modified.dateTime, equals(original.dateTime));
        expect(modified.isScrolling, true);
      });

      test('should preserve values when not specified', () {
        final original = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 0),
          isScrolling: true,
        );

        final copy = original.copyWith();

        expect(copy.dateTime, equals(original.dateTime));
        expect(copy.isScrolling, original.isScrolling);
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final dateTime = DateTime(2024, 1, 1, 14, 30, 0);
        final state1 = TimePickerState(dateTime: dateTime);
        final state2 = TimePickerState(dateTime: dateTime);

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('should not be equal when dateTime differs', () {
        final state1 = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 0),
        );
        final state2 = TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 1),
        );

        expect(state1, isNot(equals(state2)));
      });

      test('should not be equal when scrolling differs', () {
        final dateTime = DateTime(2024, 1, 1, 14, 30, 0);
        final state1 = TimePickerState(
          dateTime: dateTime,
          isScrolling: true,
        );
        final state2 = TimePickerState(
          dateTime: dateTime,
          isScrolling: false,
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    test('stringify should return true', () {
      final state = TimePickerState(
        dateTime: DateTime(2024, 1, 1, 14, 30, 0),
      );

      expect(state.stringify, true);

      // This should produce a readable string representation
      final stateString = state.toString();
      expect(stateString, contains('TimePickerState'));
      expect(stateString, contains('2024-01-01'));
    });

    test('props should contain dateTime and isScrolling', () {
      final dateTime = DateTime(2024, 1, 1, 14, 30, 0);
      final state = TimePickerState(
        dateTime: dateTime,
        isScrolling: true,
      );

      expect(state.props, equals([dateTime, true]));
    });
  });
}
