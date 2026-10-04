// packages/datetime_popover_pickers/lib/src/date/date_picker.dart
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'abbrevated_month.dart' show AbbreviatedMonth;

/// Refined DatePicker that uses Cupertino and special layouts for scrolling
/// DatePicking
class DatePicker extends StatefulWidget {
  /// Constructor
  const DatePicker({
    required this.onDateChanged,
    required this.pickerSize,
    this.initialDate,
    super.key,
  });

  /// The initial date (can/should contain hours, minutes, seconds)
  final DateTime? initialDate;

  /// The dimensions (height/width) of the picker
  final Size pickerSize;

  /// Call that updates the date-portion when the value changes
  final void Function(DateTime) onDateChanged;

  @override
  State<DatePicker> createState() => _DatePicker();
}

class _DatePicker extends State<DatePicker> {
  late DateTime currentDateTime;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate == null) {
      currentDateTime = DateTime.now();
      currentDateTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        0,
        0,
        0,
        0,
        0,
      );
    } else {
      currentDateTime = DateTime(
        widget.initialDate!.year,
        widget.initialDate!.month,
        widget.initialDate!.day,
        widget.initialDate!.hour,
        widget.initialDate!.minute,
        widget.initialDate!.second,
        0,
        0,
      );
    }
  }

  void _onDateChanged(DateTime date) {
    setState(
      () => currentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        currentDateTime.hour,
        currentDateTime.minute,
        currentDateTime.second,
        0,
        0,
      ),
    );
    widget.onDateChanged(currentDateTime);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.pickerSize.height,
    width: widget.pickerSize.width,
    child: Localizations.override(
      context: context,
      delegates: const [AbbreviatedMonth.delegate],
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        dateOrder: DatePickerDateOrder.dmy,
        initialDateTime: currentDateTime,
        onDateTimeChanged: _onDateChanged,
      ),
    ),
  );
}

/// Formats a [DateTime] as `21 Dec 2024`.
class DateLabelFormatter {
  /// Creates a [DateLabelFormatter].
  const DateLabelFormatter();

  static final DateFormat _format = DateFormat('d MMM yyyy');

  /// Returns [date] rendered as day, abbreviated month, four-digit year.
  String format(DateTime date) => _format.format(date);
}
