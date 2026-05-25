// lib/src/presentation/cubits/date_picker/date_picker_cubit.dart

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';

part 'date_picker_state.dart';

/// Cubit that manages the selected date for a scrolling date picker.
///
/// Exposes granular update methods for year, month, and day so that each
/// scroll column can operate independently. Day values are automatically
/// clamped to the number of days in the current month, and year values are
/// clamped to the range `1900–2100`. A debounce timer gates the
/// `isScrolling` flag so that downstream listeners are not flooded while
/// the user is actively scrolling.
class DatePickerCubit extends Cubit<DatePickerState> {
  /// Creates a [DatePickerCubit] with an optional [initialDate].
  ///
  /// When [initialDate] is `null`, [DateTime.now] is used.
  DatePickerCubit({DateTime? initialDate})
    : super(
        DatePickerState(
          date: initialDate ?? DateTime.now(),
        ),
      );

  Timer? _debounceTimer;

  /// Returns the number of days in [month] for the given [year].
  ///
  /// Handles February correctly for both leap and non-leap years.
  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    }
    const daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysPerMonth[month - 1];
  }

  /// Returns `true` when [year] is a leap year.
  ///
  /// Follows the Gregorian calendar rules: divisible by 400, or divisible
  /// by 4 but not by 100.
  static bool _isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    if (year % 4 == 0) return true;
    return false;
  }

  /// Replaces the entire selected date with [newDate] and starts the
  /// debounce timer.
  ///
  /// Emits an intermediate state with `isScrolling: true` immediately, then
  /// emits `isScrolling: false` after [TimingConstants.callbackDebounce].
  void updateDate(DateTime newDate) {
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  /// Updates only the year component of the selected date.
  ///
  /// [year] is clamped to `1900–2100`. If the current day exceeds the number
  /// of days in the resulting month (e.g. 31 March → 30 February does not
  /// exist), the day is clamped to the last valid day of that month.
  void updateYear(int year) {
    final clampedYear = year.clamp(1900, 2100);
    final daysInNewMonth = _getDaysInMonth(clampedYear, state.month);
    final validDay = state.day > daysInNewMonth ? daysInNewMonth : state.day;
    final newDate = DateTime(clampedYear, state.month, validDay);
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  /// Updates only the month component of the selected date.
  ///
  /// If the current day exceeds the number of days in [month] for the
  /// current year, the day is clamped to the last valid day of that month.
  void updateMonth(int month) {
    final daysInNewMonth = _getDaysInMonth(state.year, month);
    final validDay = state.day > daysInNewMonth ? daysInNewMonth : state.day;
    final newDate = DateTime(state.year, month, validDay);
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  /// Updates only the day component of the selected date.
  ///
  /// [day] is clamped to the valid range `1` through [daysInCurrentMonth],
  /// preventing out-of-range values from reaching [DateTime].
  void updateDay(int day) {
    final daysInMonth = _getDaysInMonth(state.year, state.month);
    final validDay = day.clamp(1, daysInMonth);
    final newDate = DateTime(state.year, state.month, validDay);
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  /// The number of days in the currently selected month and year.
  ///
  /// Derived from state.year and state.month. Changes whenever either
  /// component is updated.
  int get daysInCurrentMonth => _getDaysInMonth(state.year, state.month);

  /// Cancels any pending debounce timer and starts a new one.
  ///
  /// When the timer fires it emits `isScrolling: false`, signalling that
  /// the user has stopped scrolling and the final date value is settled.
  void _debounceCallback() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TimingConstants.callbackDebounce, () {
      emit(state.copyWith(isScrolling: false));
    });
  }

  /// Cancels the debounce timer and closes the cubit.
  ///
  /// Always call [super.close] to ensure the underlying stream is disposed.
  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
