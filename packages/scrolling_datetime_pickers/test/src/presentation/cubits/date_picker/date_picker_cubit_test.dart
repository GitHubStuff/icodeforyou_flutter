// test/src/presentation/cubits/date_picker/date_picker_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/date_picker/date_picker_cubit.dart';

void main() {
  group('DatePickerCubit', () {
    late DatePickerCubit cubit;

    setUp(() {
      cubit = DatePickerCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('should initialize with current date', () {
      final now = DateTime.now();
      expect(cubit.state.date.year, now.year);
      expect(cubit.state.date.month, now.month);
      expect(cubit.state.date.day, now.day);
      expect(cubit.state.isScrolling, false);
    });

    test('should initialize with custom date', () {
      final customDate = DateTime(2024, 6, 15);
      final customCubit = DatePickerCubit(initialDate: customDate);

      expect(customCubit.state.date, customDate);
      customCubit.close();
    });

    test('should validate invalid initial date', () {
      // DateTime(2024, 2, 31) actually creates March 2, 2024 in Dart
      final invalidDate = DateTime(2024, 2, 31);
      final validatingCubit = DatePickerCubit(initialDate: invalidDate);

      // The cubit receives March 2, which is valid, so no adjustment
      expect(validatingCubit.state.date.day, 2);
      expect(validatingCubit.state.date.month, 3);
      expect(validatingCubit.state.date.year, 2024);
      validatingCubit.close();

      // Test with a date we manually construct to be invalid
      final feb30 = DateTime(2024, 2, 30); // Becomes March 1
      final feb30Cubit = DatePickerCubit(initialDate: feb30);
      expect(feb30Cubit.state.date.day, 1);
      expect(feb30Cubit.state.date.month, 3);
      feb30Cubit.close();
    });

    test('should handle month change that makes day invalid', () {
      // Start with Jan 31
      final cubit = DatePickerCubit(initialDate: DateTime(2023, 1, 31));

      // Change to February (which has only 28 days in 2023)
      cubit.updateMonth(2);

      // Should adjust to last day of February
      expect(cubit.state.date.day, 28);
      expect(cubit.state.date.month, 2);
      expect(cubit.state.date.year, 2023);

      cubit.close();
    });

    test('should update year and adjust day for leap year', () {
      final initialDate = DateTime(2024, 2, 29); // Leap year date
      cubit = DatePickerCubit(initialDate: initialDate);

      cubit.updateYear(2023); // Not a leap year

      expect(cubit.state.date.year, 2023);
      expect(cubit.state.date.month, 2);
      expect(cubit.state.date.day, 28); // Adjusted to last day of Feb
    });

    test('should update month and adjust day', () {
      final initialDate = DateTime(2024, 1, 31);
      cubit = DatePickerCubit(initialDate: initialDate);

      cubit.updateMonth(2); // February

      expect(cubit.state.date.month, 2);
      expect(cubit.state.date.day, 29); // Leap year, so 29 days

      cubit.updateMonth(4); // April
      expect(cubit.state.date.month, 4);
      expect(cubit.state.date.day, 29); // April has 30 days, 29 is valid

      final march31 = DateTime(2024, 3, 31);
      cubit = DatePickerCubit(initialDate: march31);

      cubit.updateMonth(4); // April has 30 days
      expect(cubit.state.date.day, 30); // Adjusted to last day
    });

    test('should update day within valid range', () {
      final initialDate = DateTime(2024, 2, 15);
      cubit = DatePickerCubit(initialDate: initialDate);

      cubit.updateDay(29);
      expect(cubit.state.date.day, 29); // Valid for leap year Feb

      cubit.updateDay(30);
      expect(cubit.state.date.day, 29); // Clamped to max days in Feb

      cubit.updateDay(0);
      expect(cubit.state.date.day, 1); // Clamped to minimum
    });

    test('should clamp year to valid range', () {
      cubit.updateYear(1899);
      expect(cubit.state.date.year, 1900);

      cubit.updateYear(2101);
      expect(cubit.state.date.year, 2100);

      cubit.updateYear(2000);
      expect(cubit.state.date.year, 2000);
    });

    test('should identify leap years correctly', () {
      final leap2000 = DatePickerCubit(initialDate: DateTime(2000, 2, 1));
      leap2000.updateDay(29);
      expect(leap2000.state.date.day, 29); // 2000 is leap (divisible by 400)
      leap2000.close();

      final notLeap1900 = DatePickerCubit(initialDate: DateTime(1900, 2, 1));
      notLeap1900.updateDay(29);
      expect(
          notLeap1900.state.date.day, 28); // 1900 not leap (divisible by 100)
      notLeap1900.close();

      final leap2004 = DatePickerCubit(initialDate: DateTime(2004, 2, 1));
      leap2004.updateDay(29);
      expect(leap2004.state.date.day, 29); // 2004 is leap (divisible by 4)
      leap2004.close();

      final notLeap2001 = DatePickerCubit(initialDate: DateTime(2001, 2, 1));
      notLeap2001.updateDay(29);
      expect(notLeap2001.state.date.day, 28); // 2001 not leap
      notLeap2001.close();
    });

    test('should get correct days in current month', () {
      // January - 31 days
      cubit = DatePickerCubit(initialDate: DateTime(2024, 1, 1));
      expect(cubit.daysInCurrentMonth, 31);

      // February leap year - 29 days
      cubit = DatePickerCubit(initialDate: DateTime(2024, 2, 1));
      expect(cubit.daysInCurrentMonth, 29);

      // February non-leap - 28 days
      cubit = DatePickerCubit(initialDate: DateTime(2023, 2, 1));
      expect(cubit.daysInCurrentMonth, 28);

      // April - 30 days
      cubit = DatePickerCubit(initialDate: DateTime(2024, 4, 1));
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
      await Future.delayed(const Duration(milliseconds: 500));
      expect(cubit.state.isScrolling, false);
    });
  });
}
