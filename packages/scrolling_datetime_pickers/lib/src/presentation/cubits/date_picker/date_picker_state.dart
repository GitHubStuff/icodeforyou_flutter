// lib/src/presentation/cubits/date_picker/date_picker_state.dart

part of 'date_picker_cubit.dart';

class DatePickerState extends Equatable {
  final DateTime date;
  final bool isScrolling;

  const DatePickerState({
    required this.date,
    this.isScrolling = false,
  });

  int get year => date.year;
  int get month => date.month;
  int get day => date.day;

  String get monthAbbreviation {
    return DateFormat('MMM').format(date);
  }

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
