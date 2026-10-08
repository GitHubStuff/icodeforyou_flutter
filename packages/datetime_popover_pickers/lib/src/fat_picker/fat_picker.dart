// packages/datetime_popover_pickers/lib/src/fat/fat_picker.dart
import 'package:datetime_popover_pickers/datetime_popover_pickers.dart' show DatePicker;
import 'package:datetime_popover_pickers/src/picker_size.dart' show PickerSize;
import 'package:datetime_popover_pickers/src/time/time_picker.dart' show TimePicker;
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;

/// A single picker with date wheels (day / month / year) and time wheels
/// (hour / minute / optional second / AM-PM) side by side. Composes
/// [DatePicker] and [TimePicker] and emits one merged [DateTime].
class FatPicker extends StatefulWidget {
  /// Constructor
  const FatPicker({
    required this.onDateTimeChanged,
    required this.size,
    required this.showSeconds,
    this.initialDateTime,
    this.minimumYear,
    this.maximumYear,
    this.textStyle,
    super.key,
  });

  /// The initial date and time
  final DateTime? initialDateTime;

  /// Size preset shared by both groups of wheels
  final PickerSize size;

  /// Whether the seconds wheel is shown. When `false` the emitted value
  /// always has `second == 0`.
  final bool showSeconds;

  /// First year on the year wheel; defaults to [DatePicker]'s default
  final int? minimumYear;

  /// Last year on the year wheel; defaults to [DatePicker]'s default
  final int? maximumYear;

  /// Optional style overrides for colour, weight or family. Font size is
  /// always taken from [size] and cannot be overridden here.
  final TextStyle? textStyle;

  /// Called with the merged date-time whenever any wheel changes
  final void Function(DateTime) onDateTimeChanged;

  @override
  State<FatPicker> createState() => _FatPickerState();
}

class _FatPickerState extends State<FatPicker> {
  late DateTime _datePart;
  late DateTime _timePart;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateTime ?? DateTime.now();
    _datePart = initial;
    _timePart = widget.showSeconds
        ? initial
        : DateTime(
            initial.year,
            initial.month,
            initial.day,
            initial.hour,
            initial.minute,
          );
  }

  DateTime get _merged => DateTime(
    _datePart.year,
    _datePart.month,
    _datePart.day,
    _timePart.hour,
    _timePart.minute,
    _timePart.second,
  );

  void _onDateChanged(DateTime date) {
    _datePart = date;
    widget.onDateTimeChanged(_merged);
  }

  void _onTimeChanged(DateTime time) {
    _timePart = time;
    widget.onDateTimeChanged(_merged);
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      DatePicker(
        size: widget.size,
        initialDate: _datePart,
        minimumYear: widget.minimumYear ?? DatePicker.defaultMinimumYear,
        maximumYear: widget.maximumYear ?? DatePicker.defaultMaximumYear,
        textStyle: widget.textStyle,
        onDateChanged: _onDateChanged,
      ),
      SizedBox(width: widget.size.groupSpacing),
      TimePicker(
        size: widget.size,
        initialTime: _timePart,
        showSeconds: widget.showSeconds,
        textStyle: widget.textStyle,
        onTimeChanged: _onTimeChanged,
      ),
    ],
  );
}

/// Formats a [DateTime] as `21 Dec 2024 1:47:22 AM`, or without seconds
/// when they are hidden.
class FatLabelFormatter {
  /// Creates a [FatLabelFormatter].
  const FatLabelFormatter({required this.showSeconds});

  /// Whether seconds are included in the formatted output.
  final bool showSeconds;

  static final DateFormat _withSeconds = DateFormat('d MMM yyyy h:mm:ss a');
  static final DateFormat _withoutSeconds = DateFormat('d MMM yyyy h:mm a');

  /// Returns [dateTime] rendered as date and 12-hour time with AM/PM.
  String format(DateTime dateTime) =>
      (showSeconds ? _withSeconds : _withoutSeconds).format(dateTime);
}
