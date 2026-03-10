// lib/src/presentation/cubits/time_picker/time_picker_cubit.dart

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';

part 'time_picker_state.dart';

class TimePickerCubit extends Cubit<TimePickerState> {

  TimePickerCubit({DateTime? initialDateTime})
    : super(
        TimePickerState(
          dateTime: _normalizeDateTime(initialDateTime),
        ),
      );
  Timer? _debounceTimer;

  /// Normalize datetime for time picker:
  /// - If datetime provided: preserve it exactly (caller is responsible for
  /// normalization)
  /// - If no datetime provided: Jan 1st of current year with current time, 
  /// seconds = 0
  static DateTime _normalizeDateTime(DateTime? dateTime) {
    if (dateTime != null) {
      // Preserve provided datetime exactly
      return dateTime;
    }

    // No datetime provided - default to Jan 1st current year with current time
    final now = DateTime.now();
    return DateTime(
      now.year,
      1,
      1,
      now.hour,
      now.minute,
    );
  }

  /// Update the time with a new DateTime value
  void updateDateTime(DateTime newDateTime) {
    emit(state.copyWith(dateTime: newDateTime, isScrolling: true));
    _startDebounceTimer();
  }

  /// Update only the hour component
  void updateHour(int hour, bool isAm) {
    final currentDateTime = state.dateTime;
    final hour24 = isAm
        ? (hour == StyleConstants.hoursMax ? 0 : hour)
        : (hour == StyleConstants.hoursMax
              ? StyleConstants.hoursMax
              : hour + StyleConstants.hoursMax);

    final newDateTime = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      hour24,
      currentDateTime.minute,
      currentDateTime.second,
    );

    emit(state.copyWith(dateTime: newDateTime, isScrolling: true));
    _startDebounceTimer();
  }

  /// Update only the minute component
  void updateMinute(int minute) {
    final currentDateTime = state.dateTime;
    final newDateTime = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      currentDateTime.hour,
      minute,
      currentDateTime.second,
    );

    emit(state.copyWith(dateTime: newDateTime, isScrolling: true));
    _startDebounceTimer();
  }

  /// Update only the second component
  void updateSecond(int second) {
    final currentDateTime = state.dateTime;
    final newDateTime = DateTime(
      currentDateTime.year,
      currentDateTime.month,
      currentDateTime.day,
      currentDateTime.hour,
      currentDateTime.minute,
      second,
    );

    emit(state.copyWith(dateTime: newDateTime, isScrolling: true));
    _startDebounceTimer();
  }

  /// Update AM/PM
  void updateAmPm(bool isAm) {
    final currentHour = state.hour12;
    updateHour(currentHour, isAm);
  }

  /// Start or restart the debounce timer
  void _startDebounceTimer() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TimingConstants.callbackDebounce, () {
      emit(state.copyWith(isScrolling: false));
    });
  }

  /// Clean up resources
  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
