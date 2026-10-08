// packages/datetime_popover_pickers/lib/src/time/time_picker.dart
import 'package:datetime_popover_pickers/src/picker_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;

/// Refined 12-hour time picker with hour, minute, optional second, and AM/PM
/// wheels, composed from [CupertinoPicker] columns sharing one selection
/// overlay. Row geometry derives from [size]; column widths derive from the
/// measured width of each column's widest label.
class TimePicker extends StatefulWidget {
  /// Constructor
  const TimePicker({
    required this.onTimeChanged,
    required this.size,
    required this.showSeconds,
    this.initialTime,
    this.textStyle,
    super.key,
  });

  /// The initial time (hours, minutes and seconds are read from it)
  final DateTime? initialTime;

  /// Size preset controlling font size, row height, and column padding
  final PickerSize size;

  /// Whether the seconds wheel is shown. When `false` the emitted time
  /// always has `second == 0`.
  final bool showSeconds;

  /// Optional style overrides for colour, weight or family. Font size is
  /// always taken from [size] and cannot be overridden here.
  final TextStyle? textStyle;

  /// Called with the updated time whenever any wheel changes
  final void Function(DateTime) onTimeChanged;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  static const int _hoursOnClock = 12;
  static const int _minutesPerHour = 60;
  static const int _secondsPerMinute = 60;
  static const List<String> _periods = ['AM', 'PM'];

  /// Widest two-digit sample in virtually every Latin typeface.
  static const String _widestTwoDigits = '88';

  late DateTime _currentTime;
  late int _hour12;
  late int _minute;
  late int _second;
  late bool _isPm;

  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;
  late final FixedExtentScrollController _secondController;
  late final FixedExtentScrollController _periodController;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.initialTime ?? DateTime.now();
    _hour12 = _to12Hour(_currentTime.hour);
    _minute = _currentTime.minute;
    _second = widget.showSeconds ? _currentTime.second : 0;
    _isPm = _currentTime.hour >= _hoursOnClock;

    _hourController = FixedExtentScrollController(initialItem: _hour12 - 1);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
    _secondController = FixedExtentScrollController(initialItem: _second);
    _periodController = FixedExtentScrollController(initialItem: _isPm ? 1 : 0);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  static int _to12Hour(int hour24) {
    final remainder = hour24 % _hoursOnClock;
    return remainder == 0 ? _hoursOnClock : remainder;
  }

  static int _to24Hour({required int hour12, required bool isPm}) {
    final base = hour12 % _hoursOnClock;
    return isPm ? base + _hoursOnClock : base;
  }

  void _emit() {
    setState(() {
      _currentTime = DateTime(
        _currentTime.year,
        _currentTime.month,
        _currentTime.day,
        _to24Hour(hour12: _hour12, isPm: _isPm),
        _minute,
        _second,
      );
    });
    widget.onTimeChanged(_currentTime);
  }

  void _onHourChanged(int index) {
    _hour12 = index + 1;
    _emit();
  }

  void _onMinuteChanged(int index) {
    _minute = index;
    _emit();
  }

  void _onSecondChanged(int index) {
    _second = index;
    _emit();
  }

  void _onPeriodChanged(int index) {
    _isPm = index == 1;
    _emit();
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  TextStyle _resolveTextStyle(BuildContext context) =>
      CupertinoTheme.of(context).textTheme.pickerTextStyle
          .merge(widget.textStyle)
          .merge(widget.size.textStyle);

  static double _measure(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  double _columnWidth(BuildContext context, TextStyle style, String widest) =>
      widget.size.columnWidthFor(_measure(context, widest, style));

  Widget _column({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int index) label,
    required ValueChanged<int> onChanged,
    required TextStyle style,
    required double width,
    bool looping = true,
  }) => SizedBox(
    width: width,
    child: CupertinoPicker(
      scrollController: controller,
      itemExtent: widget.size.itemExtent,
      looping: looping,
      selectionOverlay: null,
      onSelectedItemChanged: onChanged,
      children: List<Widget>.generate(
        itemCount,
        (index) => Center(child: Text(label(index), style: style)),
      ),
    ),
  );

  List<Widget> _columns(BuildContext context, TextStyle style) {
    final digitsWidth = _columnWidth(context, style, _widestTwoDigits);
    final periodWidth = _periods
        .map((period) => _columnWidth(context, style, period))
        .reduce((a, b) => a > b ? a : b);

    return [
      _column(
        controller: _hourController,
        itemCount: _hoursOnClock,
        label: (index) => '${index + 1}',
        onChanged: _onHourChanged,
        style: style,
        width: digitsWidth,
      ),
      _column(
        controller: _minuteController,
        itemCount: _minutesPerHour,
        label: _twoDigits,
        onChanged: _onMinuteChanged,
        style: style,
        width: digitsWidth,
      ),
      if (widget.showSeconds)
        _column(
          controller: _secondController,
          itemCount: _secondsPerMinute,
          label: _twoDigits,
          onChanged: _onSecondChanged,
          style: style,
          width: digitsWidth,
        ),
      _column(
        controller: _periodController,
        itemCount: _periods.length,
        label: (index) => _periods[index],
        onChanged: _onPeriodChanged,
        style: style,
        width: periodWidth,
        looping: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveTextStyle(context);

    return SizedBox(
      height: widget.size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: SizedBox(
                height: widget.size.itemExtent,
                width: double.infinity,
                child: const CupertinoPickerDefaultSelectionOverlay(),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _columns(context, style),
          ),
        ],
      ),
    );
  }
}

/// Formats a [DateTime] as `1:47:22 AM`, or `1:47 AM` when seconds are
/// hidden.
class TimeLabelFormatter {
  /// Creates a [TimeLabelFormatter].
  const TimeLabelFormatter({required this.showSeconds});

  /// Whether seconds are included in the formatted output.
  final bool showSeconds;

  static final DateFormat _withSeconds = DateFormat('h:mm:ss a');
  static final DateFormat _withoutSeconds = DateFormat('h:mm a');

  /// Returns [time] rendered as 12-hour clock with AM/PM.
  String format(DateTime time) =>
      (showSeconds ? _withSeconds : _withoutSeconds).format(time);
}
