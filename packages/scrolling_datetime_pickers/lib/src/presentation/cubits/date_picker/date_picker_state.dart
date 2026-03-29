// lib/src/presentation/cubits/date_picker/date_picker_state.dart

part of 'date_picker_cubit.dart';

/// Immutable state for [DatePickerCubit].
class DatePickerState extends Equatable {
  /// Creates a [DatePickerState] with a required [date] and an optional
  /// [isScrolling] flag that defaults to `false`.
  const DatePickerState({
    required this.date,
    this.isScrolling = false,
  });

  /// The currently selected date.
  ///
  /// Always a valid [DateTime]. Individual components are exposed via
  /// [year], [month], and [day] for convenience.
  final DateTime date;

  /// Whether any scroll column is actively scrolling.
  ///
  /// Set to `true` immediately when a scroll begins and reverted to `false`
  /// after [TimingConstants.callbackDebounce] has elapsed with no further
  /// scroll activity. Consumers can use this flag to suppress callbacks or
  /// defer downstream work until scrolling has settled.
  final bool isScrolling;

  /// The year component of [date].
  int get year => date.year;

  /// The month component of [date], in the range `1–12`.
  int get month => date.month;

  /// The day component of [date], in the range `1–31`.
  int get day => date.day;

  /// The abbreviated month name for [date], formatted as `MMM` (e.g. `Jan`).
  ///
  // ignore: comment_references
  /// Uses the locale resolved by the [intl] package at the time of the call.
  String get monthAbbreviation {
    return DateFormat('MMM').format(date);
  }

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// Fields not provided retain their current values.
  DatePickerState copyWith({
    DateTime? date,
    bool? isScrolling,
  }) {
    return DatePickerState(
      date: date ?? this.date,
      isScrolling: isScrolling ?? this.isScrolling,
    );
  }

  @override
  List<Object> get props => [date, isScrolling];

  @override
  bool get stringify => true;
}
