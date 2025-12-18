// lib/src/presentation/cubits/date_picker/date_picker_cubit.dart

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';

part 'date_picker_state.dart';

class DatePickerCubit extends Cubit<DatePickerState> {
  Timer? _debounceTimer;

  DatePickerCubit({DateTime? initialDate})
      : super(DatePickerState(
          date: initialDate ?? DateTime.now(),
        ));

  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    }
    const daysPerMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysPerMonth[month - 1];
  }

  static bool _isLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    if (year % 4 == 0) return true;
    return false;
  }

  void updateDate(DateTime newDate) {
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  void updateYear(int year) {
    final clampedYear = year.clamp(1900, 2100);
    final daysInNewMonth = _getDaysInMonth(clampedYear, state.month);
    final validDay = state.day > daysInNewMonth ? daysInNewMonth : state.day;

    final newDate = DateTime(clampedYear, state.month, validDay);
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  void updateMonth(int month) {
    final daysInNewMonth = _getDaysInMonth(state.year, month);
    final validDay = state.day > daysInNewMonth ? daysInNewMonth : state.day;

    final newDate = DateTime(state.year, month, validDay);
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  void updateDay(int day) {
    final daysInMonth = _getDaysInMonth(state.year, state.month);
    final validDay = day.clamp(1, daysInMonth);

    final newDate = DateTime(state.year, state.month, validDay);
    emit(state.copyWith(date: newDate, isScrolling: true));
    _debounceCallback();
  }

  int get daysInCurrentMonth => _getDaysInMonth(state.year, state.month);

  void _debounceCallback() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TimingConstants.callbackDebounce, () {
      emit(state.copyWith(isScrolling: false));
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
