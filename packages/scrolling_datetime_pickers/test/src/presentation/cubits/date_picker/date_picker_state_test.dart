// test/src/presentation/cubits/date_picker/date_picker_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/date_picker/date_picker_cubit.dart';

void main() {
  group('DatePickerState', () {
    test('should create state with required date', () {
      final date = DateTime(2024, 6, 15);
      final state = DatePickerState(date: date);

      expect(state.date, date);
      expect(state.isScrolling, false);
    });

    test('should create state with scrolling flag', () {
      final date = DateTime(2024, 6, 15);
      final state = DatePickerState(date: date, isScrolling: true);

      expect(state.date, date);
      expect(state.isScrolling, true);
    });

    test('should expose year, month, day getters', () {
      final date = DateTime(2024, 12, 25);
      final state = DatePickerState(date: date);

      expect(state.year, 2024);
      expect(state.month, 12);
      expect(state.day, 25);
    });

    test('should format month abbreviation', () {
      final january = DatePickerState(date: DateTime(2024, 1, 1));
      expect(january.monthAbbreviation, 'Jan');

      final february = DatePickerState(date: DateTime(2024, 2, 1));
      expect(february.monthAbbreviation, 'Feb');

      final december = DatePickerState(date: DateTime(2024, 12, 1));
      expect(december.monthAbbreviation, 'Dec');
    });

    test('should copy with new values', () {
      final original = DatePickerState(date: DateTime(2024, 6, 15));

      final newDate = DateTime(2025, 1, 1);
      final copied = original.copyWith(date: newDate);

      expect(copied.date, newDate);
      expect(copied.isScrolling, false);
      expect(original.date, DateTime(2024, 6, 15));
    });

    test('should copy with scrolling flag', () {
      final original = DatePickerState(date: DateTime(2024, 6, 15));
      final copied = original.copyWith(isScrolling: true);

      expect(copied.date, original.date);
      expect(copied.isScrolling, true);
      expect(original.isScrolling, false);
    });

    test('should copy with null values retaining originals', () {
      final original = DatePickerState(
        date: DateTime(2024, 6, 15),
        isScrolling: true,
      );

      final copied = original.copyWith();

      expect(copied.date, original.date);
      expect(copied.isScrolling, true);
    });

    test('should have correct equality', () {
      final date = DateTime(2024, 6, 15);
      final state1 = DatePickerState(date: date);
      final state2 = DatePickerState(date: date);
      final state3 = DatePickerState(date: date, isScrolling: true);
      final state4 = DatePickerState(date: DateTime(2024, 6, 16));

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
      expect(state1, isNot(equals(state4)));
    });

    test('should stringify', () {
      final state = DatePickerState(date: DateTime(2024, 6, 15));
      final string = state.toString();

      expect(string, contains('DatePickerState'));
      expect(string, contains('2024-06-15'));
      expect(string, contains('false')); // isScrolling value
    });
  });
}
