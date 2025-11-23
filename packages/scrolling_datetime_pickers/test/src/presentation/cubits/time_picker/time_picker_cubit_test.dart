// test/src/presentation/cubits/time_picker/time_picker_cubit_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scrolling_datetime_pickers/src/presentation/cubits/time_picker/time_picker_cubit.dart';

void main() {
  group('TimePickerCubit', () {
    late TimePickerCubit cubit;

    setUp(() {
      cubit = TimePickerCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state uses current time', () {
      final now = DateTime.now();
      final state = cubit.state;

      expect(state.isScrolling, false);
      expect(state.dateTime.year, now.year);
      expect(state.dateTime.month, now.month);
      expect(state.dateTime.day, now.day);
    });

    test('initial state uses provided time', () {
      final customTime = DateTime(2024, 1, 15, 14, 30, 45);
      final customCubit = TimePickerCubit(initialDateTime: customTime);

      expect(customCubit.state.dateTime, equals(customTime));
      expect(customCubit.state.isScrolling, false);

      customCubit.close();
    });

    blocTest<TimePickerCubit, TimePickerState>(
      'updateDateTime emits new state with scrolling true then false',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 12, 0, 0),
      ),
      act: (cubit) => cubit.updateDateTime(DateTime(2024, 1, 1, 13, 30, 0)),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 13, 30, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 13, 30, 0),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles 12 AM correctly',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 13, 30, 0),
      ),
      act: (cubit) => cubit.updateHour(12, true), // 12 AM
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 0, 30, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 0, 30, 0),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles 12 PM correctly',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 1, 30, 0),
      ),
      act: (cubit) => cubit.updateHour(12, false), // 12 PM
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 30, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 30, 0),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles AM hours correctly',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 0, 0, 0),
      ),
      act: (cubit) => cubit.updateHour(5, true), // 5 AM
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 5, 0, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 5, 0, 0),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles PM hours correctly',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 0, 0, 0),
      ),
      act: (cubit) => cubit.updateHour(5, false), // 5 PM
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 17, 0, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 17, 0, 0),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateMinute updates minute only',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 14, 0, 30),
      ),
      act: (cubit) => cubit.updateMinute(45),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 45, 30),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 45, 30),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateSecond updates second only',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 14, 30, 0),
      ),
      act: (cubit) => cubit.updateSecond(15),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 15),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 15),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateAmPm toggles between AM and PM',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 10, 30, 0), // 10:30 AM
      ),
      act: (cubit) => cubit.updateAmPm(false), // Change to PM
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 22, 30, 0), // 10:30 PM
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 22, 30, 0),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'multiple rapid updates debounce correctly',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 12, 0, 0),
      ),
      act: (cubit) async {
        cubit.updateMinute(10);
        await Future.delayed(const Duration(milliseconds: 50));
        cubit.updateMinute(20);
        await Future.delayed(const Duration(milliseconds: 50));
        cubit.updateMinute(30);
      },
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 10, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 20, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 30, 0),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 30, 0),
          isScrolling: false,
        ),
      ],
      wait: const Duration(milliseconds: 500),
    );

    test('close cancels timer', () async {
      cubit.updateDateTime(DateTime(2024, 1, 1, 13, 0, 0));
      await cubit.close();

      // Timer should be cancelled, no further emissions
      await expectLater(
        cubit.stream,
        emitsInOrder([]),
      );
    });
  });
}
