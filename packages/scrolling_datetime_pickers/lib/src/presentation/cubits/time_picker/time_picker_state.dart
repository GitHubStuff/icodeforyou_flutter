// lib/src/presentation/cubits/time_picker/time_picker_state.dart

part of 'time_picker_cubit.dart';

/// Immutable state for [TimePickerCubit].
class TimePickerState extends Equatable {
  /// Creates a [TimePickerState] with a required [dateTime] and an optional
  /// [isScrolling] flag that defaults to `false`.
  const TimePickerState({
    required this.dateTime,
    this.isScrolling = false,
  });

  /// The currently selected date and time.
  ///
  /// The date components are carried along but are not meaningful to the time
  /// picker UI. Individual time components are exposed via [hour12], [isAm],
  /// [minute], and [second] for convenience.
  final DateTime dateTime;

  /// Whether any scroll column is actively scrolling.
  ///
  /// Set to `true` immediately when a scroll begins and reverted to `false`
  /// after [TimingConstants.callbackDebounce] has elapsed with no further
  /// scroll activity. Consumers can use this flag to suppress callbacks or
  /// defer downstream work until scrolling has settled.
  final bool isScrolling;

  /// The hour component of [dateTime] expressed as a 12-hour clock value
  /// in the range `1–12`.
  ///
  /// Conversion rules:
  /// - `0` (midnight) → `12`
  /// - `1–12` → returned unchanged
  /// - `13–23` → subtract `12`
  int get hour12 {
    if (dateTime.hour == 0) return StyleConstants.hoursMax;
    if (dateTime.hour > StyleConstants.hoursMax) {
      return dateTime.hour - StyleConstants.hoursMax;
    }
    return dateTime.hour;
  }

  /// Whether the current time falls in the AM period.
  ///
  // ignore: comment_references
  /// Returns `true` when [dateTime.hour] is less than `12` (i.e. midnight
  /// through 11:59 AM). Returns `false` for noon and all PM hours.
  bool get isAm => dateTime.hour < StyleConstants.hoursMax;

  /// The minute component of [dateTime], in the range `0–59`.
  int get minute => dateTime.minute;

  /// The second component of [dateTime], in the range `0–59`.
  int get second => dateTime.second;

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// Fields not provided retain their current values.
  TimePickerState copyWith({
    DateTime? dateTime,
    bool? isScrolling,
  }) {
    return TimePickerState(
      dateTime: dateTime ?? this.dateTime,
      isScrolling: isScrolling ?? this.isScrolling,
    );
  }

  @override
  List<Object> get props => [dateTime, isScrolling];

  @override
  bool get stringify => true;
}
