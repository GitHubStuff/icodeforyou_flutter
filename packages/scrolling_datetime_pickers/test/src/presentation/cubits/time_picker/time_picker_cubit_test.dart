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

    tearDown(() async {
      await cubit.close();
    });

    test(
      'initial state defaults to Jan 1st of current year with current time',
      () {
        final now = DateTime.now();
        final state = cubit.state;

        expect(state.isScrolling, false);
        expect(state.dateTime.year, now.year);
        expect(state.dateTime.month, 1);
        expect(state.dateTime.day, 1);
        expect(state.dateTime.hour, now.hour);
        expect(state.dateTime.minute, now.minute);
        expect(state.dateTime.second, 0);
      },
    );

    test('initial state preserves provided datetime exactly', () async {
      final customTime = DateTime(2024, 1, 15, 14, 30, 45);
      final customCubit = TimePickerCubit(initialDateTime: customTime);

      expect(customCubit.state.dateTime, equals(customTime));
      expect(customCubit.state.isScrolling, false);

      await customCubit.close();
    });

    blocTest<TimePickerCubit, TimePickerState>(
      'updateDateTime emits new state with scrolling true then false',
      build: () => TimePickerCubit(initialDateTime: DateTime(2024, 1, 1, 12)),
      act: (cubit) => cubit.updateDateTime(DateTime(2024, 1, 1, 13, 30)),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 13, 30),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 13, 30)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles 12 AM correctly',
      build: () =>
          TimePickerCubit(initialDateTime: DateTime(2024, 1, 1, 13, 30)),
      act: (cubit) => cubit.updateHour(12, true),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 0, 30),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 0, 30)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles 12 PM correctly',
      build: () =>
          TimePickerCubit(initialDateTime: DateTime(2024, 1, 1, 1, 30)),
      act: (cubit) => cubit.updateHour(12, false),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 30),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 12, 30)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles AM hours correctly',
      build: () => TimePickerCubit(initialDateTime: DateTime(2024, 1)),
      act: (cubit) => cubit.updateHour(5, true),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 5),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 5)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateHour handles PM hours correctly',
      build: () => TimePickerCubit(initialDateTime: DateTime(2024, 1)),
      act: (cubit) => cubit.updateHour(5, false),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 17),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 17)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateMinute updates minute only',
      build: () =>
          TimePickerCubit(initialDateTime: DateTime(2024, 1, 1, 14, 0, 30)),
      act: (cubit) => cubit.updateMinute(45),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 45, 30),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 14, 45, 30)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateSecond updates second only',
      build: () =>
          TimePickerCubit(initialDateTime: DateTime(2024, 1, 1, 14, 30)),
      act: (cubit) => cubit.updateSecond(15),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 14, 30, 15),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 14, 30, 15)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'updateAmPm toggles between AM and PM',
      build: () => TimePickerCubit(
        initialDateTime: DateTime(2024, 1, 1, 10, 30),
      ),
      act: (cubit) => cubit.updateAmPm(false),
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 22, 30),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 22, 30)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    blocTest<TimePickerCubit, TimePickerState>(
      'multiple rapid updates debounce correctly',
      build: () =>
          TimePickerCubit(initialDateTime: DateTime(2024, 1, 1, 12)),
      act: (cubit) async {
        cubit.updateMinute(10);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        cubit.updateMinute(20);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        cubit.updateMinute(30);
      },
      expect: () => [
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 10),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 20),
          isScrolling: true,
        ),
        TimePickerState(
          dateTime: DateTime(2024, 1, 1, 12, 30),
          isScrolling: true,
        ),
        TimePickerState(dateTime: DateTime(2024, 1, 1, 12, 30)),
      ],
      wait: const Duration(milliseconds: 500),
    );

    test('close cancels timer', () async {
      cubit.updateDateTime(DateTime(2024, 1, 1, 13));
      await cubit.close();

      await expectLater(cubit.stream, emitsInOrder([]));
    });
  });
}
