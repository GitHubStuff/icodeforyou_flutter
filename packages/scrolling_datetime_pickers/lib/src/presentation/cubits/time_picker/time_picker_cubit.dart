// lib/src/presentation/cubits/time_picker/time_picker_cubit.dart

import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/style_constants.dart';
import 'package:scrolling_datetime_pickers/src/core/constants/timing_constants.dart';

part 'time_picker_state.dart';

/// Cubit that manages the selected time for a scrolling time picker.
///
/// Exposes granular update methods for hour, minute, second, and AM/PM so
/// that each scroll column can operate independently. Hour values are
/// converted between 12-hour and 24-hour representations internally. A
/// debounce timer gates the `isScrolling` flag so that downstream listeners
/// are not flooded while the user is actively scrolling.
class TimePickerCubit extends Cubit<TimePickerState> {
  /// Creates a [TimePickerCubit] with an optional [initialDateTime].
  ///
  /// When [initialDateTime] is provided it is preserved exactly — the caller
  /// is responsible for any normalisation. When omitted the state defaults to
  /// 1 January of the current year at the current hour and minute, with
  /// seconds zeroed. See [_normalizeDateTime].
  TimePickerCubit({DateTime? initialDateTime})
    : super(
        TimePickerState(
          dateTime: _normalizeDateTime(initialDateTime),
        ),
      );

  Timer? _debounceTimer;

  /// Returns a normalised [DateTime] suitable for use as the initial state.
  ///
  /// When [dateTime] is non-null it is returned unchanged. When `null`, a
  /// [DateTime] is constructed from 1 January of the current year at the
  /// current hour and minute, with seconds set to `0`.
  static DateTime _normalizeDateTime(DateTime? dateTime) {
    if (dateTime != null) {
      return dateTime;
    }
    final now = DateTime.now();
    return DateTime(
      now.year,
      1,
      1,
      now.hour,
      now.minute,
    );
  }

  /// Replaces the entire selected [DateTime] with [newDateTime] and starts
  /// the debounce timer.
  ///
  /// Emits an intermediate state with `isScrolling: true` immediately, then
  /// emits `isScrolling: false` after [TimingConstants.callbackDebounce].
  void updateDateTime(DateTime newDateTime) {
    emit(state.copyWith(dateTime: newDateTime, isScrolling: true));
    _startDebounceTimer();
  }

  /// Updates only the hour component of the selected time.
  ///
  /// [hour] is a 12-hour clock value (`1–12`) and [isAm] indicates whether
  /// it falls in the AM or PM period. The value is converted to 24-hour
  /// representation before being stored:
  /// - AM 12 → `0` (midnight)
  /// - PM 12 → `12` (noon)
  /// - PM 1–11 → `13–23`
  ///
  /// All other date and time components are preserved from the current state.
  // ignore: avoid_positional_boolean_parameters
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

  /// Updates only the minute component of the selected time.
  ///
  /// [minute] must be in the range `0–59`. All other date and time components
  /// are preserved from the current state.
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

  /// Updates only the second component of the selected time.
  ///
  /// [second] must be in the range `0–59`. All other date and time components
  /// are preserved from the current state.
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

  /// Updates the AM/PM period while preserving the current 12-hour clock value.
  ///
  /// Delegates to [updateHour] using [TimePickerState.hour12] as the hour
  /// value, so the conversion to 24-hour representation is applied
  /// consistently.
  // ignore: avoid_positional_boolean_parameters
  void updateAmPm(bool isAm) {
    final currentHour = state.hour12;
    updateHour(currentHour, isAm);
  }

  /// Cancels any pending debounce timer and starts a new one.
  ///
  /// When the timer fires it emits `isScrolling: false`, signalling that
  /// the user has stopped scrolling and the final time value is settled.
  void _startDebounceTimer() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(TimingConstants.callbackDebounce, () {
      emit(state.copyWith(isScrolling: false));
    });
  }

  /// Cancels the debounce timer and closes the cubit.
  ///
  /// Always calls [super.close] to ensure the underlying stream is disposed.
  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
