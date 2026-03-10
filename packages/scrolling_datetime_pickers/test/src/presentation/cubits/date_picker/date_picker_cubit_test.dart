// test/src/presentation/cubits/date_picker/date_picker_cubit_test.dart

// ignore_for_file: document_ignores, cascade_invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/date_picker/date_picker_cubit.dart';

void main() {
  group('DatePickerCubit', () {
    late DatePickerCubit cubit;

    setUp(() {
      cubit = DatePickerCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('should initialize with current date', () {
      final now = DateTime.now();
      expect(cubit.state.date.year, now.year);
      expect(cubit.state.date.month, now.month);
      expect(cubit.state.date.day, now.day);
      expect(cubit.state.isScrolling, false);
    });

    test('should initialize with custom date', () async {
      final customDate = DateTime(2024, 6, 15);
      final customCubit = DatePickerCubit(initialDate: customDate);

      expect(customCubit.state.date, customDate);
      await customCubit.close();
    });

    test('should validate invalid initial date', () async {
      // DateTime(2024, 2, 31) actually creates March 2, 2024 in Dart
      final invalidDate = DateTime(2024, 2, 31);
      final validatingCubit = DatePickerCubit(initialDate: invalidDate);

      // The cubit receives March 2, which is valid, so no adjustment
      expect(validatingCubit.state.date.day, 2);
      expect(validatingCubit.state.date.month, 3);
      expect(validatingCubit.state.date.year, 2024);
      await validatingCubit.close();

      // Test with a date we manually construct to be invalid
      final feb30 = DateTime(2024, 2, 30); // Becomes March 1
      final feb30Cubit = DatePickerCubit(initialDate: feb30);
      expect(feb30Cubit.state.date.day, 1);
      expect(feb30Cubit.state.date.month, 3);
      await feb30Cubit.close();
    });

    test('should handle month change that makes day invalid', () async {
      final montCubit = DatePickerCubit(initialDate: DateTime(2023, 1, 31));

      // Change to February (which has only 28 days in 2023)
      montCubit.updateMonth(2);

      // Should adjust to last day of February
      expect(montCubit.state.date.day, 28);
      expect(montCubit.state.date.month, 2);
      expect(montCubit.state.date.year, 2023);

      await montCubit.close();
    });

    test('should update year and adjust day for leap year', () {
      final initialDate = DateTime(2024, 2, 29); // Leap year date
      cubit = DatePickerCubit(initialDate: initialDate);

      cubit.updateYear(2023); // Not a leap year

      expect(cubit.state.date.year, 2023);
      expect(cubit.state.date.month, 2);
      expect(cubit.state.date.day, 28); // Adjusted to last day of Feb
    });

    test('should update month and adjust day', () async {
      cubit = DatePickerCubit(initialDate: DateTime(2024, 1, 31));

      cubit.updateMonth(2); // February
      expect(cubit.state.date.month, 2);
      expect(cubit.state.date.day, 29); // Leap year, so 29 days

      cubit.updateMonth(4); // April
      expect(cubit.state.date.month, 4);
      expect(cubit.state.date.day, 29); // April has 30 days, 29 is valid

      final march31Cubit = DatePickerCubit(initialDate: DateTime(2024, 3, 31));
      march31Cubit.updateMonth(4); // April has 30 days
      expect(march31Cubit.state.date.day, 30); // Adjusted to last day
      await march31Cubit.close();
    });

    test('should update day within valid range', () {
      cubit = DatePickerCubit(initialDate: DateTime(2024, 2, 15));

      cubit
        ..updateDay(29)
        ..updateDay(30); // Clamped to max days in Feb
      expect(cubit.state.date.day, 29);

      cubit.updateDay(0);
      expect(cubit.state.date.day, 1); // Clamped to minimum
    });

    test('should clamp year to valid range', () {
      cubit
        ..updateYear(1899)
        ..updateYear(2101);
      expect(cubit.state.date.year, 2100);

      cubit.updateYear(2000);
      expect(cubit.state.date.year, 2000);
    });

    test('should identify leap years correctly', () async {
      final leap2000 = DatePickerCubit(initialDate: DateTime(2000, 2));
      leap2000.updateDay(29);
      expect(leap2000.state.date.day, 29); // 2000 is leap (divisible by 400)
      await leap2000.close();

      final notLeap1900 = DatePickerCubit(initialDate: DateTime(1900, 2));
      notLeap1900.updateDay(29);
      expect(
        notLeap1900.state.date.day,
        28,
      ); // 1900 not leap (divisible by 100)
      await notLeap1900.close();

      final leap2004 = DatePickerCubit(initialDate: DateTime(2004, 2));
      leap2004.updateDay(29);
      expect(leap2004.state.date.day, 29); // 2004 is leap (divisible by 4)
      await leap2004.close();

      final notLeap2001 = DatePickerCubit(initialDate: DateTime(2001, 2));
      notLeap2001.updateDay(29);
      expect(notLeap2001.state.date.day, 28); // 2001 not leap
      await notLeap2001.close();
    });

    test('should get correct days in current month', () {
      // January - 31 days
      cubit = DatePickerCubit(initialDate: DateTime(2024));
      expect(cubit.daysInCurrentMonth, 31);

      // February leap year - 29 days
      cubit = DatePickerCubit(initialDate: DateTime(2024, 2));
      expect(cubit.daysInCurrentMonth, 29);

      // February non-leap - 28 days
      cubit = DatePickerCubit(initialDate: DateTime(2023, 2));
      expect(cubit.daysInCurrentMonth, 28);

      // April - 30 days
      cubit = DatePickerCubit(initialDate: DateTime(2024, 4));
      expect(cubit.daysInCurrentMonth, 30);
    });

    test('should update full date', () {
      final newDate = DateTime(2025, 12, 25);
      cubit.updateDate(newDate);

      expect(cubit.state.date, newDate);
      expect(cubit.state.isScrolling, true);
    });

    test('should set isScrolling when updating', () async {
      expect(cubit.state.isScrolling, false);

      cubit.updateDay(15);
      expect(cubit.state.isScrolling, true);

      // Wait for debounce
      await Future<void>.delayed(const Duration(milliseconds: 500));
      expect(cubit.state.isScrolling, false);
    });
  });
}
