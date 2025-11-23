// lib/src/presentation/cubits/time_picker/time_picker_state.dart

part of 'time_picker_cubit.dart';

class TimePickerState extends Equatable {
  final DateTime dateTime;
  final bool isScrolling;

  const TimePickerState({
    required this.dateTime,
    this.isScrolling = false,
  });

  /// Get hour in 12-hour format (1-12)
  int get hour12 {
    if (dateTime.hour == 0) return StyleConstants.hoursMax; // 12 AM
    if (dateTime.hour > StyleConstants.hoursMax) {
      return dateTime.hour - StyleConstants.hoursMax;
    }
    return dateTime.hour;
  }

  /// Check if time is AM
  bool get isAm => dateTime.hour < StyleConstants.hoursMax;

  /// Get minute value
  int get minute => dateTime.minute;

  /// Get second value
  int get second => dateTime.second;

  /// Create a copy with optional new values
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
